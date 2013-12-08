package away3d.materials
{
	import away3d.materials.methods.GifMethod;
	import away3d.materials.TextureMaterial;
	import away3d.textures.BitmapTexture;
	import away3d.textures.GifTexture;
	import away3d.textures.Texture2DBase;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Pete Shand
	 */
	public class GifMaterial extends TextureMaterial 
	{
		private var gifMethod:GifMethod;
		private var gifTexture:GifTexture;
		
		public function GifMaterial(gifTexture:GifTexture=null, smooth:Boolean=true, repeat:Boolean=false, mipmap:Boolean=true) 
		{
			super(null, smooth, repeat, mipmap);
			this.gifTexture = gifTexture;
			
			gifTexture.addEventListener(GifTexture.EVENT_TEXTURE_CHANGE, OnTextureChange);
			gifTexture.addEventListener(GifTexture.EVENT_FRAME_CHANGE, OnFrameChange);
			
			gifMethod = new GifMethod();
			this.addMethod(gifMethod);
		}
		
		private function OnFrameChange(e:Event):void 
		{
			gifMethod.placement = gifTexture.placement;
			gifMethod.scale = gifTexture.scale;
		}
		
		private function OnTextureChange(e:Event):void 
		{
			this.texture = gifTexture.currentTexture;
		}
	}
}