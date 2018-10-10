package edu.mcw.hmgc.rgd.utils
{
	import edu.mcw.hmgc.rgd.diagrammer.shapes.BasicShapeModel;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class GeometryUtil
	{
		public function GeometryUtil()
		{
		}

		static public function getCloserPoint(angPoint:Number, r:Rectangle):Point {
			
			var r_center:Point = new Point(r.x + r.width / 2, r.y + r.height /2);
			var angRect:Number = Math.atan2(r.height, r.width);
			
			if (Math.abs(angPoint) <= angRect) {
				// Right side
				return new Point(r.right, r_center.y +
					Math.tan(angPoint) * r.width / 2);
			} else if (Math.abs(angPoint) >= (Math.PI - angRect)) {
				// Left side
				return new Point(r.left, r_center.y - 
					Math.tan(angPoint) * r.width / 2);
			} else if (angPoint >= angRect && angPoint <= (Math.PI - angRect)) {
				// Bottom side
				return new Point(r_center.x + r.height / 2 * Math.tan(Math.PI / 2 - angPoint),
					r.bottom);
			} else {
				// Top side
				return new Point(r_center.x + r.height / 2 * Math.tan(Math.PI / 2 + angPoint),
					r.top);
			}
		}
		
		static public function rotatePoint(p:Point, o_x:Number, o_y:Number, a:Number, convert_a:Boolean=false):void
		{
			if (p == null) return;
			if (convert_a) a = a / 180 * Math.PI;
			p.offset(-o_x, -o_y);
			var p_tmp:Point = new Point(p.x, p.y);
			p.x = Math.cos(a) * p_tmp.x - Math.sin(a) * p_tmp.y;
			p.y = Math.sin(a) * p_tmp.x + Math.cos(a) * p_tmp.y;
			p.offset(o_x, o_y);
		}
		
		static public function normalizeAngle(angle:Number):Number
		{
			if (angle > Math.PI)
			{
				do {
					angle -= Math.PI;
					angle -= Math.PI;
				} while (angle > Math.PI);
				return angle;
			} else if (angle < - Math.PI)
			{
				do {
					angle += Math.PI;
					angle += Math.PI;
				} while (angle < - Math.PI);
				return angle;
			} else
				return angle;
		}
		
		static public function realRect(shape_model:BasicShapeModel):Rectangle
		{
			var p1:Point = new Point(shape_model.x, shape_model.y);
			var p2:Point = new Point(p1.x + shape_model.width, p1.y);
			var p3:Point = new Point(p1.x + shape_model.width, p1.y + shape_model.height);
			var p4:Point = new Point(p1.x, p1.y + shape_model.height);
			rotatePoint(p2, p1.x, p1.y, shape_model.rotation, true);
			rotatePoint(p3, p1.x, p1.y, shape_model.rotation, true);
			rotatePoint(p4, p1.x, p1.y, shape_model.rotation, true);
			var new_left:Number = Math.min(p1.x, p2.x, p3.x, p4.x);
			var new_top:Number = Math.min(p1.y, p2.y, p3.y, p4.y);
			var new_right:Number = Math.max(p1.x, p2.x, p3.x, p4.x);
			var new_bot:Number = Math.max(p1.y, p2.y, p3.y, p4.y);
			
			return new Rectangle(new_left, new_top, new_right - new_left, new_bot - new_top);
		}
		
		static public function fitByRatio(srcSize:Point, dstSize:Point):Point 
		{
			var ratio:Number = srcSize.x / srcSize.y;
			var fitP:Point = new Point();
			if (ratio >=1) {
				fitP.x = dstSize.x;
				fitP.y = dstSize.x / ratio;
			} else {
				fitP.y = dstSize.y;
				fitP.x = dstSize.y * ratio;
			}
			return fitP;
		}
	}
}