package away3d.materials
{
	import away3d.arcane;
	import away3d.materials.passes.SegmentPass;
	import flash.display.BlendMode;
	
	use namespace arcane;
	
	/**
	 * SegmentMaterial is a material exclusively used to render wireframe objects
	 *
	 * @see away3d.entities.Lines
	 */
	public class SegmentMaterial extends MaterialBase
	{
		private var _screenPass:SegmentPass;
		
		/**
		 * Creates a new SegmentMaterial object.
		 *
		 * @param thickness The thickness of the wireframe lines.
		 */
		public function SegmentMaterial(thickness:Number = 1.25)
		{
			super();
			
			bothSides = true;
			addPass(_screenPass = new SegmentPass(thickness));
			_screenPass.material = this;
			blendMode = BlendMode.NORMAL;
		}
		
		override public function set blendMode(value:String):void
		{
			super.blendMode = value;
			_screenPass.setBlendMode(value);
		}
	}
}
