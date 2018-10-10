package edu.mcw.hmgc.rgd.utils
{
	import flash.events.TextEvent;

	public class StrUtil
	{
		public function StrUtil()
		{
		}
		
		static public function getToken(value:String, delim:String = "_", pos:int = 0):String
		{
			var tokens:Array = value.split(delim);
			return tokens[pos];
		}
		
		static public function getURLfromHTML(value:String):String
		{
			var re:RegExp = new RegExp("<A HREF=\"(.*?)\" TARGET=\"_blank\">", "");
			var result:Object = re.exec(value);
			if (result == null) return "";
			return (result[1] as String);
		}
		
		static public function getDiagramNameFromURL(value:String):String
		{
			return getURLObject(value);
		}
		
		static public function getURLObject(value:String):String
		{
			var re:RegExp = new RegExp(".*\/\/(.*)", "");
			var result:Object = re.exec(value);
			if (result == null) return "";
			return (result[1] as String);
		}
		
		static public function getURLType(value:String):String
		{
			var re:RegExp = new RegExp("(.*):\/\/.*", "");
			var result:Object = re.exec(value);
			if (result == null) return "";
			return (result[1] as String);
		}
		
		static public function addLinkEvent(value:String, obj:Object=null):String
		{
//			var refPattern:RegExp = /<A HREF="HTTP:\/\//gi;
			var refPattern:RegExp = /<A HREF="/gi;
			if (obj != null) obj.addEventListener(TextEvent.LINK, labelLinkHandler);
//			return value.replace(refPattern, '<A HREF="event:http://');
			return value.replace(refPattern, '<A HREF="event:');
		}
		
		static protected function labelLinkHandler(event:TextEvent):void
		{
			//				Alert.show("url clicked", event.text);
			WEBUtils.processURL(event.text, event);
		}
	}
}