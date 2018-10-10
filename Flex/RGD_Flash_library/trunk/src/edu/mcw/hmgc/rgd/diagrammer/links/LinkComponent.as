package edu.mcw.hmgc.rgd.diagrammer.links{
	import com.degrafa.GeometryGroup;
	import com.degrafa.geometry.utilities.GeometryUtils;
	import com.roguedevelopment.objecthandles.ObjectChangedEvent;
	
	import edu.mcw.hmgc.rgd.bio.Relationship;
	import edu.mcw.hmgc.rgd.diagrammer.shapes.BasicShape;
	import edu.mcw.hmgc.rgd.diagrammer.shapes.BasicShapeModel;
	import edu.mcw.hmgc.rgd.utils.GeometryUtil;
	import edu.mcw.hmgc.rgd.utils.GraphicsUtil;
	import edu.mcw.hmgc.rgd.utils.XMLUtils;
	
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import flexlib.scheduling.scheduleClasses.utils.GraphicUtils;
	
	import mx.utils.XMLUtil;

	public class LinkComponent extends GeometryGroup{
		
		public static var CONNECTION_STRAIGHT:int = 0;
		public static var CONNECTION_CURVE:int = 1;

		private var _linkFrom:BasicShape;
		private var _linkTo:BasicShape;
		
		private var _fromPoint:Point;
		private var _toPoint:Point;
		private var _controlPosition:Point;
		
		private var _margin_start:int = 6;
		private var _margin_end:int = 6;
		
		public var model:BasicShapeModel;
		private var _line:ThreePointLink = new ThreePointLink(this as GeometryGroup);
		private var _arrow:Arrow = new Arrow(this as GeometryGroup);
		private var _icon:LinkIcon = new LinkIcon(this as GeometryGroup);
		private var _controlPoint:LinkIcon = new LinkIcon(this as GeometryGroup);
		
		protected var _state:String;
		public function set state(value:String):void
		{
			_state = value;
		}
		public function get state():String
		{
			return _state;
		}
		
		private var _relationship:Relationship = new Relationship();
		public function get relationship():String
		{
			return _relationship.type;
		}
		
		public function set relationship(value:String):void
		{
			_relationship.type = value;
			var link_settings:XMLList = _relationship.linkSetting;
			_line.setting = link_settings.link;
			_arrow.setting = link_settings.arrow;
			_margin_start = _arrow.margin_start;
			_margin_end = _arrow.margin_end;
			
			_icon.setting = link_settings.icon;
			_controlPoint.setting = link_settings.control;
//			_controlPoint.textStr = value;
			update();
		}
		
		public function LinkComponent(fromPoint:BasicShape, toPoint:BasicShape){
			
			_fromPoint = new Point();
			_toPoint = new Point();
			
			_linkFrom = fromPoint;
			_linkTo = toPoint;
			
			var centerFrom:Point = new Point(_linkFrom.model.x + _linkFrom.model.width/2, 
				_linkFrom.model.y + _linkFrom.model.height/2);
			var centerTo:Point = new Point(_linkTo.model.x + _linkTo.model.width/2, 
				_linkTo.model.y + _linkTo.model.height/2);
			
			_controlPosition = Point.interpolate(centerFrom, centerTo, 0.5);
			
			arrowType = "arrow_plain";
			_icon.type = "plus";

			_relationship.type = "unknown";
			_linkFrom.addEventListener(ObjectChangedEvent.OBJECT_MOVED, fromPointMoveHandler);
			_linkTo.addEventListener(ObjectChangedEvent.OBJECT_MOVED, toPointMoveHandler);
		}

		public function getPoints():void{
			getFromPoint();
			getToPoint();
		}
		
		private function getFromPoint():void 
		{
			if (_linkFrom == null) return;
			_fromPoint = GraphicsUtil.getEdgePoint(_controlPosition, _linkFrom, _margin_start);
		}
		
		private function getToPoint():void
		{
			if (_linkTo == null) return;
			_toPoint = GraphicsUtil.getEdgePoint(_controlPosition, _linkTo, _margin_end); 
		}
		
		public function set lineStyle(value:String):void{
			_line.lineStyle = value;
		}
		public function get lineStyle():String{
			return _line.lineStyle;
		}
		
		public function get controlPoint():Point{
			var returnPoint:Point = new Point();
			returnPoint.x = this.x + _controlPoint.position.x + this.parent.x;
			returnPoint.y = this.y + _controlPoint.position.y + this.parent.y;
			return returnPoint;
		}
		
		private function fromPointMoveHandler(event:Event):void{
			getFromPoint();
			refresh();
		}

		private function toPointMoveHandler(event:Event):void{
			getToPoint();
			refresh();
		}
		
		public function removeLink():void {
			_icon.remove();
			_controlPoint.remove();
			_arrow.remove();
			_line.remove();
		}
		
		private function _drawLine():void {
			_line.setPoints(_fromPoint, _controlPosition, _toPoint);

			var d1:Number = Point.distance(_controlPosition, _toPoint);
			var d2:Number = Point.distance(_controlPosition, _fromPoint);
			var dt:Number = d1 + d2;
			var r:Number = d1 / dt;
			var angle:Number = _line.angleAt(r);
			
			angle = angle + (angle < 0 ? Math.PI : 0);
			angle = (angle == Math.PI ? 0 : angle);
			angle = angle - Math.PI / 2;
			
			_controlPoint.setPosAng(_controlPosition, angle);
		}

		public function refresh():void{
			removeLink();
			_drawLine();	
			_drawArrow();
			_drawIcon();
			this.draw(null,null);
		}
		
		public function update():void
		{
			getPoints();
			_line.boldWeight = boldLink;
			_arrow.bold = _line.boldWeight;
			refresh();
		}
		
		public function get linkFrom():BasicShape{
			return _linkFrom;
		}
		
		public function set linkFrom(value:BasicShape):void
		{
			if (_linkFrom != null) 
				_linkFrom.removeEventListener(ObjectChangedEvent.OBJECT_MOVED, fromPointMoveHandler);
			_linkFrom = value;
			getFromPoint();
			refresh();
			_linkFrom.addEventListener(ObjectChangedEvent.OBJECT_MOVED, fromPointMoveHandler);
		}
		
		public function get linkTo():BasicShape{
			return _linkTo;
		}
		
		public function set linkTo(value:BasicShape):void
		{
			if (_linkTo != null)
				_linkTo.removeEventListener(ObjectChangedEvent.OBJECT_MOVED, toPointMoveHandler);
			_linkTo = value;
			getToPoint();
			refresh();
			_linkTo.addEventListener(ObjectChangedEvent.OBJECT_MOVED, toPointMoveHandler);
		}
		
		public function remove():void{
			_linkFrom.removeEventListener(ObjectChangedEvent.OBJECT_MOVED, fromPointMoveHandler);
			_linkTo.removeEventListener(ObjectChangedEvent.OBJECT_MOVED, toPointMoveHandler);
			removeLink();
			_linkFrom = null;
			_linkTo = null;
			target = null;
			model = null;
		}
		
		public function set arrowColor(color:Object):void {
			_arrow.color = color;
		}
		
		public function move(x:Number, y:Number):void {
			_controlPosition.x = x;
			_controlPosition.y = y;
			update();
		}
		
		public function get arrowType():String {
			return _arrow.type;
		}
		
		public function set arrowType(value:String):void {
			_arrow.type = value;
			_margin_start = _arrow.margin_start;
			_margin_end = _arrow.margin_end;
			getToPoint();
			refresh();
		}
		
		public function set iconType(value:String):void {
			_icon.type = value;			
		}
		
		private function _drawArrow():void {
			_arrow.setPosAng(_toPoint, _line.angleAt(1));
		}
		
		private function _drawIcon():void {
			var dx:Number = _toPoint.x - _controlPosition.x;
			var dy:Number = _toPoint.y - _controlPosition.y;
			
			var iconPoint:Point;
			var angle:Number;

			var d1:Number = Point.distance(_controlPosition, _toPoint);
			var d2:Number = Point.distance(_controlPosition, _fromPoint);
			var dt:Number = d1 + d2;
			var r:Number = (30 > d1 ? d1 / dt : 1 - (30 / d1)*(d1/dt));
			iconPoint = _line.pointAt(r);
			angle = _line.angleAt(r);
			
			angle = angle + (angle < 0 ? Math.PI : 0);
			angle = (angle == Math.PI ? 0 : angle);
			angle = angle - Math.PI / 2;
			
			_icon.setPosAng(iconPoint, angle);
		}

		public function set connectionType(value:String):void {
			_line.type = value;
			refresh();
		}
		
		public function get connectionType():String {
			return _line.type;
		}

		public function set dash(value:int):void {
			_line.dash = value;
			refresh();
		}
		
		public function get dash():int {
			return _line.dash;
		}
		
		public function set gap(value:int):void {
			_line.gap = value; 
			refresh();
		}
		
		public function get gap():int {
			return _line.gap;
		}
		
		public function set lineColor(color:Object):void {
			_line.color = color;
			refresh();
		}
		
		public function get properties():XMLList
		{
			var xml_str:String = new String();
			xml_str += XMLUtils.getXML("model", model.properties.toXMLString());
			xml_str += XMLUtils.getXML("from_node", _linkFrom.model.index);  
			xml_str += XMLUtils.getXML("to_node", _linkTo.model.index);
			xml_str += XMLUtils.getXML("from_x", int(_fromPoint.x)); 
			xml_str += XMLUtils.getXML("from_y", int(_fromPoint.y)); 
			xml_str += XMLUtils.getXML("to_x", int(_toPoint.x)); 
			xml_str += XMLUtils.getXML("to_y", int(_toPoint.y)); 
			xml_str += XMLUtils.getXML("arrow", _arrow.type);
			xml_str += XMLUtils.getXML("line", _line.type);
			xml_str += XMLUtils.getXML("icon", _icon.type);
			xml_str += XMLUtils.getXML("control", _controlPoint.type);
			xml_str += XMLUtils.getXML("relationship", _relationship.type);
			xml_str += XMLUtils.getXML("bold_link", _line.boldWeight);
			return new XMLList(xml_str);
		}
		
		[Bindable]
		public function set boldLink(value:Boolean):void
		{
			_line.boldWeight = value;
			_arrow.bold = _line.boldWeight;
			refresh();
		}
			
		public function get boldLink():Boolean
		{
			return _line.boldWeight;
		}
		
		public function set properties(value:XMLList):void
		{
			if (model == null) model = new BasicShapeModel();
			model.properties = value.model;

			_controlPosition.x = model.x;
			_controlPosition.y = model.y;
			width = model.width;
			height = model.height;
			if ("relationship" in value && (value.relationship.toString() != "unknown")) 
			{
				relationship = value.relationship;				
			} else
			{
				_arrow.type = value.arrow;
				_line.type = value.line;
				_icon.type = value.icon;
				_controlPoint.type = value.control;
			}
				
			if ("from_x" in value)
			{
				_fromPoint = new Point(value.from_x, value.from_y); 	
				_toPoint = new Point(value.to_x, value.to_y); 	
			}
			
			if ("bold_link" in value)
			{
				_line.boldWeight = Boolean(value.bold_link == "true");
				_arrow.bold = _line.boldWeight;
			}
			refresh();
		}
		
		public function adjustToModel():void{
			_controlPosition.x = model.x;
			_controlPosition.y = model.y;
			update();
		}
		
		public function cleanUpMemory():void {
			_arrow.cleanUpMemory();
			_line.cleanUpMemory();
			_icon.cleanUpMemory();
			_controlPoint.cleanUpMemory();
			_arrow = null;
			_line = null;
			_icon = null;
			_controlPoint = null;
		}
	}
}
