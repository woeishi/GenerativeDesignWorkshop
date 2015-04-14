/*
3D Perlin Noise on the vertex shader
Gooch version////////////////////////////////////////////////////////

based originally on
vBomb.fx HLSL vertex noise shader,
and gooch.fx
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
float4x4 tW  : WORLD;        //the models world matrix
float4x4 tV  : VIEW;         //view matrix as set via Renderer (EX9)
float4x4 tWVP: WORLDVIEWPROJECTION;
float4x4 tWIT : WorldInverseTranspose;
float4x4 tVI  : ViewInverse;

float4x4 TT ;
float4x4 NoiseMatrix = {1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1};

//light properties
float3 lPos <string UIName = "Light Position";> = {0, -5, 2};
float4 LiteCol : COLOR <string UIName =  "Bright Surface Color";> = {0.8, 0.5, 0.1, 1};
float4 DarkCol : COLOR <string UIName =  "Dark Surface Color";> = {0.0, 0.0, 0.0, 1};
float4 WarmCol : COLOR <string UIName =  "Gooch Warm Tone";> = {0.5, 0.4, 0.05, 1};
float4 CoolCol : COLOR <string UIName =  "Gooch Cool Tone";> = {0.05, 0.05, 0.6, 1};
float4 SpecCol : COLOR <string UIName =  "Hilight Color";> = {0.7, 0.7, 1.0, 1};

float SpecExpon <string UIName =  "Specular Exponent";
float UIMin = 0;
float UIStep = 1.0;>
 = 40.0;

float GlossTop <string UIName =  "Maximum for Gloss Dropoff";
float UIMin = 0;
float UIStep = 0.05;>
 = 0.7;

float GlossBot <string UIName =  "Minimum for Gloss Dropoff";
float UIMin = 0;
float UIStep = 0.05;>
 = 0.5;

float GlossDrop <string UIName =  "Strength of Glossy Dropoff";
float UIMin = 0;
float UIStep = 0.05;>
 = 0.2;

// include the noise-table
#include "vnoise-table.fxh"

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

float timer : TIME;

float TurbDensity <string uiname="Turbulence Density";
float UIMin = 0;
float UIStep = 0.001;>
= 2.27;

float Disp <string uiname="Displacement";
float UIMin = 0;
float UIStep = 0.01;>
= 1.6;

float Sharp <string uiname="Sharpness";
float UIMin = 0;
float UIStep = 0.1;>
= 1.90;

float Speed <string uiname="Speed";
float UIMin = 0;
float UIStep = 0.001;>
= 0.3;

float radius = 1;

//float4 dd[5] = {0,2,3,1, 2,2,2,2, 3,3,3,3, 4,4,4,4, 5,5,5,5 };


struct vs2ps
{
    float4 HPosition	: POSITION;
    float4 TexCoord	: TEXCOORD0;
    float3 LightVec	: TEXCOORD1;
    float3 WorldNormal	: TEXCOORD2;
    float3 WorldPos	: TEXCOORD3;
    float3 WorldEyePos	: TEXCOORD4;
};

// --------------------------------------------------------------------------------------------------
// FUNCTIONS:
// --------------------------------------------------------------------------------------------------
#define TWOPI 6.28318531
#define PI 3.14159265
#define gridSpaceX 0.001
#define gridSpaceY 0.001


float3 sphere(float u, float v)
 {
    float x = radius * cos(v) * sin(u) ;
    float y = radius * sin(v) * sin(u) ;
    float z = radius * cos(u) ;

    return float3(x, y, z);
}

// this is the smoothstep function f(t) = 3t^2 - 2t^3, without the normalization
float3 scurve3D(float3 t) { return t*t*( float3(3,3,3) - float3(2,2,2)*t); }

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

float3 vNoiseFunc3D(float u, float v)
{

    float4 PosO = float4(sphere(u, v), 1);
    float4 noisePos = TurbDensity*mul(PosO+(Speed*timer),NoiseMatrix);
    float i = (noise3D(noisePos.xyz, NTab) + 1.0) * 0.5f;
    // displacement along normal
    float ni = pow(abs(i),Sharp);
    i -=  0.5;
    //i = sign(i) * pow(i,Sharpness);
    float4 Nn = float4(normalize(PosO).xyz,0);

    return  PosO - (Nn * (ni-0.5) * Disp);
}

// --------------------------------------------------------------------------------------------------
// VERTEXSHADERS
// --------------------------------------------------------------------------------------------------

vs2ps VS_vNoise3D(
    float4 PosO: POSITION,
    float3 NormO: NORMAL,
    float4 UV : TEXCOORD0)
{
    //inititalize all fields of output struct with 0
    vs2ps OUT = (vs2ps)0;
    PosO =  mul(PosO, TT);
    
    float x, y, z, u, v;
    float u2, v2;
    float3 tang, bitang;

    u = (PosO.x + 0.5) * PI;
    v = (PosO.y + 0.5) *TWOPI;

    //to get neighbour
    u2 = (PosO.x + gridSpaceX + 0.5)*PI;
    v2 = (PosO.y + gridSpaceY + 0.5)*TWOPI;

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
    OUT.LightVec = normalize(-mul(lPos, tV));

    //normal in view space
    OUT.WorldNormal = mul(NormO, tWIT).xyz;
    float4 Po = float4(PosO.xyz,1);
    float3 Pw = mul(Po, tW).xyz;
    OUT.WorldPos = Pw;
    OUT.LightVec = lPos - Pw;
    OUT.TexCoord = mul(UV, tTex);
    OUT.WorldEyePos = tVI[3].xyz;
    OUT.HPosition = mul(Po, tWVP);
    return OUT;
}

// --------------------------------------------------------------------------------------------------
// PIXELSHADERS:
// --------------------------------------------------------------------------------------------------
static float g_Min = min(GlossBot,GlossTop);
static float g_Max = max(GlossBot,GlossTop);
static float g_Dr = (1.0 - GlossDrop);

void gooch_shared(vs2ps IN,
		out float4 DiffuseContrib,
		out float4 SpecularContrib)
{
    float3 Ln = normalize(IN.LightVec);
    float3 Nn = normalize(IN.WorldNormal);
    float3 Vn = normalize(IN.WorldEyePos - IN.WorldPos);
    float3 Hn = normalize(Vn + Ln);
    float hdn = pow(max(0,dot(Hn,Nn)),SpecExpon);
    hdn = hdn * (GlossDrop+smoothstep(g_Min,g_Max,hdn)*g_Dr);
    SpecularContrib = float4((hdn * SpecCol));
    float ldn = dot(Ln,Nn);
    float mixer = 0.5 * (ldn + 1.0);
    float diffComp = max(0,ldn);
    float3 surfColor = lerp(DarkCol,LiteCol,mixer);
    float3 toneColor = lerp(CoolCol,WarmCol,mixer);
    DiffuseContrib = float4((surfColor + toneColor),1);
}


float4 PS(vs2ps IN) :COLOR
{
       float4 diffContrib;
       float4 specContrib;
	gooch_shared(IN,diffContrib,specContrib);
    float4 result = tex2D(Samp,IN.TexCoord.xy)*diffContrib + specContrib;
    return mul(result,tColor);
}


// --------------------------------------------------------------------------------------------------
// TECHNIQUES:
// --------------------------------------------------------------------------------------------------

technique vNoiseGoochy
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
        VertexShader = compile vs_3_0 VS_vNoise3D();
        PixelShader = compile ps_2_0 PS();
    }
}
