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
	[PluginInfo(Name = "Peano", Category = "2d", Help = "Basic template with one value in/out", Tags = "")]
	#endregion PluginInfo
	public class C2dPeanoNode : IPluginEvaluate
	{
		#region fields & pins
		private int recurse = 0;
		
		[Input("A ")]
		IDiffSpread<Vector2D> FInputA;

		[Input("B ")]
		IDiffSpread<Vector2D> FInputB;

		[Input("C ")]
		IDiffSpread<Vector2D> FInputC;

		[Input("D ")]
		IDiffSpread<Vector2D> FInputD;

        [Input("Interactions", DefaultValue = 1, MinValue = 1, StepSize = 1, IsSingle = true, AsInt = true)]
        IDiffSpread<int> FInteractions;

		[Output("Output ")]
		ISpread<Vector2D> FOutput;

		[Import()]
		ILogger FLogger;
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
            	
            	
            	for(int i = 0; i < points.Count; i = i + 4){
            		Vector2D center = new Vector2D(( points[i].x + points[i+1].x + points[i+2].x + points[i+3].x )/4,( points[i].y + points[i+1].y + points[i+2].y + points[i+3].y )/4);
            		
            		Vector2D a = new Vector2D();
            		Vector2D b = new Vector2D();
            		Vector2D c = new Vector2D();
            		Vector2D d = new Vector2D();
            		
            		// translate to origin
            		a = points[i]   - center;
            		b = points[i+1] - center;
            		c = points[i+2] - center;
            		d = points[i+3] - center;
            		
            		// scale
            		a = a/2;
            		b = b/2;
            		c = c/2;
            		d = d/2;
            		
            		// translate to each of the four starting points
            		// every input point generates 4 output points
            		outpoints.Add(new Vector2D(a.x + points[i].x,a.y + points[i].y));
            		outpoints.Add(new Vector2D(d.x + points[i].x,d.y + points[i].y));
            		outpoints.Add(new Vector2D(c.x + points[i].x,c.y + points[i].y));
            		outpoints.Add(new Vector2D(b.x + points[i].x,b.y + points[i].y));
            		
            		outpoints.Add(new Vector2D(a.x + points[i+1].x,a.y + points[i+1].y));
            		outpoints.Add(new Vector2D(b.x + points[i+1].x,b.y + points[i+1].y));
            		outpoints.Add(new Vector2D(c.x + points[i+1].x,c.y + points[i+1].y));
            		outpoints.Add(new Vector2D(d.x + points[i+1].x,d.y + points[i+1].y));
            		
            		outpoints.Add(new Vector2D(a.x + points[i+2].x,a.y + points[i+2].y));
            		outpoints.Add(new Vector2D(b.x + points[i+2].x,b.y + points[i+2].y));
            		outpoints.Add(new Vector2D(c.x + points[i+2].x,c.y + points[i+2].y));
            		outpoints.Add(new Vector2D(d.x + points[i+2].x,d.y + points[i+2].y));
            		
            		outpoints.Add(new Vector2D(c.x + points[i+3].x,c.y + points[i+3].y));
            		outpoints.Add(new Vector2D(b.x + points[i+3].x,b.y + points[i+3].y));
            		outpoints.Add(new Vector2D(a.x + points[i+3].x,a.y + points[i+3].y));
            		outpoints.Add(new Vector2D(d.x + points[i+3].x,d.y + points[i+3].y));
            	}

            	recurse--;
                if (recurse > 0)
                    outpoints = Iteration(outpoints);

                return outpoints;
            }
            catch (Exception ex)
            {
                //Flogger.Log(LogType.Debug, "Iteration error: " + ex.Message);
                return null;
            }
        }

		//called when data for any output pin is requested
		public void Evaluate(int SpreadMax)
		{
            if (FInteractions.IsChanged || FInputA.IsChanged || FInputB.IsChanged || FInputC.IsChanged || FInputD.IsChanged )
            {
                if (FInputA.SliceCount == 0) return;
            	if (FInputB.SliceCount == 0) return;
            	if (FInputC.SliceCount == 0) return;
            	if (FInputD.SliceCount == 0) return;
            	            	
                List<Vector2D> inputpoints = new List<Vector2D>();
                /// copy inputs points to list
                inputpoints.Add(FInputA[0]);
            	inputpoints.Add(FInputB[0]);
            	inputpoints.Add(FInputC[0]);
            	inputpoints.Add(FInputD[0]);
                recurse = FInteractions[0];

                List<Vector2D> outpoints = Iteration(inputpoints);
                if (outpoints == null) return;
                FOutput.SliceCount = outpoints.Count;
                for (int i = 0; i < outpoints.Count; i++)
                    FOutput[i] = outpoints[i];

            }
			//FLogger.Log(LogType.Debug, "hi tty!");
		}
	}
}
