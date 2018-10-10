package edu.mcw.hmgc.rgd.utils.grouping
{
	import edu.mcw.hmgc.rgd.utils.XMLUtils;

	public class Layer extends Group
	{
		private var _label:String;
		private var _description:String;
		private var _elementsString:String;
		
		public function Layer()
		{
			super();
		}

		public function get elementsString():String
		{
			return _elementsString;
		}

		public function set elementsString(value:String):void
		{
			_elementsString = value;
		}

		public function get description():String
		{
			return _description;
		}

		public function set description(value:String):void
		{
			_description = value;
		}

		public function get label():String
		{
			return _label;
		}

		public function set label(value:String):void
		{
			_label = value;
		}

		public function getElementsStr():String
		{
			var elements_str:String = new String(",");
			for each (var element:GroupElement in elements)
			{
				var obj_index:Number = element.object.index;
				if (obj_index > 0) elements_str += (obj_index.toString() + ",");
			}
			return elements_str;			
		}
		
		override public function get elementProperties():XMLList
		{
			var xml_string:String = new String();
			xml_string += XMLUtils.getXML("label", _label);
			xml_string += XMLUtils.getXML("description", XMLUtils.getNormalizedXML(_description));
			xml_string += XMLUtils.getXML("elements", getElementsStr());
			return new XMLList(xml_string);
		}
		
		public function hasElementID(element_id:int, against_elements:Boolean=true):Boolean
		{
			if (against_elements)
			{
				for each (var element:GroupElement in elements)
				{
					var obj_index:Number = element.object.index;
					if (obj_index == element_id) return true;
				}
			} else
			{
				if (_elementsString.indexOf(("," + element_id.toString() + ",")) >= 0) return true; 
			}

			return false; 
		}
	}
}