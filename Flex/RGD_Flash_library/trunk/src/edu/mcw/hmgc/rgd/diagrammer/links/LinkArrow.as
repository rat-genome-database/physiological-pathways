package edu.mcw.hmgc.rgd.diagrammer.links{
	import com.degrafa.geometry.Path;
	import com.degrafa.paint.SolidFill;
	
	public class LinkArrow extends Path{
		
		private var _whiteFill:SolidFill;
		
		function LinkArrow():void{
			super.data = "M25,0 L0,25 L0,10 L-25,10 L-25,-10 L0,-10 L0,-25 L25,0z";
			
			
            _whiteFill = new SolidFill();
            _whiteFill.color = 0xFFFFFF;
            _whiteFill.alpha = 0.7;
			
			this.fill = _whiteFill;
		}
		
		
	}
}