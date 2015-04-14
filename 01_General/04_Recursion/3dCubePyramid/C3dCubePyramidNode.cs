#region usings
using System;
using System.ComponentModel.Composition;

using VVVV.PluginInterfaces.V1;
using VVVV.PluginInterfaces.V2;
using VVVV.Utils.VColor;
using VVVV.Utils.VMath;

using System.Collections.Generic;

using VVVV.Core.Logging;
#endregion usings

namespace VVVV.Nodes
{
	#region PluginInfo
	[PluginInfo(Name = "CubePyramid", Category = "3d", Help = "Basic template with one value in/out", Tags = "")]
	#endregion PluginInfo
	public class C3dCubePyramidNode : IPluginEvaluate
	{
		#region fields & pins
		[Input("Scale", DefaultValue = 1.0)]
		public IDiffSpread<double> FInScale;
		
		[Input("Iterations", DefaultValue = 1.0, IsSingle = true)]
		public IDiffSpread<int> FInIterations;
		
		[Input("Scale Factor", DefaultValue = 1.0, IsSingle = true)]
		public IDiffSpread<double> FInScaleFactor;
		
		[Output("Position XYZ")]
		public ISpread<Vector3D> FOutPos;
		
		[Output("Scale")]
		public ISpread<double> FOutScale;
		
		private List<Vector3D> offsetVectors;
		
		private List<Vector3D> cubesXYZ;
		private List<double> cubesSize;
		
		[Import()]
		public ILogger FLogger;
		#endregion fields & pins
		
		public C3dCubePyramidNode()
		{
			offsetVectors = new List<Vector3D>();
			offsetVectors.Add(new Vector3D(-1,0,0)); //left
			offsetVectors.Add(new Vector3D(1,0,0)); //right
			offsetVectors.Add(new Vector3D(0,-1,0)); //down
			offsetVectors.Add(new Vector3D(0,1,0)); //up
			offsetVectors.Add(new Vector3D(0,0,-1)); //backward
			offsetVectors.Add(new Vector3D(0,0,1)); //forward
		}
		
		//called when data for any output pin is requested
		public void Evaluate(int SpreadMax)
		{
			if (FInIterations.IsChanged || FInScale.IsChanged || FInScaleFactor.IsChanged)
			{
				cubesXYZ = new List<Vector3D>();
				cubesSize = new List<double>();
				
				int iterationCounter = 0;
				GenerateCubes(new Vector3D(0,0,0), FInScale[0], iterationCounter);
				
				FOutPos.AssignFrom(cubesXYZ);
				FOutScale.AssignFrom(cubesSize);
			}
		}
		
		private void GenerateCubes(Vector3D center, double size, int iterationLevel)
		{
			if (iterationLevel <= FInIterations[0])
			{
				cubesXYZ.Add(center);
				cubesSize.Add(size);
				
				iterationLevel++;
				foreach (Vector3D oV in offsetVectors)
				{
					GenerateCubes(center + oV * size*FInScaleFactor[0], size*FInScaleFactor[0], iterationLevel);
				}
			}
		}
	}
}
