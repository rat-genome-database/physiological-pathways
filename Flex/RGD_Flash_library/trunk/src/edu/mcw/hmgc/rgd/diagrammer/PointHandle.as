package edu.mcw.hmgc.rgd.diagrammer
{
	import com.roguedevelopment.objecthandles.SpriteHandle;
	
	public class PointHandle extends SpriteHandle
	{
		public function PointHandle()
		{
			//TODO: implement function
			super();
		}

		override public function redraw():void
		{
			graphics.clear();
			if( isOver )
			{
				graphics.lineStyle(1,0x3dff40);
				graphics.beginFill(0xc5ffc0	,1);				
			}
			else
			{
				graphics.lineStyle(1,0);
				graphics.beginFill(0xff0000,1);
			}
			
			graphics.drawCircle(0,0,6);
			graphics.endFill();
		}
	}
}