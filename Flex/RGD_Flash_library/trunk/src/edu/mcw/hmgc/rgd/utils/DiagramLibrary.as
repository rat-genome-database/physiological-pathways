package edu.mcw.hmgc.rgd.utils
{
	public class DiagramLibrary
	{
		static protected var _folderName:String = "Diagrams";
		static protected var _libraryFolder:ServerFolder = new ServerFolder(_folderName);
		
		public function DiagramLibrary()
		{
		}
		
		static public function refreshList(ready_func:Function=null):void
		{
			_libraryFolder.getFileList(ready_func);
		}
		
		static public function get list():XMLList
		{
			return _libraryFolder.fileList;
		}

		static public function getFile(parent:Object, file_name:String, on_success:Function):void
		{
			_libraryFolder.getFile(parent, file_name, on_success);
		}
		
		static public function saveTextFile(parent:Object, file_name:String, file_data:String, on_success:Function):void
		{
			_libraryFolder.saveTextFile(parent, file_name, file_data, on_success);
		}
	}
}