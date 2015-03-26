/*
3D Perlin Noise on the vertex shader
based originally on vBomb.fx HLSL vertex noise shader,
from the NVIDIA Shader Library.

based on Ken Perlins original code:
http://mrl.nyu.edu/~perlin/doc/oscar.html

vvvv setup : desaxismundi
http://vvvv.org/users/desaxismundi

shading:         phong
lighting model:  blinn
lighting type:   directional
*/
// --------------------------------------------------------------------------------------------------
// PARAMETERS:
// --------------------------------------------------------------------------------------------------

//transforms
float4x4 tW: WORLD;        //the models world matrix
float4x4 tV: VIEW;         //view matrix as set via Renderer (EX9)
float4x4 tWV: WORLDVIEW;
float4x4 tVP: VIEWPROJECTION;
float4x4 tWVP: WORLDVIEWPROJECTION;
float4x4 tP: PROJECTION;   //projection matrix as set via Renderer (EX9)

float4x4 TT ;
float4x4 NoiseMatrix = {1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1};
// include the noise-table
#include "vnoise-table.fxh"

//light properties
float3 lDir <string uiname="Light Direction";> = {0, -5, 2};        //light direction in world space
float4 lAmb  : COLOR <String uiname="Ambient Color";>  = {0.15, 0.15, 0.15, 1};
float4 lDiff : COLOR <String uiname="Diffuse Color";>  = {0.85, 0.85, 0.85, 1};
float4 lSpec : COLOR <String uiname="Specular Color";> = {0.35, 0.35, 0.35, 1};
float lPower <String uiname="Power"; float uimin=0.0;> = 25.0;     //shininess of specular highlight

//texture
texture Tex <string uiname="Texture";>;
sampler Samp = sampler_state    //sampler for doing the texture-lookup
{
    Texture   = (Tex);          //apply a texture to the sampler
    MipFilter = LINEAR;         //sampler states
    MinFilter = LINEAR;
    MagFilter = LINEAR;
};

float4x4 tTex: TEXTUREMATRIX <string uiname="Texture Transform";>;
float4x4 tColor <string uiname="Color Transform";>;

////////////////Tweakables//////////////////////////////////////

float timer;

float TurbDensity <string uiname="Turbulence Density";
	float UIMin = 0.01;
	float UIMax = 8.0;
	float UIStep = 0.001;>
        = 2.27;

float Disp <string uiname="Displacement";
      float UIMin = 0.0;
      float UIMax = 2.0;
      float UIStep = 0.01;>
      = 1.6;

float Sharp <string uiname="Sharpness";
	float UIMin = 0.1;
	float UIMax = 5.0;
	float UIStep = 0.1;>
        = 1.90;

float Speed <string uiname="Speed";
	float UIMin = 0.01;
	float UIMax = 1.0;
	float UIStep = 0.001;>
        = 0.3;

struct vs2ps
{
    float4 PosWVP: POSITION;
    float4 TexCd : TEXCOORD0;
    float3 LightDirV: TEXCOORD1;
    float3 NormV: TEXCOORD2;
    float3 ViewDirV: TEXCOORD3;
    float3 Pos: TEXCOORD4;
};

// --------------------------------------------------------------------------------------------------
// FUNCTIONS:
// --------------------------------------------------------------------------------------------------

#define TWOPI 6.28318531
#define PI 3.14159265

#define gridSpaceX 0.001
#define gridSpaceY 0.001

float gridScaleX = 1;
float gridScaleY = 1;

float param1 = 1;
float param2 = 1;
float param3 = 1;
float param4 = 1;

float3 cone(float u, float theta)
 {

   float3 p;
   float a = ((gridScaleX-u) / gridScaleX) * param1;// * (param2 * (cos(u*param3)+1) + 1);

   float3 offset;

   p.x = a * cos(theta);
   p.y = a * sin(theta);
   p.z = u ;

   offset.x = u * cos(param2 * TWOPI - u);
   offset.y = u * cos(param3 * TWOPI - u);
   offset.z = 0;

   return p+offset*param4;
}

///////////// functions//////////////////////////////////////////////////////////

