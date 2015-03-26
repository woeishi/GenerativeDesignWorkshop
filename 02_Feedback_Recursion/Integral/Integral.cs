//@author: sanch
//@credits:tonfilm
#region usings
using System;
using System.ComponentModel.Composition;
using System.Collections.Generic;
using SlimDX;
using VVVV.PluginInterfaces.V1;
using VVVV.PluginInterfaces.V2;
using VVVV.Utils.VColor;
using VVVV.Utils.VMath;
using VVVV.Core.Logging;
#endregion usings

namespace VVVV.Nodes
{
	#region PluginInfo
	[PluginInfo(Name = "Integral", Category = "Transform", Help = "Basic template with one transform in/out", Tags = "matrix")]
	#endregion PluginInfo
	public class Integral : IPluginEvaluate
	{
		#region fields & pins


		[Input("Transform In")]
		ISpread<Matrix> FTransformIn;

		[Input("Source")]
		ISpread<ISpread<Matrix>> FInput;

		[Output("Transform")]
		ISpread<ISpread<Matrix>> FOutput;
		#endregion fields & pins

		//called each frame by vvvv
		public void Evaluate(int SpreadMax)
		{
			FOutput.SliceCount = FInput.SliceCount;

			for (int b = 0; b < FInput.SliceCount; b++) {
				var inputSpread = FInput[b];
				var outputSpread = FOutput[b];

				outputSpread.SliceCount = inputSpread.SliceCount;
				
                outputSpread[0] = inputSpread[0] * FTransformIn[b];
                
				for (int i = 1; i < inputSpread.SliceCount; i++) {
				outputSpread[i] = inputSpread[i] * outputSpread[i - 1];
					
				}
			}
		}
	}
}
