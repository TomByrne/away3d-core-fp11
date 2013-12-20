package away3d.materials 
{
	import away3d.materials.methods.FrameAnimationMethod;
	import away3d.textures.ATFTexture;
	import away3d.textures.FrameAnimationTexture;
	import away3d.textures.BitmapTexture;
	import away3d.textures.Texture2DBase;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	import imag.masdar.experience.control.Placement;
	
	/**
	 * ...
	 * @author Pete Shand
	 */
	public class FrameAnimationMaterial extends TextureMaterial 
	{
		private var frameAnimationMethod:FrameAnimationMethod;
		private var frameAnimationTexture:FrameAnimationTexture;
		private var dipatcher:Sprite;
		
		private var _currentFrame:int = -1;
		
		private var currentPlacement:Placement;
		
		private var tempTextureBmd:BitmapData;
		private var currentTextureBmd:BitmapData;
		
		private var tempTexture:BitmapTexture;
		private var currentTexture:BitmapTexture;
		
		private var placement:Point = new Point();
		private var scale:Point = new Point();
		
		public var stageFrameRate:int = 60;
		public var playbackFrameRate:int = 30;
		private var count:int = 0;
		
		public function FrameAnimationMaterial(frameAnimationTexture:FrameAnimationTexture=null, smooth:Boolean=true, repeat:Boolean=false, mipmap:Boolean=true) 
		{
			super(frameAnimationTexture, smooth, repeat, mipmap);
			this.frameAnimationTexture = frameAnimationTexture;
			
			dipatcher = new Sprite();
			
			frameAnimationMethod = new FrameAnimationMethod();
			this.addMethod(frameAnimationMethod);
			
			currentFrame = 0;
			
		}
		
		public function play():void
		{
			count = 0;
			dipatcher.addEventListener(Event.ENTER_FRAME, Update);
		}
		
		public function stop():void
		{
			dipatcher.removeEventListener(Event.ENTER_FRAME, Update);
		}
		
		private function Update(e:Event):void 
		{
			if (count % phase == 0) currentFrame++;
			count++;
		}
		
		private function get phase():int
		{
			return stageFrameRate / playbackFrameRate; 
		}
		
		public function set currentFrame(value:int):void 
		{
			if (_currentFrame == value) return;
			_currentFrame = value;
			if (_currentFrame >= frameAnimationTexture.totalFrames) _currentFrame = 0;
			if (_currentFrame < 0) _currentFrame = frameAnimationTexture.totalFrames - 1;
			
			currentPlacement = frameAnimationTexture.getPlacement(currentFrame);
			
			scale.x = currentPlacement.width / currentPlacement.textureMaxWidth;
			scale.y = currentPlacement.height / currentPlacement.textureMaxHeight;
			
			placement.x = currentPlacement.position.x / currentPlacement.textureMaxWidth;
			placement.y = currentPlacement.position.y / currentPlacement.textureMaxHeight;
			
			frameAnimationMethod.placement = placement;
			frameAnimationMethod.scale = scale;
			
			frameAnimationTexture.updateTexture(currentPlacement.index);
			
			/*tempTextureBmd = frameAnimationTexture.getTextureBmd(currentPlacement.index);
			if (currentTextureBmd != tempTextureBmd) {
				currentTextureBmd = tempTextureBmd;
				if (currentTexture) currentTexture.dispose();
				currentTexture = new BitmapTexture(currentTextureBmd, false);
				this.texture = currentTexture;
			}*/
		}
		
		
		public function get currentFrame():int 
		{
			return _currentFrame;
		}
		
		public function get totalFrames():int 
		{
			return frameAnimationTexture.totalFrames;
		}
	}
}