package edu.mcw.hmgc.rgd.diagrammer.shapes
{
	import adobe.utils.XMLUI;
	
	import com.degrafa.GeometryGroup;
	import com.degrafa.geometry.Polygon;
	import com.degrafa.geometry.RoundedRectangle;
	import com.degrafa.geometry.utilities.GeometryUtils;
	import com.degrafa.paint.GradientFillBase;
	import com.degrafa.paint.GradientStop;
	import com.degrafa.paint.LinearGradientFill;
	import com.degrafa.paint.SolidFill;
	import com.degrafa.paint.SolidStroke;
	
	import edu.mcw.hmgc.rgd.diagrammer.Diagram;
	import edu.mcw.hmgc.rgd.graphics.RoundedRectCallout;
	import edu.mcw.hmgc.rgd.graphics.Surface;
	import edu.mcw.hmgc.rgd.utils.GeometryUtil;
	import edu.mcw.hmgc.rgd.utils.StrUtil;
	import edu.mcw.hmgc.rgd.utils.XMLUtils;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	
	import mx.binding.utils.BindingUtils;
	
	public class CalloutShape extends BasicShape
	{
		static public var TEXT_MARGIN:Number = 3;
		static public var TEXT_MARGIN_EXTRA_RIGHT:Number = 0;
		static public var CORNER_RADIUS:Number = 10;

		private var _textMargin:Number = TEXT_MARGIN;
		
		
		[Bindable]
		public var _bodyModel:BasicShapeModel;
		
		[Bindable]
		public var _tailModel:BasicShapeModel;
		
		protected var _rounded_rect:RoundedRectCallout = new RoundedRectCallout();

		private var _fillColor:Number;
		private var _strokeColor:Object = 0x006699;
		private var _strokeWidth:Number = 2;
		private var _rectAlpha:Number = .5;

		
		protected var _stroke:SolidStroke = new SolidStroke(_strokeColor, _rectAlpha, _strokeWidth);
//		protected var _:SolidFill = new SolidFill(_fillColor);
		protected var _fill:LinearGradientFill = new LinearGradientFill();
		protected var _surface:Surface = new Surface();
		protected var _type:String;

		[Bindable]
		public function get strokeWidth():Number
		{
			return _strokeWidth;
		}
		
		public function set strokeWidth(value:Number):void
		{
			_strokeWidth = value;
			_stroke.weight = value;
		}
		
		[Bindable]
		public function get strokeColor():Object
		{
			return _strokeColor;
		}
		
		public function set strokeColor(value:Object):void
		{
			_strokeColor = value;
			_stroke.color = value;
		}

		[Bindable]
		public function get fillColor():Number
		{
			return _fillColor;
		}
		public function set fillColor(value:Number):void
		{
			_fillColor = value;
			_fill.gradientStops = [
				new GradientStop(0xFFFFFF, .9, 0),
				new GradientStop(_fillColor, _rectAlpha, .03), 
				new GradientStop(_fillColor, _rectAlpha, .97), 
				new GradientStop(_fillColor, .8, 1)
			];
		}
		
		[Bindable]
		public function get textMargin():Number
		{
			return _textMargin;
		}

		public function set textMargin(value:Number):void
		{
			_textMargin = value;
		}

		protected function get type():String
		{
			return _type;
		}
		
		static public const TYPE_RECT:String = "Rect";
		
		public function initModel():void
		{
			_bodyModel = new BasicShapeModel();
			_bodyModel.x = x;
			_bodyModel.y = y;
			_bodyModel.width = width;
			_bodyModel.height = height * 0.7;
			
			_tailModel = new BasicShapeModel();
			_tailModel.x = x + width / 4;
			_tailModel.y = y + height - 1;
			_tailModel.width = 1;
			_tailModel.height = 1;
			
			getWholeModel();
		}
		
		override public function set model(value:BasicShapeModel):void
		{
			_model = value;
			x = value.x;
			y = value.y;
			width = value.width;
			height = value.height;
			initModel();
		}
		
		public function moveTo(new_x:Number, new_y:Number):void
		{
			_tailModel.x += (new_x - _bodyModel.x);
			_tailModel.y += (new_y - _bodyModel.y);
			_bodyModel.x = new_x;
			_bodyModel.y = new_y;
		}
		
		public function CalloutShape()
		{
			super();
			
			fillColor = 16777164;
//			fillColor = 0;

			//			fillColor = 15658734;
			_rounded_rect.fill = _fill;
			_rounded_rect.stroke = _stroke;
			_rounded_rect.cornerRadius = CORNER_RADIUS;
			var gGroup:GeometryGroup = new GeometryGroup();
			gGroup.geometry = [_rounded_rect];
			_surface.addChild(gGroup);
			addChild(_surface);
			BindingUtils.bindSetter(tailZoneChangeHandler, _rounded_rect, "tailZone");
		}
		
		protected function tailZoneChangeHandler(value:Number):void
		{
			trace("zone changed to: " + value.toString());
			switch (value)
			{
				case 0:
				case 2:
					_fill.angle = 0;
					break;
				case 1:
				case 5:
					_fill.angle = -90;
					break;
				case 4:
				case 6:
					_fill.angle = 180;
					break;
				case 3:
				case 7:
					_fill.angle = 90;
					break;
			}
		}
		
		public function set bodyModel(value:BasicShapeModel):void 
		{
			_bodyModel = value;
			if (value == null) return;
			getWholeModel();
		}
		
		public function set tailModel(value:BasicShapeModel):void
		{
			_tailModel = value;
			if (value == null) return;
			getWholeModel();
		}
		
		public function get bodyModel():BasicShapeModel
		{
			return _bodyModel;
		}
		
		public function get tailModel():BasicShapeModel
		{
			return _tailModel;
		}
		
		public function getWholeModel():void
		{
			trace("tail: " + _tailModel.x + " " + _tailModel.y);
			if (_bodyModel != null && _tailModel != null) 
				_model = _bodyModel.union(_tailModel);
			width = _model.width;
			height = _model.height;
			move(_model.x, _model.y);
			redraw();
			adjustTextPosition();
		}
		
		public function moveBody(new_x:int, new_y:int):void
		{
			_bodyModel.x = new_x;
			_bodyModel.y = new_y;
			getWholeModel();
		}
		
		public function moveTail(new_x:int, new_y:int):void
		{
			_tailModel.x = new_x;
			_tailModel.y = new_y;
			getWholeModel();
		}
		
		public function redraw():void
		{
			
		}
		
		/**
		 * Get the the zone number of the tail position
		 * Return: an integer with 3 bits to indicate the zone value
		 * Bit 0: 0 means it's left/right side, 1 means top/bottom
		 * Bit 1: 0 means top half, 1 means bottom half
		 * Bit 2: 0 means right half, 1 means left half
		 */
		protected function getZone():int
		{
			var center_x:Number = _bodyModel.x + _bodyModel.width / 2;
			var center_y:Number = _bodyModel.y + _bodyModel.height / 2;
			var angle_tail:Number = Math.atan2(_tailModel.y - center_y, _tailModel.x - center_x);
			var angle_rect:Number = Math.atan2(_bodyModel.height, _bodyModel.width);
			
			var angle_tail_abs:Number = Math.abs(angle_tail);
			var zone_number:int = 0;
			zone_number += int(Math.abs(Math.PI/2 - angle_tail_abs) < (Math.PI/2 - angle_rect));
			zone_number += 2 * int(angle_tail > 0);
			zone_number += 4 * int(angle_tail_abs > (Math.PI / 2));
			
			return zone_number;
		}
		
		override public function adjustToModel():void
		{
			if (tailDistance < 20) {
				_tailModel.x = _bodyModel.x + _bodyModel.width / 2;
				_tailModel.y = _bodyModel.y + _bodyModel.height;
			}
			getWholeModel();
		}
		
		public function get tailDistance():Number {
			return Point.distance(new Point(_bodyModel.x + _bodyModel.width / 2, _bodyModel.y + _bodyModel.height),
				new Point(_tailModel.x, _tailModel.y));
		}
		
		public function get properties():XMLList
		{
			var xml_str:String = new String();
			
			xml_str += XMLUtils.getXML("type", _type);
			xml_str += XMLUtils.getXML("bodyModel", XMLUtils.getXML("model", _bodyModel.properties.toXMLString()));
			xml_str += XMLUtils.getXML("tailModel", XMLUtils.getXML("model", _tailModel.properties.toXMLString()));
			xml_str += XMLUtils.getXML("fill", _fillColor.toString());
			xml_str += XMLUtils.getXML("stroke", _strokeColor.toString());
			xml_str += XMLUtils.getXML("strokeWidth", _strokeWidth.toString());
			xml_str += glowXML;
			xml_str += XMLUtils.getHtmlXML("html_text", shapeLabel);
			return new XMLList(xml_str); 
		}
		
		public override function set properties(value:XMLList):void
		{
			super.properties = value;	
			_type = value.type;
			if (_bodyModel == null) _bodyModel = new BasicShapeModel();
			if (_tailModel == null) _tailModel = new BasicShapeModel();
			if (model == null) model = new BasicShapeModel();
			if ("fill" in value) fillColor = int(value.fill);
			if ("stroke" in value) strokeColor = int(value.stroke);
			if ("strokeWidth" in value) strokeWidth = int(value.strokeWidth);
			shapeLabel = value.html_text.toString();
			_bodyModel.properties = value.bodyModel.model;
			_tailModel.properties = value.tailModel.model;
			getWholeModel();
			glow = value.glowColor.toString();
		}
		
		protected override function adjustTextPosition(value:Number=0):void
		{
			if (_shapeLabel == null) return;
/*			_shapeLabel.x = _bodyModel.x - _model.x + textMargin;
*/	
			_shapeLabel.x = _bodyModel.x - _model.x;
			_shapeLabel.y = _bodyModel.y - _model.y;
			_shapeLabel.width = _bodyModel.width;
			_shapeLabel.height = _bodyModel.height;

			_shapeLabel.setStyle("paddingLeft", textMargin);
			_shapeLabel.setStyle("paddingRight", textMargin);
			_shapeLabel.setStyle("paddingTop", 3);
			_shapeLabel.setStyle("paddingBottom", 3);

/*			_shapeLabel.width = _bodyModel.width - 2 * textMargin;
			_shapeLabel.height = _bodyModel.height - 2 * textMargin;
*/		}
		
		override protected function setTextStyle():void
		{
						
		}
		
		override public function moveOffset(offset_x:Number, offset_y:Number):void
		{
			_bodyModel.moveOffset(offset_x, offset_y);
			_tailModel.moveOffset(offset_x, offset_y);
			_model.moveOffset(offset_x, offset_y);
			adjustToModel();
		}
		
		public function addMouseOverHandler(handler_func:Function):void
		{
//			handler_func = showEvent;
			_surface.addEventListener(MouseEvent.MOUSE_OVER, handler_func);
			_shapeLabel.addEventListener(MouseEvent.MOUSE_OVER, handler_func);
			_surface.addEventListener(MouseEvent.ROLL_OVER, handler_func);
			_shapeLabel.addEventListener(MouseEvent.ROLL_OVER, handler_func);
		}
		
		public function removeMouseOverHandler(handler_func:Function):void
		{
//			handler_func = showEvent;
			_surface.removeEventListener(MouseEvent.MOUSE_OVER, handler_func);
			_shapeLabel.removeEventListener(MouseEvent.MOUSE_OVER, handler_func);
			_surface.removeEventListener(MouseEvent.ROLL_OVER, handler_func);
			_shapeLabel.removeEventListener(MouseEvent.ROLL_OVER, handler_func);
		}

		private function showEvent(event:Event):void
		{
			trace("type:" + event.type + " target:" +event.target.toString()); 
		}
		
		public function addMouseOutHandler(handler_func:Function):void
		{
//			handler_func = showEvent;
			_surface.addEventListener(MouseEvent.ROLL_OUT, handler_func);
			_shapeLabel.addEventListener(MouseEvent.ROLL_OUT, handler_func);
			_surface.addEventListener(MouseEvent.MOUSE_OUT, handler_func);
			_shapeLabel.addEventListener(MouseEvent.MOUSE_OUT, handler_func);
		}
		
		public function removeMouseOutHandler(handler_func:Function):void
		{
			handler_func = showEvent;
//			_surface.removeEventListener(MouseEvent.ROLL_OUT, handler_func);
//			_shapeLabel.removeEventListener(MouseEvent.ROLL_OUT, handler_func);
		}

		public override function set state(value:String):void
		{
			_state = value;
			if (_state == Diagram.STATE_PLAYER) {
				bodyModel.isLocked = true;
				tailModel.isLocked = true;
//				bodyModel.width += (2 * textMargin);
				//							calloutShape.bodyModel.height += 1;
				visible = false;
				
				var shadow:DropShadowFilter = new DropShadowFilter();
				shadow.color = 0;
				shadow.distance = 5;
				shadow.angle = 60;
				shadow.blurX = 3;
				shadow.blurY = 3;
				shadow.alpha = .5;
				
				filters = [shadow];
				
				// Replace href="http:// to href="event:http://
				// So that program can intercept the URL clicked
				shapeText.htmlText = StrUtil.addLinkEvent(shapeText.htmlText);
				
				doubleClickEnabled = false;
				useHandCursor = false;
				mouseChildren = true;
				mouseEnabled = false;
				enableText();
//				addTextShadow();
			}
		}
		
		public override function set alpha(value:Number):void {
			_rectAlpha = value;
			_fill.gradientStops = [
				new GradientStop(0xFFFFFF, _rectAlpha, 0),
				new GradientStop(_fillColor, _rectAlpha, .03), 
				new GradientStop(_fillColor, _rectAlpha, .97), 
				new GradientStop(_fillColor, _rectAlpha/1.3, 1)
			];
			_stroke.alpha = value * 2;
		}
		
		public override function get alpha():Number {
			return _rectAlpha;
		}
	}
}