// this is the smoothstep function f(t) = 3t^2 - 2t^3, without the normalization
float3 scurve3D(float3 t) { return t*t*( float3(3,3,3) - float3(2,2,2)*t); }
float2 scurve2D(float2 t) { return t*t*( float2(3,3) - float2(2,2)*t); }
float  scurve1D(float  t) { return t*t*(3.0-2.0*t); }

// 3D version
float noise3D(float3 v,
const uniform float4 pg[FULLSIZE])
{
    v = v + abs(v);   // hack to avoid negative numbers

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

float3 vNoiseFunc3D(float u, float v)
{

    float4 PosO = float4(cone(u, v), 1);
    float4 noisePos = TurbDensity*mul(PosO+(Speed*timer),NoiseMatrix);
    float i = (noise3D(noisePos.xyz, NTab) + 1.0) * 0.5f;
    // displacement along normal
    float ni = pow(abs(i),Sharp);
    i -=  0.5;
    //i = sign(i) * pow(i,Sharpness);

    // we will use our own "normal" vector because the default geom is a sphere
    float4 Nn = float4(normalize(PosO).xyz,0);

    return  PosO - (Nn * (ni-0.5) * Disp);
}


// --------------------------------------------------------------------------------------------------
// VERTEXSHADERS
// --------------------------------------------------------------------------------------------------


vs2ps VS_vNoise3D(
    float4 PosO: POSITION,
    float3 NormO: NORMAL,
    float4 TexCd : TEXCOORD0)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;
    PosO =  mul(PosO, TT);
    
    float x, y, z, u, v, pi;
    float u2, v2;
    float3 tang, bitang;

    //map u and v
    gridScaleX *= PI;
    gridScaleY *= TWOPI;

    u = (PosO.x + 0.5) * gridScaleX;
    v = (PosO.y + 0.5) * gridScaleY;

    //to get neighbour in u direction
    u2 = (PosO.x + gridSpaceX + 0.5) * gridScaleX;

    //to get neighbour in v direction
    v2 = (PosO.y + gridSpaceY + 0.5) * gridScaleY;

    //get position
    PosO.xyz = vNoiseFunc3D(u, v);

    //get position of neighbours
    tang   = vNoiseFunc3D(u2, v);
    bitang = vNoiseFunc3D(u, v2);

    //get tangent and bitangent
    tang   -= PosO.xyz;
    bitang -= PosO.xyz;

    //get normal
    NormO = cross(tang, bitang);
    //inverse light direction in view space
    Out.LightDirV = normalize(-mul(lDir, tV));

    //normal in view space
    Out.NormV = normalize(mul(NormO, tWV));

    //position (projected)
    Out.PosWVP  = mul(PosO, tWVP);
    Out.TexCd = mul(TexCd, tTex);
    Out.ViewDirV = -normalize(mul(PosO, tWV));
    return Out;
}

// --------------------------------------------------------------------------------------------------
// PIXELSHADERS:
// --------------------------------------------------------------------------------------------------


float4 PS(vs2ps In): COLOR
{
    //In.TexCd = In.TexCd / In.TexCd.w; // for perpective texture projections (e.g. shadow maps) ps_2_0

    lAmb.a = 1;
    //halfvector
    float3 H = normalize(In.ViewDirV + In.LightDirV);

    //compute blinn lighting
    float3 shades = lit(dot(In.NormV, In.LightDirV), dot(In.NormV, H), lPower);

    float4 diff = lDiff * shades.y;
    diff.a = 1;

    //reflection vector (view space)
    float3 R = normalize(2 * dot(In.NormV, In.LightDirV) * In.NormV - In.LightDirV);
    //normalized view direction (view space)
    float3 V = normalize(In.ViewDirV);

    //calculate specular light
    float4 spec = pow(max(dot(R, V),0), lPower*.2) * lSpec;

    float4 col = tex2D(Samp, In.TexCd);
    col.rgb *= (lAmb + diff) + spec;
    return mul(col, tColor);
}


// --------------------------------------------------------------------------------------------------
// TECHNIQUES:
// --------------------------------------------------------------------------------------------------

technique vNoise3D
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
        VertexShader = compile vs_3_0 VS_vNoise3D();
        PixelShader = compile ps_2_a PS();
    }
}
