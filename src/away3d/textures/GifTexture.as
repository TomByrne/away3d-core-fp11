package away3d.textures
{
	import away3d.textures.BitmapTexture;
	import com.worlize.gif.events.GIFPlayerEvent;
	import com.worlize.gif.GIFPlayer;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	/**
	 * ...
	 * @author Pete Shand
	 */
	public class GifTexture extends EventDispatcher
	{
		public var gifPlayer:GIFPlayer;
		private var generateMipmaps:Boolean;
		public var textureBmds:Vector.<BitmapData>;
		private var textures:Vector.<BitmapTexture>;
		
		private var maxFrameWidth:int = 512;
		private var maxFrameHeight:int = 512;
		private var maxTextureSize:uint = 2048;
		private var padding:int = 1;
		
		private var placements:Vector.<Placement>;
		private var maxPlacements:Vector.<Point> = new Vector.<Point>();
		
		private var _currentTexture:BitmapTexture;
		private var _currentTextureIndex:int = -1;
		
		public static const EVENT_TEXTURE_CHANGE:String = 'textureChange';
		public static const EVENT_FRAME_CHANGE:String = 'frameChange';
		
		public var placement:Point = new Point(0, 0);
		public var scale:Point = new Point(0.5, 0.5);
		
		public function GifTexture(gifPlayer:GIFPlayer, generateMipmaps:Boolean = true)
		{
			this.gifPlayer = gifPlayer;
			this.generateMipmaps = generateMipmaps;
			
			var frameBmds:Vector.<BitmapData> = gifPlayer.getFrames();
			var placement:Rectangle = new Rectangle(0, 0, gifPlayer.width, gifPlayer.height);
			
			var currentIndex:int = 0;
			maxPlacements.push(new Point());
			placements = new Vector.<Placement>(frameBmds.length);
			for (var i:int = 0; i < frameBmds.length; ++i)
			{
				placements[i] = new Placement(currentIndex, maxFrameWidth, maxFrameHeight);
				placements[i]._width = placement.width;
				placements[i]._height = placement.height;
				placements[i]._x = placement.x;
				placements[i]._y = placement.y;
				
				maxPlacements[currentIndex] = placements[i].checkMaxPlacement(maxPlacements[currentIndex]);
				
				if (i == frameBmds.length - 1) break;
				
				placement.x += placement.width + padding;
				
				if (placement.x + placement.width > maxTextureSize / placements[k].scale.x) {
					placement.x = 0;
					placement.y += placement.height + padding;
					if (placement.y + placement.height > maxTextureSize / placements[k].scale.y) {
						// new bitmapdata required
						currentIndex++;
						maxPlacements.push(new Point());
						placement.x = 0;
						placement.y = 0;
					}
				}
				
			}
			
			textureBmds = new Vector.<BitmapData>(currentIndex+1);
			for (var j:int = 0; j < textureBmds.length; ++j) 
			{	
				maxPlacements[j].x = getBestPowerOf2(maxPlacements[j].x);
				maxPlacements[j].y = getBestPowerOf2(maxPlacements[j].y);
				textureBmds[j] = new BitmapData(maxPlacements[j].x, maxPlacements[j].y, true, 0x00000000);
			}
			
			var matrix:Matrix;
			var sx:Number;
			var sy:Number;
			
			for (var k:int = 0; k < placements.length; ++k) {
				matrix = new Matrix();
				sx = placements[k].scale.x;
				sy = placements[k].scale.y;
				matrix.scale(sx, sy);
				matrix.tx = placements[k].x;
				matrix.ty = placements[k].y;
				
				placements[k].textureMaxWidth = maxPlacements[placements[k].index].x;
				placements[k].textureMaxHeight = maxPlacements[placements[k].index].y;
				
				var textureIndex:int = placements[k].index;
				var frameBmd:BitmapData = frameBmds[k];
				textureBmds[textureIndex].draw(frameBmd, matrix, null, null, null, true);
			}
			
			textures = new Vector.<BitmapTexture>(textureBmds.length);
			for (var l:int = 0; l < textureBmds.length; ++l) {
				textures[l] = new BitmapTexture(textureBmds[l], generateMipmaps);
			}
			
			gifPlayer.addEventListener(GIFPlayerEvent.FRAME_RENDERED, handleFrameRendered);
		}
		
		private function handleFrameRendered(e:GIFPlayerEvent):void 
		{
			scale.x = placements[gifPlayer.currentFrame-1].width / placements[gifPlayer.currentFrame-1].textureMaxWidth;
			scale.y = placements[gifPlayer.currentFrame-1].height / placements[gifPlayer.currentFrame-1].textureMaxHeight;
			
			placement.x = placements[gifPlayer.currentFrame-1].position.x / placements[gifPlayer.currentFrame-1].textureMaxWidth;
			placement.y = placements[gifPlayer.currentFrame-1].position.y / placements[gifPlayer.currentFrame-1].textureMaxHeight;
			
			if (placements[gifPlayer.currentFrame-1].index != _currentTextureIndex) {
				currentTexture = textures[placements[gifPlayer.currentFrame-1].index];
			}
			this.dispatchEvent(new Event(GifTexture.EVENT_FRAME_CHANGE));
		}
		
		public function get currentTexture():BitmapTexture 
		{
			return _currentTexture;
		}
		
		public function set currentTexture(value:BitmapTexture):void 
		{
			_currentTexture = value;
			for (var i:int = 0; i < textures.length; ++i) {
				if (textures[i] == value) _currentTextureIndex = i;
			}
			this.dispatchEvent(new Event(GifTexture.EVENT_TEXTURE_CHANGE));
		}
		
		
		
		private function getBestPowerOf2(value:uint):Number
		{
			var p:uint = 1;
			
			while (p < value)
				p <<= 1;
			
			if (p > maxTextureSize)
				p = maxTextureSize;
			
			return p;
		}
	}
}

import flash.geom.Rectangle;
import flash.geom.Point;

class Placement extends Rectangle {
	
	public var index:int = 0;
	public var scale:Point = new Point(1, 1);
	public var position:Point = new Point();
	public var maxFrameWidth:Number;
	public var maxFrameHeight:Number;
	public var textureMaxWidth:int;
	public var textureMaxHeight:int;
	
	public function Placement(index:int, maxFrameWidth:Number, maxFrameHeight:Number) 
	{
		this.index = index;
		this.maxFrameWidth = maxFrameWidth;
		this.maxFrameHeight = maxFrameHeight;
		
		super(0, 0, 0, 0);
	}
	
	public function checkMaxPlacement(maxPlacement:Point):Point 
	{
		if (maxPlacement.x < this.x + this.width) maxPlacement.x = this.x + this.width;
		if (maxPlacement.y < this.y + this.height) maxPlacement.y = this.y + this.height;
		return maxPlacement;
	}
	
	public function set _width(value:Number):void
	{
		if (value > maxFrameWidth) {
			scale.x = maxFrameWidth / value;
			value = maxFrameWidth;
		}
		else scale.x = 1;
		width = value;
	}
	public function set _height(value:Number):void
	{
		if (value > maxFrameHeight) {
			scale.y = maxFrameHeight / value;
			value = maxFrameHeight;
		}
		else scale.y = 1;
		height = value;
	}
	
	public function set _x(value:Number):void
	{
		x = value * scale.x;
		position.x = x;
	}
	
	public function set _y(value:Number):void
	{
		y = value * scale.y;
		position.y = y;
	}
}