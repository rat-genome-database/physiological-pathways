package edu.mcw.hmgc.rgd.utils
{
	import com.famfamfam.silk.IconLibrary;
	
	import edu.mcw.hmgc.rgd.diagrammer.events.InnerDiagramEvent;
	import edu.mcw.hmgc.rgd.popups.SingleImage;
	
	import flash.display.DisplayObject;
	import flash.display.StageDisplayState;
	import flash.external.ExternalInterface;
	
	import mx.controls.Alert;
	import mx.core.Application;
	import mx.formatters.SwitchSymbolFormatter;
	import mx.managers.PopUpManager;

	public class WEBUtils
	{
		public function WEBUtils()
		{
		}
		
		static public function navigateToURL(url:String, target : String="_blank"):void
		{
			if (embed(url)) return;
			openURLinPopup(url, target);
		}

		static public function openURLinPopup(url:String, target : String="_blank"):void
		{
			var success : Boolean = ExternalInterface.call( "openURL", url, target );
			if ( !success )
				Alert.show( "Pop-up Blocker detected. Please disable it.", "Error", 4, null, null, IconLibrary.EXCLAMATION );			
		}
		
		static public function setPageTitle(title_str:String):void
		{
			ExternalInterface.call( "myMovie_DoFSCommand", "changeTitle", title_str );
		}
		
		static public function setPageDescription(des_str:String):void
		{
			ExternalInterface.call( "myMovie_DoFSCommand", "changeDescription", des_str );
		}
		
		static protected function embed(url:String):Boolean
		{
			// Exit FULL_SCREEN mode becuase IFrame won't work
			if (Application.application.stage.displayState == StageDisplayState.FULL_SCREEN) {
				Application.application.stage.displayState = StageDisplayState.NORMAL;					
			};
			
			// Won't embed if the site is not in RGD
			if (url.indexOf("rgd.mcw.edu") <0)
			{
				openURLinPopup(url, "ppp_player_popup");
				return true;
			} else
			{
				var new_url:String = "http://rgd.mcw.edu/rgdweb/pathway/chart.html?type=map&acc_id=PW";
				// Get PW id
				var pw_index:int = url.indexOf("PW:");
				
				if (url.indexOf("pathwayRecord.html?") > 0 && pw_index > 0)
				{
					var PW_ID:String = url.substr(pw_index + 3, 7);
					Application.application.switchToEmbedded(new_url + PW_ID, url);
					return true;
				} else
				{
					Application.application.switchToEmbedded(url);
					return true;
				}
			}
		}
		
		static public function getURL():String
		{
			return ExternalInterface.call("getURL");
		}
		
		static private var _popup:SingleImage;
		
		static public function processURL(url:String, event:Object):void
		{
			var urlType:String = StrUtil.getURLType(url).toLowerCase();
			switch (urlType) {
				case "http":
					//						navigateToURL(new URLRequest(url));
					WEBUtils.navigateToURL(url);
					break;
				case "diagram":
					var event_to_dispatch:InnerDiagramEvent = new InnerDiagramEvent("OpenInnerDiagram");
					event_to_dispatch.objClicked = event.target;
					event_to_dispatch.fileName = StrUtil.getDiagramNameFromURL(url);
					Application.application.dispatchEvent(event_to_dispatch);
					break;
				case "image":
					_popup = new SingleImage();
					_popup.imageName = StrUtil.getURLObject(url);
					PopUpManager.addPopUp(_popup, Application.application as DisplayObject, true);
					PopUpManager.centerPopUp(_popup);
					break;
			}
		}
	}
}