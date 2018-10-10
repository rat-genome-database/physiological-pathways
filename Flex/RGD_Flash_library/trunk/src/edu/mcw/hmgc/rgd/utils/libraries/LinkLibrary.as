package edu.mcw.hmgc.rgd.utils.libraries
{
	import com.degrafa.Surface;
	import com.degrafa.geometry.RasterText;
	
	import edu.mcw.hmgc.rgd.bio.Relationship;
	import edu.mcw.hmgc.rgd.diagrammer.links.LinkComponent;
	import edu.mcw.hmgc.rgd.diagrammer.shapes.BasicShape;
	import edu.mcw.hmgc.rgd.diagrammer.shapes.BasicShapeModel;
	import edu.mcw.hmgc.rgd.ui.controls.Canvas;
	import edu.mcw.hmgc.rgd.utils.Configurations;
	import edu.mcw.hmgc.rgd.utils.FileLoader;
	import edu.mcw.hmgc.rgd.utils.events.FileEvent;
	import edu.mcw.hmgc.rgd.utils.events.LibraryEvent;
	
	import mx.controls.Text;
	import mx.core.Application;
	
	public class LinkLibrary
	{
		
		public static const REMOTE_SOURCE:String = "remote";
		public static const MANUAL_SOURCE:String = "manual";
		public static const LOCAL_SOURCE:String = "local"
		
		public static var oriX:Number = 0;
		public static var linkLength:Number = 100;
		public static var oriY:Number = 20;
		public static var yStep:Number = 40;
		public static var textOffsetX:Number = 5;
		public static var textOffsetY:Number = -5;
			
		private static var _parent:Application;
		
		
		private static var _linkList:XML;
		
		public function LinkLibrary(application:Application)
		{
			_parent = application;
			var fileLoader:FileLoader = new FileLoader(_parent, Configurations.PATH + "link_list.xml", onListReady);
		}
		
		public static function onListReady():void {
			_parent.removeEventListener(FileEvent.FILE_READY, onListReady);
			_parent.dispatchEvent(new LibraryEvent(LibraryEvent.LINK_LIBRARY_READY));
		}
		
		public static function drawAllLinks(surface:Surface, canvas:Canvas, relationship_list:XMLList=null):void
		{
			var x:Number = oriX;
			var y:Number = oriY;
			var array:Array = [];
			
			var max_text_width:Number = 0;
			if (relationship_list == null) relationship_list = Relationship.types;
			
			for each (var link_type:XML in relationship_list.relationship)
			{
				var link_type_label:String = link_type.@label;
				if (link_type_label == null || link_type_label.length == 0)
				{
					link_type_label = Relationship.getLabel(link_type.@name);
				}
				// Skip drawing the process if it starts with '-'
				if (link_type_label.charAt() == '-') continue;
				var text:Text = new Text();
				text.x = x + linkLength + textOffsetX;
				text.y = y + textOffsetY;
				text.text = link_type_label;
//				text.
//				text.textColor = 0x000000;
//				text.s .size = 16;
//				text.graphicsTarget = [surface];
//				array.push(text);
				text.setStyle("fontSize", "12");
				canvas.addChild(text);
				var measured_width:Number = text.measureText(link_type_label).width;
				if (max_text_width < measured_width) max_text_width = measured_width;

				var from:BasicShape = new BasicShape();
				var model:BasicShapeModel = new BasicShapeModel();
				from.model = model;
				from.model.x = x;
				from.model.y = y;
				from.model.width = 10;
				from.model.height = 10;
				from.adjustToModel();
				from.width = from.model.width;
				from.height = from.model.height;
				
				var to:BasicShape = new BasicShape();
				model = new BasicShapeModel();
				to.model = model;
				to.model.x = x + linkLength;
				to.model.y = y;
				to.model.width = 10;
				to.model.height = 10;
				to.adjustToModel();
				to.width = to.model.width;
				to.height = to.model.height;
				
				y += yStep;
				var link:LinkComponent = new LinkComponent(from, to);
				surface.graphicsCollection.addItem(link);
				link.target = surface;
				link.relationship = link_type.@name;
				link.move(link.controlPoint.x, link.controlPoint.y - 5);
			}
			canvas.width = max_text_width + oriX + linkLength + textOffsetX + 10;
			canvas.parent.width = canvas.width + 10;
		}
	}
}