package edu.mcw.hmgc.rgd.diagrammer
{
	public class Node implements INode, IDiagramElement
	{
		private var _toLinks:Array = null;
		private var _fromLinks:Array = null;
		
		private var _elementType:String = "Node";
		
		public function Node()
		{
			_toLinks = new Array();
			_fromLinks = new Array();
		}
		
		public function get elementType():String {
			return _elementType;
		}
		
		public function addToLink(value:ILink):uint {
			return _toLinks.push(value);
		}
		
		public function addFromLink(value:ILink):uint {
			return _fromLinks.push(value);
		}
		
		public function removeToLink(value:ILink):void {
			_toLinks.splice(_toLinks.indexOf(value), 1);
		}
		
		public function removeFromLink(value:ILink):void {
			_fromLinks.splice(_fromLinks.indexOf(value), 1);
		}
		
		public function disconnect():void {
			for each (var fromLink:ILink in _fromLinks) {
				fromLink.unsetFromNode();
			}
			
			for each (var toLink:ILink in _toLinks) {
				toLink.unsetToNode();
			}
		}
	}
}