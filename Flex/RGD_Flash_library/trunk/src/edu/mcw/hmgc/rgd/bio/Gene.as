package edu.mcw.hmgc.rgd.bio
{
	import mx.controls.Alert;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.RemoteObject;

	public class Gene
	{
		
		public var symbol:String;

		[Bindable]
		public var rgdID:int = -2;
		public var name:String;
		public var key:int;
		public var geneFunction:String;
		public var description:String;
		public var notes:String;
		public var type:String;
		public var speciyTypeKey:int;
		public var product:String;
		
		public function Gene()
		{
		}
		
		public function getInfo():void
		{
			var remoteO:RemoteObject = new RemoteObject("CreatingRpc");
			
			remoteO.getGeneInfo.addEventListener(ResultEvent.RESULT, onResult);
			remoteO.getGeneInfo.addEventListener(FaultEvent.FAULT, onFault);
			remoteO.getGeneInfo(symbol, "");
		}
		
		protected function onResult(event:ResultEvent):void
		{
//			Alert.show(event.result as String);
			var xml:XML = new XML(event.result);
			description = xml.@description;
			rgdID = xml.@rgdID;
		}
		
		protected function onFault(event:FaultEvent):void
		{
			Alert.show(event.toString());
		}
		
	}
}