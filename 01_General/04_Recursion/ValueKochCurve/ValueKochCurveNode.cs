#region usings
using System;
using System.ComponentModel.Composition;

using System.Collections.Generic;

using VVVV.PluginInterfaces.V1;
using VVVV.PluginInterfaces.V2;
using VVVV.Utils.VColor;
using VVVV.Utils.VMath;

using VVVV.Core.Logging;
#endregion usings

namespace VVVV.Nodes
{
	#region PluginInfo
	[PluginInfo(Name = "KochCurve", Category = "Value", Help = "Basic template with one value in/out", Tags = "")]
	#endregion PluginInfo
	public class ValueKochCurveNode : IPluginEvaluate
	{
		#region fields & pins
		[Input("Input", DefaultValues = new double[] {0.0,0.0})]
		public IDiffSpread<Vector2D> FInput;
		
		[Input("Iterations", DefaultValue = 1, IsSingle = true)]
		public IDiffSpread<int> FIterations;
		
		[Output("Output")]
		public ISpread<Vector2D> FOutput;
		
		[Import()]
		public ILogger FLogger;
		#endregion fields & pins
		
		//called when data for any output pin is requested
		public void Evaluate(int SpreadMax)
		{
			if (FInput.IsChanged || FIterations.IsChanged)
			{
				FOutput.AssignFrom(FInput);
				
				for (int i = 0; i < FIterations[0]; i++) {
					int segCount = FOutput.SliceCount - 1;
					for (int k = 0; k < segCount*4; k=k+4) {
						
						Vector2D segStart = FOutput[k];
						Vector2D segEnd = FOutput[k + 1];
						Vector2D segThird = (segEnd - segStart) / 3;
						
						FOutput.Insert(k+1, segStart + segThird);
						FOutput.Insert(k+2, segStart + segThird + (VMath.RotateZ(VMath.DegToRad * 60) * segThird).xy);
						FOutput.Insert(k+3, segStart + 2 * segThird);
						
					}
					
				}
				
			}
			
		}
		
	}
}
