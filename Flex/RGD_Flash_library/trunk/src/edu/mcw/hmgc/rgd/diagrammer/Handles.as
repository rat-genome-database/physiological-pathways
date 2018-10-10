package edu.mcw.hmgc.rgd.diagrammer
{
	import com.roguedevelopment.objecthandles.HandleDescription;
	import com.roguedevelopment.objecthandles.HandleRoles;
	
	import flash.geom.Point;

	public class Handles
	{
		public static const POINT:Array = [new HandleDescription( HandleRoles.MOVE, new Point(50, 50),
			new Point(0, 0))];

		public static const FULL:Array = [ new HandleDescription( HandleRoles.RESIZE_UP + HandleRoles.RESIZE_LEFT, 
			new Point(0,0) ,
			new Point(0,0) ),
			new HandleDescription( HandleRoles.RESIZE_UP + HandleRoles.RESIZE_RIGHT,
				new Point(100,0) ,
				new Point(0,0) ),
			new HandleDescription( HandleRoles.RESIZE_DOWN + HandleRoles.RESIZE_RIGHT,
				new Point(100,100) , 
				new Point(0,0) ),
			new HandleDescription( HandleRoles.RESIZE_UP ,
				new Point(50,0) , 
				new Point(0,0) ),
			new HandleDescription( HandleRoles.RESIZE_RIGHT,
				new Point(100,50) , 
				new Point(0,0) ),
			new HandleDescription( HandleRoles.RESIZE_DOWN ,
				new Point(50,100) ,
				new Point(0,0) ),
			new HandleDescription( HandleRoles.RESIZE_LEFT,
				new Point(0,50) ,
				new Point(0,0) ),
			new HandleDescription( HandleRoles.ROTATE,
				new Point(50,0) , 
				new Point(0,-30) ),
			new HandleDescription( HandleRoles.RESIZE_DOWN + HandleRoles.RESIZE_LEFT,
				new Point(0,100) ,
				new Point(0,0) )
		];
		
		public static const NO_ROTATE:Array = [ new HandleDescription( HandleRoles.RESIZE_UP + HandleRoles.RESIZE_LEFT, 
			new Point(0,0) ,
			new Point(0,0) ),
			new HandleDescription( HandleRoles.RESIZE_UP + HandleRoles.RESIZE_RIGHT,
				new Point(100,0) ,
				new Point(0,0) ),
			new HandleDescription( HandleRoles.RESIZE_DOWN + HandleRoles.RESIZE_RIGHT,
				new Point(100,100) , 
				new Point(0,0) ),
			new HandleDescription( HandleRoles.RESIZE_UP ,
				new Point(50,0) , 
				new Point(0,0) ),
			new HandleDescription( HandleRoles.RESIZE_RIGHT,
				new Point(100,50) , 
				new Point(0,0) ),
			new HandleDescription( HandleRoles.RESIZE_DOWN ,
				new Point(50,100) ,
				new Point(0,0) ),
			new HandleDescription( HandleRoles.RESIZE_LEFT,
				new Point(0,50) ,
				new Point(0,0) ),
			new HandleDescription( HandleRoles.RESIZE_DOWN + HandleRoles.RESIZE_LEFT,
				new Point(0,100) ,
				new Point(0,0) )
		];
		
		private static const LINK_CONTROL_SIZE:int = 10;
		public static const LINK_CONTROL:Array = [ 
			new HandleDescription( HandleRoles.NO_ROLE, 
				new Point(0,0) ,
				new Point(-LINK_CONTROL_SIZE,-LINK_CONTROL_SIZE) ), 
			new HandleDescription( HandleRoles.NO_ROLE, 
				new Point(100,0) ,
				new Point(LINK_CONTROL_SIZE,-LINK_CONTROL_SIZE) ),
			new HandleDescription( HandleRoles.NO_ROLE, 
				new Point(100,100) , 
				new Point(LINK_CONTROL_SIZE,LINK_CONTROL_SIZE) ),
			new HandleDescription( HandleRoles.NO_ROLE, 
				new Point(0,100) ,
				new Point(-LINK_CONTROL_SIZE,LINK_CONTROL_SIZE) )
		];
		
		public function Handles()
		{
		}
	}
}