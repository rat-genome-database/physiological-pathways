package edu.mcw.hmgc.rgd.utils
{
	import edu.mcw.hmgc.rgd.utils.events.FileEvent;
	
	import flash.utils.ByteArray;
	
	import mx.controls.Alert;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.RemoteObject;

	public class ServerFolder
	{
		
		protected var _folderName:String;
		private var _requested:Boolean = false;
		
		private var _onSuccess:Function = null;

		private var _onFileSucces:Function = null;
		private var _fileDesc:String;
		
		[Bindable]
		public function get folderName():String
		{
			return _folderName;
		}
		
		public function set folderName(value:String):void
		{
			if (value == null || value.length == 0 || _folderName === value) return;
			_folderName = value;
			if (_folderName.lastIndexOf("/") != _folderName.length - 1) _folderName += "/";
			getFileList();
		}
		
		protected var _fileList:XMLList;
		
		[Bindable]
		public function get fileList():XMLList
		{
			return _fileList;
		}
		
		public function set fileList(value:XMLList):void
		{
			_fileList = value;
		}
		
		
		public function ServerFolder(folder_name:String)
		{
			folderName = folder_name;
		}
		
		public function getFileList(on_success:Function=null):void
		{
			if (_requested || on_success == null) return;
			_onSuccess = on_success;
			var remoteO:RemoteObject = new RemoteObject("CreatingRpc");
			remoteO.GetFileList.addEventListener(ResultEvent.RESULT, onRemoteResult);
			remoteO.GetFileList.addEventListener(FaultEvent.FAULT, onRemoteFault);
			remoteO.GetFileList(_folderName);
			_requested = true;
		}
		
		private function onRemoteResult(event:ResultEvent):void {
			var xml_returned:XML = new XML(event.result as ByteArray);
			fileList = xml_returned.file;
			_requested = false;
			if (_onSuccess != null) _onSuccess();
		}
		
		private function onRemoteFault(event:FaultEvent):void {
			_fileList = new XMLList();
			Alert.show(event.toString());
			_requested = false;
		}
		
		public function getFile(parent:Object, file_name:String, on_success:Function):void
		{
			_onFileSucces = on_success;
			var file_loader:FileLoader = new FileLoader(parent, _folderName + file_name, on_success);
		}
		
		private function onFileReady(event:FileEvent):void
		{
//			_onFileSucces();
		}
		
		public function saveTextFile(parent:Object, file_name:String, file_data:String, on_success:Function):void
		{
			_onFileSucces = on_success;
			var file_saver:FileSaver = new FileSaver(parent, _folderName + file_name, file_data, on_success);
		}
	}
}