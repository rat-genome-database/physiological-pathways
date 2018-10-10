package edu.mcw.hmgc.rgd.diagrammer.events
{
	import flash.events.Event;
	
	public class InnerDiagramEvent extends Event
	{
		public var objClicked:Object = null;
		public var fileName:String = "";
		
		public function InnerDiagramEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}