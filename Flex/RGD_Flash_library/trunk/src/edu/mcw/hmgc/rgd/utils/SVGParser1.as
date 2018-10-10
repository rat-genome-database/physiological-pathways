package edu.mcw.hmgc.rgd.utils
{
	import com.degrafa.GeometryComposition;
	import com.degrafa.GraphicPoint;
	import com.degrafa.IGeometry;
	import com.degrafa.IGeometryComposition;
	import com.degrafa.core.IGraphicsFill;
	import com.degrafa.core.IGraphicsStroke;
	import com.degrafa.geometry.Circle;
	import com.degrafa.geometry.Ellipse;
	import com.degrafa.geometry.Geometry;
	import com.degrafa.geometry.Line;
	import com.degrafa.geometry.Path;
	import com.degrafa.geometry.Polygon;
	import com.degrafa.geometry.Polyline;
	import com.degrafa.geometry.RasterText;
	import com.degrafa.geometry.RoundedRectangleComplex;
	import com.degrafa.paint.DashedStroke;
	import com.degrafa.paint.GradientStop;
	import com.degrafa.paint.LinearGradientFill;
	import com.degrafa.paint.RadialGradientFill;
	import com.degrafa.paint.SolidFill;
	import com.degrafa.paint.SolidStroke;
	import com.degrafa.transform.MatrixTransform;
	import com.degrafa.transform.Transform;
	
	import edu.mcw.hmgc.rgd.graphics.DashedLineDecorator;
	
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import flexlib.scheduling.scheduleClasses.renderers.SolidScheduleEntryRenderer;
	
	import mx.collections.ArrayCollection;
	import mx.graphics.Stroke;
	
	/**
	 * Parses SVG xml and builds two lists, one for fill colours and one for path data.
	 * The fills and paths structures have a one to one relationship.
	 * 
	 */	
	public class SVGParser1
	{
		public static const XLINK_NS:Namespace = new Namespace("http://www.w3.org/1999/xlink");

		public static var TEXT_FILL:String = "fill";
		public static var TEXT_PATH:String = "path";
		public static var TEXT_RGB:String = "rgb";
		
		private var __defs:ArrayCollection = null;
		private var __geometries:ArrayCollection = null;
		private var __fills:Object = null;
		
		private var parseHandlers:Object = null;
		
		public var max_width:Number = 0;
		public var max_height:Number = 0;
		
		public var max_right:Number = 0;
		public var max_bottom:Number = 0;
		public var min_left:Number = 99999999999;
		public var min_top:Number = 99999999999;
		
		public function SVGParser1():void
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
					
					radialGradient: this.parseRadialGradient,
					linearGradient: this.parseLinearGradient,
					perspective: this.parsePerspective
			};
			
			__defs = new ArrayCollection();
			__geometries = new ArrayCollection();
			__fills = new Object();
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
					return true;
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
			
			if (fillName in SVGColors.colors) {
				var nameFill:SolidFill = new SolidFill();
				nameFill.color = SVGColors.colors[fillName];
				nameFill.alpha = opacity;
				return nameFill;
			}
			
			return null;
		}
		
		private function getStroke(strokeName:String):IGraphicsStroke
		{
			if (strokeName == "none" || strokeName == "") {
				var noneStroke:DashedStroke = new DashedStroke();
				noneStroke.color = 0x000000;
				noneStroke.alpha = 0;
				return noneStroke;	
			}
			
			var rgbVal:String = extractRGBValue(strokeName);
			if (rgbVal != null) {
				strokeName = rgbVal;
			}

			//			if (strokeName.charAt(0) == "#" && strokeName.length == 7) {
			// Some times the color is not in 6-full hex digit format			
			if (strokeName.charAt(0) == "#" && strokeName.length > 1) {
				var hexStroke:DashedStroke = new DashedStroke();
				hexStroke.color = Number("0x" + strokeName.substr(1));
				hexStroke.alpha = 1;
				return hexStroke;
			}
			
			if (strokeName in SVGColors.colors) {
				var nameStroke:DashedStroke = new DashedStroke();
				nameStroke.color = SVGColors.colors[strokeName];
				nameStroke.alpha = 1;
				return nameStroke;
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
		public function parse(data:XML):Boolean
		{
			var status:Boolean = false;
			
			var defsXML:XMLList = data.*.(defsE4XFilter(localName())).*;
			
			// Reset structures
			__defs.removeAll();
			__geometries.removeAll();
			var fill:FillWrapper;
			var parsed:Object;
			if (defsXML.length() > 0) 
			{
				for each (var def:XML in defsXML)
				{
					parsed = parseHandlers[def.localName()](def);
					
					if (parsed != null) {
						if (parsed is FillWrapper) {
							fill = parsed as FillWrapper;
							fills[fill.id] = fill.fill;
						} else if (parsed is GeometryComposition) {
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
							if (parsed is FillWrapper) {
								fill = parsed as FillWrapper;
								fills[fill.id] = fill.fill;
							} else if (parsed is IGeometry) {
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
			
			max_width = max_right - min_left;
			max_height = max_bottom - min_top;
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
			
			if (fill != null) {
				pGeometry.fill = getFill(fill, Number(fillOpacity));
				if (pGeometry is GeometryComposition) passFill2Children(pGeometry as GeometryComposition);
				
			}
			
			if (stroke != null) {
				pGeometry.stroke = getStroke(stroke);
				pGeometry.stroke.weight = strokeWidth;
				if (pGeometry is GeometryComposition) passStroke2Children(pGeometry as GeometryComposition);
			}
			
			return pGeometry;
		}
		
		private function parseLinearGradient(gradient:XML):FillWrapper
		{	
			var lGradient:LinearGradientFill = new LinearGradientFill();
			
			if (!"@x1" in gradient) {
				gradient.@x1 = 0; 
			}
			
			if (!"@x2" in gradient) {
				gradient.@x2 = "100%";
			}
			
			if (!"@y1" in gradient) {
				gradient.@y1 = 0; 
			}
			
			if (!"@y2" in gradient) {
				gradient.@y2 = 0;
			}
			
			var x1:Number = Number(gradient.@x1);
			var y1:Number = Number(gradient.@y1);
			var x2:Number = Number(gradient.@x2);
			var y2:Number = Number(gradient.@y2);
			
//			lGradient.x = x1;
//			lGradient.y = y1;
//			lGradient.x = -100;
//			lGradient.y = 0;
			
			// Zero degrees is along the positive X axis.
			var degreesOffX:Number = Math.atan2((y2-y1),
				(x2-x1)) * 180 / Math.PI;
			lGradient.angle = degreesOffX;

			var href:String = gradient.@XLINK_NS::href;
			
			if (href.length>0)
			{
				// Color stops defined somewhere else
				lGradient.gradientStops = (href.search("-") > -1) ? 
					__fills[href.slice(1,href.search("-"))].gradientStops
					: __fills[href.slice(1)].gradientStops;
			}
			else
			{
				for each (var stop:XML in gradient.*::stop) {
					var gStop:GradientStop = new GradientStop();
					var attrPairs:Array;
					if ("@stop-color" in stop) {
						gStop.color = stop.attribute("stop-color");
					} else {
						attrPairs = stop.@style.split(";");
						gStop.color = extractRGB(attrPairs, "stop-color");
					}
					
					if ("@stop-opacity" in stop) {
						gStop.alpha = stop.attribute["stop-opacity"];
					} else {
						attrPairs = stop.@style.split(";");
						for each (var rawPair:Object in attrPairs) {
							var parsedPair:Array = rawPair.split(":");
							var name:String = strip(parsedPair[0]);
							if (name == "stop-opacity") {
								var value:Number = Number(parsedPair[1]);
								gStop.alpha = value;	
								break;
							}
						}
					}
					if ("@offset" in gradient) {
						gStop.ratio = Number(gradient.@offset);
					}
					lGradient.gradientStopsCollection.addItem(gStop);
				}
			}
			
			
			var retval:FillWrapper = new FillWrapper();
			retval.fill = lGradient;
			retval.id = gradient.@id;
			
			return retval;
		}
		
		private function parseRadialGradient(gradient:XML):FillWrapper
		{	
			var rGradient:RadialGradientFill = new RadialGradientFill();
			
			if ("@fx" in gradient) {
				gradient.@fx = gradient.@cx;
			}
			
			if ("@fy" in gradient) {
				gradient.@fy = gradient.@cy;
			}
			
			if ("@cx" in gradient) {
				rGradient.cx = gradient.@cx;
			}
			
			if ("@cy" in gradient) {
				rGradient.cy = gradient.@cy;
			}
			
			if ("@r" in gradient == false) {
				gradient.@r = 0.5;
			}

			var ma:MatrixTransform = new MatrixTransform();	

			if ("@gradientTransform" in gradient) {
				var ma_str:String = new String(gradient.@gradientTransform);
				var coeffs:Array = ma_str.split(/matrix\(|,|\)/);
				ma.a = coeffs[1];
				ma.b = coeffs[2];
				ma.c = coeffs[3];
				ma.d = coeffs[4];
				ma.tx = coeffs[5];
				ma.ty = coeffs[6];
				rGradient.radiusX = gradient.@r * ma.a;
				rGradient.radiusY = gradient.@r * ma.d;
//				var p1:Point = ma.transformPoint(new Point(rGradient.cx, rGradient.cy));
//				rGradient.cx = rGradient.cx * ma.a;
//				rGradient.cy = rGradient.cy * ma.d;
//				rGradient.transform = ma;
			}
			
			// Distance from center (Pythagoras) divided by radius 
//			var distanceFromCenter:Number = Math.sqrt(Number(gradient.@fx)<<1 + Number(gradient.@fy)<<1); 
//			rGradient.focalPointRatio = distanceFromCenter/gradient.@r;
			
			// ArcCos of (distance/x_offset) adjusted for quadrant in degrees. 
			// Zero degrees is along the positive X axis.
//			var degreesOffX:Number =
//				(Math.acos(distanceFromCenter/Number(gradient.@fx)) * (180/Math.PI));
//			if (gradient.@fx > 0) {
//				if (gradient.@fy > 0) {
//					rGradient.angle = 360 - degreesOffX;
//				} else {
//					rGradient.angle = degreesOffX;
//				}
//			} else {
//				if (gradient.@fy > 0) {
//					rGradient.angle = 180 + degreesOffX;
//				} else {
//					rGradient.angle = 180 - degreesOffX;
//				}
//			}
				
			rGradient.radius = gradient.@r;
			var href:String = gradient.@XLINK_NS::href;
						
			if (href.length)
			{
				// Color stops defined somewhere else
				rGradient.gradientStops = (href.search("-") > -1) ? 
					__fills[href.slice(1,href.search("-"))].gradientStops
					: __fills[href.slice(1)].gradientStops;
			}
			else
			{
				for each (var stop:XML in gradient.*::stop) {
					var gStop:GradientStop = new GradientStop();
					var attrPairs:Array;
					if ("@stop-color" in stop) {
						gStop.color = stop.attribute("stop-color");
					} else {
						attrPairs = stop.@style.split(";");
						gStop.color = extractRGB(attrPairs, "stop-color");
					}
					
					if ("@stop-opacity" in stop) {
						gStop.alpha = stop.attribute["stop-opacity"];
					} else {
						attrPairs = stop.@style.split(";");
						for each (var rawPair:Object in attrPairs) {
							var parsedPair:Array = rawPair.split(":");
							var name:String = strip(parsedPair[0]);
							if (name == "stop-opacity") {
								var value:Number = Number(parsedPair[1]);
								gStop.alpha = value;	
								break;
							}
						}
					}
					rGradient.gradientStopsCollection.addItem(gStop);
				}
			}
			
			
			var retval:FillWrapper = new FillWrapper();
			retval.fill = rGradient;
			retval.id = gradient.@id;
			
			return retval;
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
							if (parsed is FillWrapper) {
								var fill:FillWrapper = parsed as FillWrapper;
								fills[fill.id] = fill.fill;
							} else if (parsed is IGeometry) {
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
		
		private function parsePath(path:XML):IGeometry
		{
			var gGroup:GeometryComposition = new GeometryComposition();
			var dataPath:String = path.@d;
			
			var myPath:Path = new Path();
			myPath.data = dataPath;
			gGroup.geometryCollection.addItem(myPath);
			myPath.preDraw();
			
			if (max_right < myPath.bounds.right) max_right = myPath.bounds.right;
			if (max_bottom < myPath.bounds.bottom) max_bottom = myPath.bounds.bottom;
			if (min_left > myPath.bounds.left) min_left = myPath.bounds.left;
			if (min_top > myPath.bounds.top) min_top = myPath.bounds.top;
			
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
		
		public function parsePerspective(perspective:XML):IGeometry
		{
			return null;
		}
		
		public function passFill2Children(gGroup:GeometryComposition):GeometryComposition
		{
			if (gGroup.fill == null) return gGroup;
			
			for each (var geo:Geometry in gGroup.geometryCollection.items)
			{
				if (geo.fill == null)
				{
					geo.fill = gGroup.fill;
					if (geo is GeometryComposition)
					{
						passFill2Children(geo as GeometryComposition);
					}
				}
			}
			return gGroup;
		}
		
		public function passStroke2Children(gGroup:GeometryComposition):GeometryComposition
		{
			if (gGroup.stroke == null) return gGroup;
			for each (var geo:Geometry in gGroup.geometryCollection.items)
			{
				if (geo.stroke == null)
				{
					geo.stroke = gGroup.stroke;
					if (geo.decorators != null) geo.decorators = gGroup.decorators;
					if (geo is GeometryComposition)
					{
						passStroke2Children(geo as GeometryComposition);
					}
				}
			}
			return gGroup;
		}

	}
}