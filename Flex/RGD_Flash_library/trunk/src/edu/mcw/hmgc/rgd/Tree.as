package edu.mcw.hmgc.rgd
{
	import mx.controls.Tree;
	
	public class Tree extends mx.controls.Tree
	{
		public function Tree()
		{
			super();
		}

		public function get maxRowCount():Number
		{
			return collection.length;
		}
	}
	
}