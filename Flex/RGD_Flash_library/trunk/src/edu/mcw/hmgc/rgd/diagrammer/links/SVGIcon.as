package edu.mcw.hmgc.rgd.diagrammer.links
{
	import com.degrafa.GeometryGroup;
	import com.degrafa.geometry.Path;
	import com.degrafa.geometry.RasterText;
	import com.degrafa.paint.GradientStop;
	import com.degrafa.paint.RadialGradientFill;
	import com.degrafa.paint.SolidFill;
	import com.degrafa.paint.SolidStroke;
	import com.degrafa.transform.MatrixTransform;
	
	import edu.mcw.hmgc.rgd.diagrammer.BasicDrawComponent;
	
	import flash.geom.Point;

	public class SVGIcon extends BasicDrawComponent
	{
		protected var _path:Path;
		protected var _outlinePath:Path;
		protected var _pathStr:String = new String();
		protected var _outlineStr:String = new String();
		protected var _color:Object;
		protected var _fill:Object;
		protected var _outlineColor:Object;
		protected var _outlineBgColorIn:Object;
		protected var _outlineBgColorOut:Object;
		protected var _text:RasterText;
		protected var _parent:GeometryGroup;
		
		protected var _position:Point = new Point();

		private var _properties:XMLList;

		public function set properties(value:XMLList):void 
		{
			_properties = value.copy();
			with (_properties)
			{
				_pathStr = pathStr;  
				_color = color.toString();
				_fill = fill.toString();
				_outlineStr = outlineStr;
				_outlineBgColorIn = outlineBgColorIn.toString();
				_outlineBgColorOut = outlineBgColorOut.toString();
				_outlineColor = outlineColor.toString();
			}
		}
		
		public function get properties():XMLList
		{
			with (_properties)
			{
				pathStr = _pathStr;  
				color = _color;
				fill = _fill;
				outlineStr = _outlineStr;
				outlineBgColor = _outlineBgColor;
				outlineColor = _outlineColor;
			}
			return _properties;
		}
		
		public function set pathStr(value:String):void
		{
			_pathStr = value;
			refresh();
		}
		
		public function get pathStr():String
		{
			return _pathStr;
		}
		
		public function set position(value:Point):void
		{
			_position = value.clone();
			refresh();
		}
		
		public function get position():Point
		{
			return _position;
		}
		
		protected var _angle:Number; 
		public function set angle(value:Number):void
		{
			_angle = value;
			refresh();
		}
		
		public function get angle():Number
		{
			return _angle;
		}

		public function setPosAng(pos:Point, ang:Number):void
		{
			_position = pos.clone();
			_angle = ang;
			refresh();
		}
		
		public function SVGIcon(__parent:GeometryGroup)
		{
			_parent = __parent;
		}
		
		public override function draw():void
		{
			if (_hasDrawn || _position == null) return;

			var text_r:Number = 10;
			
			_outlinePath = new Path();
			_outlinePath.data = _outlineStr;			
			var tm:MatrixTransform = new MatrixTransform();
			 
			tm.tx = _position.x;
			tm.ty = _position.y;
			tm.registrationPoint = "center";
			
			_outlinePath.transform = tm;
			
			_outlinePath.stroke = new SolidStroke(_outlineColor, 1, 1);
			var outlineFill:RadialGradientFill = new RadialGradientFill();
			outlineFill.cx = 2;
			outlineFill.cy = -2;
			outlineFill.radius = 10;
			outlineFill.gradientStops = [new GradientStop(_outlineBgColorIn), new GradientStop(_outlineBgColorOut)];
			_outlinePath.fill = outlineFill;
			_parent.geometryCollection.addItem(_outlinePath);
			
			_path = new Path();
			_path.data = _pathStr;			
			tm = new MatrixTransform();
			
			tm.registrationPoint = "center";
			var offset_x:Number = (_path.bounds.left + _path.bounds.right) / 2;
			var offset_y:Number = (_path.bounds.top + _path.bounds.bottom) / 2;
			
			tm.tx = _position.x - offset_x;
			tm.ty = _position.y - offset_y;
			
			_path.transform = tm;
			
			_path.stroke = new SolidStroke(_color, 1, 1);
			_path.fill = new SolidFill(_fill);
			_parent.geometryCollection.addItem(_path);
			
			_text = new RasterText();
			_text.x = _position.x + text_r * Math.cos(_angle);
			_text.y = _position.y + text_r * Math.sin(_angle) 
				+ (_angle < 0 ? -15 : 0);
			
			_text.htmlText = _textStr;
			_parent.geometryCollection.addItem(_text);
			
			_hasDrawn = true;
		}
		
		public override function remove():void
		{
			if (!_hasDrawn) return;
			with (_parent)
			{
				geometryCollection.removeItem(_text);
				geometryCollection.removeItem(_path);
				geometryCollection.removeItem(_outlinePath);
			}
			_hasDrawn = false;
		}
		
		protected var _textStr:String = new String();
		public function set textStr(value:String):void
		{
			_textStr = value;
			refresh();
		}
		
		public function get textStr():String
		{
			return _textStr;
		}
	}
}