package edu.mcw.hmgc.rgd.diagrammer
{
	public interface INode
	{

		function addToLink(value:ILink):uint;
		
		function addFromLink(value:ILink):uint;
		
		function removeToLink(value:ILink):void;
		
		function removeFromLink(value:ILink):void;
		
		function disconnect():void;
		
	}
}