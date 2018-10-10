package edu.mcw.hmgc.rgd.diagrammer
{
	public class BasicDrawComponent implements IBasicDrawComponent
	{
		protected var _hasDrawn:Boolean = false;
		
		public function BasicDrawComponent()
		{
		}
		
		public function draw():void
		{
		}
		
		public function remove():void
		{
		}

		public function refresh():void
		{
			remove();
			draw();
		}
	}
	
}