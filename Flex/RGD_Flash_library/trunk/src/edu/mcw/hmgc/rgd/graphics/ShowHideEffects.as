package edu.mcw.hmgc.rgd.graphics
{
	import caurina.transitions.Tweener;
	
	import edu.mcw.hmgc.rgd.ui.controls.HTMLToolTips;
	import edu.mcw.hmgc.rgd.utils.StrUtil;
	
	import flash.events.MouseEvent;
	
	import mx.controls.Alert;
	import mx.controls.ToolTip;
	import mx.core.UITextField;
	import mx.managers.ToolTipManager;

	public class ShowHideEffects
	{
		public function ShowHideEffects()
		{
		}
		
		static public function showFadeIn(obj:Object, 
										  reset_alpha:Boolean=false,
										  fade_in_duration:Number=1, 
										  fade_in_transition:String="easeIn",
										  dest_alpha:Number=1):void
		{
			if (obj.visible == false) obj.alpha = 0;
			obj.visible = true;
			if (reset_alpha) obj.alpha = 0;
			var show_func:Function = function():void {obj.visible = true; obj.alpha = dest_alpha;};
			if (obj.hasOwnProperty("displayAlpha")) dest_alpha = obj.displayAlpha;
			Tweener.addTween(obj, {alpha:dest_alpha, time: fade_in_duration, transition:fade_in_transition, onComplete:show_func});
		}

		static public function hideFadeOut(obj:Object, 
										  check_visible:Boolean=true,
										  fade_in_duration:Number=1, 
										  fade_in_transition:String="easeOut"):void
		{
			if (check_visible && (!obj.hasOwnProperty("visible") || obj.visible == false)) return;
			var hide_func:Function = function():void {
				obj.visible = false; 
				if (obj.hasOwnProperty("displayAlpha")) { 
					obj.alpha = obj.displayAlpha;	
				} else
				{
					obj.alpha = 1;
				}
			};
			fade_in_duration = obj.alpha;
			Tweener.addTween(obj, {alpha:0, time: fade_in_duration, transition:fade_in_transition, onComplete:hide_func});
		}
		
		static public function showHideFade(obj:Object, visibile:Boolean):void
		{
			if (visibile) 
			{
				showFadeIn(obj);
			} else
			{
				hideFadeOut(obj);
			}
		}
		
		static public function hangAround(obj:Object):void
		{
			hideFadeOut(obj);
			obj.mouseEnabled = true;
			if (obj is ToolTip) {
				obj.getChildAt(0).addEventListener(MouseEvent.MOUSE_OVER, hangAroundHandler);
				obj.getChildAt(1).addEventListener(MouseEvent.MOUSE_OVER, hangAroundHandler);
			} 
//			_singleToolTip.mouseChildren = false;
			obj.addEventListener(MouseEvent.MOUSE_OVER, hangAroundHandler);
		}
		
		static protected function hangAroundHandler(event:MouseEvent):void
		{
//			Alert.show("moused over");
			var obj:Object = event.target;
			obj.removeEventListener(MouseEvent.MOUSE_OVER, hangAroundHandler);
			if (obj.parent is ToolTip) {
				showFadeIn(obj.parent);
			} else 
			{
				showFadeIn(obj);				
			}
			obj.addEventListener(MouseEvent.MOUSE_OUT, hangOutHandler);
		}
		
		static protected function hangOutHandler(event:MouseEvent):void
		{
			var obj:Object = event.target;
			obj.removeEventListener(MouseEvent.MOUSE_OUT, hangOutHandler);
			if (obj.parent is ToolTip) {
				hideFadeOut(obj.parent);
			} else 
			{
				hideFadeOut(obj);
			}
			obj.addEventListener(MouseEvent.MOUSE_OVER, hangAroundHandler);
		}
	}
}