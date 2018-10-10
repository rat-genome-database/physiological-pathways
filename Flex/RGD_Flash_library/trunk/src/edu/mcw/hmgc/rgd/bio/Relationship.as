package edu.mcw.hmgc.rgd.bio
{
	import mx.collections.XMLListCollection;

	public class Relationship
	{
		public static var types:XMLList;
		
		private var _type:String = new String();
		public function get type():String
		{
			return _type;
		}
		public function set type(value:String):void
		{
			_type = value;
			properties = types.relationship.(@name==_type);
		}
		
		static public function getLabel(link_type:String):String
		{
			var link_xml:XMLList = types.relationship.(@name==link_type);
			
			return link_xml[0].@label.toString();
		}
//		private var _linkProperties:XMLList;
//		public function get linkProperties():XMLList
//		{
//			return _linkProperties;
//		}
//		public function set linkProperties(xmllist:XMLList):void
//		{
//			_linkProperties = new XMLList(xmllist);
//		}
//		
		private var _properties:XMLList;
		public function set properties(value:XMLList):void
		{
			_properties = value;
		}
		
		public function Relationship()
		{
		}
		
		public function get linkSetting():XMLList
		{
			return _properties.link_properties;
		}
	}
}