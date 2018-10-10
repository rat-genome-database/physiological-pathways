package edu.mcw.hmgc.rgd.diagrammer
{
	import com.roguedevelopment.objecthandles.HandleDescription;
	import com.roguedevelopment.objecthandles.HandleRoles;
	import com.roguedevelopment.objecthandles.ObjectChangedEvent;
	import com.roguedevelopment.objecthandles.ObjectHandles;
	import com.roguedevelopment.objecthandles.ObjectHandlesSelectionManager;
	
	import edu.mcw.hmgc.rgd.bio.Relationship;
	import edu.mcw.hmgc.rgd.diagrammer.links.LinkComponent;
	import edu.mcw.hmgc.rgd.diagrammer.shapes.BasicShape;
	import edu.mcw.hmgc.rgd.diagrammer.shapes.BasicShapeModel;
	import edu.mcw.hmgc.rgd.diagrammer.shapes.CalloutShape;
	import edu.mcw.hmgc.rgd.diagrammer.shapes.GIFShape;
	import edu.mcw.hmgc.rgd.diagrammer.shapes.PNGShape;
	import edu.mcw.hmgc.rgd.diagrammer.shapes.RectCalloutShape;
	import edu.mcw.hmgc.rgd.diagrammer.shapes.SVGShape;
	import edu.mcw.hmgc.rgd.graphics.RoundedRectCallout;
	import edu.mcw.hmgc.rgd.graphics.ShowHideEffects;
	import edu.mcw.hmgc.rgd.graphics.Surface;
	import edu.mcw.hmgc.rgd.utils.FilterUtility;
	import edu.mcw.hmgc.rgd.utils.GeometryUtil;
	import edu.mcw.hmgc.rgd.utils.HistoryTracker;
	import edu.mcw.hmgc.rgd.utils.events.ViewEvent;
	import edu.mcw.hmgc.rgd.utils.grouping.Group;
	import edu.mcw.hmgc.rgd.utils.grouping.GroupElement;
	import edu.mcw.hmgc.rgd.utils.grouping.Grouper;
	import edu.mcw.hmgc.rgd.utils.grouping.Layer;
	import edu.mcw.hmgc.rgd.utils.grouping.Layers;
	import edu.mcw.hmgc.rgd.utils.libraries.ImageLibrary;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.sampler.getGetterInvocationCount;
	import flash.utils.getQualifiedClassName;
	
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.collections.XMLListCollection;
	import mx.containers.Canvas;
	import mx.controls.ToolTip;
	import mx.managers.ToolTipManager;
	
	public class Diagram
	{
		public static const STATE_DESIGNER:String = "design";
		public static const STATE_PLAYER:String = "play";
		private static const DUPLICATE_OFFSET:Number = 15;
		
		protected var _titleAdded:Boolean = false;
		protected var _playableFilter:Array = [];
		private var _tooltipsCanvas:Canvas;
		private var _title:String;
		
		private var _callouts:Array = []; 
		
		private var _shapesToShow:Array = [];
		private var _subTitle:String;
		
		private var _type:String;
		private var _activeLayers:Array = [];

		private var _layerGroups:XMLList = null;
		private var _layerGroupTreeXML:XML
		
		private var _metaData:XMLList;

		public function get metaData():XMLList
		{
			return _metaData;
		}

		public function set metaData(value:XMLList):void
		{
			_metaData = value;
		}

		
		public static const DESIGNER_DIAGRAM_MODE:String = "diagram";
		public static const DESIGNER_LAYER_MODE:String = "layer";

		private var _designerMode:String = DESIGNER_DIAGRAM_MODE;

		public function get designerMode():String
		{
			return _designerMode;
		}

		private var _layerEditing:int = -1;
		
		public function get activeLayers():Array
		{
			return _activeLayers;
		}

		public function set activeLayers(value:Array):void
		{
			_activeLayers = value;
		}

		public function get type():String
		{
			return _type;
		}

		public function set type(value:String):void
		{
			_type = value;
		}

		[Bindable]
		public function get subTitle():String
		{
			return _subTitle;
		}

		public function set subTitle(value:String):void
		{
			_subTitle = value;
		}

		public function get layers():Layers
		{
			return _layers;
		}

		public function set layers(value:Layers):void
		{
			_layers = value;
		}

		[Bindable]
		public function get title():String
		{
			return _title;
		}

		public function set title(value:String):void
		{
			_title = value;
		}

		public function get tooltipsCanvas():Canvas
		{
			return _tooltipsCanvas;
		}

		public function set tooltipsCanvas(value:Canvas):void
		{
			_tooltipsCanvas = value;
		}

		public function get showCallouts():Boolean
		{
			return _showCallouts;
		}

		[Bindable]
		public function set showCallouts(value:Boolean):void
		{
			_showCallouts = value;
			if (_objHandles == null) return;
			for  (var i:int = 1; i < _objHandles.modelList.length; i++)
			{
				var obj_mod:BasicShapeModel = _objHandles.modelList[i] as BasicShapeModel;
				var obj:Object = _objHandles.getDisplayForModel(obj_mod);
				if (obj is RectCalloutShape)
				{
					ShowHideEffects.showHideFade(obj, _showCallouts);
				}
			}
		}

		public function get callouts():Array
		{
			return _callouts;
		}
		
		private var _grouper:Grouper = new Grouper();
		
		private var _layers:Layers = new Layers();
		
		private var _backgroundColor:Object = "0xFFFFFF";
		
		private var _addingSelection:Boolean = false;
	
		private var _lastXML:XMLList;
		
		protected var _showCallouts:Boolean = false;
		
		public function get isLoading():Boolean
		{
			return _isLoading;
		}

		public function get grouper():Grouper
		{
			return _grouper;
		}

		public function set grouper(value:Grouper):void
		{
			_grouper = value;
		}

		public function get addingSelection():Boolean
		{
			return _addingSelection;
		}
		
		private var _changed:Boolean = false;
		
		private var _isLoading:Boolean = false;
		
		private var _fileName:String = "";
		[Bindable]
		public function get fileName():String
		{
			return _fileName;
		}
		public function set fileName(value:String):void
		{
			_fileName = value;
		}
		
		protected var _historyTracker:HistoryTracker = new HistoryTracker();

		protected var _singleToolTip:ToolTip;
		
		protected var _parent:Object;
		
		private var _contentBounds:Rectangle = null;

		[Bindable]
		public function get contentBounds():Rectangle
		{
			if (_contentBounds == null) return null;
			var temp_rect:Rectangle = _contentBounds.clone();
			temp_rect.width += 15;
			return temp_rect;
		}

		public function set contentBounds(value:Rectangle):void
		{
			_contentBounds = value;
		}

		
		private var _bkColor:Object = null;
		
		public function Diagram(par_obj:Object)
		{
			_parent = par_obj;
		}
		
		protected var _bkCanvas:Canvas;
		public function set bkCanvas(value:Canvas):void 
		{
			_bkCanvas = value;
		}
		
		public function get bkCanvas():Canvas
		{
			return _bkCanvas;
		}
		
		protected var _upperCanvas:Canvas;
		public function set upperCanvas(value:Canvas):void
		{
			_upperCanvas = value;
		}
		
		protected var _lowCanvas:Canvas;
		public function set lowCanvas(value:Canvas):void 
		{
			_lowCanvas = value;
		}
		
		public function get lowCanvas():Canvas
		{
			return _lowCanvas;
		}
		
		protected var _mainCanvas:Canvas;
		public function set mainCanvas(value:Canvas):void
		{
			_mainCanvas = value;
		}
		
		public function get mainCanvas():Canvas
		{
			return _mainCanvas;
		}
		
		protected var _mainSurface:Surface;
		public function set mainSurface(value:Surface):void
		{
			_mainSurface = value;
		}
		
		public function get mainSurface():Surface
		{
			return _mainSurface;
		}
		
		protected var _linkSurface:Surface;
		public function set linkSurface(value:Surface):void
		{
			_linkSurface = value;
		}
		
		public function get linkSurface():Surface
		{
			return _linkSurface;
		}
		
		protected var _objHandles:ObjectHandles;
		public function set objectHandles(value:ObjectHandles):void
		{
			_objHandles = value;
		}
		
		public function get objectHandles():ObjectHandles
		{
			return _objHandles;
		}
		
		protected var _poiHandles:ObjectHandles;
		public function set poiHandles(value:ObjectHandles):void
		{
			_poiHandles = value;
		}
		
		public function get poiHandles():ObjectHandles
		{
			return _poiHandles;
		}
		
		protected var _state:String = new String;
		public function set state(value:String):void 
		{
			_state = value;
		}
		public function get state():String
		{
			return _state;
		}

		private var _links:XML;
		public function get links():XML
		{
			return _links;
		}

		public function set links(value:XML):void
		{
			_links = value;
		}
		
		
		public function addNewShape(shape:BasicShape):void
		{
			_mainCanvas.addChild(shape);
			if (shape.model.rotation != 0) 
			{
				rotateShape(shape);
			}
		}
		
		protected function adjustToCenter(shape:BasicShape):void
		{
			if (shape.model.rotation == 0) return;
			with (shape.model)
			{
				var angle_r:Number = rotation / 180 * Math.PI;
				var x1:Number = x + width * Math.cos(angle_r);
				var y1:Number = y + width * Math.sin(angle_r);
				var x2:Number = x1 - height * Math.sin(angle_r);
				var y2:Number = y1 + height * Math.cos(angle_r);
				var x3:Number = (x + x2) / 2;
				var y3:Number = (y + y2) / 2;
				shape.move(x3 - width / 2, y3 - height / 2);
			}
		}
		
		public function rotateShape(shape:BasicShape):void
		{
			shape.rotate();
			refreshRelatedLinks(shape);
		}
		
		public function resizeShape(shape:BasicShape):void
		{
			if (shape.maintainAspectRatio)
			{
				var resize_scale:Number = Math.abs(shape.model.width / shape.width) / 
					Math.abs(shape.model.height / shape.height);

				if (resize_scale < 1)
				{
					shape.model.width /= resize_scale;;
				} else
				{
					shape.model.height *= resize_scale;;
				}
			}
			
			
			shape.width = shape.model.width;
			shape.height = shape.model.height;
			shape.rotate();
			shape.validateNow();
			refreshRelatedLinks(shape);
		}
		
		protected function addLink(link:LinkComponent):void
		{
			_mainSurface.graphicsCollection.addItem(link);
			link.target = _linkSurface;
			_objHandles.registerComponent(link.model, link, getHandles(3));
		}
		
		public function getShape(index:int):Object
		{
			var model:BasicShapeModel = _objHandles.modelList[index];
			var shape:Object = _objHandles.getDisplayForModel(model);
			
			return shape;
		}
		
		public function getModelByID(index:int):BasicShapeModel
		{
			return _objHandles.modelList[index];
		}
		
		/**
		 * Returns handles for different situations
		 *  
		 * 0: Full;
		 * 1: Point;
		 * 2: No rotation;
		 * 3: Link control-point;
		 * 
		 **/
		public function getHandles(handle_type:int=0):Array
		{
			if (_state == STATE_PLAYER) return []; 
			
			switch (handle_type)
			{
				case 0: 
					return Handles.FULL;
					break;
				case 1: 
					return Handles.POINT;
					break;
				case 2: 
					return Handles.NO_ROTATE;
					break;
				case 3: 
					return Handles.LINK_CONTROL;
					break;
			};
			
			return Handles.FULL;
		}
		
		public function toXMLString():String
		{
			var xml_return:XMLList = new XMLList("<diagram></diagram>");
			if (_bkColor != null) xml_return.@bkColor = _bkColor;
			if (_title != null) xml_return.@title = _title;
			if (_subTitle != null) xml_return.@subTitle = _subTitle;
			if (_type != null) xml_return.@type = _type;
			var obj_index:int;
			for each (var obj_model:Object in _objHandles.modelList)
			{
				if (obj_model is BasicShapeModel)
				{
					var basic_model:BasicShapeModel = obj_model as BasicShapeModel;
					var obj_xml:XMLList = new XMLList("<object id=\"" 
						+ basic_model.index + "\" type=\"unknown\"></object>");
					var obj:Object = _objHandles.getDisplayForModel(obj_model);
					getObjXML(obj, obj_xml);
					
					xml_return.appendChild(obj_xml);
				}
			}
			var grouper_xml:XMLList = new XMLList("<grouper></grouper>");
			grouper_xml.appendChild(grouper.properties);
			xml_return.appendChild(grouper_xml);
			
			var layers_xml:XMLList = new XMLList("<layers></layers>");
			layers_xml.appendChild(layers.properties);
			if (_layerGroups != null) layers_xml.appendChild(_layerGroups);
			xml_return.appendChild(layers_xml);
			
			xml_return.appendChild(metaData);
			
			xml_return.appendChild(links);
			
			return xml_return.toXMLString();
		}
		
		public function vFlipSelection():void 
		{
			for each (var obj_mod:BasicShapeModel in selectionManager.currentlySelected) {
				var obj:Object = _objHandles.getDisplayForModel(obj_mod);
				if (obj is BasicShape) {
					var obj_sel:BasicShape = obj as BasicShape;
					obj_sel.flipV();
				} else if (obj_sel is LinkComponent) {
				}
			}
		}
		
		public function hFlipSelection():void 
		{
			for each (var obj_mod:BasicShapeModel in selectionManager.currentlySelected) {
				var obj:Object = _objHandles.getDisplayForModel(obj_mod);
				if (obj is BasicShape) {
					var obj_sel:BasicShape = obj as BasicShape;
					obj_sel.flipH();
				} else if (obj_sel is LinkComponent) {
				}
			}
		}
		
		public function bringToFront():void
		{
			for each (var obj_mod:BasicShapeModel in selectionManager.currentlySelected) {
				var obj:Object = _objHandles.getDisplayForModel(obj_mod);
				if (obj is BasicShape) {
					var obj_sel:BasicShape = obj as BasicShape;
					obj_sel.parent.removeChild(obj_sel);
					_mainCanvas.addChild(obj_sel);
				} else if (obj_sel is LinkComponent) {
					var link_sel:LinkComponent = obj as LinkComponent;
					link_sel.parent.parent.setChildIndex(link_sel.parent, link_sel.parent.parent.numChildren + 1);
					_mainSurface.parent.setChildIndex(_mainSurface, _mainSurface.parent.numChildren+1);
				}
			}
			keepRecord();
		}
		
		public function get selectionManager():ObjectHandlesSelectionManager
		{
			return _objHandles.selectionManager;
		}
		
		public function linkSelection():void
		{
			if (_objHandles.selectionManager.currentlySelected.length != 2) return;
			var fromPoint:BasicShape = _objHandles.getDisplayForModel(_objHandles.selectionManager.currentlySelected[0]) as BasicShape;
			var toPoint:BasicShape = _objHandles.getDisplayForModel(selectionManager.currentlySelected[1]) as BasicShape;
			var link:LinkComponent = new LinkComponent(fromPoint, toPoint);
			var linkModel:BasicShapeModel = new BasicShapeModel();
			_mainSurface.graphicsCollection.addItem(link);
			link.target = _linkSurface;
			var linkPoint:Point = link.controlPoint;
			linkModel.x = linkPoint.x;
			linkModel.y = linkPoint.y;
			linkModel.width = link.width;
			linkModel.height = link.height;
			
			link.model = linkModel;
			_objHandles.registerComponent(link.model, link, getHandles(3));
			clearSelection();
			selectionManager.addToSelected(linkModel);
			_mainSurface.setFocus();
			keepRecord();
		}
		
		public function clearSelection(forced:Boolean=false):void
		{
			if (!forced && _designerMode == DESIGNER_LAYER_MODE) return;
			selectionManager.clearSelection();	
			_poiHandles.selectionManager.clearSelection();
		}
		
		public function deleteSelection(save_result:Boolean=true):void
		{
			for each (var obj_mod:BasicShapeModel in selectionManager.currentlySelected) {
				var obj:Object = _objHandles.getDisplayForModel(obj_mod);
				if (obj is BasicShape) {
					deleteShape(obj as BasicShape);
				} else if (obj is LinkComponent) {
					deleteLink(obj as LinkComponent);
				}
				var tmp_ind:int = _shapesToShow.indexOf(obj);
				if (tmp_ind >= 0) _shapesToShow.splice(tmp_ind, 1);
			}
			if (save_result) keepRecord();
		}
		
		protected function deleteShape(shape:BasicShape):void
		{
			deleteRelatedLinks(shape);
			if (shape is RectCalloutShape)
			{
				var rectCallout:RectCalloutShape = shape as RectCalloutShape;
				_objHandles.unregisterModel(rectCallout._bodyModel);
				rectCallout._bodyModel = null;
				_poiHandles.unregisterModel(rectCallout._tailModel);
				rectCallout._tailModel = null;
				rectCallout.parent.removeChild(rectCallout);
				return;
			}
			_objHandles.unregisterModel(shape.model);
			shape.model = null;
			shape.parent.removeChild(shape);
			shape.cleanUpMemory();
		}
		
		public function selectAll():void
		{
			var i:int;
			_addingSelection = true;
			clearSelection();
			for  (i = 1; i < _objHandles.modelList.length; i++)
			{
				var obj_mod:BasicShapeModel = _objHandles.modelList[i] as BasicShapeModel;
				selectionManager.addToSelected(obj_mod);
			}
			_addingSelection = false;
			_parent.dispatchEvent(new ViewEvent(ViewEvent.SELECTION_CHANGED));
		}
		
		public function resizeSelection():void
		{
			for each (var obj_mod:BasicShapeModel in selectionManager.currentlySelected) {
				var obj:Object = _objHandles.getDisplayForModel(obj_mod);
				
				if (obj is BasicShape) {
					resizeShape(obj as BasicShape);
				} else if (obj is LinkComponent) {
					(obj as LinkComponent).adjustToModel();
				}
			}
			keepRecord();
		}
		
		public function refreshRelatedLinks(shape:BasicShape):void
		{
			var i:int;
			for  (i = 1; i < _objHandles.modelList.length; i++)
			{
				var obj_mod:BasicShapeModel = _objHandles.modelList[i] as BasicShapeModel;
				var obj:Object = _objHandles.getDisplayForModel(obj_mod);
				if (obj is LinkComponent)
				{
					var link:LinkComponent = obj as LinkComponent;
					if (link.linkFrom == shape || link.linkTo == shape) link.update();
				}
			}
		}
		
		protected function deleteLink(link:LinkComponent):void
		{
			selectionManager.removeFromSelected(link.model);
			_objHandles.unregisterModel(link.model);
			link.remove();
			link.cleanUpMemory();
			_mainSurface.graphicsCollection.removeItem(link);
		}
		
		public function deleteRelatedLinks(shape:BasicShape):void
		{
			var i:int;
			var link_array:Array = getRelatedLinks(shape);
			if (link_array.length == 0) return;
			while (link_array.length > 0)
			{
				deleteLink(link_array.pop());
			}
		}
		
		/**
		 * Get links from/to an object
		 * 
		 * shape: object
		 * 
		 * link_mod: 0: both direction;
		 *   1: from;
		 *   2: to;
		 * 
		 * Return: an array of links
		 */ 
		protected function getRelatedLinks(shape:BasicShape, link_mode:int=0):Array
		{
			var link_array:Array = [];
			for  (var i:int = 1; i < _objHandles.modelList.length; i++)
			{
				var obj_mod:BasicShapeModel = _objHandles.modelList[i] as BasicShapeModel;
				var obj:Object = _objHandles.getDisplayForModel(obj_mod);
				if (obj is LinkComponent)
				{
					var link:LinkComponent = obj as LinkComponent;
					switch (link_mode)
					{
						case 0: // both
							if (link.linkFrom == shape || link.linkTo == shape) 
							{
								link_array.push(link);
							};
							break;
						case 1: // Link from
							if (link.linkFrom == shape) 
							{
								link_array.push(link);
							};
							break;
						case 2: // Link to
							if (link.linkTo == shape) 
							{
								link_array.push(link);
							};
							break;
					}
				}
			}
			return link_array;
		}
		
		public function rotateSelection():void
		{
			for each (var obj_mod:BasicShapeModel in selectionManager.currentlySelected) {
				var obj:Object = _objHandles.getDisplayForModel(obj_mod);
				
				if (obj is BasicShape) {
					rotateShape(obj as BasicShape);
				} else if (obj is LinkComponent) {
					(obj as LinkComponent).adjustToModel();
				}
			}
			keepRecord();
		}
		
		public function dragSelect(rect:Rectangle):void
		{
			clearSelection();
			var i:int;
			_addingSelection = true;
			for  (i = 1; i < _objHandles.modelList.length; i++)
			{
				var obj_mod:BasicShapeModel = _objHandles.modelList[i] as BasicShapeModel;
				var obj_rect:Rectangle = new Rectangle(obj_mod.x, obj_mod.y, obj_mod.width, obj_mod.height);
				if (rect.containsRect(obj_rect)) selectionManager.addToSelected(obj_mod);
			}
			_addingSelection = false;
			_parent.dispatchEvent(new ViewEvent(ViewEvent.SELECTION_CHANGED));
		}
		
		public function sendToBack():void
		{
			for each (var obj_mod:BasicShapeModel in selectionManager.currentlySelected) {
				var obj:Object = _objHandles.getDisplayForModel(obj_mod);
				
				if (obj is BasicShape) {
					var obj_shape:BasicShape = obj as BasicShape;
					obj_shape.parent.removeChild(obj_shape);
					_lowCanvas.addChildAt(obj_shape, 0);
					
				} else if (obj is LinkComponent) {
					(obj as LinkComponent).adjustToModel();
				}
			}
			keepRecord();
		}
		
		public function clearAll():void
		{
			if (state == STATE_PLAYER) 
			{
				while (_mainSurface.graphicsCollection.items.length > 0)
				{
					var obj:Object = _mainSurface.graphicsCollection.pop();
					if (obj is LinkComponent)
					{
						LinkComponent(obj).remove();
						LinkComponent(obj).cleanUpMemory();
					}
				}
				_bkCanvas.removeAllChildren();
				_lowCanvas.removeAllChildren();
				_mainCanvas.removeAllChildren();
				_contentBounds = null;
				 _titleAdded = false;
				 _playableFilter = [];
			}
			else if (state == STATE_DESIGNER)
			{
				_grouper = new Grouper();
				selectAll();
				deleteSelection(false);
			}
		}
		
		protected function onPlayerClick(event:MouseEvent):void
		{
		}
		
		protected function onPlayerLinkMouseOver(event:MouseEvent):void
		{
		}
		
		protected function onPlayerLinkMouseOut(event:MouseEvent):void
		{
			ToolTipManager.destroyToolTip(_singleToolTip);
		}

		protected function onPlayerShapeMouseOver(event:MouseEvent):void
		{
		}
		
		protected function onPlayerShapeMouseOut(event:MouseEvent):void
		{
		}
		
		protected function checkContentBounds(rect:Rectangle):void
		{
			if (_contentBounds == null) 
			{
				_contentBounds = new Rectangle(rect.x, rect.y, rect.width, rect.height);
			} else
			{
				_contentBounds =  _contentBounds.union(rect);
			}
		}
		
		public function addFilterToSelection(filterFunction:Function, args:Array=null):void 
		{
			for each (var obj_mod:BasicShapeModel in selectionManager.currentlySelected) {
				var obj:Object = _objHandles.getDisplayForModel(obj_mod);
				
				obj.filters = [filterFunction(args)];
			}
			keepRecord();
		}
		
		public function removeFilterFromSelection():void 
		{
			for each (var obj_mod:BasicShapeModel in selectionManager.currentlySelected) {
				var obj:Object = _objHandles.getDisplayForModel(obj_mod);
				
				obj.filters = [];
			}
			keepRecord();
		}
		
		public function duplicateSelection():void
		{
			var xml_selection:XMLList = new XMLList("<selection></selection>");
			var obj_index:int = _objHandles.modelList.length;
			for each (var obj_mod:BasicShapeModel in selectionManager.currentlySelected) {
				var obj:Object = _objHandles.getDisplayForModel(obj_mod);
				if ((obj is BasicShape) && !(obj is LinkComponent))
				{
					var obj_xml:XMLList = new XMLList("<object id=\"" 
						+ obj_index + "\" type=\"unknown\"></object>");
					getObjXML(obj, obj_xml)
					xml_selection.appendChild(obj_xml);
					obj_index ++;
				}
			
			}
			clearSelection();
			
			_addingSelection = true;
			var obj_list:XMLListCollection = new XMLListCollection(xml_selection.object);
			loadObjXML(obj_list, true, DUPLICATE_OFFSET, DUPLICATE_OFFSET);
			_addingSelection = false;
			_parent.dispatchEvent(new ViewEvent(ViewEvent.SELECTION_CHANGED));
			keepRecord();
		}
		
		protected function getObjXML(obj:Object, obj_xml:XMLList):void
		{
			switch (getQualifiedClassName(obj))
			{
				case "edu.mcw.hmgc.rgd.diagrammer.shapes::SVGShape":
				case "edu.mcw.hmgc.rgd.diagrammer.shapes::PNGShape":
				case "edu.mcw.hmgc.rgd.diagrammer.shapes::GIFShape":
					obj_xml.@type = "Shape";
					obj_xml.@alpha = obj.alpha;
					break;
				case "edu.mcw.hmgc.rgd.diagrammer.links::LinkComponent":
					obj_xml.@type = "Link";
					break;
				case "edu.mcw.hmgc.rgd.diagrammer.shapes::RectCalloutShape":
					obj_xml.@type = "Callout";
					obj_xml.@alpha = obj.alpha;
					break;
			};
			obj_xml.appendChild(obj.properties);
			
			switch (obj.parent) 
			{
				case _mainCanvas:
					obj_xml.@layer = "main";
					obj_xml.@order = _mainCanvas.getChildIndex(obj as BasicShape);
					break;
				case _lowCanvas:
					obj_xml.@layer = "lower";
					obj_xml.@order = _lowCanvas.getChildIndex(obj as BasicShape);
					break;
			}
			
			if (obj.hasOwnProperty("tag")) obj_xml.@tag = obj.tag;
		}
		
		public function restoreAspectRatio():void
		{
			for each (var obj_mod:BasicShapeModel in selectionManager.currentlySelected) {
				var obj:Object = _objHandles.getDisplayForModel(obj_mod);
				if (obj.hasOwnProperty("maintainAspectRatio"))
				{
					obj.maintainAspectRatio = true;
					if (obj.hasOwnProperty("model"))
					{
						obj.model.width = obj.width;
						obj.model.height = obj.height;
					}
					obj.maintainAspectRatio = false;
				}
			}
		}
		
		public function addObject(obj:Object):void
		{
			if (obj is RectCalloutShape)
			{
				var co_obj:CalloutShape = obj as CalloutShape;
				co_obj.moveTo(obj.x, obj.y);
				_objHandles.selectionManager.clearSelection();
				_poiHandles.selectionManager.clearSelection();
				registerCalloutShape(co_obj);
			} else
			{
				obj.model.x = obj.x;
				obj.model.y = obj.y;
				
				switch (getQualifiedClassName(obj)) {
					case "edu.mcw.hmgc.rgd.diagrammer.shapes::SVGShape":
						var obj_svg:SVGShape = obj as SVGShape;
						obj.width = obj_svg.svg_image.width;
						obj.height = obj_svg.svg_image.height;
						obj.maintainAspectRatio = false;
						break;
					case "edu.mcw.hmgc.rgd.diagrammer.shapes::PNGShape":
						obj.maintainAspectRatio = true;
						break;
					case "edu.mcw.hmgc.rgd.diagrammer.shapes::GIFShape":
						var obj_gif:GIFShape = obj as GIFShape;
						obj.width = obj_gif.image.width;
						obj.height = obj_gif.image.height;
						obj.maintainAspectRatio = true;
						break;
				}
				
				obj.model.width = obj.width;
				obj.model.height = obj.height;
				
				_objHandles.registerComponent(obj.model, obj as DisplayObject, getHandles());
				_objHandles.selectionManager.clearSelection();
				_objHandles.selectionManager.addToSelected(obj.model);
			}	
			obj.setFocus();
			if (_shapesToShow.length == 0) _shapesToShow = [new Object()];
			if (_shapesToShow.indexOf(obj) < 0) _shapesToShow.push(obj);
			keepRecord();
		}
		
		protected function registerCalloutShape(shape:CalloutShape, addToSelection:Boolean=true):void
		{
			_objHandles.registerComponent(shape.bodyModel, shape, getHandles(2));
			_poiHandles.registerComponent(shape.tailModel, shape, getHandles(1));
			if (addToSelection) 
			{
				selectionManager.addToSelected(shape.bodyModel);
				_poiHandles.selectionManager.addToSelected(shape.tailModel);
			}
		}
		
		protected function keepRecord(xml_input:String=null):void 
		{
			if (_state == STATE_PLAYER) return;
			
			var xml_string:String;
			if (xml_input == null) 
			{
				xml_string = toXMLString();	
			}
			else
			{	
				xml_string = xml_input;
			}
			var last_xml:String = _historyTracker.currentState as String;
			if (!(xml_string == last_xml)) _historyTracker.append(xml_string);
			notifyParentContentChange();
			_changed = true;
		}

		/**
		 * Undo the last operation.
		 */
		public function undo():void
		{
			if (_historyTracker.undoLength == 0) return;
			loadXML(new XMLList(_historyTracker.undo() as String));
			notifyParentContentChange();
		}
		
		/**
		 * Redo the last operation.
		 */
		public function redo():void
		{
			var current_xml:String = _historyTracker.redo() as String;
			if (current_xml != null)
			{
				loadXML(new XMLList(current_xml));
				notifyParentContentChange();
			}
		}
		
		public function onObjectMoved(event:ObjectChangedEvent):void
		{
			for each(var obj_mod:BasicShapeModel in selectionManager.currentlySelected) {
				var obj:Object = _objHandles.getDisplayForModel(obj_mod);
				
				if (obj is BasicShape) {
					var obj_sel:BasicShape = obj as BasicShape;
					obj_sel.adjustToModel();
					obj_sel.dispatchEvent(event);
				} else if (obj is LinkComponent) {
					var obj_sel1:LinkComponent = obj as LinkComponent;
					obj_sel1.move(obj_mod.x, obj_mod.y);
				}
			}
			keepRecord();
		}
		
		public function load(value:XMLList, file_name:String):void
		{
			loadXML(value);
			fileName = file_name;
			_historyTracker.clearHistory();
			keepRecord(value.toXMLString());
			clearChangeFlag();
		}
		
		public function loadXML(value:XMLList):void
		{
			_isLoading = true;
			_lastXML = value;
			_layers.reset();
			_layerGroups = null;
			_layerGroupTreeXML = null;
			_metaData = null;
			activeLayers = [];
			clearAll();
			// Sort the objetct list according to the order in the object handler
			var obj_list:XMLListCollection = new XMLListCollection(value.object);
			var idSort:Sort = new Sort();
			idSort.fields = [new SortField('@id', false, false, true)];
			
			obj_list.sort = idSort;
			obj_list.refresh();
			_shapesToShow = [new Object()];
			loadObjXML(obj_list);
			
			if ("grouper" in value) loadGroups(value.grouper);
			if ("layers" in value) loadLayers(value.layers);
			if ("layer_groups" in value.layers) loadLayerGroups(value.layers.layer_groups);
			
			if (value.@bkColor != null && value.@bkColor.toString().length > 0) backgroundColor = value.@bkColor;
			if (value.@title != null) title = value.@title;
			if (value.@subTitle != null) subTitle = value.@subTitle;
			if (value.@type != null) type = value.@type;
			if (value.metaData != null) metaData = value.metaData;
			if (value.links) links = value.links[0]; 
			
			// Remove objects from object_handle if in PLAYER mode
			if (_state == STATE_PLAYER) 
			{
				var i:int;
				for  (i = _objHandles.modelList.length - 1; i > 0; i--)
				{
					var obj_mod:BasicShapeModel = _objHandles.modelList[i] as BasicShapeModel;
					var display_obj:Object = _objHandles.getDisplayForModel(obj_mod);
					if (display_obj is RectCalloutShape)
					{
						_objHandles.unregisterComponent(display_obj as RectCalloutShape);
					}
					else
					{
						_objHandles.unregisterModel(obj_mod);
					}
					
				}
				_parent.dispatchEvent(new Event("DIAGRAM_READY"));
			}
			_isLoading = false;
			// Set diagram level settings
		}
		
		protected function loadObjXML(obj_list:XMLListCollection, addToSelection:Boolean=false, 
									  offset_x:Number=0, offset_y:Number=0):void
		{
			_callouts = [];
			// Create new objects and add them to the object handler.
			for each (var obj_xml:XML in obj_list)
			{
				var xmlList:XMLList = new XMLList(obj_xml);
				var obj_type:String = obj_xml.@type.toString();
				
				switch (obj_type)
				{
					case "Shape":
						var shape:Object;
						switch (ImageLibrary.getImage(obj_xml.imageName.toString()).format)
						{
							case "svg":
								shape = new SVGShape();
								break;
							case "png":
								shape = new PNGShape();
								break;							
							case "swf":
								shape = new PNGShape();
								break;
							case "gif":
								shape = new GIFShape();
								break;
						}
						var basic_shape:BasicShape = shape as BasicShape;
						basic_shape.maintainAspectRatio = false;
						if (basic_shape is PNGShape)
							basic_shape.maintainAspectRatio = true;
						shape.properties = xmlList;
						_shapesToShow.push(basic_shape);
						if (_state == STATE_PLAYER) {
							addShapeEventListener(basic_shape);
							basic_shape.addTextShadow();
							basic_shape.showTooltip();
//							var glow:GlowFilter = new GlowFilter();
//							glow.color = 0xFFFFFF;
//							glow.alpha = .8;
//							glow.blurX = glow.blurY =3;
////							glow.inner = true;
////							glow.knockout = true;
//							glow.strength = 3;
//							glow.quality = BitmapFilterQuality.HIGH;
//							
//							basic_shape.shapeText.filters = [glow];
						}
						adjustToCenter(basic_shape);
						rotateShape(basic_shape);
						basic_shape.moveOffset(offset_x, offset_y);
						basic_shape.model.isLocked = (_state == STATE_PLAYER);
						_objHandles.registerComponent(basic_shape.model, basic_shape, getHandles());
						//						checkContentBounds(basic_shape.getBounds(_mainCanvas));
						checkContentBounds(GeometryUtil.realRect(basic_shape.model));
						if (addToSelection) selectionManager.addToSelected(basic_shape.model);
						break;
					case "Link":
						var fromIndex:int = xmlList.from_node;
						var toIndex:int = xmlList.to_node;
						var linkShape:LinkComponent = new LinkComponent(getShape(fromIndex) as BasicShape, getShape(toIndex) as BasicShape);
						linkShape.properties = xmlList;
						addLink(linkShape);
						_shapesToShow.push(linkShape);
						if (_state == STATE_PLAYER)
						{
							linkShape.doubleClickEnabled = true;
							linkShape.addEventListener(MouseEvent.DOUBLE_CLICK, onPlayerClick);
							linkShape.addEventListener(MouseEvent.MOUSE_OVER, onPlayerLinkMouseOver);
							linkShape.addEventListener(MouseEvent.MOUSE_OUT, onPlayerLinkMouseOut);
							
						}
						//						checkContentBounds(linkShape.getBounds(_mainCanvas));
						checkContentBounds(GeometryUtil.realRect(linkShape.model));
						break;
					case "Callout":
						var calloutShape:RectCalloutShape;
						switch (xmlList.type.toString())
						{
							case CalloutShape.TYPE_RECT:
								calloutShape = new RectCalloutShape();
								break;
						}
						calloutShape.maintainAspectRatio = false;
						calloutShape.properties = xmlList;
						calloutShape.moveOffset(offset_x, offset_y);
						_shapesToShow.push(calloutShape);
						if (_state == STATE_PLAYER) 
						{
							_callouts.push(calloutShape);
							calloutShape.state = STATE_PLAYER;
							
						}
						
						rotateShape(calloutShape);
						calloutShape.model.isLocked = (_state == STATE_PLAYER);
						registerCalloutShape(calloutShape, addToSelection);
						//						checkContentBounds(calloutShape.getBounds(_mainCanvas));
						var shape_rect:Rectangle = GeometryUtil.realRect(calloutShape.model);
						// Leave some space for the title bar.
						shape_rect.x -= 20;
						shape_rect.y -= 25;
						checkContentBounds(shape_rect);
						
						break;
				}
			}
			
			// Re-sort the list according to the layer order 
			// So that the objects can be added to the canvases in the right order
			var layerSort:Sort = new Sort(); 
			layerSort.fields = [new SortField('@order', false, false, true)];
			
			obj_list.sort = layerSort;
			obj_list.refresh();
			
			for each (obj_xml in obj_list)
			{
				var new_obj:Object = _objHandles.getDisplayForModel(_objHandles.modelList[obj_xml.@id]);
				if (new_obj != null) 
				{
					var layer_canvas:Canvas;
					switch (obj_xml.@layer.toString())
					{
						case "main":
							layer_canvas = _mainCanvas;
							layer_canvas.addChild(new_obj as DisplayObject);
							new_obj.displayAlpha = obj_xml.@alpha;
							break;
						case "lower":
							layer_canvas = _lowCanvas;
							layer_canvas.addChild(new_obj as DisplayObject);
							new_obj.displayAlpha = obj_xml.@alpha;
							break;
					}
				}
			}
		}
		
		private function addShapeEventListener(obj:Object):void
		{
			with (obj)
			{
				addEventListener(MouseEvent.CLICK, onPlayerClick);
				addEventListener(MouseEvent.MOUSE_OVER, onPlayerShapeMouseOver);
				addEventListener(MouseEvent.MOUSE_OUT, onPlayerShapeMouseOut);
				doubleClickEnabled = true;
				
				
				if (hasOwnProperty("URL") && URL.length > 0){
	//				var glow_filter:GlowFilter = new GlowFilter(0x0033ff, 0.9, 0, 0, 4, 1, false, false);
//					filters.push(glow_filter);
//					filters.splice(0,0,glow_filter);
//					var seq:Sequence = FilterUtility.generateZoomInOutFilter();
//					seq.target = obj;
//					seq.repeatCount = 0;
//					_playableFilter.push(seq);
//					seq.play();
//					FilterUtility.makeRaisedButton(obj);
					FilterUtility.makeButton(obj);
				}  else {
					useHandCursor = false;
				}
				mouseChildren = false;
				buttonMode = true;
			}
		}
		
		public function swapSelection():void
		{
			switch (_objHandles.selectionManager.currentlySelected.length)
			{
				case 1: // Swap from/to if it is link
					var link_obj:LinkComponent =  _objHandles.getDisplayForModel(_objHandles.selectionManager.currentlySelected[0]) as LinkComponent;
					if (link_obj == null) return;
					var tmp_obj:BasicShape = link_obj.linkFrom;
					link_obj.linkFrom = link_obj.linkTo;
					link_obj.linkTo = tmp_obj;
					break;
				case 2: // Swap position and links if it is two shapes
					var source_obj:BasicShape = _objHandles.getDisplayForModel(_objHandles.selectionManager.currentlySelected[0]) as BasicShape;
					var dest_obj:BasicShape = _objHandles.getDisplayForModel(selectionManager.currentlySelected[1]) as BasicShape;
					
					if (source_obj == null || dest_obj == null) return; // Both should be BasicShape
					
					var model_tmp:BasicShapeModel = new BasicShapeModel();
					
					// Swap models
					model_tmp.copy(source_obj.model);
					source_obj.model.copy(dest_obj.model);
					dest_obj.model.copy(model_tmp);
					source_obj.adjustToModel();
					dest_obj.adjustToModel();
					
					// Swap texts
					var tmp_shape_label:String = new String();
					tmp_shape_label = source_obj.shapeLabel.valueOf();
					source_obj.shapeLabel = dest_obj.shapeLabel;
					dest_obj.shapeLabel = tmp_shape_label;
					
					// Swap links
					var link_from_source:Array = getRelatedLinks(source_obj, 1);
					var link_from_dest:Array = getRelatedLinks(dest_obj, 1);
					var link_to_source:Array = getRelatedLinks(source_obj, 2);
					var link_to_dest:Array = getRelatedLinks(dest_obj, 2);
					
					replaceLinkObjAll(link_from_source, dest_obj, 0);
					replaceLinkObjAll(link_from_dest, source_obj, 0);
					replaceLinkObjAll(link_to_source, dest_obj, 1);
					replaceLinkObjAll(link_to_dest, source_obj, 1);
					clearSelection();
					
					// Swap the order in the model list array
					var source_index:int = objectHandles.modelList.indexOf(source_obj.model);
					var dest_index:int = objectHandles.modelList.indexOf(dest_obj.model);
					objectHandles.modelList.splice(source_index, 1, dest_obj.model);
					objectHandles.modelList.splice(dest_index, 1, source_obj.model);
					
					// Add them back to selection
					selectionManager.addToSelected(source_obj.model);
					selectionManager.addToSelected(dest_obj.model);
					break;
				default:
					return;
			}
			keepRecord();
		}
		
		/**
		 * Replace an object connected to link with the given one
		 * 
		 * mode: 0: replace "from" object;
		 *       1: replace "to" object
		 * 
		 */
		protected function replaceLinkObj(link:LinkComponent, obj:BasicShape, mode:int):void
		{
			if (mode == 0)
			{
				link.linkFrom = obj;
			} else
			{
				link.linkTo = obj;				
			}
		}
		
		/**
		 * Replace objects connected to links with the given one
		 * 
		 * mode: 0: replace "from" object;
		 *       1: replace "to" object
		 * 
		 */
		protected function replaceLinkObjAll(links:Array, obj:BasicShape, mode:int):void
		{
			if (links == null) return;
			while (links.length > 0)
			{
				replaceLinkObj(links.pop(), obj, mode);
			}
		}
		
		public function get backgroundColor():Object
		{
			return _backgroundColor;
		}
		
		public function set backgroundColor(bk_color:Object):void
		{
			if (bk_color == null) return;
			_backgroundColor = bk_color;
			_bkColor = bk_color;
			if (state == STATE_PLAYER) _parent.setBackgroundColor(bk_color);
			_bkCanvas.setStyle("backgroundColor", bk_color);
		}

		public function newDiagram():void
		{
			selectAll();
			deleteSelection();
			_layers.reset();
			_changed = false;
			fileName = "";
		}
		
		private function notifyParentContentChange():void
		{
			_parent.dispatchEvent(new ViewEvent(ViewEvent.CONTENT_CHANGED));
		}
		
		public function ifChanged():Boolean
		{
			return _changed;	
		}
		
		public function clearChangeFlag():void
		{
			_changed = false;
		}
		
		public function groupSelection():void
		{
			grouper.groupObjects(selectionManager.currentlySelected);
		}
		
		public function ungroupSelection():void
		{
			grouper.ungroupObjects(selectionManager.currentlySelected);
		}
		
		public function addGroupToSelection(group:Group):void
		{
			for each (var group_obj:Object in group.getAllObjects())
			{
				selectionManager.addToSelected(group_obj);
			}
		}
		
		public function getCalloutInGroup(group:Group, include_subgroup:Boolean=false):Array
		{
			var callouts_in_group:Array = new Array();
			for each (var group_obj:GroupElement in group.getAllLeaves(null, null, false))
			{
				var shape_obj:Object = getDisplayForModel(group_obj.object as BasicShapeModel);
				if (shape_obj is RectCalloutShape) callouts_in_group.push(shape_obj);
			}
			return callouts_in_group;
		}
		
		public function addObjGroupToSelection(obj:BasicShapeModel):void
		{
			addGroupToSelection(grouper.topGroup(obj));
		}
		
		public function loadGroups(grouper_xml:XMLList):void
		{
			for each (var group_xml:XML in grouper_xml.group)
			{
				clearSelection();
				var group_xml_list:XMLList = new XMLList(group_xml);
				for each (var element_xml:XML in group_xml_list.element)
				{
					if (element_xml.isLeaf[0] == "true") 
					{
						var shape_obj:Object = getShape(element_xml.objID);
						if (shape_obj is RectCalloutShape) {
							selectionManager.addToSelected(RectCalloutShape(shape_obj).bodyModel);
						} else {
							selectionManager.addToSelected(shape_obj.model);
						}
					} else
					{
						addGroupToSelection(grouper.getGroupByID(element_xml.groupID));
					};
				}
				groupSelection();
				clearSelection();
			}
		}
		
		public function loadLayers(layers_xml:XMLList):void
		{
			_layers.reset();
			for each (var layer_xml:XML in layers_xml.layer)
			{
				var layer_xml_list:XMLList = new XMLList(layer_xml);
				var new_layer:Layer = _layers.addLayer();
				new_layer.label = layer_xml_list.label;
				new_layer.description = layer_xml_list.description;
				new_layer.elementsString = layer_xml_list.elements;
				var objects:Array = [];
				var elements_str:String = layer_xml_list.elements;
				var elements:Array = elements_str.split(/,/);
				for each (var element_str:String in elements)
				{
					if (element_str.length > 0)
					{
						objects.push(getModelByID(int(element_str)));
					}
				}
				_layers.addObjects(objects, [int(layer_xml.@id)]);
			}
		}
		
		public function get processList():XMLList
		{
			var return_value:XMLList = new XMLList("<process_list></process_list>");
			var links_xml:XMLListCollection = new XMLListCollection(_lastXML.object.(@type=="Link").relationship);
			
			var sort:Sort = new Sort();
			sort.fields = [new SortField(null, false, false, false)];
			
			links_xml.sort = sort;
			links_xml.refresh();

			var last_link_name:String = "";
			for each (var link:XML in links_xml)
			{
				if (link.toString() != last_link_name)
				{
					last_link_name = link.toString();
					return_value.appendChild(new XML("<relationship name=\"" + last_link_name +
						"\"/>"));
				}
			}
			return return_value;
		}
		
		public function showLayers(layers_to_show:Array):void
		{
			_activeLayers = layers_to_show;
			showAllObjects(true, true, false);
			for (var i:int=1; i < _shapesToShow.length; i++)
			{
				var a_shape:Object = _shapesToShow[i];
				if (a_shape.hasOwnProperty("visible") && a_shape.visible == false)
				{
					if (a_shape is RectCalloutShape && _showCallouts && !layers.isObjectLayered(a_shape))
					{
						ShowHideEffects.showFadeIn(a_shape);
					}	else
					{
						for each (var layer_id:int in layers_to_show)
						{
							var layer:Layer = _layers.layers[layer_id] as Layer;
							if (layer != null && layer.hasElementID(i, !(_state == STATE_PLAYER))) {
								if (a_shape is RectCalloutShape)
								{
									if (_showCallouts) ShowHideEffects.showFadeIn(a_shape);
								}  else {
									ShowHideEffects.showFadeIn(a_shape);
								} 
//								if (a_shape is LinkComponent)
//								{
//									if (PhysiologicalPathwayDiagram(this) != null)
//									{
//										PhysiologicalPathwayDiagram(this).glowObjects([a_shape]);
//									}
//								}
							}
						}
					}
				}
			}
		}
		
		public function shapeInActiveLayers(shape:Object):Boolean
		{
			if (layers.layers.length == 0) return false;
			for each (var layer_number:int in activeLayers) 
			{
				if (layers.layers[layer_number].hasObject(shape))
				{
					return true;
				}
			}
			return false;
		}
		
		protected function showAllObjects(if_visible:Boolean=true, checkLayers:Boolean=false, includeCallouts:Boolean=true):void
		{
			for each (var shape:Object in _shapesToShow)
			{
				if (shape != null && shape.hasOwnProperty("visible"))
				{
					shape.visible = if_visible;
					if (checkLayers && if_visible && shape.hasOwnProperty("model")) 
					{
						if (_layers.isObjectLayered(shape.model))
						{
							ShowHideEffects.hideFadeOut(shape);
							shape.visible = false;
						}	
					} 
				}
				if (!includeCallouts && (shape is RectCalloutShape))
				{
					ShowHideEffects.hideFadeOut(shape);
					shape.visible = false;
				}
			}
		}	
		
		protected function loadLayerGroups(layer_groups:XMLList):void
		{
			_layerGroups = layer_groups;
			for each (var layer_group:XML in layer_groups.layer_group)
			{
				for each (var layer_ele:XML in layer_group.layer)
				{
					if (layer_ele.localName() == "layer") layer_ele.@label = Layer(layers.layers[layer_ele.@ref_layer]).label;
				}
			}
		}
			
		public function get layerGroups():XMLList
		{
			return _layerGroups;
		}
		
		public function getShapeCallout(shape:BasicShape):CalloutShape
		{
			var shape_group:Group = grouper.directGroup(shape.model);
			if (shape_group == null) return null;
			var callout_array:Array = getCalloutInGroup(shape_group, false);
			if (callout_array == null || callout_array.length < 1) return null;
			return callout_array[0];
		}
		
		public function getDisplayForModel(model_obj:BasicShapeModel):Object 
		{
			if (model_obj == null) return null;
			for each (var display_obj:Object in _shapesToShow)
			{
				if (display_obj.hasOwnProperty("model") && display_obj.model == model_obj) return display_obj;
				if (display_obj.hasOwnProperty("_bodyModel") && display_obj._bodyModel == model_obj) return display_obj;
			}
			return null;
		}
		
		public function deleteLayer(layer_id:int):int
		{
			return layers.removeLayer(layer_id);
		}
		
		public function addLayer():Layer
		{
			return layers.addLayer();
		}
		
		public function selectLayer(layer_id:int):void
		{
			var selected_layer:Layer = layers.layers[layer_id];
			for each (var obj:Object in selected_layer.getAllObjects())
			{
				selectionManager.addToSelected(obj);
			}
		}
		
		private function switchDesignMode(new_mode:String):void
		{
			if (_designerMode == DESIGNER_DIAGRAM_MODE) 
			{
				if (new_mode == DESIGNER_LAYER_MODE)
				{
					clearSelection();
					_designerMode = new_mode;
					_objHandles.enableToggleMode();
				}
			} else if (_designerMode == DESIGNER_LAYER_MODE)
			{
				if (new_mode == DESIGNER_DIAGRAM_MODE)
				{
					clearSelection();
					_designerMode = new_mode;
					_objHandles.disableToggleMode();
				}
			}
		}
		
		public function editLayer(layer_id:int):void
		{
			switchDesignMode(DESIGNER_LAYER_MODE);
			selectLayer(layer_id);
			_layerEditing = layer_id;
		}
		
		public function finishEditLayer():void
		{
			if (_designerMode != DESIGNER_LAYER_MODE) return;
			layers.setObjects(selectionManager.currentlySelected, [_layerEditing]);
			_layerEditing = -1;
			switchDesignMode(DESIGNER_DIAGRAM_MODE);
		}
		
		public function get dragSelectionEnabled():Boolean
		{
			if (_designerMode == DESIGNER_LAYER_MODE) return false;
			return true;
		}
		
		private function refreshShapesToShow():void 
		{
			
		}
		
		public function getLinkGroups(group_index:int):XML
		{
			return XMLList(links).link_group[group_index];
		}
	}
}