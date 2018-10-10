package edu.mcw.hmgc.rgd.utils.grouping
{
	public class Layers
	{
		
		private var _layers:Array = [];
		private var _layeredObjects:String = "";
		public function Layers()
		{
		}
		
		public function get layeredObjects():String
		{
			return _layeredObjects;
		}

		public function set layeredObjects(value:String):void
		{
			_layeredObjects = value;
		}

		public function get layers():Array
		{
			return _layers;
		}

		public function set layers(value:Array):void
		{
			_layers = value;
		}

		public function addLayer():Layer
		{
			var new_layer:Layer = new Layer();
			new_layer.description = "";
			_layers.push(new_layer);
			return new_layer;
		}
		
		public function removeLayer(layer_index:int):int
		{
//			var layer_index:int = _layers.indexOf(layer_to_remove);
			if (layer_index >= 0)
			{
				return _layers.splice(layer_index, 1);
			}
			return -1;
		}
		
		public function addObjects(objects:Array, layer_indexes:Array=null):void
		{
			if (layer_indexes == null)
			{
				layer_indexes = [];
				for (var i:int=0; i < _layers.length; i++) layer_indexes.push(i);
			}
			
			for each (var obj:Object in objects)
			{
				for each (var j:int in layer_indexes)
				{
					var current_layer:Layer = _layers[j] as Layer;
					current_layer.addElement(new GroupElement(obj));
				}
			} 
		}
		
		public function setObjects(objects:Array, layer_indexes:Array=null):void
		{
			for each (var j:int in layer_indexes)
			{
				var current_layer:Layer = _layers[j] as Layer;
				current_layer.clearElements();
			}
			addObjects(objects, layer_indexes);
		}
		
		public function removeObjects(objects:Array, layer_indexes:Array=null):void
		{
			if (layer_indexes == null)
			{
				layer_indexes = [];
				for (var i:int=0; i < _layers.length; i++) layer_indexes.push(i);
			}
			
			for each (var obj:Object in objects)
			{
				for each (var j:int in layer_indexes)
				{
					var current_layer:Layer = _layers[j] as Layer;
					current_layer.removeElement(current_layer.getElementByObject(obj));
				}
			} 
		}

		public function get properties():XMLList
		{
			var xml_str:String = new String();
			for (var layer_id:Number = 0; layer_id < _layers.length; layer_id ++)
			{
				var layer:Layer = _layers[layer_id];
				var layer_xml:XMLList = new XMLList("<layer></layer>");
				layer_xml.@id = layer_id;
				layer_xml.appendChild(layer.elementProperties);
				xml_str += layer_xml.toXMLString();
			}
			return new XMLList(xml_str);
		}
		
		public function reset():void
		{
			_layers = [];
			_layeredObjects = "";
		}
		
//		public function getLayeredObjects():String 
//		{
//			if (_layeredObjects.length > 0) return;
//			_layeredObjects = "";
//			for each (var layer:Layer in _layers)
//			{
//				_layeredObjects += layer.getElementsStr();
//			}
//			return _layeredObjects;
//		}
//		
		public function isObjectLayered(obj:Object):Boolean
		{
			for each (var layer:Layer in _layers)
			{
				if (layer.hasObject(obj)) return true;
			}
			return false;
		}
	}
}