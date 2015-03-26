#region usings
using System;
using System.Collections.Generic;
using System.ComponentModel.Composition;

using VVVV.PluginInterfaces.V1;
using VVVV.PluginInterfaces.V2;
using VVVV.Utils.VColor;
using VVVV.Utils.VMath;

using VVVV.Core.Logging;
#endregion usings

namespace VVVV.Nodes
{
	#region PluginInfo
	[PluginInfo(Name = "TemplateChaosToy", Category = "2d", Version = "0.1", Author = "fibo", Help = "Basic template for a 2d Chaos Toy", Tags = "2d,chaos")]
	#endregion PluginInfo
	public class TemplateChaosToy : IPluginEvaluate
	{
		#region fields & pins
		[Input("Input", DefaultValue = 1.0)]
		IDiffSpread<Vector2D> FInput;

		[Input("StepCount", DefaultValue = 0, MinValue = 0, StepSize = 1, IsSingle = true, AsInt = true)]
		IDiffSpread<int> FStepCount;

		[Input("Reset", DefaultValue = 0, MinValue = 0, MaxValue = 1, StepSize = 1, IsSingle = true, IsBang = true, AsInt = true)]
		ISpread<int> FReset;

		[Input("DeltaT", DefaultValue = 0.01, MinValue = -1, StepSize = 0.001, IsSingle = true)]
		ISpread<double> FDeltaT;

		[Output("Output")]
		ISpread<Vector2D> FOutput;

		[Import()]
		ILogger Flogger;

		double stepCount = 0;
		List<Vector2D> previous = new List<Vector2D>();
		bool evolve = false;

		#endregion fields & pins

		//called when data for any output pin is requested
		public void Evaluate(int SpreadMax)
		{
			FOutput.SliceCount = FInput.SliceCount;

			if (FReset[0] == 1 || FStepCount.IsChanged || FInput.IsChanged) {
				stepCount = FStepCount[0];
				previous.Clear();
				for (int i = 0; i < FInput.SliceCount; i++) {
					previous.Add(new Vector2D());
					previous[i] = FInput[i];
				}
				evolve = true;
			}

			if (stepCount == 0)
				evolve = true;

			if (FDeltaT[0] == 0)
				evolve = false;

			if (evolve) {
				//Flogger.Log(LogType.Debug, "stepCount = " + stepCount);

				Vector2D current = new Vector2D();

				for (int i = 0; i < FInput.SliceCount; i++) {

					//@@@@@@ edit here your dynamical system formula @@@@@@@@@@@
					current.x = -previous[i].y + Math.Cos(previous[i].x);
					current.y = previous[i].x;
					//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
					
					current *= FDeltaT[0];

					previous[i] += current;

					//Flogger.Log(LogType.Debug, "current = " + current.x + " , " + current.y);
					//Flogger.Log(LogType.Debug, "previous = " + previous[i].x + " , " + previous[i].y);

					FOutput[i] = previous[i];

				}

			}

			if (stepCount > 1)
				stepCount--;

			if (stepCount == 1)
				evolve = false;

		}
	}
}
