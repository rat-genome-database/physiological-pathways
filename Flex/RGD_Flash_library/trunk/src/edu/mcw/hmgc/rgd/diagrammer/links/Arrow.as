package edu.mcw.hmgc.rgd.diagrammer.links
{
	import com.degrafa.GeometryGroup;
	import com.degrafa.geometry.Path;
	import com.degrafa.paint.SolidFill;
	import com.degrafa.paint.SolidStroke;
	import com.degrafa.transform.MatrixTransform;
	
	import edu.mcw.hmgc.rgd.diagrammer.BasicDrawComponent;
	import edu.mcw.hmgc.rgd.utils.Configurations;
	import edu.mcw.hmgc.rgd.utils.XMLUtils;
	
	import flash.geom.Point;

	public class Arrow extends BasicDrawComponent{
		
		
		protected var _path:Path;
		private var _pathStr:String = new String();
		private var _center:String = new String();
		private var _color:Object;
		protected var _parent:GeometryGroup;
		protected var _position:Point;
		protected var _angle:Number;
		
		public static var types:XMLList;
		protected var _properties:XMLList;
		private var _weight:int;
		private var _normalWeight:int;
		private var _boldWeight:int = 4;
		
		private var _bold:Boolean = false;
		
		public function Arrow(__parent:GeometryGroup){
			_parent = __parent;
			_type = "arrow_plain";
		}
		
		public function get bold():Boolean
		{
			return _bold;
		}

		public function set bold(value:Boolean):void
		{
			_bold = value;
			if (_bold)
			{
				_normalWeight = _weight;
				_weight = _boldWeight;
			} else
			{
				_weight = _normalWeight;
			}
		}

		public function get weight():int
		{
			return _weight;
		}

		public function set weight(value:int):void
		{
			_weight = value;
		}

		public override function remove():void
		{
			if (!_hasDrawn) return;
			_parent.geometryCollection.removeItem(_path);
			_hasDrawn = false;
		}
		
		public function set color(color:Object):void {
			_color = color;
			refresh();
		}
		
		private var _type:String;
		public function get type():String {
			return _type;
		}
		
		public function set type(value:String):void {
			if (value == null) return;
			_type = value;
			properties = types.arrow.(@name==_type);
			refresh();
		}

		protected var _margin_start:Number;
		public function get margin_start():Number
		{
			return _margin_start;
		}
		
		protected var _margin_end:Number;
		
		public function get margin_end():Number
		{
			return _margin_end;
		}
		
		public function set properties(value:XMLList):void
		{
			_properties = value;
			with (_properties) 
			{
				_pathStr = pathStr;
				_color = color.toString();
				_center = center;
				_margin_start = margin_start;
				_margin_end = margin_end;
				_weight = weight;
				_normalWeight = weight;
			}
		}	
		
		public function get properties():XMLList
		{
//			with (_properties)
//			{
//				pathStr = _pathStr;
//				color = _color;
//				center = _center;
//				margin_start = _margin_start;
//				margin_end = margin_end;
//				weight = _weight;
//			}
//			return _properties;
			
			var xml_str:String = new String();
			xml_str += XMLUtils.getXML("pathStr", _pathStr);
			xml_str += XMLUtils.getXML("color", _color);
			xml_str += XMLUtils.getXML("center", _center);
			xml_str += XMLUtils.getXML("margin_start", _margin_start);
			xml_str += XMLUtils.getXML("margin_end", _margin_end);
			xml_str += XMLUtils.getXML("weight", _weight);
			
			return new XMLList(xml_str);
		}
		
		public function setPosAng(pos:Point, ang:Number):void
		{
			_position = pos.clone();
			_angle = ang;
			refresh();
		}
		
		public override function draw():void {
			if (_hasDrawn || _position == null) return;
			_path = new Path();
			_path.data = _pathStr;			
			_path.preDraw();
			
			// Adjust to the center of the Path, otherwise, degrafa will use (0,0) as the center point
			var offset_x:Number = 0;
			var offset_y:Number = 0;
			switch (_center)
			{
				case "center":
					offset_x = (_path.bounds.left + _path.bounds.right) / 2;
					offset_y = (_path.bounds.top + _path.bounds.bottom) / 2;
					break;
				case "centerTop":
					offset_x = (_path.bounds.left + _path.bounds.right) / 2;
					offset_y = _path.bounds.top;
					break;
				case "centerBottom":
					offset_x = (_path.bounds.left + _path.bounds.right) / 2;
					offset_y = _path.bounds.bottom;
					break;
				case "centerLeft":
					offset_x = _path.bounds.left;
					offset_y = (_path.bounds.top + _path.bounds.bottom) / 2;
					break;
				case "centerRight":
					offset_x = _path.bounds.right;
					offset_y = (_path.bounds.top + _path.bounds.bottom) / 2;
					break;
			}
			
			var tm:MatrixTransform = new MatrixTransform();
			tm.a = Math.cos(_angle);
			tm.b = Math.sin(_angle);
			tm.c = Math.sin(-_angle);
			tm.d = Math.cos(_angle);
			
			tm.tx = _position.x - offset_x;
			tm.ty = _position.y - offset_y;
			tm.registrationPoint = _center;
			
			_path.transform = tm;
			
			_path.stroke = new SolidStroke(_color, 1, _weight);
			_path.fill = new SolidFill(_color);
			_parent.geometryCollection.addItem(_path);
			
			_hasDrawn = true;
		}

		public function set setting(settings:XMLList):void
		{
			type = settings.@type;			
			if ("@color" in settings) _color = settings.@color.toString();
			
			refresh();
		}

		public function cleanUpMemory():void
		{
			_parent = null;
		}
	}
}

