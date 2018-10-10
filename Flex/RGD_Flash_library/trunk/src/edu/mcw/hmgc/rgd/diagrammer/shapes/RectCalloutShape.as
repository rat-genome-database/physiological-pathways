package edu.mcw.hmgc.rgd.diagrammer.shapes
{
	import com.degrafa.GeometryComposition;
	import com.degrafa.geometry.Polygon;
	import com.degrafa.geometry.RoundedRectangle;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.sampler.getGetterInvocationCount;
	
	public class RectCalloutShape extends CalloutShape
	{

		public function RectCalloutShape()
		{
			_type = TYPE_RECT;
			super();
		}
		
		override public function redraw():void
		{
			
			var p_left:int = _bodyModel.x - _model.x;
			var p_top:int = _bodyModel.y - _model.y;
			var p_tail:Point = new Point(_tailModel.x - _model.x, _tailModel.y - _model.y);
			
			_rounded_rect.x = p_left;
			_rounded_rect.y = p_top;
			_rounded_rect.width = _bodyModel.width;
			_rounded_rect.height = _bodyModel.height;
			_rounded_rect.outX = p_tail.x;
			_rounded_rect.outY = p_tail.y;
		}
	}
}