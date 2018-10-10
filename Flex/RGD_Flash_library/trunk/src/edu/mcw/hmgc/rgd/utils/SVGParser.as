package edu.mcw.hmgc.rgd.utils
{
	import com.degrafa.GeometryComposition;
	import com.degrafa.GeometryGroup;
	import com.degrafa.GraphicPoint;
	import com.degrafa.IGeometry;
	import com.degrafa.core.IGraphicsFill;
	import com.degrafa.core.IGraphicsStroke;
	import com.degrafa.core.collections.FillCollection;
	import com.degrafa.geometry.Circle;
	import com.degrafa.geometry.Ellipse;
	import com.degrafa.geometry.Line;
	import com.degrafa.geometry.Path;
	import com.degrafa.geometry.Polygon;
	import com.degrafa.geometry.Polyline;
	import com.degrafa.geometry.RasterText;
	import com.degrafa.geometry.RoundedRectangleComplex;
	import com.degrafa.paint.GradientStop;
	import com.degrafa.paint.LinearGradientFill;
	import com.degrafa.paint.RadialGradientFill;
	import com.degrafa.paint.SolidFill;
	import com.degrafa.paint.SolidStroke;
	import com.degrafa.transform.MatrixTransform;
	
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	import flexlib.scheduling.scheduleClasses.renderers.SolidScheduleEntryRenderer;
	
	import mx.collections.ArrayCollection;
	import mx.graphics.Stroke;

	/**
	 * Parses SVG xml and builds two lists, one for fill colours and one for path data.
	 * The fills and paths structures have a one to one relationship.
	 * 
	 */	
	public class SVGParser 
	{
		public static var TEXT_FILL:String = "fill";
		public static var TEXT_PATH:String = "path";
		public static var TEXT_RGB:String = "rgb";
		
		private var __defs:ArrayCollection = null;
		private var __geometries:ArrayCollection = null;
		private var __fills:Object = null;
		private var myPath:Path = null;
		
		private var parseHandlers:Object = null;

		private var local_g:GeometryGroup = null;
		[Bindable]
		private var local_stroke:IGraphicsStroke = null;
		[Bindable]
		private var local_fill:IGraphicsFill = null;
		[Bindable]
		private var local_width:Number;
		[Bindable]
		private var local_height:Number;
		
		private var default_stroke:SolidStroke;
		private var default_fill:SolidFill;
		
		public function SVGParser():void
		{
			
			parseHandlers = { g: parseG,
			  path: this.parsePath,
			  rect: this.parseRect,
			  circle: this.parseCircle,
			  ellipse: this.parseEllipse,
			  line: this.parseLine,
			  polyLine: this.parsePolyline,
			  polygon: this.parsePolygon,
			  symbol: this.parseG,
			  text: this.parseText,
			  font: this.parseFont,
			  
			  radialGradient: this.parseRadialGradient,
			  linearGradient: this.parseLinearGradient };
		
			__defs = new ArrayCollection();
			__geometries = new ArrayCollection();
			__fills = new Object();
			
			default_stroke = new SolidStroke(16737792, 1);
			default_fill = new SolidFill(16774638);
		}

		// This filter is for ignoring non-standard/third party elements in the SVG XML

		private function standardObjectsE4XFilter(name:String):Boolean
		{
			switch(name) {
				case "g":
				case "path":
				case "rect":
				case "circle":
				case "ellipse":
				case "line":
				case "polyline":
				case "polygon":
				case "text":
				case "radialGradient":
				case "linearGradient":
					return true;
			}
			
			return false;
		}
		
		private function defsE4XFilter(name:String):Boolean
		{
			switch(name) {
				case "defs":
					return false;
			}
			return false;
		}
		
		private function getFill(fillName:String, opacity:Number = 1):IGraphicsFill
		{ 	
			var urlRegExp:RegExp = /url\(#(.*)\)/;
			var matches:Object = urlRegExp.exec(fillName);
			if (matches) {
				fillName = matches[1];
			}
			
			if (fillName in __fills) {
				return __fills[fillName];
			}
			
			if (fillName == "none" || fillName == "") {
				var noneFill:SolidFill = new SolidFill();
				noneFill.color = 0x000000;
				noneFill.alpha = 0;
				return noneFill;	
			}
						
			var rgbVal:String = extractRGBValue(fillName);
			if (rgbVal != null) {
				fillName = rgbVal;
			}
			
			if (fillName.charAt(0) == "#" && fillName.length == 7) {
				var hexFill:SolidFill = new SolidFill();
				hexFill.color = Number("0x" + fillName.substr(1));
				hexFill.alpha = opacity;
				return hexFill;
			}
			
	
			return null;
		}
		
		private function getStroke(strokeName:String):IGraphicsStroke
		{
			if (strokeName == "none" || strokeName == "") {
				var noneStroke:SolidStroke = new SolidStroke();
				noneStroke.color = 0x000000;
				noneStroke.alpha = 0;
				return noneStroke;	
			}
			var rgbVal:String = extractRGBValue(strokeName);
			if (rgbVal != null) {
				strokeName = rgbVal;
			}
			
			if (strokeName.charAt(0) == "#" && strokeName.length == 7) {
				var hexStroke:SolidStroke = new SolidStroke();
				hexStroke.color = Number("0x" + strokeName.substr(1));
				hexStroke.alpha = 1;
				return hexStroke;
			}
			
			
			return null;
		}
		
//		private function getTransform(transformText:String):ITransform
//		{
//		}
		
		/**
		 * parse fills and paths from data.
		 * 
		 * @param data The SVG data in XML form.
		 * 
		 */
		public function parse(data:XML, parent_g:GeometryGroup):Boolean
		{
			
			// Set local variables to caller's value
			local_g = parent_g;
			
			var status:Boolean = false;
			
			var defsXML:XMLList = data.*.(defsE4XFilter(localName())).*;
			
			// Reset structures
			__defs.removeAll();
			__geometries.removeAll();
			var parsed:Object;
			if (defsXML.length() > 0) 
			{
				for each (var def:XML in defsXML)
				{
					parsed = parseHandlers[def.localName()](def);
					
					if (parsed != null) {
						if (parsed is GeometryComposition) {
							var geometry:GeometryComposition = parsed as GeometryComposition;
							__defs[geometry.id] = parsed;
						} else {
							trace("Unsupported def!!! " + def.localName());
						}
					} else {
						trace("Unsupported element!!! " + def.localName());
					}
				}
			}
			
			var geometryXML:XMLList = data.*.(standardObjectsE4XFilter(localName()));

			if (geometryXML.length()>0)
			{
				status = true;
			
				// For each line extract fill colour and path data.
				for each (var geo:XML in geometryXML)
				{
					if (!("@display" in geo && geo.@display == "none")) {
						parsed = parseHandlers[geo.localName()](geo);
						
						if (parsed != null) {
		 if (parsed is IGeometry) {
								__geometries.addItem(parseGeometry(geo, parsed as IGeometry));	
							} else {
								trace("Unsupported def!!! " + geo.localName());
							}
						} else {
							trace("Unsupported element!!! " + geo.localName());
						}
					}
		 		}
		 	}
			addPath();
		 	return status;	
		}

		private function parseGeometry(geo:XML, pGeometry:IGeometry):IGeometry
		{
					var strokeWidth:Number = 1;
					var fillOpacity:Number = 1;
					var stroke:String = null;
					var fill:String = null;					
					
					
					if ("@fill" in geo) {
						fill = extractFillValue(geo.@fill);
					} 
					
					if ("@opacity" in geo) {
						fillOpacity = Number(geo.@opacity);
					}
					
					if ("@stroke" in geo) {
						stroke = extractFillValue(geo.@stroke);
					}
					
					if ("@stroke-width" in geo) {
						strokeWidth = Number(geo.attribute("stroke-width"));
					}
					
//					if ("@transform" in geo) {
//						pGeometry.transform = getTransform(geo.@transform);
//					}
					
					if ("@style" in geo) {
						var attrPairs:Array = geo.@style.split(";");
						for each (var rawPair:Object in attrPairs) {
							var parsedPair:Array = rawPair.split(":");
							var name:String = strip(parsedPair[0]);
							var value:String;
							if (name == "fill") {
								fill = extractFillValue(strip(parsedPair[1]));
							}
							if (name == "stroke") {
								value = extractFillValue(strip(parsedPair[1]));
								if (pGeometry is RasterText) {
									var pText:RasterText = pGeometry as RasterText;
//									pText.textColor = value;
								} else {
									stroke = value;
								}
							}
							if (name == "stroke-width") {
								strokeWidth = Number(strip(parsedPair[1]));
							}
							if (name == "opacity") {
								fillOpacity = Number(value);
							}
						}
					}

			if (fill != null && myPath != null) {
				pGeometry.fill = getFill(fill, Number(fillOpacity));
				local_fill = pGeometry.fill;
				myPath.fill = local_fill;
			}
			
			if (stroke != null  && myPath != null) {
				pGeometry.stroke = getStroke(stroke);
				pGeometry.stroke.weight = strokeWidth;
				local_stroke = pGeometry.stroke;
				//				local_stroke.weight = 2;
				local_stroke.weight = strokeWidth;
				myPath.stroke = local_stroke;
			}

//			if (fill != null && stroke != null && myPath != null)	{
			
			return pGeometry;
		}

		private function parseLinearGradient(gradient:XML):void
		{	
		}
		
		private function parseRadialGradient(gradient:XML):void
		{	
		}

		private function parseText(text:XML):IGeometry 
		{
			var dText:RasterText = new RasterText();

			if ("@font-family" in text) {
				dText.fontFamily = text.attribute("font-family");
			}
			
			if ("@font-size" in text) {
				dText.fontSize = Number(text.attribute("font-size"));
			}
			
			if ("@style" in text) {
				var attrPairs:Array = text.@style.split(";");
				for each (var rawPair:Object in attrPairs) {
					var parsedPair:Array = rawPair.split(":");
					var name:String = strip(parsedPair[0]);
					if (name == "font-size") {
						dText.fontSize = 80;//Number(parsedPair[1]);
					}
					else if (name == "font-family") {
						dText.fontFamily = parsedPair[1];
					}
				}
			}
			
			if ("@x" in text) {
				dText.x = text.@x;
			} else {
				dText.x = 0;
			}
			
			if ("@y" in text) {
				dText.y = text.@y - dText.fontSize;
			} else {
				dText.y = 0;
			}
			
			dText.text = text;
			
			return dText;
		}

		private function parseCircle(circle:XML):IGeometry
		{
			var dCircle:Circle = new Circle();
			dCircle.centerX = Number(circle.@cx);
			dCircle.centerY = Number(circle.@cy);
			dCircle.radius = Number(circle.@r);
			return dCircle;
		}

		private function parseEllipse(ellipse:XML):IGeometry
		{
			
			var dEllipse:Ellipse = new Ellipse();
		
			var cx:Number;
			var cy:Number;
			var rx:Number;
			var ry:Number;
			
			if (ellipse.hasOwnProperty("@cx")) {
				cx = ellipse.@cx;
			} else {
				cx = 0;
			}
			
			if (ellipse.hasOwnProperty("@cy")) {
				cy = ellipse.@cy;
			} else {
				cy = 0;
			}
			
			rx = ellipse.@rx;
			ry = ellipse.@ry;
			
			dEllipse.x = cx - rx;
			dEllipse.y = cy - ry;
			dEllipse.width = rx*2;
			dEllipse.height = ry*2;
			return dEllipse;
		}

		private function parseG(g:XML):IGeometry
		{
			var gGroup:GeometryComposition = new GeometryComposition(); 
			
			var geometryXML:XMLList = g.*.(standardObjectsE4XFilter(localName()));

			if (geometryXML.length()>0)
			{			
				// For each line extract fill colour and path data.
				for each (var geo:XML in geometryXML)
				{
					if (!("@display" in geo && geo.@display == "none")) {
						var parsed:Object = parseHandlers[geo.localName()](geo);
						var pGeometry:IGeometry = null;
						if (parsed != null) {
							 if (parsed is IGeometry) {
								pGeometry = parseGeometry(geo, parsed as IGeometry);
								gGroup.geometryCollection.addItem(pGeometry);
							} else {
								trace("Unsupported def!!! " + geo.localName());
							}
						} else {
							trace("Unsupported element!!! " + geo.localName());
						}
					}
		 		}
		 	}
			
			if ("@id" in g) {
				gGroup.id = g.@id;
			}
			
			return gGroup;
		}
		
		private function parseLine(line:XML):IGeometry
		{
			var dLine:Line = new Line();
			dLine.x = Number(line.@x1);
			dLine.y = Number(line.@y1);
			dLine.x1 = Number(line.@x2);
			dLine.y1 = Number(line.@y2);
			return dLine;
		}
		
		private function parsePolygon(polygon:XML):IGeometry
		{
			var dPoly:Polygon = new Polygon();
			
			dPoly.x = 0;
			dPoly.y = 0;
			
			var points:Array = polygon.@points.split(" ");
			for each (var pointStr:String in points) {
				var pointVals:Array = pointStr.split(",");
				var point:GraphicPoint = new GraphicPoint();
				point.x = Number(pointVals[0]);
				point.y = Number(pointVals[1]);
				dPoly.pointCollection.addItem(point);
			}
			return dPoly;
		}
		
		private function parsePolyline(polyline:XML):IGeometry
		{
			var dPoly:Polyline = new Polyline();
			
			dPoly.x = Number(polyline.@x);
			dPoly.y = Number(polyline.@y);
			
			var points:Array = polyline.@points.split(" ");
			for each (var pointStr:String in points) {
				var pointVals:Array = pointStr.split(",");
				var point:GraphicPoint = new GraphicPoint();
				point.x = Number(pointVals[0]);
				point.y = Number(pointVals[1]);
				dPoly.pointCollection.addItem(point);
			}
			
			return dPoly;
		}
		
		private function parseRect(rect:XML):IGeometry
		{
			
			var dRect:RoundedRectangleComplex = new RoundedRectangleComplex();
			dRect.width = Number(rect.@width);
			dRect.height = Number(rect.@height);
			dRect.x = Number(rect.@x);
			dRect.y = Number(rect.@y);
			
			if (("@rx" in rect) == false) {
				if ("@ry" in rect) {
					rect.@rx = rect.@ry;
				} else {
					rect.@rx = 0;
				}
			}
			
			if (("@ry" in rect) == false) {
				if ("@rx" in rect) {
					rect.@ry = rect.@rx;
				} else {
					rect.@ry = 0;
				}
			}
			
			var averageRadius:Number = (rect.@rx + rect.@ry) / 2;
			dRect.bottomLeftRadius = averageRadius;
			dRect.bottomRightRadius = averageRadius;
			dRect.topLeftRadius = averageRadius;
			dRect.topRightRadius = averageRadius;
			
			return dRect;
		}
		
		private function addPath():void {
			if (myPath != null)	{
				myPath.preDraw();
				
				if (myPath.fill == null) myPath.fill = default_fill;
				if (myPath.stroke == null) myPath.stroke = default_stroke;
				local_g.geometryCollection.addItem(myPath);
				
				myPath = null;
			}
		}
		
		private function parsePath(path:XML):IGeometry
		{
			var gGroup:GeometryComposition = new GeometryComposition();
			var dataPath:String = path.@d;
			addPath();

		    myPath = new Path();
		    myPath.data = dataPath;
		    gGroup.geometryCollection.addItem(myPath);
			
			// Adding path to geometry group from the caller
//			myPath.calculateLayout();
//			myPath.bounds.width=50;
//			myPath.bounds.height=50;
//			myPath.bounds.offset(-(myPath.bounds.left+myPath.bounds.width/local_width*2) ,
//				-(myPath.bounds.top+myPath.bounds.height/local_height*2));
			
		    return(gGroup);	
		}

		/**
		* This function will return the rgb hex string from the svg style attributes
		* held in the attrPairs array.
		*
		* @param attrPairs The Array of svg style pairs.
		*
		*/
		private function extractRGB(attrPairs:Array, styleName:String):String
		{
			var rgb:String = null;
			
			var found:Boolean = false;
			var index:Number = 0;
			while (index<attrPairs.length)
			{
				var pair:Array = attrPairs[index].split(":");
				
				var name:String = strip(pair[0]);
				
				if (name==styleName)
				{
					var value:String = strip(pair[1]);
					
					var indexAt:Number = value.indexOf(TEXT_RGB);
					
					if (indexAt!=-1)
					{
						return(extractRGBValue(value));
					} else {
						return value;
					} 
				}
				
				index++;
			}	
			
			return rgb;
		}
		
		/**
		* This function will return the rgb hex string for the equivilant SVG rgb
		* definition which is in this form 'rgb(41.176474%,38.431376%,28.235295%)'.
		*
		* @param value The svg rbg string.
		*
		*/
		private function extractRGBValue(value:String):String
		{
			var rgb:String = null;
			
			var start:Number = value.indexOf("(");
			var end:Number = value.indexOf(")");
			var subString:String = value.substring(start+1,end);
			var percentages:Array = subString.split(",");

			// The holy trinity of colour.
			if (percentages.length==3)
			{
				rgb = "#";
				
				for each (var percentageStr:String in percentages)
				{
					var pecentageSign:Number = percentageStr.indexOf("%");
					var colourNumber:Number;
					if (pecentageSign!=-1)
					{
						// Bless us with thy value
						colourNumber = (Number(percentageStr.substr(0, pecentageSign-1))/100)*255;
						if (colourNumber<16)
						{
							rgb = rgb + "0" + colourNumber.toString(16);		
						}
						else
						{
							rgb = rgb + colourNumber.toString(16);		
						}
					}
					else
					{
						colourNumber = Number(percentageStr);
						// Assume decimal value
						if (colourNumber<16)
						{
							rgb = rgb + "0" + colourNumber.toString(16);		
						}
						else
						{
							rgb = rgb + colourNumber.toString(16);		
						}
					}
				}
			}
			else
			{
//				trace('Error, could not parse, ',value);
			}
			
			return rgb;
		}

		/**
		* This function will return the fill id out of a fill style.
		*
		* @param value The svg url string.
		*
		*/
		private function extractFillValue(value:String):String
		{
			var url:String = null;
			
			var start:Number = value.indexOf("#");
			var end:Number = value.indexOf(")");
			var subString:String = value.substring(start+1,end);
			if ((start == -1) || (end == -1)) {
				return value;
			}
			return subString;
		}
		
		/**
		 * Strip out newlines and tabs and spaces from supplied string.
		 * 
		 * @param value The String to strip out.
		 * 
		 */
		private function strip(value:String):String
		{
			value =  value.split("\r").join("");
			value =  value.split("\t").join("");
			value =  value.split(" ").join("");

			return value;
		}
					
		/**
		 * Getter for list of fill colours.
		 * 
		 */
		public function get fills():Object
		{
			return __fills;
		}
		
		/**
		 * Getter for list of geometries.
		 * 
		 */
		public function get geometries():ArrayCollection
		{
			return __geometries
		}

		private function parseFont(font:XML):IGeometry
		{
			return null;
		}
		
		
	}
}