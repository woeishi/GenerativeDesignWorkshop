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
    [PluginInfo(Name = "Koch", Category = "2d", Author = "fibo", Help = "", Tags = "2d,curve,fractal")]
    #endregion PluginInfo
    public class Koch : IPluginEvaluate
    {

        #region fields & pins
    	private int recurse = 0;
    	
        [Input("Input ", DefaultValue = 1.0)]
        IDiffSpread<Vector2D> FInput;

        [Input("K1", DefaultValue = 0.333)]
        IDiffSpread<double> FK1;

        [Input("K2", DefaultValue = 0.433)]
        IDiffSpread<double> FK2;

        [Input("K3", DefaultValue = 0.666)]
        IDiffSpread<double> FK3;

        [Input("Interactions", DefaultValue = 1, MinValue = 1, StepSize = 1, IsSingle = true, AsInt = true)]
        IDiffSpread<int> FInteractions;

        [Output("Output ")]
        ISpread<Vector2D> FOutput;

        [Import()]
        ILogger Flogger;
        #endregion fields & pins

        /// <summary>
        /// One iteration
        /// </summary>
        /// <param name="points"></param>
        protected List<Vector2D> Iteration(List<Vector2D> points)
        {
            try
            {
                List<Vector2D> outpoints = new List<Vector2D>();
                for (int i = 0; i < points.Count + (points.Count - 1) * 3; i++)
                    outpoints.Add(new Vector2D());


                for (int i = 0; i < points.Count - 1; i++)
                {
                    Vector2D perpendicular = new Vector2D(points[i + 1].y - points[i].y, points[i].x - points[i + 1].x);

                    outpoints[4 * i] = points[i];
                    outpoints[4 * i + 1] = points[i] + (points[i + 1] - points[i]) * FK1[i];
                    outpoints[4 * i + 2] = points[i] * 0.5 + points[i + 1] * 0.5 + perpendicular * FK2[i];
                    outpoints[4 * i + 3] = points[i] + (points[i + 1] - points[i]) * FK3[i];
                }
                outpoints[outpoints.Count - 1] = points[points.Count - 1];
                recurse--;
                if (recurse > 0)
                    outpoints = Iteration(outpoints);
                return outpoints;
            }
            catch (Exception ex)
            {
                Flogger.Log(LogType.Debug, "Iteration error: " + ex.Message);
                return null;
            }
        }

        //called when data for any output pin is requested
        public void Evaluate(int SpreadMax)
        {

            if (FInput.IsChanged || FK1.IsChanged || FK2.IsChanged || FK3.IsChanged || FInteractions.IsChanged)
            {
                if (FInput.SliceCount == 0) return;
                List<Vector2D> inputpoints = new List<Vector2D>();
                /// copy input points to list
                for (int i = 0; i < FInput.SliceCount; i++)
                    inputpoints.Add(FInput[i]);
                recurse = FInteractions[0];
                List<Vector2D> outpoints = Iteration(inputpoints);
                if (outpoints == null) return;
                FOutput.SliceCount = outpoints.Count;
                for (int i = 0; i < outpoints.Count; i++)
                    FOutput[i] = outpoints[i];
            }

            //Flogger.Log(LogType.Debug, "Logging to Renderer (TTY)");
        }
    }
}
