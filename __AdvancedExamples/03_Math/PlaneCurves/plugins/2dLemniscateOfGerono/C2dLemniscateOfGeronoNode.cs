#region usings
using System;
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
	[PluginInfo(Name = "LemniscateOfGerono", Category = "2d", Author = "fibo", Help = "Plane curve", Tags = "2d,curve")]
	#endregion PluginInfo
	public class C2dLemniscateOfGeronoNode : IPluginEvaluate
	{
		#region fields & pins
		[Input("A", DefaultValue = 1.0)]
		ISpread<double> FInputA;
		[Input("B", DefaultValue = 1.0)]
		ISpread<double> FInputB;
		[Input("T", DefaultValue = 0.0)]
		ISpread<double> FInputT;

		[Output("Output X")]
		ISpread<double> FOutputX;
		[Output("Output Y")]
		ISpread<double> FOutputY;

		[Import()]
		ILogger Flogger;
		#endregion fields & pins

		//called when data for any output pin is requested
		public void Evaluate(int SpreadMax)
		{
			FOutputX.SliceCount = SpreadMax;
			FOutputY.SliceCount = SpreadMax;

			for (int i = 0; i < SpreadMax; i++) {
				FOutputX[i] = FInputA[i]*Math.Cos(FInputT[i]);
				FOutputY[i] = FInputB[i]*Math.Cos(FInputT[i]) * Math.Sin(FInputT[i]);
			}

			//Flogger.Log(LogType.Debug, "Logging to Renderer (TTY)");
		}
	}
}
