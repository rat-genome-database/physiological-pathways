package edu.mcw.hmgc.rgd.ui.controls
{
	import flash.events.KeyboardEvent;
	
	import mx.containers.Canvas;
	
	public class Canvas extends mx.containers.Canvas
	{
		
		private var _vScrollBarLeft:Boolean = false;

		public function get vScrollBarLeft():Boolean
		{
			return _vScrollBarLeft;
		}

		public function set vScrollBarLeft(value:Boolean):void
		{
			_vScrollBarLeft = value;
		}

		protected var _hScrollBarTop:Boolean = false;
		public function Canvas()
		{
			super();
		}
		
		protected override function updateDisplayList( unscaledWidth:Number, unscaledHeight:Number ):void
		{
			super.updateDisplayList( unscaledWidth, unscaledHeight );
		}
		
		public override function validateDisplayList( ):void{
			super.validateDisplayList( );
			
			if(_vScrollBarLeft && verticalScrollBar && verticalScrollBar.visible ){
				verticalScrollBar.x = 0;
			}	
			
		}
		
		override protected function keyDownHandler(event:KeyboardEvent):void
		{
			
		}
	}
}