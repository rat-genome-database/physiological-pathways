package edu.mcw.hmgc.rgd.utils
{
	import mx.effects.easing.Back;

	/**
	 * A basic tracker that keeps the history of some object.
	 */
	public class HistoryTracker extends Object
	{

		static private const MAX_DEPTH:int = 30; 
		
		protected var _currentObj:Object = null;
		protected var _recordsFront:Array = new Array();
		protected var _recordsBack:Array = new Array();
		public function clearHistory():void
		{
			_recordsFront = new Array();
			dumpBack();
		}
		
		public function get currentState():Object
		{
			return _currentObj;
		}
		
		protected function dumpBack():void
		{
			_recordsBack = new Array();
		}

		protected var _maxRecords:int = MAX_DEPTH;
		public function get maxRecords():int 
		{
			return _maxRecords;
		}
		public function set maxRecords(value:int):void
		{
			_maxRecords = value;
		}
		
		public function HistoryTracker(max_records:int=MAX_DEPTH)
		{
			//TODO: implement function
			super();
			
			maxRecords = max_records;
		}
		
		/**
		 * Add object to object history.
		 */	
		public function append(obj:Object):int
		{
			if (_recordsBack.length > 0) dumpBack();
			while (_recordsFront.length > _maxRecords - 1)
			{
				_recordsFront.shift();
			}
			if (_currentObj != null) _recordsFront.push(_currentObj);
			_currentObj = obj;
			return _recordsFront.length;
		}
		
		/**
		 * Get the last object for undo operation.
		 * Returns null if undo stack is empty.
		 */
		public function undo():Object
		{
			if (_recordsFront.length == 0) return null;
			_recordsBack.push(_currentObj);
			_currentObj = _recordsFront.pop();
			return _currentObj;
		}
		
		/**
		 * Get the next object for redo operation.
		 * Return null if redo stack is empty.
		 */
		public function redo():Object
		{
			if (_recordsBack.length == 0)  return null;
			_recordsFront.push(_currentObj);
			_currentObj = _recordsBack.pop();
			return _currentObj;
		}
		
		public function get undoLength():int
		{
			return _recordsFront.length;
		}
	}
}