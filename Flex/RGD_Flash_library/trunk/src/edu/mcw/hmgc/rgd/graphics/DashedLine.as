package edu.mcw.hmgc.rgd.graphics
{
	import com.degrafa.geometry.Line;
	import com.degrafa.geometry.command.CommandStack;
	import com.degrafa.geometry.command.CommandStackItem;
	
		public class DashedLine extends Line
		{
			public function DashedLine(x:Number=0, y:Number=0, x1:Number=0, y1:Number=0)
			{
				super(x, y, x1, y1);
			}
			
			private var _dash:Number = 10;
			/**
			 * The length of the dashed.
			 * a default value of 0 is used.
			 **/
			public function get dash():Number
			{
				if (!_dash)
					return 0;
				return _dash;
			}
			public function set dash(value:Number):void
			{
				if (_dash != value)
				{
					_dash = value;
					if (gap == 0)
						gap = value;            
					invalidated = true;
				}
			}
			
			private var _gap:Number = 10;
			/**
			 * The length of the gap between dashes.
			 * a default value of 0 or the dash value if its > 0 is used.
			 **/
			public function get gap():Number
			{
				if (!_gap)
					return 0;
				return _gap;
			}
			public function set gap(value:Number):void
			{
				if (_gap != value)
				{
					_gap = value;
					invalidated = true;
				}
			}
			
			
			/**
			 * @inheritDoc 
			 **/
			override public function preDraw():void
			{
				if(invalidated)
				{
					// take care of calcBounds() and private issue
					super.preDraw();
					commandStack.length = 0;
					commandStack.addMoveTo(x, y); 
//					commandStack.push({type:"m",x:x,y:y});
					
					if (dash == 0 && gap == 0)
					{    
						commandStack.addLineTo(x1, y1);
						;//commandStack.push({type:"l",x:x1,y:y1});
					}
					else
					{
						var length:Number = Math.abs(Math.sqrt(Math.pow(x-x1, 2) + Math.pow(y-y1, 2)));
						
						var count:int = 0;
						var currentLength:int = 0;
						var ratio:Number = 1;
						while (currentLength < length)
						{
							// dash
							if (count % 2 == 0)
							{
								currentLength += dash;
								ratio = Math.min(1,(currentLength / length));
								trace("currentLength: " + currentLength + " x: " + (x + ((x1-x)*ratio)));
								commandStack.addLineTo(
									x + ((x1-x)*ratio),
									y + ((y1-y)*ratio));
//								commandStack.push({type:"l",x:x + ((x1-x)*ratio),y:y + ((y1-y)*ratio)});
							}
							else
							{
								currentLength += gap;
								ratio = Math.min(1,(currentLength / length));
								
								commandStack.addMoveTo(
									x + ((x1-x)*ratio),
									y + ((y1-y)*ratio));
//								commandStack.push({type:"m",x:x + ((x1-x)*ratio),y:y + ((y1-y)*ratio)});
							}
							count++;
						}
					}
					
					invalidated = false;
				}
				
			}
			
			
		}
		
}