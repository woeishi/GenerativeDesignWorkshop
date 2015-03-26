/*
3D Perlin Noise on the vertex shader
based originally on vBomb.fx HLSL vertex noise shader,
from the NVIDIA Shader Library.

based on Ken Perlins original code:
http://mrl.nyu.edu/~perlin/doc/oscar.html

vvvv setup : desaxismundi
http://vvvv.org/users/desaxismundi

*/
// --------------------------------------------------------------------------------------------------
// PARAMETERS:
// --------------------------------------------------------------------------------------------------

//transforms
float4x4 tW   : WORLD;        //the models world matrix
float4x4 tV   : VIEW;         //view matrix as set via Renderer (EX9)
float4x4 tP   : PROJECTION;   //projection matrix as set via Renderer (EX9)
float4x4 tWVP : WORLDVIEWPROJECTION;

// include the noise-table
#include "vnoise-table.fxh"

////////////texture////////////////////////////////////////

texture Tex <string uiname="Texture";>;
sampler Samp = sampler_state      //sampler for doing the texture-lookup
{
Texture   = (Tex);                //apply a texture to the sampler
MinFilter = LINEAR;
MagFilter = LINEAR;               //sampler states
MipFilter = POINT;
AddressU = CLAMP;
AddressV = CLAMP;
};

float4x4 NoiseMatrix = {1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1};

float timer : TIME;

float4 tColor : color ;

float Disp <string uiname="Displacement";
      float UIMin = 0.0;
      float UIMax = 10.0;
      float UIStep = 0.01;>
      = 1.6;

float Sharp <string uiname="Sharpness";
	float UIMin = 0.1;
	float UIMax = 10.0;
	float UIStep = 0.1;>
        = 1.90;

float Speed <string uiname="Speed";
	float UIMin = 0.01;
	float UIMax = 5.0;
	float UIStep = 0.001;>
        = 0.3;

float TurbDensity <string uiname="Turbulence Density";
	float UIMin = 0.01;
	float UIMax = 10.0;
	float UIStep = 0.001;>
        = 2.27;
        
float ColSharp <string uiname="ColorSharpness";
	float UIMin = 0.1;
	float UIMax = 10.0;
	float UIStep = 0.1;>
        = 3.0;
        
float ColorRange <string uiname="Color Range";
	float UIMin = -6.0;
	float UIMax = 5.0;
	float UIStep = 0.01;>
        = -2.0;

//float4 dd[5] = {0,2,3,1, 2,2,2,2, 3,3,3,3, 4,4,4,4, 5,5,5,5 };


///////////// functions//////////////////////////////////////////////////////////

// this is the smoothstep function f(t) = 3t^2 - 2t^3, without the normalization
float3 scurve3D(float3 t) { return t*t*( float3(3,3,3) - float3(2,2,2)*t); }
float2 scurve2D(float2 t) { return t*t*( float2(3,3) - float2(2,2)*t); }
float  scurve1D(float  t) { return t*t*(3.0-2.0*t); }

// 3D version
float noise3D(float3 v,
const uniform float4 pg[FULLSIZE])
{
    //v = v + float3(10000.0, 10000.0, 10000.0);   // hack to avoid negative numbers
    v = v + abs(v);
    
    
    float3 i = frac(v * NOISEFRAC) * BSIZE;   // index between 0 and BSIZE-1
    float3 f = frac(v);            // fractional position

// lookup in permutation table
    float2 p;
    p.x = pg[ i[0]     ].w;
    p.y = pg[ i[0] + 1 ].w;
    p = p + i[1];

    float4 b;
    b.x = pg[ p[0] ].w;
    b.y = pg[ p[1] ].w;
    b.z = pg[ p[0] + 1 ].w;
    b.w = pg[ p[1] + 1 ].w;
    b = b + i[2];

// compute dot products between gradients and vectors
    float4 r;
    r[0] = dot( pg[ b[0] ].xyz, f );
    r[1] = dot( pg[ b[1] ].xyz, f - float3(1.0, 0.0, 0.0) );
    r[2] = dot( pg[ b[2] ].xyz, f - float3(0.0, 1.0, 0.0) );
    r[3] = dot( pg[ b[3] ].xyz, f - float3(1.0, 1.0, 0.0) );

    float4 r1;
    r1[0] = dot( pg[ b[0] + 1 ].xyz, f - float3(0.0, 0.0, 1.0) );
    r1[1] = dot( pg[ b[1] + 1 ].xyz, f - float3(1.0, 0.0, 1.0) );
    r1[2] = dot( pg[ b[2] + 1 ].xyz, f - float3(0.0, 1.0, 1.0) );
    r1[3] = dot( pg[ b[3] + 1 ].xyz, f - float3(1.0, 1.0, 1.0) );

// interpolate
    f = scurve3D(f);
    r = lerp( r, r1, f[2] );
    r = lerp( r.xyyy, r.zwww, f[1] );
    return lerp( r.x, r.y, f[0] );
}


// define outputs from vertex shader
struct vs2ps
{
    float4 Pos    : POSITION;
    float4 Color0 : COLOR0;
};

// --------------------------------------------------------------------------------------------------
// VERTEXSHADERS
// --------------------------------------------------------------------------------------------------

vs2ps VS_vBomb3D(
         float4 PosO     : POSITION,
         float4 NormO     : NORMAL,
         float4 TexCd    : TEXCOORD0)
 {
 //inititalize all fields of output struct with 0
    vs2ps OUT = (vs2ps)0;
    
    float4 noisePos = TurbDensity*mul(PosO+(Speed*timer),NoiseMatrix);
    float i = (noise3D(noisePos.xyz, NTab) + 1.0) * 0.5f;
    float cr = 1.0-(0.5+ColorRange*(i-0.5));
    cr = pow(cr,ColSharp);
    OUT.Color0 = float4((cr).xxx, 1.0);
    // displacement along normal
    float ni = pow(abs(i),Sharp);
    i -=  0.5;
    //i = sign(i) * pow(i,Sharpness);
    // we will use our own "normal" vector because the default geom is a sphere
    float4 Nn = float4(normalize(PosO).xyz,0);
    float4 NewPos = PosO - (Nn * (ni-0.5) * Disp);
    //position.w = 1.0f;
    OUT.Pos = mul(NewPos,tWVP);
    return OUT;
}

// --------------------------------------------------------------------------------------------------
// PIXELSHADERS:
// --------------------------------------------------------------------------------------------------

float4 PS(vs2ps IN) : COLOR
{
float2 nuv = float2(IN.Color0.x,0.5);
float4 nc = tex2D(Samp,nuv);
	//return float4(IN.Color0.xxx,1.0);
return nc*tColor;
}


// --------------------------------------------------------------------------------------------------
// TECHNIQUE:
// --------------------------------------------------------------------------------------------------

technique vBomb3Dnoise
 {
	pass p0
	
 {
		VertexShader = compile vs_2_0 VS_vBomb3D();
		PixelShader = compile ps_2_0 PS();
	}
}
