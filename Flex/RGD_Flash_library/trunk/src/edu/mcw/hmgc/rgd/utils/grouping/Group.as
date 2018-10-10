package edu.mcw.hmgc.rgd.utils.grouping
{
	import edu.mcw.hmgc.rgd.diagrammer.shapes.RectCalloutShape;

	public class Group extends GroupElement
	{
		private var _elements:Array = [];
		public function get elements():Array
		{
			return _elements;
		}
		
		public function getAllLeaves(starting_group:Group=null, return_array:Array=null, include_sub_groups:Boolean=true):Array
		{
			if (return_array == null) return_array = [];
			if (starting_group == null) starting_group = this;
			
			for each (var obj:GroupElement in starting_group.elements)
			{
				if (obj.isLeaf) 
				{
					return_array.push(obj);
				} 
				else
				{
					if (include_sub_groups) getAllLeaves(obj as Group, return_array);
				}
			}
			
			return return_array;
		}
		
		public function getAllObjects(include_sub_groups:Boolean=true):Array
		{
			var return_array:Array = [];
			for each (var element:GroupElement in getAllLeaves(null, null, include_sub_groups))
			{
				return_array.push(element.object);
			}
			return return_array;
		}
		
		public function hasElement(obj:GroupElement):Boolean
		{
			return (_elements.indexOf(obj) >= 0);
		}
		
		public function hasObject(obj_in:Object):Boolean
		{
			var obj:Object;
			if (obj_in == null) return false;
			var leaves:Array = getAllLeaves();
			if (obj_in is RectCalloutShape) {
				obj = RectCalloutShape(obj_in).bodyModel;	
			} else if (obj_in.hasOwnProperty("model")) {
				obj = obj_in.model;
			} else {
				obj = obj_in;
			}
			for each (var a_leaf:GroupElement in leaves)
			{
				if (a_leaf.object == obj) return true;
			}
			return false;
		}
		
		public function getElementByObject(obj:Object):GroupElement
		{
			var leaves:Array = getAllLeaves();
			for each (var a_leaf:GroupElement in leaves)
			{
				if (a_leaf.object == obj) return a_leaf;
			}
			return null;
		}
		
		public function addElement(obj:GroupElement):uint
		{
			if (!hasElement(obj))
			{
				obj.parent = this;
				return _elements.push(obj);
			}
			else 
				return _elements.length;
		}
		
		public function removeElement(obj:GroupElement):uint
		{
			if (obj != null && hasElement(obj)) 
			{
				obj.parent = null;
				_elements.splice(_elements.indexOf(obj), 1);
			}
			return _elements.length;
		}
		
		public function clearElements():void
		{
			_elements = [];
		}
		
		public static function merge(group1:Group, group2:Group):Group
		{
			var return_group:Group = new Group();

			var elements3:Array = return_group.elements;
			var obj:Object;

			for each (obj in group1.elements)
			{
				elements3.push(obj);
			};
			for each (obj in group2.elements)
			{
				elements3.push(obj);
			};
			
			return return_group;
		}
		
		public function destroy():void
		{
			for each (var obj:GroupElement in _elements)
			{
				obj.parent = null;
			}
			_elements = [];
		}
		
		public function Group()
		{
			isLeaf = false;			
		}
		
		public function get elementProperties():XMLList
		{
			var xml_string:String = new String();
			for each (var element:GroupElement in _elements)
			{
				xml_string += ("<element>" + element.properties
					+ "</element>");
			} 
			return new XMLList(xml_string);
		}
	}
}