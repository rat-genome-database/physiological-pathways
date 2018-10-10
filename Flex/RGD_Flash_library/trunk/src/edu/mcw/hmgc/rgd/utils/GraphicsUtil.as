package edu.mcw.hmgc.rgd.utils
{
	import edu.mcw.hmgc.rgd.diagrammer.shapes.BasicShape;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.IBitmapDrawable;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.controls.Image;
	
	public class GraphicsUtil
	{
		static private const SHAPE_MARGIN:Number = -5;
		static private const INTRUSION_RATIO:Number = 0.4;
		
		/**
		 * Constructor
		 */
		public function GraphicsUtil()
		{
		}
		
		/**
		 * Get a hit point from the start point to the center of a shape. 
		 * A hit is found if current pixel is not background pixel.
		 */
		static public function getHitPoint(shape:BasicShape, start_point:Point, margin:Number=SHAPE_MARGIN):Point 
		{
			var bmp:BitmapData = getSnapshot(shape); 
			
			var center_p:Point = new Point(bmp.width / 2, bmp.height / 2);
			var dis:Number = Point.distance(center_p, start_point);
			
			var dx:Number = (center_p.x - start_point.x) / dis;
			var dy:Number = (center_p.y - start_point.y) / dis;
			
			var current:Point = start_point.clone();
			for (var i:Number = 0; i < dis * INTRUSION_RATIO; i++)
			{
				var argb:uint = bmp.getPixel32(current.x, current.y);
				if (argb > 0x00000000) 
				{
					current.offset(-margin * dx, -margin * dy);
					bmp.dispose();
					return current;	
				}
				current.offset(dx, dy);
			}
			bmp.dispose();
			current.offset(-margin * dx, -margin * dy);

			return current;
		}
		
		/**
		 * Get the edge point of a shape from a given point to the center of the shape with a margin.
		 */
		static public function getEdgePoint(p:Point, shape:BasicShape, m:int=0):Point 
		{
			var r:Rectangle = new Rectangle(shape.model.x, shape.model.y, shape.model.width, 
				shape.model.height);
			var r_center:Point = new Point(r.x + r.width / 2, r.y + r.height /2);
			var angle:Number = shape.model.rotation * Math.PI / 180;
			GeometryUtil.rotatePoint(r_center, shape.model.x, shape.model.y, angle);
			
			var r1:Rectangle = r.clone();
			r1.width = Math.abs(r1.width);
			r1.height = Math.abs(r1.height);
			var p1:Point = p.clone();
			r1.offset(-r_center.x, -r_center.y);
			p1.offset(-r_center.x, -r_center.y);
			var angle_sign:Number = -1;
			if (shape.model.width < 0) 
			{
				p1.x = -p1.x;	
				angle_sign = - angle_sign;
			};
			if (shape.model.height < 0) 
			{
				p1.y = -p1.y;
				angle_sign = - angle_sign;
			};
			
			var angPoint:Number = Math.atan2(p1.y, p1.x) + angle_sign * angle;

			var tmp_point:Point = GeometryUtil.getCloserPoint(GeometryUtil.normalizeAngle(angPoint), r1);
			tmp_point.offset(- r1.x, - r1.y);
			
			var p_return:Point = getHitPoint(shape, tmp_point, m);
			p_return.offset(-Math.abs(shape.model.width/2), -Math.abs(shape.model.height/2));
			GeometryUtil.rotatePoint(p_return, 0, 0, - angle_sign * angle);
			if (shape.model.width < 0) p_return.x = - p_return.x;
			if (shape.model.height < 0) p_return.y = - p_return.y;
			p_return.offset(r_center.x, r_center.y);
			
			return p_return;
		}
		
		static public function getSnapshot(shape:Object, transparent:Boolean = true,
		fill_color:Number=0x00, 
		with_scale:Boolean=false, scale_x0:Number=1, scale_y0:Number=1):BitmapData
		{
			var bmp:BitmapData = new BitmapData(Math.abs(shape.width), Math.abs(shape.height), true, fill_color);
			// Filters won't be considered as part of the object
			var filter_buf:Array = shape.filters;
			
			var matrix : Matrix = new Matrix();
			var scale_x:Number = 1;
			var scale_y:Number = 1;
			if (shape.width < 0) 
			{
				scale_x = -1;
			}
			if (shape.height < 0)
			{
				scale_y = -1;
			}
			
			if (with_scale){
				scale_x *= scale_x0;
				scale_y *= scale_y0;
			} 
		
			matrix.scale(scale_x, scale_y);
			
			shape.filters = [];
			bmp.draw(IBitmapDrawable(shape), matrix);
			shape.filters = filter_buf;
			return bmp;
		}
		
		public static function hitTest(obj:Object, x:int, y:int):Boolean {
			if (obj.hasOwnProperty("image")) obj = obj.image;
//			if(!obj.hitTestPoint(x, y, true)) {
//				return false;
//			}
//			else 
			{
				var bmpData:BitmapData = getSnapshot(obj);
				
				var returnVal:Boolean = bmpData.hitTest(new Point(0,0), 0, obj.globalToLocal(new Point(x, y)));
				
				bmpData.dispose();
				trace("hitTest:" + returnVal.toString());
				return returnVal;
			}
		}
		
		
		public static function createHitArea(obj1:Object, win_size:int=2):void {
			var obj:Image = obj1.image;
			obj.validateNow();
//			var bmpData:BitmapData = getSnapshot(obj, true, 0x00, true, obj1.model.width/obj.contentWidth,
//				obj1.model.height / obj.contentHeight);
			
			var bmpData:BitmapData = getSnapshot(obj);

			var hitarea:Sprite = new Sprite();
			hitarea.graphics.beginFill(0xFFFFFF, 1.0);
			for(var x:uint = 0;x < bmpData.width; x += win_size) {
				for(var y:uint = 0;y < bmpData.height; y += win_size) {                    
					if(bmpData.hitTest(new Point(0,0), 0, (new Point(x, y)))) {
						hitarea.graphics.drawRect(x, y, win_size, win_size);                        
					}                    
				}
			}            
			hitarea.graphics.endFill(); 
			hitarea.visible = false;
			hitarea.mouseEnabled = false;
			obj1.rawChildren.addChild(hitarea);
			obj1.hitArea = hitarea;
			obj1.mouseChildren = false;
			obj.validateDisplayList();
		}
	}
}