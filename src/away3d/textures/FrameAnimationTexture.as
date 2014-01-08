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
		
		public static function fromPackagedByteArray(data:ByteArray, generateMipmaps:Boolean=false):FrameAnimationTexture
		{
			registerClassAlias("imag.masdar.core.control.ATFVideoObject", ATFVideoObject);
			registerClassAlias("imag.masdar.core.control.Placement", Placement);
			registerClassAlias("flash.utils.ByteArray", ByteArray);
			registerClassAlias("flash.geom.Point", Point);
			registerClassAlias("flash.geom.Rectangle", Rectangle);
			
			trace("data == null: " + Boolean(data == null));
			data.position = 0;
			var atfVideoObject:ATFVideoObject = ATFVideoObject(data.readObject());
			
			var placements:Vector.<Placement> = atfVideoObject.placements;
			var totalFrames:int = placements.length;
			var numTextures:int  = atfVideoObject.atfTextures.length;
			var animationWidth:int = atfVideoObject.originalWidth;
			var animationHeight:int = atfVideoObject.originalHeight;
			var bitmapdatas:Vector.<BitmapData> = new Vector.<BitmapData>(numTextures);
			
			for (var i:int = 0; i < numTextures; ++i) {
				var data:ByteArray = atfVideoObject.atfTextures[i];
				data.position = 0;
				data.uncompress();
				var _width:int = atfVideoObject.textureRects[i].width;
				var _height:int = atfVideoObject.textureRects[i].height;
				var bmd:BitmapData = new BitmapData(_width, _height, true, 0x55FF0000); // 24 bit bitmap
				bmd.setPixels(bmd.rect, data); // position of data is now at 5th byte				
				bitmapdatas[i] = bmd;
			}
			
			var frameAnimationTexture:FrameAnimationTexture = new FrameAnimationTexture(bitmapdatas, generateMipmaps);
			frameAnimationTexture.placements = placements;
			frameAnimationTexture.totalFrames = totalFrames;
			frameAnimationTexture.numTextures = numTextures;
			frameAnimationTexture.animationWidth = animationWidth;
			frameAnimationTexture.animationHeight = animationHeight;
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
			this.bitmapData = bmds[textureIndex];
		}
		
		override public function dispose():void
		{
			if (bmds){
				for (var i:int = 0; i < bmds.length; ++i) {
					bmds[i].dispose();
					bmds[i] = null;
				}
				bmds = null;
			}
			if (this.bitmapData){
				this.bitmapData.dispose();
				this.bitmapData = null;
			}
			super.dispose();
		}
	}
}