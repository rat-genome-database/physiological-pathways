package edu.mcw.hmgc.rgd.utils.grouping
{
	import adobe.utils.XMLUI;
	
	import edu.mcw.hmgc.rgd.utils.Element;
	import edu.mcw.hmgc.rgd.utils.XMLUtils;
	
	import mx.effects.easing.Back;

	public class GroupElement extends Element
	{
		private var _isLeaf:Boolean = true;
		private var _parent:GroupElement = null;
		private var _object:Object = null;
		private var _grouper:Grouper = null;

		public function get grouper():Grouper
		{
			return _grouper;
		}

		public function set grouper(value:Grouper):void
		{
			_grouper = value;
		}

		public function get object():Object
		{
			return _object;
		}

		public function set object(value:Object):void
		{
			_object = value;
		}

		public function get parent():GroupElement
		{
			return _parent;
		}

		public function set parent(value:GroupElement):void
		{
			_parent = value;
		}

		public function get isLeaf():Boolean
		{
			return _isLeaf;
		}	
		
		public function set isLeaf(value:Boolean):void
		{
			_isLeaf = value;
		}
				
		public function GroupElement(obj:Object=null)
		{
			object = obj;
		}
		
		public function get properties():XMLList
		{
			var xml_string:String = new String();
			xml_string += XMLUtils.getXML("isLeaf", isLeaf);
			if (isLeaf)
			{
				if (object != null && object.hasOwnProperty("index")) xml_string += XMLUtils.getXML("objID", object.index);	
			}
			else
			{
				xml_string += XMLUtils.getXML("groupID", grouper.getGroupID(this as Group));
			}
			return new XMLList(xml_string);
		}
	}
}