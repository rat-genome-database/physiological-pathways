package edu.mcw.hmgc.rgd.diagrammer
{
	import com.degrafa.GeometryComposition;
	import com.degrafa.Surface;
	import com.roguedevelopment.objecthandles.HandleDescription;
	import com.roguedevelopment.objecthandles.HandleRoles;
	import com.roguedevelopment.objecthandles.ObjectHandles;
	
	import edu.mcw.hmgc.rgd.diagrammer.shapes.BasicShape;
	import edu.mcw.hmgc.rgd.diagrammer.shapes.BasicShapeModel;
	import edu.mcw.hmgc.rgd.diagrammer.shapes.CalloutShape;
	import edu.mcw.hmgc.rgd.diagrammer.shapes.GIFShape;
	import edu.mcw.hmgc.rgd.diagrammer.shapes.PNGShape;
	import edu.mcw.hmgc.rgd.diagrammer.shapes.RectCalloutShape;
	import edu.mcw.hmgc.rgd.diagrammer.shapes.SVGShape;
	import edu.mcw.hmgc.rgd.utils.libraries.ImageLibrary;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.containers.Canvas;
	import mx.core.ClassFactory;
	
	public class ObjectSource 
	{
		protected var _factory:ClassFactory;
		protected var _position:Point;
		protected static var _diagram:Diagram;
		protected var _parent:Canvas;
		protected var _mainCanvas:Canvas;
		protected var _mainBoard:Canvas;
		
		[Bindable]
		protected var _shapeModel:BasicShapeModel;
		
		static protected var _newObj:BasicShape = null;
		protected var _value:String;
		
		protected var _mouseX:Number;
		protected var _mouseY:Number;
		
		public function ObjectSource(factory:ClassFactory,
									 value:String,
									 parent:Canvas, mainCavas:Canvas,
									 position:Point)
		{
			_factory = factory;
			_position = position;
			_parent = parent;
			_mainCanvas = mainCavas;
			_mainBoard = _mainCanvas.parent as Canvas;
			_value = value;
			
			create(0);
		}
		
		protected function getPosition(obj:BasicShape, handleMode:Number=0):void
		{
			_shapeModel = new BasicShapeModel();
			_shapeModel.width = 50;
			_shapeModel.height = 50;
			obj.width = _shapeModel.width;
			obj.height = _shapeModel.height;
			obj.maintainAspectRatio = true;

			switch (handleMode)
			{
				case 0: // Source position
					_shapeModel.x = _position.x;
					_shapeModel.y = _position.y;
					break;
				case 1: // Clone position
					var canvas_pos:Point = _parent.localToGlobal(_position);
					canvas_pos.x -= _parent.horizontalScrollPosition;
					canvas_pos.y -= _parent.verticalScrollPosition;
					var new_pos:Point = _mainCanvas.globalToLocal(canvas_pos);
					_shapeModel.x = new_pos.x + ( 
						_mouseX * (1 - _mainCanvas.parent.scaleX) / _mainCanvas.parent.scaleX);
					_shapeModel.y = new_pos.y + (
						_mouseY * (1 - _mainCanvas.parent.scaleY) / _mainCanvas.parent.scaleY);
					break;
			}
			obj.model = _shapeModel;
		}

		protected function create(handleMode:Number=0) : void {
			var obj:BasicShape = _factory.newInstance() as BasicShape;

			switch (_factory.generator) {
				case edu.mcw.hmgc.rgd.diagrammer.shapes.SVGShape:
					SVGShape(obj).imageName = _value;
					break;
				case edu.mcw.hmgc.rgd.diagrammer.shapes.PNGShape:
					PNGShape(obj).imageName = _value;
					break;
				case edu.mcw.hmgc.rgd.diagrammer.shapes.GIFShape:
					GIFShape(obj).imageName = _value;
					break;
				case edu.mcw.hmgc.rgd.diagrammer.shapes.RectCalloutShape:
					break;
			}
			getPosition(obj, handleMode);
			
			switch (handleMode) {
				case 0: // Create source
					_parent.addChild(obj);
					obj.toolTip = ImageLibrary.getImage(_value).description;
					obj.addEventListener(MouseEvent.MOUSE_DOWN, onClick );
					break;
				case 1: // Create clone
					obj.startDrag();
					_newObj = obj;
					_mainCanvas.addChild(obj);
					obj.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
					break;
				case 2:
					break;
				default:
			}
		}
		
		protected function onClick(event:MouseEvent) : void
		{
			resetNewObj();
			var temp_pos:Point = _parent.globalToContent(new Point(event.stageX, event.stageY));
			
			_mouseX = temp_pos.x - _position.x;
			_mouseY = temp_pos.y - _position.y;
			
			switch (_factory.generator) {
				case edu.mcw.hmgc.rgd.diagrammer.shapes.SVGShape:
					create(1);
					break;
				case edu.mcw.hmgc.rgd.diagrammer.shapes.PNGShape:
					create(1);
					break;
				case edu.mcw.hmgc.rgd.diagrammer.shapes.GIFShape:
					create(1);
					break;
				case edu.mcw.hmgc.rgd.diagrammer.shapes.RectCalloutShape:
					create(1);
					break;
			}
		}
		
		protected function onMouseUp(event:MouseEvent):void {

			var obj:BasicShape = _newObj;
			_newObj = null;
			obj.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			
			obj.stopDrag();
			var view_rect:Rectangle = _mainCanvas.getVisibleRect();
			view_rect.offset(
				Canvas(_mainBoard.parent).horizontalScrollPosition, Canvas(_mainBoard.parent).verticalScrollPosition);
			if (view_rect.contains(obj.x, obj.y))
			{
				_diagram.addObject(obj);
			}
			else
			{
				_mainCanvas.removeChild(obj);
			}
		}
		
		public static function set diagram(value:Diagram):void
		{
			_diagram = value;
		}
		
		private function resetNewObj():void
		{
			if (_newObj != null) {
				_mainCanvas.removeChild(_newObj);
				_newObj = null;
			}
		}
	}
}