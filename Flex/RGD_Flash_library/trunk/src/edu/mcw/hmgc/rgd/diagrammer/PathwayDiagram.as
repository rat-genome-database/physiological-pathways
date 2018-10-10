package edu.mcw.hmgc.rgd.diagrammer
{
	import edu.mcw.hmgc.rgd.bio.Gene;
	import edu.mcw.hmgc.rgd.bio.Relationship;
	import edu.mcw.hmgc.rgd.diagrammer.links.LinkComponent;
	import edu.mcw.hmgc.rgd.diagrammer.shapes.BasicShape;
	
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import mx.binding.utils.BindingUtils;
	import mx.binding.utils.ChangeWatcher;
	import mx.controls.ToolTip;
	import mx.effects.Glow;
	import mx.managers.ToolTipManager;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.StyleManager;

	public class PathwayDiagram extends Diagram
	{
		private var _watcher1:ChangeWatcher;
		private var _toolTipStr:String;
		private var _toolTipPt:Point;
		private var _toolTipSize:Point;
		private var _rgdID:int;
		private var _gene:Gene = null;
		
		private var _scale:Number = 1;
		public function set scale(value:Number):void
		{
			_scale = value;
		}
		
		public function PathwayDiagram(par_obj:Object)
		{
			var style:CSSStyleDeclaration = StyleManager.getStyleDeclaration(".errorTip");
			style.setStyle("fontSize", "16");
			style.setStyle("borderColor", "#151B54");
			style.setStyle("backgroundColor", "#858Bd4");
			style.setStyle("borderStyle", "solid");
			style.setStyle("borderThickness", "3");
			style.setStyle("shadowColor", "#ff0000"); 
//			style.setStyle("dropShadowColor", "#959BD4"); 
			style.setStyle("shadowDistance", "20"); 
			
			style.setStyle("backgroundAlpha", ".8"); 
			style.setStyle("color", "white");
			super(par_obj);
		}
	
		protected override function onPlayerClick(event:MouseEvent):void
		{
			var obj_type:String = event.currentTarget.type;
			if (obj_type == "gene" || obj_type == "receptors" || obj_type == "ligands" 
				|| obj_type == "transcriptionfactor")
			{
				var shape:BasicShape = event.currentTarget as BasicShape;
//				var URL_str:String = new String("http://rgddev.mcw.edu/rgdweb/search/genes.html?term=");
//				URL_str += shape.Text;
//				URL_str += "&speciesType=0";
				var URL_str:String = new String("http://rgddev.mcw.edu/tools/genes/genes_view.cgi?id=");
				URL_str += _rgdID;				
				navigateToURL(new URLRequest(URL_str), '_blank');

			}
			//			Alert.show("target: " + event.currentTarget);
		}
		
		protected override function onPlayerLinkMouseOver(event:MouseEvent):void
		{
			var link_shape:LinkComponent = event.target as LinkComponent;
			var pt:Point = new Point(link_shape.controlPoint.x, link_shape.controlPoint.y);
			pt = mainCanvas.localToGlobal(pt);

			// Convert the targets 'local' coordinates to 'global' -- this fixes the
			// tooltips positioning within containers.
			var tooltip_str:String = Relationship.types.relationship.(@name == link_shape.relationship).@label;
			_singleToolTip = ToolTipManager.createToolTip(tooltip_str, pt.x, pt.y, "errorTipAbove") as ToolTip;
			setToolTipStyle();
			
			_singleToolTip.x -= 15;
			_singleToolTip.y -= (_singleToolTip.height + 5 * _scale);
			if (_singleToolTip.y < 2) {
				ToolTipManager.destroyToolTip(_singleToolTip);
				_singleToolTip = ToolTipManager.createToolTip(tooltip_str, pt.x, pt.y, "errorTipBelow") as ToolTip;
				setToolTipStyle();
				_singleToolTip.x -= 15;
				_singleToolTip.y += 5 * _scale;
			}
			var glow_objs:Array = [link_shape, link_shape.linkFrom, link_shape.linkTo];
			glowObjects(glow_objs);
		}
		
		protected override function onPlayerLinkMouseOut(event:MouseEvent):void
		{
			var link_shape:LinkComponent = event.target as LinkComponent;
			var unglow_objs:Array = [link_shape, link_shape.linkFrom, link_shape.linkTo];
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
			_toolTipPt = new Point(shape.x + shape.width / 4, shape.y);
			_toolTipPt = mainCanvas.localToGlobal(_toolTipPt);
			_toolTipSize = new Point(shape.width, shape.height);
			
			// Convert the targets 'local' coordinates to 'global' -- this fixes the
			// tooltips positioning within containers.
			_toolTipStr = event.currentTarget.type;
			
//			_singleToolTip.y -= (_singleToolTip.height - 5);
			_gene = new Gene();
			_gene.symbol = shape.Text;
			_gene.getInfo();
			//_watcher = BindingUtils.bindProperty(_singleToolTip, "text", gene, "description");
			_watcher1 = BindingUtils.bindSetter(setRGDID, _gene, "rgdID");
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
				
				setToolTipStyle();
				_singleToolTip.y -= ((_singleToolTip.height - _scale * 5));
				
				if (_singleToolTip.y < 2) {
					ToolTipManager.destroyToolTip(_singleToolTip);
					_singleToolTip = ToolTipManager.createToolTip(_toolTipStr, _toolTipPt.x, _toolTipPt.y, "errorTipBelow") as ToolTip;
					setToolTipStyle();
					_singleToolTip.y += (_scale * _toolTipSize.y);
				}
			}
		}
		
		protected override function onPlayerShapeMouseOut(event:MouseEvent):void
		{
			if (_watcher1 != null)
			{
				_watcher1.unwatch();
				_watcher1 = null;
			}
			if (_singleToolTip != null)
			{
				ToolTipManager.destroyToolTip(_singleToolTip);
				_singleToolTip = null;
			}
		}
	
		protected function glowObjects(objs:Array):void
		{
			var glower:Glow = new Glow();
			glower.duration = 1;
			glower.alphaFrom = 0;
			glower.alphaTo = 1;
			glower.blurXFrom = 0;
			glower.blurXTo = 20;
			glower.blurYFrom = 0;
			glower.blurYTo = 20;
			glower.strength = 2;
			glower.color = 0x007F00;
			glower.targets = objs;
			glower.play();
		}
		
		protected function unglowObjects(objs:Array):void
		{
			var glower:Glow = new Glow();
			glower.duration = 50;
			glower.alphaFrom = .5;
			glower.alphaTo = 0;
			glower.blurXFrom = 0;
			glower.blurXTo = 10;
			glower.blurYFrom = 0;
			glower.blurYTo = 10;
			glower.strength = 2;
			glower.color = 0x007F00;
			glower.targets = objs;
			glower.play();
		}
		
//		private const _toolTipBkColor:String = "#151B54"; 
		
		protected function setToolTipStyle():void
		{
//			_singleToolTip.setStyle("fontSize", "16");
		}
	}
}