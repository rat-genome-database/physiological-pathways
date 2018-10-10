package edu.mcw.hmgc.rgd.utils
{
	public class DiagramProject extends DiagramLibrary
	{
		private var _projectName:String;

		public function get projectName():String
		{
			return _projectName;
		}

		public function set projectName(value:String):void
		{
			_projectName = value;
			_folderName += value;
			_libraryFolder = new ServerFolder(_folderName);
		}
		
		public function DiagramProject()
		{
			super();
		}
	}
}