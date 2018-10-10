package edu.mcw.hmgc.rgd.diagrammer
{
	import mx.binding.utils.BindingUtils;

	public class ToolbarSetting extends Object
	{
		[Bindable]
		public var drawArea:Boolean = false;
		
		[Bindable]
		public var drawGrids:Boolean = true;
		
		public function ToolbarSetting()
		{
		}
		
		public function copy(input:ToolbarSetting):void
		{
			drawArea = input.drawArea;	
			drawGrids = input.drawGrids;
		}
	}
}