package edu.mcw.hmgc.rgd.diagrammer
{
	import edu.mcw.hmgc.rgd.utils.DiagramLibrary;
	import edu.mcw.hmgc.rgd.utils.FileLoader;

	public class DiagramGroup
	{
		private var _fileName:String;

		public function get fileName():String
		{
			return _fileName;
		}

		public function set fileName(value:String):void
		{
			_fileName = value;
		}
		
		private var _structureXML:XML;

		public function get structureXML():XML
		{
			return _structureXML;
		}

		public function set structureXML(value:XML):void
		{
			_structureXML = value;
		}
		
		public function load(parent:Object, file_name:String, on_success:Function):void
		{
			if (fileName != null) file_name = fileName;
			DiagramLibrary.getFile(parent, file_name, on_success);
		}
		
		public function getDiagramFileName(level_no:int, tab_no:int):String
		{
			var diagrams:XMLList = getDiagram(level_no, tab_no);
			var file_name:String = diagrams[0].@file;
			return file_name;
		} 
		
		public function getDiagramGroupID(file_name:String):int
		{
			var groups:XMLList = structureXML.group;
			for (var i:int = 0; i < groups.length(); i++)
			{
				var group:XMLList = groups[i].diagram.(@file==file_name);
				if (group.length() > 0) return groups[i].@id;
			}

			return -1;
		}
		
		public function getGroup(level_no:int):XMLList
		{
			var groups:XMLList = structureXML.group.(@id==level_no);
			return groups;
		}
		
		public function getDiagram(level_no:int, tab_no:int):XMLList
		{
			var groups:XMLList = getGroup(level_no);
			var diagrams:XMLList = groups[0].diagram.(@id==tab_no);
			return diagrams;
		}
		
		public function DiagramGroup()
		{
		}
		
		public function getTitle():String
		{
			var title_str:String = structureXML.@label;
			return title_str;
		}
		
		public function getDescription():String
		{
			var des_str:String = structureXML.description;
			return des_str;
		}
		
		public function getGroupTitle(level_no:int):String
		{
			var groups:XMLList = getGroup(level_no);
			var title_str:String = groups.@label;
			return title_str;
		}
	}
}