package edu.mcw.hmgc.rgd.utils.events
{
	import flash.events.Event;
	
	public class ViewEvent extends Event
	{
		public static const CONTENT_CHANGED:String = "content_changed";
		public static const SELECTION_CHANGED:String = "selection_changed";
		
		public var eventCode:int;
		public function ViewEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}