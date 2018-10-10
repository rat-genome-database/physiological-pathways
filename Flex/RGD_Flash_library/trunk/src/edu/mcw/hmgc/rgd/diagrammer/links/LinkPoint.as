package edu.mcw.hmgc.rgd.diagrammer.links{
	import com.degrafa.geometry.Circle;
	import com.degrafa.paint.SolidFill;
	import com.degrafa.paint.SolidStroke;
	
	import edu.mcw.hmgc.rgd.diagrammer.shapes.BasicShape;
	
	import flash.geom.Point;
	
	import mx.collections.ArrayCollection;
	
	public class LinkPoint extends Circle{
		
		private var _defaultFill:SolidFill;
		private var _defaultStroke:SolidStroke;
		private var _linked:Boolean;
		private var _parentComponent:BasicShape;
		private var _targetLinks:ArrayCollection = new ArrayCollection();
		//private var _targetComponent:ComponentGroup;
		//private var _linkCurve:LinkBezier;
				
		private var _stageX:Number;
		private var _stageY:Number;
		private var _rotated:Boolean;
		private var _rotatedX:Number;
		private var _rotatedY:Number;
		public var direction:String;
		
		function LinkPoint(parentComponent:BasicShape,directio:String, centerX:Number=0,centerY:Number=0,radius:Number=12,rotated:Boolean=false,rotatedX:Number=0,rotatedY:Number=0){
			
            _defaultFill = new SolidFill();
            _defaultFill.color = 0xFFFFFF;
            _defaultFill.alpha = 0.8;
            
            _defaultStroke = new SolidStroke();
            _defaultStroke.color = 0xFFFFFF;
            _defaultStroke.alpha = 0.4;
            _defaultStroke.weight = 2;
            
            
            
            this.centerX = centerX;
            this.centerY = centerY;
            this.radius = radius;
            this.fill = _defaultFill;
            this.stroke = _defaultStroke;
            
            _rotated = rotated;
            _rotatedX = rotatedX;
            _rotatedY = rotatedY;
            direction = directio;
            
            _parentComponent = parentComponent;
            
		}
		public function get targetLinks():ArrayCollection{
			return _targetLinks;
		}
		public function get parentComponent():BasicShape{
			return _parentComponent;
		}
		
		public function get linked():Boolean{
			return _linked;
		}
		
		public function setLink(targetComponent:BasicShape, linkCurve:LinkComponent):void{
			_linked = true;
			var newTarget:Object = new Object();
			newTarget.component = targetComponent;
			newTarget.linkCurve = linkCurve;
			_targetLinks.addItem(newTarget);
		}
		
		public function removeLinks():void{
			_linked = false;
			_targetLinks = new ArrayCollection();
		}
		
		public function isLinkPoint(point:Point):Boolean{
			
			var thisPoint:Point = new Point(this.centerX, this.centerY);
			var distance:Number = Point.distance(point, thisPoint);
			
			if(distance <= this.radius){
				return true;
			}else{
				return false;
			}
		}
				
		public function get stageX():Number{
			//if geometrygroup is rotated
			var _stageX:int;
			if(_rotated == true){
				
				_stageX = _rotatedX + _parentComponent.x;
				return _stageX;
				
			}else{
				_stageX = this.centerX + _parentComponent.x;
				return _stageX;
			}
		}
				
		public function get stageY():Number{
			//if geometrygroup is rotated	
			var _stageY:int;		
			if(_rotated == true){
			
				_stageY = _rotatedY + _parentComponent.y;
				return _stageY;
				
			}else{
				_stageY = this.centerY + _parentComponent.y;
				return _stageY;
			}
		}
		
		
	}
}
