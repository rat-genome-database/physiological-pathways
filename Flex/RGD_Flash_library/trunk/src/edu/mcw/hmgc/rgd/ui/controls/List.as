package edu.mcw.hmgc.rgd.ui.controls
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	
	import mx.controls.List;
	import mx.controls.listClasses.IListItemRenderer;
	
	public class List extends mx.controls.List
	{
		public var indicatorAlpha:Number = .9;
		public function List()
		{
			super();
		}
		
		protected override function drawSelectionIndicator(
			indicator:Sprite, x:Number, y:Number,
			width:Number, height:Number, color:uint,
			itemRenderer:IListItemRenderer):void
		{
			indicator.alpha = indicatorAlpha;
			super.drawSelectionIndicator(indicator, 0, y, unscaledWidth - viewMetrics.left - viewMetrics.right, height, color, itemRenderer);
			
		}
		
	}
}