package away3d.materials.methods
{
	import away3d.arcane;
	import away3d.core.managers.Stage3DProxy;
	import away3d.materials.compilation.ShaderRegisterCache;
	import away3d.materials.compilation.ShaderRegisterElement;
	import away3d.materials.methods.EffectMethodBase;
	import away3d.materials.methods.MethodVO;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.geom.Point;
	
	use namespace arcane;

	public class GifMethod extends EffectMethodBase
	{
		public var placement:Point = new Point(0, 0);
		public var scale:Point = new Point(1, 1);
		private var _vertexData:Vector.<Number>;
		
		public function GifMethod()
		{
			super();
			_vertexData = new Vector.<Number>(4);
		}
		
		override arcane function initVO(vo : MethodVO) : void
		{
			vo.needsProjection = true;
		}
		
		arcane override function activate(vo : MethodVO, stage3DProxy : Stage3DProxy) : void
		{
			_vertexData[0] = placement.x;
			_vertexData[1] = placement.y;
			_vertexData[2] = scale.x;
			_vertexData[3] = scale.y;
			stage3DProxy._context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 10, _vertexData, 1);
		}
		
		arcane override function getVertexCode(vo:MethodVO, regCache:ShaderRegisterCache):String
		{
			var code : String = "";
			code += "// test \n";
			code += "mov vt2, va1 \n";
			code += "mul vt2.xy, vt2.xy, vc10.zw \n";
			code += "add vt2.xy, vt2.xy, vc10.xy \n";
			code += "mov v1, vt2 \n";
			return code;
		}
		
		arcane override function getFragmentCode(vo:MethodVO, regCache:ShaderRegisterCache, targetReg:ShaderRegisterElement) : String
		{
			var fogColor : ShaderRegisterElement = regCache.getFreeFragmentConstant();
			var fogData : ShaderRegisterElement = regCache.getFreeFragmentConstant();
			var temp : ShaderRegisterElement = regCache.getFreeFragmentVectorTemp();
			regCache.addFragmentTempUsages(temp, 1);
			var temp2 : ShaderRegisterElement = regCache.getFreeFragmentVectorTemp();
			var temp3 : ShaderRegisterElement = regCache.getFreeFragmentVectorTemp();
			var temp4 : ShaderRegisterElement = regCache.getFreeFragmentVectorTemp();
			var code : String = "";
			vo.fragmentConstantsIndex = fogColor.index * 4;
			
			regCache.removeFragmentTempUsage(temp);
			
			return code;
		}
	}
}
