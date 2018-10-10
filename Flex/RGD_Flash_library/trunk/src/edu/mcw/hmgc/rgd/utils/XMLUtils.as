package edu.mcw.hmgc.rgd.utils
{
	public class XMLUtils
	{
		public function XMLUtils()
		{
		}
		
		public static function getXML(key:String, value:*):String
		{
			if (value == null) value = new String();
			return "<" + key + ">" + value.toString() + "</" + key + ">";
		}

		public static function getHtmlXML(key:String, value:*):String
		{
			if (value == null) value = new String();
			return "<" + key + "><![CDATA[" + value.toString() + "]]></" + key + ">";
		}
		
		public static function getNormalizedXML(original_str:String):String
		{
			var xml_tmp:XML = new XML("<test htmltext=\"\"/>");
			xml_tmp.@htmltext = original_str;
			return xml_tmp.@htmltext.toXMLString();
		}

		public static function getUnNormalizedXML(original_str:String):String
		{
			var xml_tmp:XML = new XML("<test htmltext=\"" + original_str + "\"/>");
			return xml_tmp.@htmltext as String;
		}
	}
}