package edu.mcw.hmgc.rgd.diagrammer
{
	public interface ILink
	{
		
		function get fromNode():INode;
		
		function get toNode():INode;
		
		function set fromNode(value:INode):void;
		
		function set toNode(value:INode):void;
		
		function unsetFromNode():void;
		
		function unsetToNode():void;
		
	}
}