package edu.mcw.hmgc.rgd.diagrammer
{
	// A logical diagram interface
	// It only stores the logical relation within a diagram.
	// It has nothing to do with graphics
	// Written by WLiu on 4/20/2010
	
	public interface IDiagram
	{
		
		function get nodes():Array;
		
		function get links():Array;
		
		function addNode(value:INode):uint;
		
		function removeNode(value:INode):Array;
		
		function addLink(value:ILink):uint;
		
		function removeLink(value:ILink):Array;
		
		function get numberOfNodes():uint;
		
		function get numberOfLinks():uint;
		
		function get totalNumberOfElements():uint;
		
	}
}