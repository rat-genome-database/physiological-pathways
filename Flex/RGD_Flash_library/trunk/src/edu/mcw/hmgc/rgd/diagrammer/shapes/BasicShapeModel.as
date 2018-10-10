package edu.mcw.hmgc.rgd.diagrammer.shapes
{
	import com.roguedevelopment.objecthandles.IMoveable;
	import com.roguedevelopment.objecthandles.IResizeable;
	import com.roguedevelopment.objecthandles.ObjectHandles;
	
	import edu.mcw.hmgc.rgd.utils.XMLUtils;
	
	import flash.geom.Rectangle;
	
	public class BasicShapeModel implements IResizeable, IMoveable
	{
		public static const TYPE_NORMAL:String = new String("normal");
		public static const TYPE_POINT:String = new String("point");
		
		public static var object_handles:ObjectHandles;
		
		[Bindable] public var x:Number = 10;
		[Bindable] public var y:Number  = 10;
		[Bindable] public var width:Number = 50;
		[Bindable] public var height:Number = 50;
		[Bindable] public var rotation:Number = 0;
		[Bindable] public var isLocked:Boolean = false;
		public var type:String = TYPE_NORMAL;
		
		public function get properties():XMLList
		{
			var xml_str:String = new String();
			
			xml_str += XMLUtils.getXML("x", Math.round(x).toString());
			xml_str += XMLUtils.getXML("y", Math.round(y).toString());
			xml_str += XMLUtils.getXML("width", Math.round(width).toString());
			xml_str += XMLUtils.getXML("height", Math.round(height).toString());
			xml_str += XMLUtils.getXML("rotation", rotation.toString());
//			xml_str += "<y>" + y.toString() + "</y>";
//			xml_str += "<width>" + width.toString() + "</width>";
//			xml_str += "<height>" + height.toString() + "</height>";
//			xml_str += "<rotation>" + rotation.toString() + "</rotation>";
 			
			return new XMLList(xml_str);
		}
		
		public function set properties(value:XMLList):void
		{
			x = value.x;
			y = value.y;
			width = value.width;
			height = value.height;
			rotation = value.rotation;
		}
		
		public function get index():int
		{
			return object_handles.modelList.indexOf(this);
		}
		
		public function union(another:BasicShapeModel):BasicShapeModel
		{
			var rect1:Rectangle = new Rectangle(x, y, width, height);
			var rect2:Rectangle = new Rectangle(another.x, another.y, another.width, another.height);
			var rect3:Rectangle = rect1.union(rect2);
			var return_value:BasicShapeModel = new BasicShapeModel();
			return_value.x = rect3.x;
			return_value.y = rect3.y;
			return_value.width = rect3.width;
			return_value.height = rect3.height;
			return_value.rotation = rotation;
			return_value.isLocked = isLocked;
			return return_value;
		}
		
		public function moveOffset(offset_x:Number, offset_y:Number):void
		{
			x += offset_x;
			y += offset_y;
		}
		
		public function copy(source_model:BasicShapeModel):void
		{
			x = source_model.x;
			y = source_model.y;
//			width = source_model.width;
//			height = source_model.height;
			rotation = source_model.rotation;
			isLocked = source_model.isLocked;
		}
	}
}