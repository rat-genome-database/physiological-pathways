package edu.mcw.hmgc.rgd.utils.grouping
{
	import flash.utils.Dictionary;

	public class Grouper
	{
		private var _objIndex:Dictionary = new Dictionary();
		private var _objDirectIndex:Dictionary = new Dictionary();
		
		private var _groups:Array = [];
		public function get groups():Array
		{
			return _groups;
		}
		
		public function Grouper()
		{
		}
		
		public function groupObjects(objects:Array):int
		{
			if (objects == null || objects.length == 0) return _groups.length;
			var new_group:Group = new Group();
			new_group.grouper = this;
			for each (var obj:Object in objects)
			{
				var an_element:GroupElement;
				if (_objIndex[obj] == null) // If the obj is not in a group
				{
					an_element = new GroupElement(obj);
					an_element.parent = new_group;
					an_element.grouper = this;
					new_group.addElement(an_element);
					_objDirectIndex[obj] = new_group;
				}
				else 
				{
					new_group.addElement(_objIndex[obj]);
					Group(_objIndex[obj]).parent = new_group;
				}
				_objIndex[obj] = new_group;
			}
			return _groups.push(new_group);
		}
		
		public function ungroupObjects(objects:Array):int
		{
			var groups:Array = [];
			
			// Keep records of the object-group relationship
			for each (var obj:Object in objects)
			{
				groups.push(_objIndex[obj]);
			}
			
			for each (var group:Group in groups)
			{
				ungroupGroup(group);
			}
			return _groups.length;
		}
		
		public function ungroupGroup(group:Group):int
		{
			if (_groups.indexOf(group) >= 0)
			{
				// Update object-group index
				for each (var element:GroupElement in group.elements)
				{
					if (element.isLeaf)
					{
						delete _objIndex[element.object]; 
						delete _objDirectIndex[element.object];
					}
					else 
					{
						for each (var a_sub_leaf:GroupElement in Group(element).getAllLeaves())
						{
							_objIndex[a_sub_leaf.object] = element;
						}
					}
				}
				
				group.destroy();
				return _groups.splice(_groups.indexOf(group), 1);
			}
			else
			{
				return -1;
			}
		}
		
		public function objectGrouped(object:Object):Boolean
		{
			return(_objIndex[object] != null); 
		}
		
		public function topGroup(object:Object):Group
		{
			return _objIndex[object];
		}
		
		public function directGroup(object:Object):Group
		{
			return _objDirectIndex[object];
		}

		public function get properties():XMLList
		{
			var xml_str:String = new String();
			for (var group_id:Number = 0; group_id < _groups.length; group_id ++)
			{
				var group:Group = _groups[group_id];
				var group_xml:XMLList = new XMLList("<group></group>");
				group_xml.@id = group_id;
				group_xml.appendChild(group.elementProperties);
				xml_str += group_xml.toXMLString();
			}
			return new XMLList(xml_str);
		}
		
		public function getGroupID(group:Group):Number
		{
			return (_groups.indexOf(group));
		}
		
		public function getGroupByID(group_id:Number):Group
		{
			if (group_id >= 0 && group_id < _groups.length)
			{
				return _groups[group_id];
			}
			else 
			{
				return null;
			}
		}
	}
}