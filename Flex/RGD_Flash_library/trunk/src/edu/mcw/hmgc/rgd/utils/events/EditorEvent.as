package edu.mcw.hmgc.rgd.utils.events
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class EditorEvent extends Event
	{
		public static const DRAG_SELECT_START:String = "grag_select_start";
		public static const DRAG_SELECT_END:String = "grag_select_end";
		
		private var _mouseEvent:MouseEvent = null;
		
		public function EditorEvent(type:String, mouse_event:MouseEvent, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			_mouseEvent = mouse_event;
			super(type, bubbles, cancelable);
		}
		
		public function get mouseEvent():MouseEvent
		{
			return _mouseEvent;
		}
	}
}