package edu.mcw.hmgc.rgd.utils.events
{
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	public class FileEvent extends Event
	{
		public static const FILE_READY:String = "file_ready";
		public static const FILE_SAVED:String = "file_saved";
		public static const FILE_FAILED:String = "file_failed";
		private var _data:ByteArray;
		private var _url:String;
		private var _fileName:String;
		
		public function FileEvent(type:String, file_url:String, data:ByteArray, bubbles:Boolean=false, cancelable:Boolean=false, file_name:String="")
		{
			_data = data;
			_url = file_url;
			_fileName = file_name;
			super(type, bubbles, cancelable);
		}
		
		public function get data():ByteArray
		{
			return _data;
		}
		
		public function get url():String
		{
			return _url;
		}
		
		public function get fileName():String
		{
			return _fileName;
		}
	}
}
