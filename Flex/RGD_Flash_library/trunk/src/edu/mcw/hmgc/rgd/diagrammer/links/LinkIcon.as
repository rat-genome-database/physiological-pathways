package edu.mcw.hmgc.rgd.diagrammer.links
{
	import com.degrafa.GeometryGroup;
	
	public class LinkIcon extends SVGIcon
	{
		public static var types:XMLList;
		
		public function LinkIcon(__parent:GeometryGroup)
		{
			super(__parent);
		}

		protected var _type:String = "normal";
		public function set type(value:String):void
		{
			_type = value;
			properties = types.linkicon.(@name==_type);
			refresh();
		}
		
		public function get type():String
		{
			return _type;
		}
		
		public function set setting(settings:XMLList):void
		{
			type = settings.@type;			
			if ("@color" in settings) _color = settings.@color.toString();
			if ("@outlineBgColorIn" in settings) _outlineBgColorIn = settings.@outlineBgColorIn.toString();
			if ("@outlineBgColorOut" in settings) _outlineBgColorOut = settings.@outlineBgColorOut.toString();
			if ("@outlineColor" in settings) _outlineColor = settings.@outlineColor.toString();
			
			
			refresh();
		}

		public function cleanUpMemory():void
		{
			_parent = null;
		}
	}
}