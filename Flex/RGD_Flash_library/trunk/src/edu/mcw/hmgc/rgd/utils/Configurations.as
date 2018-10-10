package edu.mcw.hmgc.rgd.utils
{
	import edu.mcw.hmgc.rgd.utils.FileLoader;
	import edu.mcw.hmgc.rgd.utils.events.FileEvent;
	import edu.mcw.hmgc.rgd.utils.events.LibraryEvent;
	
	import mx.core.Application;
	
	public class Configurations
	{
		
		private static var _application:Application;
		public static function get application():Application
		{
			return _application;
		}

		public static var PATH:String = "Configurations/";
		public static var URL:String = PATH + "app_configuration.xml";
		public static var settings:XML;
		
		public function Configurations()
		{
			
		}
		
		public static function load(application:Application, input:String = null):void
		{
			_application = application;
			var fileLoader:FileLoader = new FileLoader(_application, URL, onListReady);
		}

		public static function onListReady(event:FileEvent):void {
			if (URL != event.url) return;
			_application.removeEventListener(FileEvent.FILE_READY, onListReady);
			settings = new XML(event.data);
			_application.dispatchEvent(new LibraryEvent(LibraryEvent.CONFIGURATION_READY));
			
		}
	}
}