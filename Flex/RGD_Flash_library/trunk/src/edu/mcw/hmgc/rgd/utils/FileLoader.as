package edu.mcw.hmgc.rgd.utils
{
	import edu.mcw.hmgc.rgd.utils.events.FileEvent;
	
	import flash.utils.ByteArray;
	
	import mx.controls.Alert;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.RemoteObject;

	public class FileLoader
	{
		public static const REMOTE_SOURCE:String = "remote";
		public static const MANUAL_SOURCE:String = "manual";
		public static const LOCATION_REMOTE:String = "remote";
		public static const LOCAL_SOURCE:String = "local"

		public static const EVENT_READY:String = "ready";
		
		private var _requested:Boolean = false;
		private var _parent:Object;
		
		public var name:String = new String();
		[Bindable]  
		public var _data:ByteArray = new ByteArray();
		public var type:String = new String();
		public var _URL:String = new String();
		public var location:String = LOCATION_REMOTE;
		
		
		public function FileLoader(parent:Object, url:String="", onSuccess:Function=null)
		{
			_parent = parent;
			if (onSuccess != null) _parent.addEventListener(FileEvent.FILE_READY, onSuccess);
			if (url !=null && url.length > 0) loadFile(url);
		}

		public function get isLoaded():Boolean {
			return (_data.length > 0);
		}
		
		public function get data():ByteArray {
			if (!isLoaded) loadFile(_URL);
			return _data;
		}
		
		public function loadFile(url:String, fileType:String=""):void {
			_URL = url;
			type = fileType;
			switch (location) {
				case LOCATION_REMOTE:
					loadRemote();
					break;
				default:
			}
		}
		
		private function loadRemote():void {
			if (_requested) return;
			var remoteO:RemoteObject = new RemoteObject("CreatingRpc");
			remoteO.GetFile.addEventListener(ResultEvent.RESULT, onRemoteResult);
			remoteO.GetFile.addEventListener(FaultEvent.FAULT, onRemoteFault);
			remoteO.showBusyCursor = true;
			remoteO.GetFile(_URL, type);
			_requested = true;
		}
		
		private function onRemoteResult(event:ResultEvent):void {
			_data = event.result as ByteArray;
			_parent.dispatchEvent(new FileEvent(FileEvent.FILE_READY, _URL, _data));
		}
		
		private function onRemoteFault(event:FaultEvent):void {
			_data = new ByteArray();
			Alert.show(event.toString());
			_parent.dispatchEvent(new FileEvent(FileEvent.FILE_FAILED, _URL, null));
		}
	}
}