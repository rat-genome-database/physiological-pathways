package edu.mcw.hmgc.rgd.ui.controls
{
	import com.degrafa.GeometryComposition;
	import com.degrafa.core.IGraphicsFill;
	import com.degrafa.geometry.RasterTextPlus;
	import com.degrafa.paint.SolidFill;
	import com.degrafa.paint.SolidStroke;
	
	import edu.mcw.hmgc.rgd.utils.FilterUtility;
	
	import flash.events.MouseEvent;
	
	import mx.controls.Alert;
	import mx.core.UIComponent;

	
	public class RasterTextLabel extends UIComponent
	{
		private var _gc:GeometryComposition = new GeometryComposition();
		private var _rasterText:RasterTextPlus = new RasterTextPlus();

		public function get rasterText():RasterTextPlus
		{
			return _rasterText;
		}

		public function set rasterText(value:RasterTextPlus):void
		{
			_rasterText = value;
		}


		private var _text:String="";
		
		[Bindable]
		public function get text():String
		{
			return _text;
		}
		
		public function set text(value:String):void
		{
			if (value == _text) return;
			_text = value;
			if (_text != null) {
				rasterText.text = _text;
			}
		}

		private var _htmlText:String="";

		[Bindable]
		public function get htmlText():String
		{
			return _htmlText;
		}
		
		public function set htmlText(value:String):void
		{
			if (value == _htmlText) return;
			_htmlText = value;
			if (_htmlText != null) {
				rasterText.htmlText = _htmlText;
			}
		}
		
		private var _fontSize:Number = 12;
		
		[Bindalbe]
		public function get fontSize():Number
		{
			return _fontSize;
		}
		
		public function set fontSize(value:Number):void
		{
			if (_fontSize == value) return;
			_fontSize = value;
			rasterText.fontSize = _fontSize;
		}
		
		public function get fill():Object
		{
			return rasterText.fill;
		}
		
		public function set fill(value:Object):void
		{
			rasterText.fill = value as com.degrafa.core.IGraphicsFill;
		}
		
		public function get fontColor():Object
		{
			if (rasterText.fill is SolidFill)
			{
				return SolidFill(rasterText.fill).color;
			} else return null;
		}
		
		public function set fontColor(font_color:Object):void
		{
			if (rasterText.fill is SolidFill)
			{
				SolidFill(rasterText.fill).color = font_color;
			}
		}
		
		public function set fontWeight(font_weight:String):void
		{
			_rasterText.fontWeight = font_weight;
		}
		
		public function get fontWeight():String 
		{
			return _rasterText.fontWeight;
		}
		
		public function set fontUnderlined(font_underlined:Boolean):void
		{
			_rasterText.underline = true;
		}
		
		public function get fontUnderlined():Boolean
		{
			return _rasterText.underline;
		}
			
		public function RasterTextLabel()
		{
			super();
			var temp_fill:SolidFill = new SolidFill("#000000");
			_rasterText.fill = temp_fill;
			_rasterText.fontFamily = "Arial";
			_rasterText.fontSize = _fontSize;
			_gc.geometry = [_rasterText];
			_gc.graphicsTarget = [this];
			FilterUtility.addOutlineFilter(_rasterText);
		}
		
		public override function set height(value:Number):void
		{
			super.height = value;
			rasterText.height = height;
		}
		
		public function get textWidth():Number
		{
			return rasterText.textWidth;
		}
		
	}
}