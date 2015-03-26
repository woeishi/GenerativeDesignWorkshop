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
				List<Vector2D> kochPoints = new List<Vector2D>();
			for (int i = 0; i < FInput.SliceCount; i++) {
				kochPoints.Add(FInput[i]);
			}

			for (int i = 0; i < FIterations[0]; i++) {
				List<Vector2D> kochPointsNew = new List<Vector2D>();
				int segCount = kochPoints.Count - 1;
				
				for (int k = 0; k < segCount; k++) {
					
					FLogger.Log(LogType.Debug, i.ToString() + " --- " + k.ToString() + "/" + (k+1).ToString());
					
					Vector2D segStart = kochPoints[k];
					Vector2D segEnd = kochPoints[k + 1];
					Vector2D segThird = (segEnd - segStart) / 3;
					kochPointsNew.Add(segStart);
					kochPointsNew.Add(segStart + segThird);
					kochPointsNew.Add(segStart + segThird + (VMath.RotateZ(VMath.DegToRad * 60) * segThird).xy);
					kochPointsNew.Add(segStart + 2 * segThird);
					kochPointsNew.Add(segEnd);
				}

				kochPoints = kochPointsNew;
			}


			for (int i = 0; i < SpreadMax; i++)
				FOutput.AssignFrom(kochPoints);
			}

		}

	}
}
