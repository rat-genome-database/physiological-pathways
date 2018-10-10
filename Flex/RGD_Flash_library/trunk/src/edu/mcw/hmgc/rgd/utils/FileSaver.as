package edu.mcw.hmgc.rgd.utils
{
	import edu.mcw.hmgc.rgd.utils.events.FileEvent;
	
	import flash.utils.ByteArray;
	
	import mx.formatters.DateBase;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.RemoteObject;
	
	public class FileSaver
	{
		public static const REMOTE_SOURCE:String = "remote";
		public static const MANUAL_SOURCE:String = "manual";
		public static const LOCATION_REMOTE:String = "remote";
		public static const LOCAL_SOURCE:String = "local"
		
		public static const EVENT_READY:String = "done";
		
		private var _parent:Object;
		
		public var name:String = new String();
		[Bindable]  
		public var _data:ByteArray = new ByteArray();
		public var type:String = new String();
		public var URL:String = new String();
		public var location:String = LOCATION_REMOTE;
		
		private var _requested:Boolean = false;
		
		public function FileSaver(parent:Object, url:String="", data:String=null, onSuccess:Function=null)
		{
			_parent = parent;
			if (onSuccess != null) _parent.addEventListener(FileEvent.FILE_SAVED, onSuccess);
			if (url != null && url.length > 0 && data != null) saveTextFile(url, data);
		}
		
		public function get data():ByteArray {
			return _data;
		}
		
		public function saveFile(url:String, data:ByteArray):void {
			URL = url;
			_data = data;
			switch (location) {
				case LOCATION_REMOTE:
					saveRemote();
					break;
				default:
			}
		}
		
		public function saveTextFile(url:String, data:String):void {
			URL = url;
			var dataByte:ByteArray = new ByteArray();
			dataByte.writeUTFBytes(data);
			saveFile(URL, dataByte);
		}
		
		private function saveRemote():void {
			if (_requested) return;
			var remoteO:RemoteObject = new RemoteObject("CreatingRpc");
			remoteO.SaveFile.addEventListener(ResultEvent.RESULT, onRemoteResult);
			remoteO.addEventListener(FaultEvent.FAULT, onRemoteFault);
			remoteO.SaveFile(URL, type, _data);
			_requested = true;
		}
		
		private function onRemoteResult(event:ResultEvent):void {
			_data = event.result as ByteArray;
			_parent.dispatchEvent(new FileEvent(FileEvent.FILE_SAVED, URL, null));
		}
		
		private function onRemoteFault(event:FaultEvent):void {
			_data = new ByteArray();
			_parent.dispatchEvent(new FileEvent(FileEvent.FILE_FAILED, URL, null));
		}
	}
}
