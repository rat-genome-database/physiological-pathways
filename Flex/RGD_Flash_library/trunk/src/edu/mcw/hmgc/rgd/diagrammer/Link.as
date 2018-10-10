package edu.mcw.hmgc.rgd.diagrammer
{
	public class Link implements ILink
	{
		private var _fromNode:INode = null;
		private var _toNode:INode = null;
		
		public function Link()
		{
			//TODO: implement function
		}
		
		public function get fromNode():INode {
			return _fromNode;
		}
		
		public function get toNode():INode {
			return _toNode;
		}
		
		public function set fromNode(value:INode):void {
			unsetFromNode();
			_fromNode = value;
		}
		
		public function set toNode(value:INode):void {
			unsetToNode();
			_toNode = value;
		}
		
		public function unsetFromNode():void {
			if (_fromNode != null) {
				_fromNode.removeFromLink(this);			
				_fromNode = null;
			} 
		} 
		
		public function unsetToNode():void {
			if (_toNode != null) {
				_toNode.removeToLink(this);
				_toNode = null;
			}
		}
	}
}