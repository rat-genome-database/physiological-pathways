package edu.mcw.hmgc.rgd.utils.events
{
	import flash.events.Event;
	
	public class LibraryEvent extends Event
	{
		public static const IMAGE_LIBRARY_READY:String = "image_library_ready";
		public static const LINK_LIBRARY_READY:String = "link_library_ready";
		public static const CONFIGURATION_READY:String = "configuration_ready";
		public static const DIAGRAM_LIBRARY_READY:String = "diagram_library_ready";
		
		public function LibraryEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}