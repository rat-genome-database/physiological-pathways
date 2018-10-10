package edu.mcw.hmgc.rgd.utils
{
	public class MathUtil
	{
		public function MathUtil()
		{
		}
		
		static public function getSign(value:Number):Number
		{
			return (value >= 0 ? 1 : -1);
		}
	}
}