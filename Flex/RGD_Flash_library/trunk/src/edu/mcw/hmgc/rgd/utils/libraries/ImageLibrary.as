package edu.mcw.hmgc.rgd.utils.libraries
{
	import edu.mcw.hmgc.rgd.utils.Configurations;
	import edu.mcw.hmgc.rgd.utils.FileLoader;
	import edu.mcw.hmgc.rgd.utils.ImageEntry;
	import edu.mcw.hmgc.rgd.utils.events.FileEvent;
	import edu.mcw.hmgc.rgd.utils.events.LibraryEvent;
	
	import mx.core.Application;

	public class ImageLibrary
	{
		private static var _images:Array = new Array();
		
		private static var _parent:Application;
		
		private static var _imagesReady:Number = 0;
		private static var _NofImages:Number = 0;
		
		private static var _imageList:XML;

		private static var _URL:String = Configurations.PATH + "image_list.xml";
		
		public function ImageLibrary(application:Application)
		{
			_parent = application;
			var fileLoader:FileLoader = new FileLoader(_parent, _URL, loadLibrary);
		}
		
		public static function loadLibrary(event:FileEvent):void
		{
			if (_URL != event.url) return;

			_parent.removeEventListener(FileEvent.FILE_READY, loadLibrary);
			_imageList = new XML(event.data);
			loadImages();
		}
		
		private static function loadImages():void {
			var image_entry:ImageEntry;
			
			for each (var imageXML:XML in _imageList.image)
			{
				image_entry = new ImageEntry(imageXML);
				_NofImages += image_entry.loadImage();
				addImage(image_entry);
			}
		}
		
		public static function addImage(value:ImageEntry):void {
			_images.push(value);
		}
		
		public static function removeImage(value:ImageEntry):void {
			
		}
		
		public static function getImage(name:String):ImageEntry {
			for each (var image:ImageEntry in _images) {
				if (image.name.toLowerCase() == name.toLowerCase()) {
					return image;
				}
			}
			var custImg:ImageEntry = new ImageEntry();
			custImg.name = name;
			custImg.URL = name;
			custImg.format = name.substring(name.lastIndexOf(".")+1, name.length).toLowerCase();
			custImg.type = "USR";
			addImage(custImg);
			return custImg; 
		}
		
		public static function get images():Array {
			return _images;
		}
		
		public static function OneMoreReady():void {
			_imagesReady ++;
			if (_imagesReady == _NofImages) {
				_parent.dispatchEvent(new LibraryEvent(LibraryEvent.IMAGE_LIBRARY_READY));
			}
		}
	}
}