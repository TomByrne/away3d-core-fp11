package away3d.textures
{
	import away3d.textures.BitmapTexture;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.registerClassAlias;
	import flash.utils.ByteArray;
	import imag.masdar.core.control.ATFVideoObject;
	import imag.masdar.core.control.Placement;
	
	/**
	 * ...
	 * @author Pete Shand
	 */
	public class FrameAnimationTexture extends BitmapTexture
	{
		private var placements:Vector.<Placement>;
		private var bmds:Vector.<BitmapData>;
		
		public var placement:Point = new Point(0, 0);
		public var scale:Point = new Point(0.5, 0.5);
		public var numTextures:int = 0;
		public var totalFrames:int = 0;
		
		public var animationWidth:int = 0;
		public var animationHeight:int = 0;
		
		public var atfVideoObject:ATFVideoObject;
		public var uncompressCount:Vector.<Boolean>;
		
		public static function fromPackagedByteArray(atfVideoObject:ATFVideoObject, generateMipmaps:Boolean=false):FrameAnimationTexture
		{
			trace("fromPackagedByteArray");
			
			var placements:Vector.<Placement> = atfVideoObject.placements;
			var totalFrames:int = placements.length;
			var numTextures:int  = atfVideoObject.atfTextures.length;
			var animationWidth:int = atfVideoObject.originalWidth;
			var animationHeight:int = atfVideoObject.originalHeight;
			//var bitmapdatas:Vector.<BitmapData> = new Vector.<BitmapData>(numTextures);
			var uncompressCount:Vector.<Boolean> = new Vector.<Boolean>();
			
			for (var i:int = 0; i < atfVideoObject.atfTextures.length; i++) 
			{
				if (i == 0) {
					atfVideoObject.atfTextures[i].position = 0;
					atfVideoObject.atfTextures[i].uncompress();
					uncompressCount[i] = true;
					var _width:int = atfVideoObject.textureRects[0].width;
					var _height:int = atfVideoObject.textureRects[0].height;
					var bmd:BitmapData = new BitmapData(_width, _height, true, 0x55FF0000); // 24 bit bitmap
					bmd.setPixels(bmd.rect, atfVideoObject.atfTextures[i]); // position of subData is now at 5th byte
				}
				else {
					uncompressCount[i] = false;
				}
			}
			
			
			
			var frameAnimationTexture:FrameAnimationTexture = new FrameAnimationTexture(new <BitmapData>[bmd], generateMipmaps);
			frameAnimationTexture.placements = placements;
			frameAnimationTexture.totalFrames = totalFrames;
			frameAnimationTexture.numTextures = numTextures;
			frameAnimationTexture.animationWidth = animationWidth;
			frameAnimationTexture.animationHeight = animationHeight;
			frameAnimationTexture.atfVideoObject = atfVideoObject;
			frameAnimationTexture.uncompressCount = uncompressCount;
			
			//bmd = null;
			atfVideoObject = null;
			//data = null;
			placements = null;
			uncompressCount = null;
			
			
			return frameAnimationTexture;
		}
		
		public static function fromGif(gifData:ByteArray, generateMipmaps:Boolean=false):FrameAnimationTexture
		{
			// TO DO
			return new FrameAnimationTexture(null, generateMipmaps);
		}
		
		public static function fromMovieClip(movieclip:MovieClip, generateMipmaps:Boolean=false):FrameAnimationTexture
		{
			var _width:int = movieclip.width;
			var _height:int = movieclip.height;
			var bitmapdatas:Vector.<BitmapData> = new Vector.<BitmapData>(movieclip.totalFrames);
			for (var i:int = 0; i < movieclip.totalFrames; ++i) {
				movieclip.gotoAndStop(i + 1);
				var bmd:BitmapData = new BitmapData(_width, _height, true, 0x00000000);
				bmd.draw(movieclip, null, null, null, null, true);
				bitmapdatas.push(bmd);
			}
			return FrameAnimationTexture.fromBitmapDataVector(bitmapdatas, generateMipmaps);
		}
		
		public static function fromBitmapDataVector(bitmapdata:Vector.<BitmapData>, generateMipmaps:Boolean=false):FrameAnimationTexture
		{
			
			return new FrameAnimationTexture(bitmapdata, generateMipmaps);
		}
		
		public function FrameAnimationTexture(bitmapdata:Vector.<BitmapData>, generateMipmaps:Boolean=false)
		{
			bmds = bitmapdata;
			super(bmds[0], generateMipmaps);
		}
		
		public function getPlacement(frame:int):Placement 
		{
			return placements[frame];
		}
		
		public function updateTexture(textureIndex:int):void 
		{
			if (textureIndex < bmds.length) {
				this.bitmapData = bmds[textureIndex];
			}
			else {
				//if (this.bitmapData){
					//this.bitmapData.dispose();
					//this.bitmapData = null;
				//}
				this.bitmapData = updateBmd(textureIndex);
			}
		}
		
		private var currentTextureIndex:int = -1;
		private var currentByteArray:ByteArray;
		private function updateBmd(textureIndex:int):BitmapData 
		{
			if (currentTextureIndex == textureIndex) return this.bitmapData;
			currentTextureIndex = textureIndex;
			
			currentByteArray = atfVideoObject.atfTextures[textureIndex];
			currentByteArray.position = 0;
			if (!uncompressCount[textureIndex]) {
				uncompressCount[textureIndex] = true;
				currentByteArray.uncompress();
			}
			
			var _width:int = atfVideoObject.textureRects[textureIndex].width;
			var _height:int = atfVideoObject.textureRects[textureIndex].height;
			var bmd:BitmapData = new BitmapData(_width, _height, true, 0x55FF0000); // 24 bit bitmap
			bmd.setPixels(bmd.rect, currentByteArray); // position of data is now at 5th byte
			return bmd;
		}
		
		override public function dispose():void
		{
			super.dispose();
			var i:int;
			
			if (bmds){
				for (i = 0; i < bmds.length; ++i) {
					bmds[i].dispose();
					bmds[i] = null;
				}
				bmds = null;
			}
			if (this.bitmapData){
				this.bitmapData.dispose();
				//this.bitmapData = null;
			}
		}
	}
}