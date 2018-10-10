package edu.mcw.hmgc.rgd.utils
{
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BitmapFilterType;
	import flash.filters.DropShadowFilter;
	import flash.filters.GradientGlowFilter;
	
	import mx.effects.Fade;
	import mx.effects.Sequence;
	import mx.effects.Zoom;
	import mx.events.DropdownEvent;

	public class FilterUtility extends Object
	{
		static public var defaultColor:int = 0xFF0000;
		
		public function FilterUtility()
		{
			super();
			
		}

		static public function generateSimpleGlower(color:Object=null):GradientGlowFilter {
			if (color == null) color = defaultColor.toString();
			var gradientGlow:GradientGlowFilter = new GradientGlowFilter();
			gradientGlow.distance = 0;
			gradientGlow.angle = 45;
			gradientGlow.colors = [color, color];
			gradientGlow.alphas = [0, 1];
			gradientGlow.ratios = [0, 255];
			gradientGlow.blurX = 16;
			gradientGlow.blurY = 16;
			gradientGlow.strength = 2;
			gradientGlow.quality = BitmapFilterQuality.HIGH;
			gradientGlow.type = BitmapFilterType.OUTER;
			
			return gradientGlow;
		}
		
		static public function generateFlickerFilter(alphaTo:Number=.6, duration:Number = 1000, target:Object = null):Sequence{
			var seq:Sequence = new Sequence();
			var fade_out:Fade = new Fade();
			fade_out.alphaFrom = 1;
			fade_out.alphaTo = alphaTo;
			fade_out.duration = duration;
			var fade_in:Fade = new Fade();
			fade_in.alphaFrom = alphaTo;
			fade_in.alphaTo = 1;
			fade_in.duration =  duration / 2;
			seq.children = [fade_out, fade_in];
			if (target != null) seq.target = target;
			return seq;
		}

		static public function generateZoomInOutFilter(widthTo:Number=1.2, duration:Number = 1000, target:Object = null):Sequence{
			var seq:Sequence = new Sequence();
			var zoom_in:Zoom = new Zoom();
			zoom_in.duration = duration;
			zoom_in.zoomHeightFrom = 1;
			zoom_in.zoomWidthFrom = 1;
			zoom_in.zoomHeightTo = widthTo;
			zoom_in.zoomWidthTo = widthTo;
			
			var zoom_out:Zoom = new Zoom();
			zoom_out.duration = duration / 5;
			zoom_out.zoomHeightFrom = widthTo;
			zoom_out.zoomWidthFrom = widthTo;
			zoom_out.zoomHeightTo = 1;
			zoom_out.zoomWidthTo = 1;
			seq.children = [zoom_in, zoom_out];
			if (target != null) seq.target = target;
			return seq;
		}

		static public function makeRaisedButton(obj:Object):void {
			var filter_obj:DropShadowFilter = findDropShadowFilter(obj); 
			if (filter_obj == null) {
				obj.x -= 3;
				obj.y -= 3;
				obj.filters.splice(0, 0, new DropShadowFilter());						
			} else {
				filter_obj.angle = 45;
			}
			obj.filters = obj.filters;
		} 
		
		static public function makeDroppedButton(obj:Object):void {
			var filter_obj:DropShadowFilter = findDropShadowFilter(obj); 
			if (filter_obj == null) {
//				filter_obj = new DropShadowFilter();
//				filter_obj.angle = -135;
//				obj.filters.splice(0, 0, filter_obj);						
			} else {
				obj.filters.splice(0, 1);
				obj.x += 3;
				obj.y += 3;
				obj.filters = obj.filters;
			}
		} 
		
		static public function findDropShadowFilter(obj:Object):DropShadowFilter {
			if (!obj.hasOwnProperty("filters") || obj.filters == null) return null;
			for each (var filter_obj:Object in obj.filters)
			{
				if (filter_obj is DropShadowFilter) return filter_obj as DropShadowFilter;
			}
			return null;
		}
		
		static public function makeButton(obj:Object):void {
//			obj.filters.splice(0, 0, new DropShadowFilter());
			obj.buttonMode = true;
//			GraphicsUtil.createHitArea(obj);

			obj.addEventListener(MouseEvent.MOUSE_MOVE, 
				function (event:MouseEvent):void {
					makeRaisedButton(event.target);
				}
			);

			obj.addEventListener(MouseEvent.MOUSE_DOWN, 
				function (event:MouseEvent):void {
					makeDroppedButton(event.target);
				}
			);
				
			obj.addEventListener(MouseEvent.MOUSE_UP, 
				function (event:MouseEvent):void {
					makeRaisedButton(event.target);
				}
			);

			obj.addEventListener(MouseEvent.ROLL_OUT, 
				function (event:MouseEvent):void {
					makeDroppedButton(event.target);
				}
			);
//			obj.filters = obj.filters;
		}
		
		static public function addOutlineFilter(obj:Object,
												shadow_color:Number=0xFFFFFF,
												shadow_alpha:Number=.9,
												shadow_blur:Number=0,
												shadow_distance:Number=1):void
		{
			if (obj == null || !obj.hasOwnProperty("filters")) return;
			var filters:Array = obj.filters;
			var shadow0:DropShadowFilter = new DropShadowFilter(shadow_distance, 0, shadow_color, shadow_alpha, shadow_blur, shadow_blur);
			var shadow1:DropShadowFilter = new DropShadowFilter(shadow_distance, 90, shadow_color, shadow_alpha, shadow_blur, shadow_blur);
			var shadow2:DropShadowFilter = new DropShadowFilter(shadow_distance, 180, shadow_color, shadow_alpha, shadow_blur, shadow_blur);
			var shadow3:DropShadowFilter = new DropShadowFilter(shadow_distance, -90, shadow_color, shadow_alpha, shadow_blur, shadow_blur);
			filters.unshift(shadow0, shadow1, shadow2, shadow3);
			obj.filters = filters;
			return;
		}
			
		static public function addEmbossFilter(obj:Object):void
		{
			if (obj == null || !obj.hasOwnProperty("filters")) return;
			var filters:Array = obj.filters;
			var shadow_color:Number = 0x000000;
			var light_color:Number = 0xFFFFFF;
			var shadow_blur:Number = 1;
			var shadow_blur1:Number = 1;
			var shadow_distance:Number = 1;
			var shadow_alpha:Number = .8;
			var shadow0:DropShadowFilter = new DropShadowFilter(shadow_distance, 30, light_color, shadow_alpha, shadow_blur1, shadow_blur1, 6, 1);
			var shadow2:DropShadowFilter = new DropShadowFilter(shadow_distance, 60, light_color, shadow_alpha, shadow_blur1, shadow_blur1, 6, 1);
			var shadow1:DropShadowFilter = new DropShadowFilter(shadow_distance, 30, shadow_color, shadow_alpha/2, shadow_blur, shadow_blur, 4, 1, true);
			var shadow3:DropShadowFilter = new DropShadowFilter(shadow_distance, 60, shadow_color, shadow_alpha/2, shadow_blur, shadow_blur, 4, 1, true);
//			var shadow2:DropShadowFilter = new DropShadowFilter(shadow_distance, -45, shadow_color, shadow_alpha, shadow_blur, shadow_blur, 1, 1, true);
//			var shadow3:DropShadowFilter = new DropShadowFilter(shadow_distance, 135, light_color, shadow_alpha, shadow_blur, shadow_blur);
//			filters.unshift(shadow0, shadow1, shadow2, shadow3);
			filters.unshift(shadow0, shadow1, shadow2, shadow3);
			obj.filters = filters;
			return;
		}

		static public function addDropShadowFilter(obj:Object, shadow_color:Number=0xFFFFFF,
												   shadow_blur:Number=0, shadow_distance:Number=1,
												   shadow_alpha:Number=.8
		                                           ):void
		{
			if (obj == null || !obj.hasOwnProperty("filters")) return;
			var filters:Array = obj.filters;
			var shadow0:DropShadowFilter = new DropShadowFilter(shadow_distance, 30, shadow_color, shadow_alpha, shadow_blur, shadow_blur);
			var shadow2:DropShadowFilter = new DropShadowFilter(shadow_distance, 60, shadow_color, shadow_alpha, shadow_blur, shadow_blur);
//			var shadow1:DropShadowFilter = new DropShadowFilter(shadow_distance, 30, shadow_color, shadow_alpha/2, shadow_blur, shadow_blur, 4, 1, true);
//			var shadow3:DropShadowFilter = new DropShadowFilter(shadow_distance, 60, shadow_color, shadow_alpha/2, shadow_blur, shadow_blur, 4, 1, true);
			//			var shadow2:DropShadowFilter = new DropShadowFilter(shadow_distance, -45, shadow_color, shadow_alpha, shadow_blur, shadow_blur, 1, 1, true);
			//			var shadow3:DropShadowFilter = new DropShadowFilter(shadow_distance, 135, light_color, shadow_alpha, shadow_blur, shadow_blur);
			//			filters.unshift(shadow0, shadow1, shadow2, shadow3);
			filters.unshift(shadow0, shadow2);
			obj.filters = filters;
			return;
		}
	}
}