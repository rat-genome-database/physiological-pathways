package edu.mcw.hmgc.rgd.ui.controls
{
	import com.degrafa.states.AddChild;
	import com.famfamfam.silk.IconLibrary;
	
	import edu.mcw.hmgc.rgd.graphics.ShowHideEffects;
	import edu.mcw.hmgc.rgd.utils.StrUtil;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.controls.Alert;
	import mx.controls.Button;
	import mx.controls.Image;
	import mx.controls.ToolTip;
	import mx.core.UITextField;
	import mx.effects.effectClasses.HideShowEffectTargetFilter;
	import mx.managers.ToolTipManager;
	import mx.skins.halo.ToolTipBorder;
	
	public class HTMLToolTips extends ToolTipBorder
	{
		public var closeButton:Image = null;
		
		private var _includeCloseButton:Boolean = false;
		private var _textListenerAdded:Boolean = false;
		
		public function get includeCloseButton():Boolean
		{
			return _includeCloseButton;
		}

		public function set includeCloseButton(value:Boolean):void
		{
			_includeCloseButton = value;
			closeButton.visible = _includeCloseButton;
		}

		
		public function HTMLToolTips()
		{
			this.addEventListener("added", addCloseButton);
			super();
		}
		
		protected override function updateDisplayList(w:Number, h:Number):void
		{
			var toolTip:ToolTip = (this.parent as ToolTip);
			var textField:UITextField = toolTip.getChildAt(2) as UITextField;
			textField.htmlText = StrUtil.addLinkEvent(textField.text, textField);
			textField.mouseEnabled = true;
			textField.selectable = true;
			textField.embedFonts = true;

			if (!_textListenerAdded) {
				addListerners(2);
				_textListenerAdded = true;
			}
			
			var calHeight:Number = textField.height;
			calHeight += textField.y*2;
			calHeight += textField.getStyle("paddingTop");
			calHeight += textField.getStyle("paddingBottom");
			
			var calWidth:Number = textField.textWidth;
			calWidth += textField.x*2;
			calWidth += textField.getStyle("paddingLeft");
			calWidth += textField.getStyle("paddingRight");

//			closeButton.x = width+5;
			super.updateDisplayList(calWidth, calHeight);
		}
		
		public function addCloseButton(event:Event=null):void
		{
			if (closeButton != null) return;
			closeButton = new Image();
			closeButton.addEventListener(MouseEvent.CLICK, closeButtonClick);
			closeButton.width=15;
			closeButton.height = 17;
			closeButton.x = 5;
			closeButton.y = -2 ;
			closeButton.source = IconLibrary.CANCEL;
			closeButton.visible = _includeCloseButton;
			closeButton.buttonMode = true;
			closeButton.useHandCursor = true;
			parent.addChild(closeButton);
			addListerners(0);
			addListerners(1);
		}
		
		protected function addListerners(child_id:int):void
		{
			parent.getChildAt(child_id).addEventListener(MouseEvent.MOUSE_OVER, showCloseButton);
			parent.getChildAt(child_id).addEventListener(MouseEvent.ROLL_OVER, showCloseButton);
			parent.getChildAt(child_id).addEventListener(MouseEvent.MOUSE_OUT, hangOutHandler);
			parent.getChildAt(child_id).addEventListener(MouseEvent.ROLL_OUT, hangOutHandler);
		}
		
		protected function closeButtonClick(event:Event):void
		{
			this.parent.visible = false;
		}
		
		protected function showCloseButton(event:MouseEvent):void
		{
			if (_includeCloseButton)
			{
				ShowHideEffects.showFadeIn(closeButton);
			}
		}

		protected function hangOutHandler(event:MouseEvent):void
		{
			if (_includeCloseButton)
			{
				ShowHideEffects.hideFadeOut(closeButton);
			}
		}
	}
}