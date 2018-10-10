package edu.mcw.hmgc.rgd.graphics
{
	import com.degrafa.IGeometry;
	import com.degrafa.geometry.Geometry;
	import com.degrafa.geometry.command.CommandStack;
	import com.degrafa.geometry.command.CommandStackItem;
	
	import flash.display.Graphics;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	
	//--------------------------------------
	//  Other metadata
	//--------------------------------------
	
	[Bindable]		
	/**
	 *  The RoundedRectCallout element draws a callout with a rounded rectangle.
	 *  
	 *  @see http://degrafa.org/source/RoundedRectangle/RoundedRectangle.html
	 *  
	 **/
	public class RoundedRectCallout extends Geometry implements IGeometry {
		
		private var _tailZone:Number;

		public function get tailZone():Number
		{
			return _tailZone;
		}

		public function set tailZone(value:Number):void
		{
			_tailZone = value;
		}
		
		
		/**
		 *  private constant used to avoid unnecessary trignometry calculations
		 */
		private static const TRIG:Number = 0.4142135623730950488016887242097; 
		
		/**
		 * Constructor.
		 *  
		 * <p>The rounded rectangle constructor accepts 5 optional arguments that define it's 
		 * x, y, width, height and corner radius.</p>
		 * 
		 * @param x A number indicating the upper left x-axis coordinate.
		 * @param y A number indicating the upper left y-axis coordinate.
		 * @param width A number indicating the width.
		 * @param height A number indicating the height. 
		 * @param cornerRadius A number indicating the radius of each corner.
		 */		
		public function RoundedRectCallout(x:Number=NaN,y:Number=NaN,width:Number=NaN,height:Number=NaN,cornerRadius:Number=NaN, 
										   out_x:Number=NaN, out_y:Number=NaN){
			
			super();
			
			if (x) this.x=x;
			if (y) this.y=y;
			if (width) this.width=width;
			if (height) this.height=height;
			if (cornerRadius)this.cornerRadius=cornerRadius;
			
		}
		
		/**
		 * RoundedRectangle short hand data value.
		 * 
		 * <p>The rounded rectangle data property expects exactly 5 values x, 
		 * y, width, height and corner radius separated by spaces.</p>
		 * 
		 * @see Geometry#data
		 * 
		 **/
		override public function set data(value:Object):void{
			if(super.data != value){
				super.data = value;
				
				//parse the string on the space
				var tempArray:Array = value.split(" ");
				
				if (tempArray.length == 5){
					_x=tempArray[0];
					_y=tempArray[1];
					_width=tempArray[2];
					_height=tempArray[3];
					_cornerRadius = tempArray[4];
					invalidated = true;
				}	
			}
		} 
		
		private var _x:Number;
		/**
		 * The x-axis coordinate of the upper left point of the rounded rectangle. If not specified 
		 * a default value of 0 is used.
		 **/
		override public function get x():Number{
			if(!_x){return 0;}
			return _x;
		}
		override public function set x(value:Number):void{
			if(_x != value){
				_x = value;
				if (hasLayout) super.y=value
				invalidated = true;
			}
		}
		
		
		private var _y:Number;
		/**
		 * The y-axis coordinate of the upper left point of the rounded rectangle. If not specified 
		 * a default value of 0 is used.
		 **/
		override public function get y():Number{
			if(!_y){return 0;}
			return _y;
		}
		override public function set y(value:Number):void{
			if(_y != value){
				_y = value;
				if (hasLayout) super.y=value
				invalidated = true;
			}
		}
		
		
		private var _width:Number;
		/**
		 * The width of the rounded rectangle.
		 **/
		[PercentProxy("percentWidth")]
		override public function get width():Number{
			if(!_width){return (hasLayout)? 1:0;}
			return _width;
		}
		override public function set width(value:Number):void{
			if(_width != value){
				_width = value;
				if (hasLayout) super.width=value
				invalidated = true;
			}
		}
		
		
		private var _height:Number;
		/**
		 * The height of the rounded rectangle.
		 **/
		[PercentProxy("percentHeight")]
		override public function get height():Number{
			if(!_height){return (hasLayout)? 1:0;}
			return _height;
		}
		override public function set height(value:Number):void{
			if(_height != value){
				_height = value;
				if (hasLayout) super.height=value
				invalidated = true;
			}
		}
		
		
		private var _cornerRadius:Number;
		/**
		 * The radius to be used for each corner of the rounded rectangle.
		 **/
		public function get cornerRadius():Number{
			if(!_cornerRadius){return 0;}
			return _cornerRadius;
		}
		public function set cornerRadius(value:Number):void{
			if (_cornerRadius != value) {
				var oldval:Number = _cornerRadius;
				_cornerRadius = value;
				invalidated = true;
			}
		}
		
		private var _outX:Number;
		/**
		 * X of the location of the out point.
		 **/
		public function get outX():Number
		{
			return _outX;
		}

		public function set outX(value:Number):void
		{
			if(_outX != value){
				_outX = value;
				invalidated = true;
			}
		}
		
		private var _outY:Number;
		/**
		 * Y of the location of the out point.
		 **/
		public function get outY():Number
		{
			return _outY;
		}

		public function set outY(value:Number):void
		{
			if(_outY != value){
				_outY = value;
				invalidated = true;
			}
		}

		public function setOutPosition(x:Number, y:Number):void
		{
			
			
		}
		
		private var _permitCornerInversion:uint;
		[Inspectable(category="General", enumeration="true,false")]
		/**
		 * If any of the corner radii are negative, the corners with negative values will cut inwards if permitCornerInversion is true. 
		 * Defaults to false, in which case negative corner radius values represent a zero corner radius.
		 */
		public function get permitCornerInversion():Boolean {
			return _permitCornerInversion? true:false;
		}
		public function set permitCornerInversion(value:Boolean):void {
			if (value=!_permitCornerInversion) {
				_permitCornerInversion = value?1:0;
				invalidated = true;
			}
		}
		
		/**
		 * The tight bounds of this element as represented by a Rectangle object. 
		 **/
		override public function get bounds():Rectangle {
			//exception here for now, not using commandStack bounds:
			return new Rectangle(x, y, width, height);
		}
		
		
		/**
		 * private internal function to update the values in the commandStack for rendering. 
		 * This approach is taken to enforce the cornerRadius rules under layout. This method handles the corner calculations and variants with cornerInversion settings
		 * called from the render pipeline in CommandStack and also in preDraw for when layout is not active.
		 * @param	cStack
		 * @param	item
		 * @param	graphics
		 * @param	currentIndex
		 * @return
		 */
		private function updateCommandStack(cStack:CommandStack=null, item:CommandStackItem=null, graphics:Graphics=null,currentIndex:int=0):CommandStackItem {
			
			var _cornerRadius:Number = cornerRadius;
			
			//use local vars instead of the main getters
			var x:Number;
			var y:Number;
			var width:Number ;
			var height:Number
			if (hasLayout && cStack) { //handle layout variant call at render time
				CommandStack.transMatrix = CommandStack.currentTransformMatrix;
				
				x = layoutRectangle.x;
				y = layoutRectangle.y;
				width = layoutRectangle.width;
				height = layoutRectangle.height;
				
			} else {
				x = this.x;
				y = this.y;
				width = this.width;
				height = this.height;
				
			}
			
			if (!_permitCornerInversion) {
				if (_cornerRadius<0) _cornerRadius=0;
			}
			
			//set to skip
			topRightCorner1.skip = topRightCorner2.skip = 
				bottomRightCorner1.skip = bottomRightCorner2.skip=
				bottomLeftCorner1.skip = bottomLeftCorner2.skip = 
				topLeftCorner1.skip=topLeftCorner2.skip = (_cornerRadius)? false:true;
			
			if(_cornerRadius){
				
				// make sure that width + h are larger than 2*cornerRadius
				if (Math.abs(_cornerRadius)>Math.min(width, height)/2) {
					_cornerRadius = Math.min(width, height) / 2 * (_cornerRadius < 0? -1:1);
				}
				
				//round to nearest
				//	_cornerRadius = Math.round(_cornerRadius);
				
			}	
			
			var adjx:Number = 0;
			var adjy:Number = 0;
			//apply fix for player rendering bug
			if ( stroke && stroke.weight < 4 &&!stroke.pixelHinting  ) {
				//player rendering bug workaround: make sure the coords are offset from integer pixel values by at least 3 twips
				//this seems to solve an anti-aliasing error with small stroke weights that is very obvious for RoundedRectangles
				var adjbase:Number = 0.15;
				var under:Boolean;
				var diff:Number;
				if ((stroke.weight != 2 &&  (diff = Math.abs(x -Math.round(x ))) < adjbase) ) {
					under== x < Math.round(x);
					adjx = (adjbase-diff)* (under?-1:1);
					x += adjx;
				} else {
					if (stroke.weight == 2) { //variation - artefact seems to be centered around midpixel values with stroke.weight==2
						under = x < Math.round(x * 2 ) / 2;
						if ((diff = Math.abs(x -Math.round(x * 2 ) / 2)) < adjbase) {
							adjx = (adjbase-diff)* (under?-1:1);
							x += adjx;
						}
					}
				}
				
				under = y < Math.round(y);
				if (stroke.weight!=2 && (diff = Math.abs(y -Math.round(y ))) < adjbase) {
					adjy = (adjbase-diff)* (under?-1:1);
					y += adjy;
				} else {
					if (stroke.weight == 2) { //variation - artefact seems to be centered around midpixel values with stroke.weight==2
						if ((diff = Math.abs(y -Math.round(y * 2 ) / 2)) < adjbase) {
							under = y < Math.round(y * 2 ) / 2;
							adjy = (adjbase-diff)* (under?-1:1);
							y += adjx;
						}
					}
				}
				
			}
			
			//dev note:through initial testing this seems fine, but may also need to test for being on a pixel boundaries as well
			var bottom:Number = y + height-adjy;
			var right:Number = x + width-adjx;
			var innerRight:Number = right - Math.abs(_cornerRadius);
			var innerLeft:Number = x + Math.abs(_cornerRadius);
			var innerTop:Number = y + Math.abs(_cornerRadius);
			var innerBottom:Number = bottom - Math.abs(_cornerRadius);
			
			// manipulate the commandStack
			//basic rectangle:
			startPoint.x = innerLeft;
			startPoint.y = y;
			topLine.x = innerRight;
			topLine.y = y;
			rightLine.x = right;
			rightLine.y = innerBottom;
			bottomLine.x = innerLeft;
			bottomLine.y = bottom;
			leftLine.x = x;
			leftLine.y = innerTop;
			
			redraw(adjx, adjy);
			
			//corners if necessary
			if (_cornerRadius) {	
				
				var cornersplitoffset:Number;
				var controlPointOffset:Number;
				var innerRightcx:Number;
				var innerRightx:Number ;
				var innerBottomcy:Number ;
				var innerBottomy:Number ;
				var innerLeftcx:Number ;
				var innerLeftx:Number ;
				var innerTopcy:Number ;
				var innerTopy:Number ;
				cornersplitoffset = Math.SQRT1_2 * _cornerRadius;
				controlPointOffset = TRIG * _cornerRadius;
				
				if (_cornerRadius>0){
					innerRightcx = innerRight + controlPointOffset;
					innerRightx = innerRight + cornersplitoffset;
					innerBottomcy = innerBottom + controlPointOffset;
					innerBottomy = innerBottom + cornersplitoffset;
					innerLeftcx = innerLeft - controlPointOffset;
					innerLeftx = innerLeft - cornersplitoffset;
					innerTopcy = innerTop - controlPointOffset;
					innerTopy = innerTop - cornersplitoffset;
					topRightCorner1.cx = innerRightcx;
					topRightCorner1.cy = y;
					topRightCorner1.x1 = innerRightx;
					topRightCorner1.y1 = innerTopy;
					topRightCorner2.cx = right;
					topRightCorner2.cy = innerTopcy;
					topRightCorner2.x1 = right;
					topRightCorner2.y1 = innerTop;
					bottomRightCorner1.cx = right;
					bottomRightCorner1.cy = innerBottomcy;
					bottomRightCorner1.x1 = innerRightx;
					bottomRightCorner1.y1 = innerBottomy;
					bottomRightCorner2.cx = innerRightcx;
					bottomRightCorner2.cy = bottom;
					bottomRightCorner2.x1 = innerRight;
					bottomRightCorner2.y1 = bottom;
					bottomLeftCorner1.cx = innerLeftcx;
					bottomLeftCorner1.cy = bottom;
					bottomLeftCorner1.x1 = innerLeftx;
					bottomLeftCorner1.y1 = innerBottomy;
					bottomLeftCorner2.cx = x;
					bottomLeftCorner2.cy = innerBottomcy;
					bottomLeftCorner2.x1 = x;
					bottomLeftCorner2.y1 = innerBottom;
					topLeftCorner1.cx = x;
					topLeftCorner1.cy = innerTopcy;
					topLeftCorner1.x1 = innerLeftx;
					topLeftCorner1.y1 = innerTopy;
					topLeftCorner2.cx = innerLeftcx;
					topLeftCorner2.cy = y;
					topLeftCorner2.x1 = innerLeft;
					topLeftCorner2.y1 = y;/**/
				} else {
					innerRightcx = right+ controlPointOffset;
					innerRightx = right + cornersplitoffset;
					innerBottomcy = bottom+ controlPointOffset;
					innerBottomy = bottom + cornersplitoffset;
					innerLeftcx = x - controlPointOffset;
					innerLeftx = x - cornersplitoffset;
					innerTopcy = y - controlPointOffset;
					innerTopy = y - cornersplitoffset;
					topRightCorner1.cx = innerRight;
					topRightCorner1.cy = innerTopcy;
					topRightCorner1.x1 = innerRightx;
					topRightCorner1.y1 = innerTopy;
					topRightCorner2.cx = innerRightcx;
					topRightCorner2.cy = innerTop;
					topRightCorner2.x1 = right;
					topRightCorner2.y1 = innerTop;
					bottomRightCorner1.cx = innerRightcx;
					bottomRightCorner1.cy = innerBottom;
					bottomRightCorner1.x1 = innerRightx;
					bottomRightCorner1.y1 = innerBottomy;
					bottomRightCorner2.cx = innerRight;
					bottomRightCorner2.cy = innerBottomcy;
					bottomRightCorner2.x1 = innerRight;
					bottomRightCorner2.y1 = bottom;
					bottomLeftCorner1.cx = innerLeft;
					bottomLeftCorner1.cy = innerBottomcy;
					bottomLeftCorner1.x1 = innerLeftx;
					bottomLeftCorner1.y1 = innerBottomy;
					bottomLeftCorner2.cx = innerLeftcx;
					bottomLeftCorner2.cy = innerBottom;
					bottomLeftCorner2.x1 = x;
					bottomLeftCorner2.y1 = innerBottom;
					topLeftCorner1.cx = innerLeftcx;
					topLeftCorner1.cy = innerTop
					topLeftCorner1.x1 = innerLeftx;
					topLeftCorner1.y1 = innerTopy;
					topLeftCorner2.cx = innerLeft;
					topLeftCorner2.cy = innerTopcy;
					topLeftCorner2.x1 = innerLeft;
					topLeftCorner2.y1 = y;
				}
				
			} 
			
			return commandStack.source[0];
			
		}
		
		private var startPoint:CommandStackItem;
		private var topLine:CommandStackItem;
		
		private var topRightCorner1:CommandStackItem;
		private var topRightCorner2:CommandStackItem;
		
		private var rightLine:CommandStackItem;
		
		private var bottomRightCorner1:CommandStackItem;
		private var bottomRightCorner2:CommandStackItem;
		
		private var bottomLine:CommandStackItem;
		
		private var bottomLeftCorner1:CommandStackItem
		private var bottomLeftCorner2:CommandStackItem
		
		private var leftLine:CommandStackItem;
		
		private var topLeftCorner1:CommandStackItem;
		private var topLeftCorner2:CommandStackItem;
		
		private var leftStartPoint:CommandStackItem;
		private var leftMidPoint:CommandStackItem;
		private var leftEndPoint:CommandStackItem;
		
		private var topStartPoint:CommandStackItem;
		private var topMidPoint:CommandStackItem;
		private var topEndPoint:CommandStackItem;
		
		private var rightStartPoint:CommandStackItem;
		private var rightMidPoint:CommandStackItem;
		private var rightEndPoint:CommandStackItem;
		
		private var bottomStartPoint:CommandStackItem;
		private var bottomMidPoint:CommandStackItem;
		private var bottomEndPoint:CommandStackItem;
		

		/**
		 * @inheritDoc 
		 **/
		override public function preDraw():void{
			if(invalidated){
				
				if (!commandStack.length) {
					//one top level item permits a single renderDelegate call
					//var commandStackItem:CommandStackItem = commandStack.addItem(new CommandStackItem(CommandStackItem.COMMAND_STACK,NaN,NaN,NaN,NaN,NaN,NaN,new CommandStack())) ;	
					
					var commandStackItem:CommandStackItem = commandStack.addItem(new CommandStackItem(CommandStackItem.DELEGATE_TO));
					commandStackItem.delegate = updateCommandStack;
					
					//set up quick references to manipulate items directly
					startPoint=commandStack.addItem(new CommandStackItem(CommandStackItem.MOVE_TO));
					topStartPoint=commandStack.addItem(new CommandStackItem(CommandStackItem.LINE_TO));
					topMidPoint=commandStack.addItem(new CommandStackItem(CommandStackItem.LINE_TO));
					topEndPoint=commandStack.addItem(new CommandStackItem(CommandStackItem.LINE_TO));
					topLine = commandStack.addItem(new CommandStackItem(CommandStackItem.LINE_TO));
					
					topRightCorner1=commandStack.addItem(new CommandStackItem(CommandStackItem.CURVE_TO));
					topRightCorner2=commandStack.addItem(new CommandStackItem(CommandStackItem.CURVE_TO));
					
					rightStartPoint=commandStack.addItem(new CommandStackItem(CommandStackItem.LINE_TO));
					rightMidPoint=commandStack.addItem(new CommandStackItem(CommandStackItem.LINE_TO));
					rightEndPoint=commandStack.addItem(new CommandStackItem(CommandStackItem.LINE_TO));
					
					rightLine=commandStack.addItem(new CommandStackItem(CommandStackItem.LINE_TO));
					
					bottomRightCorner1=commandStack.addItem(new CommandStackItem(CommandStackItem.CURVE_TO));
					bottomRightCorner2=commandStack.addItem(new CommandStackItem(CommandStackItem.CURVE_TO));

					bottomStartPoint=commandStack.addItem(new CommandStackItem(CommandStackItem.LINE_TO));
					bottomMidPoint=commandStack.addItem(new CommandStackItem(CommandStackItem.LINE_TO));
					bottomEndPoint=commandStack.addItem(new CommandStackItem(CommandStackItem.LINE_TO));
					
					bottomLine=commandStack.addItem(new CommandStackItem(CommandStackItem.LINE_TO));
					
					bottomLeftCorner1=commandStack.addItem(new CommandStackItem(CommandStackItem.CURVE_TO));
					bottomLeftCorner2=commandStack.addItem(new CommandStackItem(CommandStackItem.CURVE_TO));
					
					leftStartPoint=commandStack.addItem(new CommandStackItem(CommandStackItem.LINE_TO));
					leftMidPoint=commandStack.addItem(new CommandStackItem(CommandStackItem.LINE_TO));
					leftEndPoint=commandStack.addItem(new CommandStackItem(CommandStackItem.LINE_TO));
					
					leftLine=commandStack.addItem(new CommandStackItem(CommandStackItem.LINE_TO));
					
					topLeftCorner1=commandStack.addItem(new CommandStackItem(CommandStackItem.CURVE_TO));
					topLeftCorner2=commandStack.addItem(new CommandStackItem(CommandStackItem.CURVE_TO));
					
				}
				
				topStartPoint.skip = topMidPoint.skip = topEndPoint.skip =
					rightStartPoint.skip = rightMidPoint.skip = rightEndPoint.skip =
					bottomStartPoint.skip = bottomMidPoint.skip = bottomEndPoint.skip =
					leftStartPoint.skip = leftMidPoint.skip = leftEndPoint.skip = true;
				
				updateCommandStack();
				
				invalidated = false;
			}
			
		}
		
		/**
		 * Performs the specific layout work required by this Geometry.
		 * @param childBounds the bounds to be layed out. If not specified a rectangle
		 * of (0,0,1,1) is used. 
		 **/
		override public function calculateLayout(childBounds:Rectangle=null):void{
			
			if(_layoutConstraint){
				if (_layoutConstraint.invalidated){
					var tempLayoutRect:Rectangle = new Rectangle(0,0,1,1);
					
					if(_width){
						tempLayoutRect.width = _width;
					}
					
					if(_height){
						tempLayoutRect.height = _height;
					}
					
					if(_x){
						tempLayoutRect.x = _x;
					}
					
					if(_y){
						tempLayoutRect.y = _y;
					}
					
					super.calculateLayout(tempLayoutRect);	
					_layoutRectangle = _layoutConstraint.layoutRectangle;
					
					
					if (isNaN(_width) || isNaN(_height)) {
						//layout defined initial state
						_width = layoutRectangle.width;
						_height = layoutRectangle.height;
						_x = layoutRectangle.x;
						_y = layoutRectangle.y;
						invalidated = true;
					}
					
				}
			}
		}
		
		/**
		 * Begins the draw phase for geometry objects. All geometry objects 
		 * override this to do their specific rendering.
		 * 
		 * @param graphics The current context to draw to.
		 * @param rc A Rectangle object used for fill bounds. 
		 **/		
		override public function draw(graphics:Graphics,rc:Rectangle):void{			
			
			//init the layout in this case done before predraw.
			if(_layoutConstraint) calculateLayout();
			
			//re init if required
			if (invalidated) preDraw();
			
			super.draw(graphics,(rc)? rc:bounds);
		}
		
		/**
		 * An object to derive this objects properties from. When specified this 
		 * object will derive it's unspecified properties from the passed object.
		 **/
		public function set derive(value:RoundedRectCallout):void{
			
			if (!fill){fill=value.fill;}
			if (!stroke){stroke = value.stroke;}
			if (!_x){_x = value.x;}
			if (!_y){_y = value.y;}
			if (!_width){_width = value.width;}
			if (!_height){_height = value.height;}
			if (!_cornerRadius) { _cornerRadius = value.cornerRadius; }
			if (isNaN(_permitCornerInversion)) { _permitCornerInversion = value.permitCornerInversion?1:0; }
		}
		
		/**
		 * Get the the zone number of the tail position
		 * Return: an integer with 3 bits to indicate the zone value
		 * Bit 0: 0 means it's left/right side, 1 means top/bottom
		 * Bit 1: 0 means top half, 1 means bottom half
		 * Bit 2: 0 means right half, 1 means left half
		 */
		protected function getZone():int
		{
			var center_x:Number = x + width / 2;
			var center_y:Number = y + height / 2;
			var angle_tail:Number = Math.atan2(_outY - center_y, _outX - center_x);
			var angle_rect:Number = Math.atan2(height, width);
			
			var angle_tail_abs:Number = Math.abs(angle_tail);
			var zone_number:int = 0;
			zone_number += int(Math.abs(Math.PI/2 - angle_tail_abs) < (Math.PI/2 - angle_rect));
			zone_number += 2 * int(angle_tail > 0);
			zone_number += 4 * int(angle_tail_abs > (Math.PI / 2));
			
			tailZone = zone_number;
			trace("zone: " + tailZone.toString());
			return zone_number;
		}

		protected function redraw(adjx:Number=0, adjy:Number=0):void
		{
			var zone_number:int = getZone();
			trace(zone_number);
			var poly_points:Array = new Array();
			
			var p_left:int = x;
			var p_top:int = y;
			var p_right:int = x + width - adjx;
			var p_bot:int = y + height - adjy;
			var h_unit:Number = width / 5;
			var v_unit:Number = height / 5;
			
			switch (zone_number)
			{
				case 0:
					rightStartPoint.x = p_right;
					rightStartPoint.y = p_top + v_unit;
					rightMidPoint.x = _outX;
					rightMidPoint.y = _outY;
					rightEndPoint.x = p_right;
					rightEndPoint.y = p_top + v_unit * 2;
					rightStartPoint.skip = rightMidPoint.skip = rightEndPoint.skip = false;
					break;
				case 1:
					topStartPoint.x = p_left + h_unit * 3;
					topStartPoint.y = p_top;
					topMidPoint.x = _outX;
					topMidPoint.y = _outY;
					topEndPoint.x = p_left + h_unit * 4;
					topEndPoint.y = p_top;
					topStartPoint.skip = topMidPoint.skip = topEndPoint.skip = false;
					break;
				case 2:
					rightStartPoint.x = p_right;
					rightStartPoint.y = p_top + v_unit * 3;
					rightMidPoint.x = _outX;
					rightMidPoint.y = _outY;
					rightEndPoint.x = p_right;
					rightEndPoint.y = p_top + v_unit * 4;
					rightStartPoint.skip = rightMidPoint.skip = rightEndPoint.skip = false;
					break;
				case 3:
					bottomStartPoint.x = p_left + h_unit * 4;
					bottomStartPoint.y = p_bot;
					bottomMidPoint.x = _outX;
					bottomMidPoint.y = _outY;
					bottomEndPoint.x = p_left + h_unit * 3;
					bottomEndPoint.y = p_bot;
					bottomStartPoint.skip = bottomMidPoint.skip = bottomEndPoint.skip = false;
					break;
				case 4:
					leftStartPoint.x = p_left;
					leftStartPoint.y = 	p_top + v_unit * 2;
					leftMidPoint.x = _outX;
					leftMidPoint.y = _outY;
					leftEndPoint.x = p_left;
					leftEndPoint.y = p_top + v_unit;
					leftStartPoint.skip = leftMidPoint.skip = leftEndPoint.skip = false;
					break;
				case 5:
					topStartPoint.x = p_left + h_unit;
					topStartPoint.y = p_top;
					topMidPoint.x = _outX;
					topMidPoint.y = _outY;
					topEndPoint.x = p_left + h_unit * 2;
					topEndPoint.y = p_top;
					topStartPoint.skip = topMidPoint.skip = topEndPoint.skip = false;
					break;
				case 6:
					leftStartPoint.x = p_left;
					leftStartPoint.y = 	p_top + v_unit * 4;
					leftMidPoint.x = _outX;
					leftMidPoint.y = _outY;
					leftEndPoint.x = p_left;
					leftEndPoint.y = p_top + v_unit * 3;
					leftStartPoint.skip = leftMidPoint.skip = leftEndPoint.skip = false;
					break;
				case 7:
					bottomStartPoint.x = p_left + h_unit * 2;
					bottomStartPoint.y = p_bot;
					bottomMidPoint.x = _outX;
					bottomMidPoint.y = _outY;
					bottomEndPoint.x = p_left + h_unit;
					bottomEndPoint.y = p_bot;
					bottomStartPoint.skip = bottomMidPoint.skip = bottomEndPoint.skip = false;
					break;
			}
		}
	}
}