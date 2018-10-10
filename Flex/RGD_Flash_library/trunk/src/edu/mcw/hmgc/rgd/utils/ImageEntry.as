package edu.mcw.hmgc.rgd.utils
{
	import edu.mcw.hmgc.rgd.graphics.SVGImage;
	import edu.mcw.hmgc.rgd.utils.libraries.ImageLibrary;
	
	import flash.utils.ByteArray;
	
	import flexlib.scheduling.samples.AlternatingHorizontalLinesViewer;
	
	import mx.controls.Alert;
	import mx.controls.Image;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.RemoteObject;

	public class ImageEntry
	{

		public static const FORMAT_SVG:String = "svg";
		public static const LOCATION_REMOTE:String = "remote";
		public static const LOCATION_CLASS:String = "class";

		public static const EVENT_READY:String = "ready";
		
		public var name:String = new String();
		[Bindable]  
		public var _data:ByteArray = new ByteArray();
		public var URL:String = new String();
		public var type:String = new String();
		public var format:String = new String();
		public var location:String = LOCATION_REMOTE;
		public var description:String = new String();
		public var thumnail:Image = null;
		public var readyFunc:Function=null;
		
		private var _requested:Boolean = false;
		
		private var _properties:XML;
		
		[Bindable]
		public var svgBase:SVGParser1 = new SVGParser1();
		
		public function ImageEntry(properties:XML=null):void
		{
			if (properties != null) {
				_properties = properties;
				getProperties();
			}
		}
		
		private function getProperties():void
		{
			name = _properties.@name;
			URL = _properties.@URL;
			location = _properties.@location;
			type = _properties.@type;
			format = _properties.@format;
			description = _properties.@description;
		}
		
		private function setProperties():void
		{
			_properties.@name = name;
			_properties.@URL = URL;
			_properties.@location = location;
			_properties.@type = type;
			_properties.@format = format;
			_properties.@description = description;
		}
		
		public function get isLoaded():Boolean {
			return (_data.length > 0);
		}
		
		public function get data():ByteArray {
			if (!isLoaded) loadImage();
			return _data;
		}
		
		public function loadImage():int {
			switch (location) {
				case LOCATION_REMOTE:
					return loadRemote();
					break;
				case LOCATION_CLASS:
					return loadClass();
					break;
				default:
					return 0;
			}
		}
		
		private function loadClass():int
		{
			return 0;
		}
		
		private function loadRemote():int {
			if (_requested) return 0;
			var remoteO:RemoteObject = new RemoteObject("CreatingRpc");
			remoteO.GetImage.addEventListener(ResultEvent.RESULT, onRemoteResult);
			remoteO.addEventListener(FaultEvent.FAULT, onRemoteFault);
			remoteO.GetImage(URL, type);
			_requested = true;
			return 1;
		}
		
		private function onRemoteResult(event:ResultEvent):void {
			_data = event.result as ByteArray;
			trace("got image from server for:" + URL + ", length: +" + _data.length);
			if (format == FORMAT_SVG)
			{
				svgBase.parse(new XML(_data));
			}
			if (readyFunc == null) {
				ImageLibrary.OneMoreReady();
			} else {
				var funcTmp:Function = readyFunc;
				readyFunc = null;
				funcTmp();
			}
		}
		
		private function onRemoteFault(event:FaultEvent):void {
			trace("image retrieval failed from server for: [" + _properties.@name + "]. Cause: " + event.fault.faultDetail);
			_data = new ByteArray();
		}
		
	}
}