package edu.mcw.hmgc.rgd.diagrammer.links
{
	import com.degrafa.GeometryGroup;
	import com.degrafa.geometry.AdvancedQuadraticBezier;
	import com.degrafa.geometry.Line;
	import com.degrafa.paint.SolidFill;
	import com.degrafa.paint.SolidStroke;
	
	import edu.mcw.hmgc.rgd.diagrammer.BasicDrawComponent;
	import edu.mcw.hmgc.rgd.graphics.DashedLineDecorator;
	
	import flash.geom.Point;
	
	public class ThreePointLink extends BasicDrawComponent{
		
		public static var STRAIGHT:String = "straight";
		public static var CURVE:String = "curve";
		
		protected var _point1:Point;
		protected var _point2:Point;
		protected var _point3:Point;
		protected var _straightLine:Line;
		protected var _lineStroke:SolidStroke;
		
		public var _shape:String = CURVE;
		public static var types:XMLList;
		
		protected var _curveSpline:AdvancedQuadraticBezier;
		
		protected var _fromCenterLine:Line;
		protected var _centerToLine:Line;
		protected var _dashDecurator:DashedLineDecorator = new DashedLineDecorator();
		
		protected var _dash:int = 1;
		protected var _gap:int = 0;
		protected var _color:Object="0";
		protected var _weight:int = 2;;
		
		protected var _parent:GeometryGroup;
		
		protected var _type:String = STRAIGHT;
		
		protected var _boldWeight:Boolean = false;

		private var _properties:XMLList;
		
		public function set boldWeight(value:Boolean):void
		{
			_boldWeight = value;
			weight = value ? 4 : 2; 
		}
		
		public function get boldWeight():Boolean
		{
			return _boldWeight;
		}

		public function set properties(value:XMLList):void 
		{
			_properties = value;
			with (_properties)
			{
				_shape = shape;
				_dash = dash;  
				_gap = gap;
				_color = color.toString();
				_weight = weight;
			}
		}
		
		public function get properties():XMLList
		{
			with (_properties)
			{
				shape = _shape;
				dash = _dash;
				gap = _gap;
				color = _color;
				weight = weight;
			}
			return _properties;
		}
		
		public function set color(color:Object):void
		{
			_color = color;
			refresh();
		}
		
		public function set type(value:String):void {
			_type = value;
			properties = types.link.(@name == value);
			refresh();
		}
		
		public function get type():String {
			return _type;
		}
		
		public function set shape(value:String):void {
			remove();
			_shape = value;
			draw();
		}
		
		public function get shape():String {
			return _shape;
		}
		
		public function set dash(value:int):void {
			_dash = value;
			refresh();
		}
		
		public function get dash():int {
			return _dash;
		}
		
		public function set gap(value:int):void {
			_gap = value;
			refresh();
		}
		
		public function get gap():int {
			return _gap;
		}
		
		public function ThreePointLink( __parent:GeometryGroup)
		{
			_parent = __parent;
			_lineStroke = new SolidStroke();
			_lineStroke.color = _color;
			_lineStroke.weight = _weight;
		}
		
		public function setPoints(p1:Point, p2:Point, p3:Point):void
		{
			_point1 = p1;
			_point2 = p2;
			_point3 = p3;
			refresh();
		}
		
		private var _lineStyle:String = "curve";
		public function set lineStyle(value:String):void{
			
			_lineStroke.alpha = 1;
			
			if(_lineStyle != value){
				_lineStyle = value;
			}
			
			refresh();
		}
		public function get lineStyle():String{
			return _lineStyle;
		}
		
		public override function remove():void {
			if (!_hasDrawn) return;
			switch (_shape) {
				case CURVE:
					_parent.geometryCollection.removeItem(_curveSpline);
					break;
				case STRAIGHT:
				default:
					_parent.geometryCollection.removeItem(_fromCenterLine);
					_parent.geometryCollection.removeItem(_centerToLine);
					break;
			}
		}
		
		public override function draw():void {

			_dashDecurator.setDash(_dash, _gap);
			_lineStroke.color = _color;
			_lineStroke.weight = _weight;
			switch (_shape) {
				case CURVE:
					_curveSpline = new AdvancedQuadraticBezier()
					_curveSpline.interpolate([_point1, _point2, _point3]);
					_curveSpline.stroke = _lineStroke;
					_curveSpline.decorators = getDashedDecurator();
					_curveSpline.preDraw();
					_parent.geometryCollection.addItem(_curveSpline);
					break;
				case STRAIGHT:
				default:
					_fromCenterLine = new Line(_point2.x, _point2.y, _point1.x, _point1.y);
					
					_fromCenterLine.decorators = getDashedDecurator();
					
					_fromCenterLine.stroke = _lineStroke;
					
					_centerToLine = new Line(_point3.x, _point3.y, _point2.x, _point2.y);
					_centerToLine.decorators = getDashedDecurator();
					_centerToLine.stroke = _lineStroke;
					
					_parent.geometryCollection.addItem(_fromCenterLine);
					_parent.geometryCollection.addItem(_centerToLine);
					
					break;
			}
			_hasDrawn = true;
		}
		
		public function set lineColor(color:Object):void {
			_color = color;
			_lineStroke.color = _color;
			refresh();
		}
		
		public function set weight(weight:int):void 
		{
			_weight = weight;
			_lineStroke.weight = _weight;
			refresh();
		}
	
		// Return 0: _point1 to _point2
		//        1: _point2 to _point3 
		protected function getSegIndex(value:Number):int
		{
			var dis1:Number = Point.distance(_point1, _point2);
			var dis2:Number = Point.distance(_point2, _point3);
			return (value < (dis1 / (dis1 + dis2)) ? 0 : 1);
		}
		
		public function angleAt(value:Number):Number
		{
			var dx:Number;
			var dy:Number;

			switch (_shape) {
				case CURVE:
					return (_curveSpline.angleAt(value));
					break;
				case STRAIGHT:
				default:
					switch (getSegIndex(value))
					{
						case 0:
							dx = _point2.x - _point1.x;
							dy = _point2.y - _point1.y;
							break;
						case 1:
							dx = _point3.x - _point2.x;
							dy = _point3.y - _point2.y;
							break;
					}
					return (Math.atan2(dy, dx)); // For staight line
			}
		}

		protected function getDashedDecurator():Array
		{
			if (_dash > 0 && _gap > 0) return [_dashDecurator];
			return [];
		}
		
		public function pointAt(value:Number):Point
		{
			switch (_shape) {
				case CURVE:
					_curveSpline.preDraw();
					return _curveSpline.pointAt(value);
					break;
				case STRAIGHT:
				default:
					var dis1:Number = Point.distance(_point1, _point2);
					var dis2:Number = Point.distance(_point2, _point3);
					switch (getSegIndex(value))
					{
						case 0:
							return Point.interpolate(_point2, _point1, 
								(value / (dis1 / (dis1 + dis2))));  
							break;
						case 1:
							return Point.interpolate(_point3, _point2, 
								((value - dis1 / (dis1 + dis2)) / (dis2 / (dis1 + dis2))));  
							break;
					}
			}
			return null;
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