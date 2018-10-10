package edu.mcw.hmgc.rgd.diagrammer
{
	import edu.mcw.hmgc.rgd.bio.Gene;
	import edu.mcw.hmgc.rgd.bio.Relationship;
	import edu.mcw.hmgc.rgd.diagrammer.events.InnerDiagramEvent;
	import edu.mcw.hmgc.rgd.diagrammer.links.LinkComponent;
	import edu.mcw.hmgc.rgd.diagrammer.shapes.BasicShape;
	import edu.mcw.hmgc.rgd.diagrammer.shapes.CalloutShape;
	import edu.mcw.hmgc.rgd.diagrammer.shapes.PNGShape;
	import edu.mcw.hmgc.rgd.diagrammer.shapes.RectCalloutShape;
	import edu.mcw.hmgc.rgd.diagrammer.shapes.SVGShape;
	import edu.mcw.hmgc.rgd.graphics.ShowHideEffects;
	import edu.mcw.hmgc.rgd.graphics.TitleToolTip;
	import edu.mcw.hmgc.rgd.utils.StrUtil;
	import edu.mcw.hmgc.rgd.utils.WEBUtils;
	import edu.mcw.hmgc.rgd.utils.grouping.Layer;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BitmapFilterType;
	import flash.filters.GradientGlowFilter;
	import flash.geom.Point;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import mx.binding.utils.BindingUtils;
	import mx.binding.utils.ChangeWatcher;
	import mx.controls.Alert;
	import mx.controls.Text;
	import mx.controls.ToolTip;
	import mx.core.Application;
	import mx.effects.Fade;
	import mx.effects.Glow;
	import mx.events.EffectEvent;
	import mx.managers.ToolTipManager;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.StyleManager;
	
	public class PhysiologicalPathwayDiagram extends Diagram
	{
		private var _watcher1:ChangeWatcher;
		private var _toolTipStr:String;
		private var _toolTipPt:Point;
		private var _toolTipSize:Point;
		private var _rgdID:int;
		private var _gene:Gene = null;
		private var _calloutShowing:CalloutShape = null;
		private var _titleToolTip:TitleToolTip = new TitleToolTip();
		private var _fadeOut:Fade = new Fade();
		private var _fadePausing:Boolean = false;
//		private var _glower:GradientGlowFilter = new GradientGlowFilter(2, 45, [0x007F00, 0x007F00],
//			[0, 1], [0, 255], 16, 16, 2, BitmapFilterQuality.MEDIUM, BitmapFilterType.OUTER, false);
		private var _glower:Glow = new Glow();
		private var _unglower:Glow = new Glow();
		
		private var _mouseOverObj:Object = null;
		
		private var _scale:Number = 1;
		public function set scale(value:Number):void
		{
			_scale = value;
		}
		
		public function PhysiologicalPathwayDiagram(par_obj:Object)
		{
			var style:CSSStyleDeclaration = StyleManager.getStyleDeclaration(".errorTip");
			setToolTipStyle(style);
//			_fadeOut.alphaFrom = 1;
			_fadeOut.alphaTo = 0;
			_fadeOut.duration = 1000;
			_fadeOut.addEventListener(EffectEvent.EFFECT_END, clearFadeOutObjects);

			super(par_obj);
		}

		protected override function onPlayerClick(event:MouseEvent):void
		{
			var shape:BasicShape = event.currentTarget as BasicShape;
			if (shape is PNGShape || shape is SVGShape)
			{
				var url:String = shape.URL;
				if (url != null && url.length > 0) 
				{
					WEBUtils.processURL(url, event);
				}
			}
			
//			var obj_type:String = event.currentTarget.type;
//			if (obj_type == "gene" || obj_type == "receptors" || obj_type == "ligands" 
//				|| obj_type == "transcriptionfactor")
//			{
//				var shape:BasicShape = event.currentTarget as BasicShape;
//				//				var URL_str:String = new String("http://rgddev.mcw.edu/rgdweb/search/genes.html?term=");
//				//				URL_str += shape.Text;
//				//				URL_str += "&speciesType=0";
//				var URL_str:String = new String("http://rgddev.mcw.edu/tools/genes/genes_view.cgi?id=");
//				URL_str += _rgdID;				
//				navigateToURL(new URLRequest(URL_str), '_blank');
//				
//			}
			//			Alert.show("target: " + event.currentTarget);
		}
		
		protected function clearFadeOutObjects(event:EffectEvent=null):void
		{
			_fadeOut.stop();
			_fadePausing = false;
			if (_fadeOut.targets == null) return;
			for each (var obj:Object in _fadeOut.targets)
			{
				ShowHideEffects.hideFadeOut(obj);
			}
			
			if (_calloutShowing != null && !_fadePausing)
			{
//				_calloutShowing.removeMouseOverHandler(holdTitleToolTip);
//				_calloutShowing.removeMouseOutHandler(fadeOutTitleToolTip);
			}

		}
		
		protected override function onPlayerLinkMouseOver(event:MouseEvent):void
		{
			removeEventListernersFromTooltips();
			
			mouseOverLink(event.target as LinkComponent);
		}
		
		public function mouseOverLink(link_shape:LinkComponent):void
		{
			_mouseOverObj = link_shape;
			var tooltip_str:String = Relationship.types.relationship.(@name == link_shape.relationship).@label;
			_calloutShowing = findCallout(link_shape.controlPoint, layers.isObjectLayered(link_shape));
			
			if (_calloutShowing == null && type == "Normal")
			{
				var pt:Point = new Point(link_shape.controlPoint.x, link_shape.controlPoint.y);
				pt = mainCanvas.localToGlobal(pt);
				
				// Convert the targets 'local' coordinates to 'global' -- this fixes the
				// tooltips positioning within containers.
				_singleToolTip = ToolTipManager.createToolTip(tooltip_str, pt.x, pt.y, "errorTipAbove") as ToolTip;
				//setToolTipStyle();
				_singleToolTip.x -= 15;
				_singleToolTip.y -= (_singleToolTip.height + 5 * _scale);
				if (_singleToolTip.y < 2) {
					ToolTipManager.destroyToolTip(_singleToolTip);
					_singleToolTip = ToolTipManager.createToolTip(tooltip_str, pt.x, pt.y, "errorTipBelow") as ToolTip;
					//setToolTipStyle();
					_singleToolTip.x -= 15;
					_singleToolTip.y += 5 * _scale;
				}
			}
			else if (_calloutShowing != null)
			{
				_calloutShowing.alpha = _calloutShowing.displayAlpha;
				if (type == "Normal") {
					addHeaderToCallout(tooltip_str);
				}
				 ShowHideEffects.showFadeIn(_calloutShowing);
				_titleToolTip.addEventListener(MouseEvent.MOUSE_OVER, holdTitleToolTip);
				_titleToolTip.addEventListener(MouseEvent.ROLL_OUT, fadeOutTitleToolTip1);
				_calloutShowing.addMouseOverHandler(holdTitleToolTip);
				_calloutShowing.addMouseOutHandler(fadeOutTitleToolTip1);
			}
			// Not glowing for now. May re-enable this in the future.
//			if ((type == "Normal") || (_calloutShowing != null && type != "Normal"))
				glowObjects([link_shape, link_shape.linkFrom, link_shape.linkTo]);
		}

		protected function addHeaderToCallout(tooltip_str:String):void 
		{
			addTitle();
			var text_width:Number = _titleToolTip.measureText(tooltip_str).width + 14;
			_titleToolTip.titleText.text = tooltip_str;
			if (text_width < _calloutShowing.bodyModel.width)
			{
				_titleToolTip.width = _calloutShowing.bodyModel.width;
				_titleToolTip.x = _calloutShowing.bodyModel.x;
			}
			else
			{
				_titleToolTip.width = text_width;
				_titleToolTip.x = _calloutShowing.bodyModel.x - (_titleToolTip.width - _calloutShowing.bodyModel.width)/2;
			}
			
			_titleToolTip.height = _titleToolTip.titleText.measureText(tooltip_str).height + 8; 
			_titleToolTip.y = _calloutShowing.bodyModel.y - _titleToolTip.height + 2;
			setToolTipStyle(_titleToolTip);
			_titleToolTip.alpha = 1;
			
			//				_titleToolTip.visible = true;
			//				_calloutShowing.visible = true;
			//		Change to fade-in transition
			ShowHideEffects.showFadeIn(_titleToolTip);
		}
		
		protected function holdTitleToolTip(evt:Event=null, shape_only:Boolean=false):void
		{
			_fadePausing = true;
			_fadeOut.stop();
			if (_calloutShowing != null) {
				ShowHideEffects.showFadeIn(_calloutShowing);
			}
			if (_mouseOverObj is RectCalloutShape && _titleToolTip != null && !shape_only) {
				ShowHideEffects.showFadeIn(_titleToolTip);
			}
		}
		
		protected function fadeOutTitleToolTip(evt:Event=null):void
		{
			trace("fading");
			if (showCallouts) {
				_fadeOut.targets = [_titleToolTip];
				
			} else
			{
				_fadeOut.targets = [_calloutShowing, _titleToolTip];
			}
			_fadeOut.play();
			_fadePausing = false;
		}
		
		protected function fadeOutTitleToolTip1(evt:Event=null):void
		{
			trace("fading1:" + evt.target.toString());
			if (showCallouts || _calloutShowing == null) {
				_fadeOut.targets = [_titleToolTip];
				
			} else
			{
				_fadeOut.targets = [_calloutShowing, _titleToolTip];
			}
			_fadeOut.play();
			_fadePausing = false;
		}
		
		protected override function onPlayerLinkMouseOut(event:MouseEvent):void
		{
			if (_calloutShowing != null) 
			{
				fadeOutTitleToolTip();
			}
			var link_shape:LinkComponent = event.target as LinkComponent;
			var unglow_objs:Array = [link_shape, link_shape.linkFrom, link_shape.linkTo];
//			if (shapeInActiveLayers(link_shape)) unglow_objs = [link_shape.linkFrom, link_shape.linkTo];
			
			// Not glowing for now. May re-enable this in the future.
			unglowObjects(unglow_objs);
			
			if (_singleToolTip != null)
			{
				ToolTipManager.destroyToolTip(_singleToolTip);
				_singleToolTip = null;
			}
		}
		
		protected override function onPlayerShapeMouseOver(event:MouseEvent):void
		{
			var shape:BasicShape = event.currentTarget as BasicShape;
			mouseOverShape(shape);
//			_toolTipPt = new Point(shape.x + shape.width / 4, shape.y);
//			_toolTipPt = mainCanvas.localToGlobal(_toolTipPt);
//			_toolTipSize = new Point(shape.width, shape.height);
//			
//			// Convert the targets 'local' coordinates to 'global' -- this fixes the
//			// tooltips positioning within containers.
//			_toolTipStr = event.currentTarget.type;
//			
//			//			_singleToolTip.y -= (_singleToolTip.height - 5);
//			_gene = new Gene();
//			_gene.symbol = shape.Text;
//			_gene.getInfo();
//			//_watcher = BindingUtils.bindProperty(_singleToolTip, "text", gene, "description");
//			_watcher1 = BindingUtils.bindSetter(setRGDID, _gene, "rgdID");
		}

		public function mouseOverShape(shape:BasicShape):void
		{
			var shape_callout:CalloutShape = getShapeCallout(shape);
			if (shape_callout != null)
			{
				_mouseOverObj = shape;
				removeEventListernersFromTooltips();

				_calloutShowing = shape_callout;
				_calloutShowing.alpha = _calloutShowing.displayAlpha;

				if (_calloutShowing.tag.length > 0)
				{
					addHeaderToCallout(_calloutShowing.tag);
				} else
				{
					_titleToolTip.visible = false;
				}
				
				ShowHideEffects.showFadeIn(_calloutShowing);
				_calloutShowing.addMouseOverHandler(holdTitleToolTip);
				_calloutShowing.addMouseOutHandler(fadeOutTitleToolTip1);
			}
		}

		private function removeEventListernersFromTooltips():void
		{
			clearFadeOutObjects();
			if (_titleToolTip != null) {
				_titleToolTip.removeEventListener(MouseEvent.MOUSE_OVER, holdTitleToolTip);
				_titleToolTip.removeEventListener(MouseEvent.ROLL_OUT, fadeOutTitleToolTip1);
			}
			if (_calloutShowing != null) {
				_calloutShowing.removeMouseOverHandler(holdTitleToolTip);
				_calloutShowing.removeMouseOutHandler(fadeOutTitleToolTip);
			}
		}
		
		private function addTitle():void
		{
			if (_titleAdded) return;
			_titleAdded = true;
			tooltipsCanvas.addChild(_titleToolTip);
			ShowHideEffects.hideFadeOut(_titleToolTip);
		}
		
		protected function setRGDID(value:int):void
		{
			if (value == -1) return;
			_rgdID = value;
			if (_gene.description == null || _gene.description == "null" || _gene.description.length<1) 
			{
				
			}
			else
			{
				_toolTipStr += ": " + _gene.description;
				_singleToolTip = ToolTipManager.createToolTip(_toolTipStr, _toolTipPt.x, _toolTipPt.y, "errorTipAbove") as ToolTip;
				
				//setToolTipStyle();
				_singleToolTip.y -= ((_singleToolTip.height - _scale * 5));
				
				if (_singleToolTip.y < 2) {
					ToolTipManager.destroyToolTip(_singleToolTip);
					_singleToolTip = ToolTipManager.createToolTip(_toolTipStr, _toolTipPt.x, _toolTipPt.y, "errorTipBelow") as ToolTip;
					//setToolTipStyle();
					_singleToolTip.y += (_scale * _toolTipSize.y);
				}
			}
		}
		
		protected override function onPlayerShapeMouseOut(event:MouseEvent):void
		{
			if (_calloutShowing != null) 
			{
				fadeOutTitleToolTip();
			}

//			if (_watcher1 != null)
//			{
//				_watcher1.unwatch();
//				_watcher1 = null;
//			}
//			if (_singleToolTip != null)
//			{
//				ToolTipManager.destroyToolTip(_singleToolTip);
//				_singleToolTip = null;
//			}
		}
		
		public function glowObjects(objs:Array):void
		{
//			for each (var obj:Object in objs)
//			{
//				if (obj.hasOwnProperty("filters") && obj.filters != null)
//				{
//					obj.filters.push(_glower);
//				}
//			}
			
//			var glower:Glow = new Glow();
//			_glower.stop();
//			_glower.duration = 1;
//			_glower.play();
			//_glower.targets = [];
			_glower.duration = 1;
			_glower.alphaFrom = 0.2;
			_glower.alphaTo = .6;
			_glower.blurXTo = _glower.blurYTo = 18;
			_glower.blurXFrom = _glower.blurYFrom = 0;
			_glower.strength = 9;
			_glower.color = 0xFFFF;
			if (type != "Normal") _glower.color = 0xFFFF;
			_glower.targets = objs;
			_glower.play();
		}
		
		protected function unglowObjects(objs:Array):void
		{
//			for each (var obj:Object in objs)
//			{
//				if (obj.hasOwnProperty("filters") && obj.filters != null)
//				{
//					obj.filters.pop();
//				}
//			}
			_glower.stop();
			_glower.targets = [];
//			var glower:Glow = new Glow();
			_unglower.duration = 1;
			_unglower.alphaFrom = .8;
			_unglower.alphaTo = 0;
			_unglower.blurXFrom = 0;
			_unglower.blurXTo = 10;
			_unglower.blurYFrom = 0;
			_unglower.blurYTo = 10;
			_unglower.strength = 2;
			_unglower.color = 0xFFFF;
			_unglower.targets = objs;
			_unglower.play();
		}
		
		//		private const _toolTipBkColor:String = "#151B54"; 
		
		protected function setToolTipStyle(style:Object):void
		{
			style.setStyle("fontSize", "14");
			style.setStyle("borderColor", "#151B54");
			style.setStyle("backgroundColor", "#151B54");
			style.setStyle("borderStyle", "solid");
			style.setStyle("borderThickness", "3");
			style.setStyle("shadowColor", "#ff0000"); 
			//			style.setStyle("dropShadowColor", "#959BD4"); 
			style.setStyle("shadowDistance", "20"); 
			
			style.setStyle("backgroundAlpha", ".8"); 
			style.setStyle("color", "white");
		}
		
		protected function findCallout(o_point:Point, check_layer:Boolean=false):CalloutShape
		{
			var min_distance:Number = -1;
			var return_obj:CalloutShape = null;
			for each (var callout:CalloutShape in callouts)
			{
				var callout_in_layer:Boolean = layers.isObjectLayered(callout);
				var callout_in_active_layer:Boolean = shapeInActiveLayers(callout);
				if ((!check_layer && (!callout_in_layer ||(callout_in_layer && callout_in_active_layer))) || (check_layer && callout_in_active_layer)) {
					var distance:Number = Point.distance(o_point, new Point(callout.tailModel.x,
						callout.tailModel.y));
					if (distance < 5 && (min_distance == -1 || min_distance > distance)) 
					{
						min_distance = distance;
						return_obj = callout;
					}
				} 
			}
			return return_obj;
		}
		
		[Bindable]
		override public function set showCallouts(callout_visible:Boolean):void {
			holdTitleToolTip(null, true);
			_showCallouts = callout_visible;
			for each (var callout:CalloutShape in callouts)
			{
				if (!shapeInActiveLayers(callout) && layers.isObjectLayered(callout))
				{
					ShowHideEffects.hideFadeOut(callout);	
				} else
				{
					ShowHideEffects.showHideFade(callout, callout_visible);
				}
			}
			
		}
	}
}