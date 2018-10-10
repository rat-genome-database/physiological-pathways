package edu.mcw.hmgc.rgd.diagrammer.shapes
{
	import com.roguedevelopment.objecthandles.IMoveable;
	import com.roguedevelopment.objecthandles.ObjectHandles;
	
	import edu.mcw.hmgc.rgd.utils.XMLUtils;
	
	public class BasicPointModel implements IMoveable
	{

		public static const TYPE_NORMAL:String = new String("normal");
		
		public static var object_handles:ObjectHandles;
		
		[Bindable] public var x:Number = 10;
		[Bindable] public var y:Number  = 10;
//		[Bindable] public var width:Number = 50;
//		[Bindable] public var height:Number = 50;
//		[Bindable] public var rotation:Number = 0;
		[Bindable] public var isLocked:Boolean = false;
		public var type:String = TYPE_NORMAL;
		
		public function get properties():XMLList
		{
			var xml_str:String = new String();
			
			xml_str += XMLUtils.getXML("x", x.toString());
			xml_str += XMLUtils.getXML("y", y.toString());
//			xml_str += XMLUtils.getXML("width", width.toString());
//			xml_str += XMLUtils.getXML("height", height.toString());
//			xml_str += XMLUtils.getXML("rotation", rotation.toString());
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
//			width = value.width;
//			height = value.height;
//			rotation = value.rotation;
		}
		
		public function get index():int
		{
			return object_handles.modelList.indexOf(this);
		}
		
		
		public function BasicPointModel()
		{
		}
	}
}