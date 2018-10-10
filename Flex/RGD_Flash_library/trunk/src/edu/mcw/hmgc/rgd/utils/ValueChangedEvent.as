package edu.mcw.hmgc.rgd.utils
{
	import flash.events.Event;
	
	public class ValueChangedEvent extends Event
	{
		public var originalValue:Object;
		public var newValue:Object;
		
		public function ValueChangedEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}