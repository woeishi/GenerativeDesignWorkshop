/*
3D Perlin Noise on the vertex shader
Reflections version/////////////////

based originally on
vBomb.fx HLSL vertex noise shader,
reflections.fx
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
float4x4 tWIT : WorldInverseTranspose;
float4x4 tWVP : WorldViewProjection;
float4x4 tW   : World;
float4x4 tVI  : ViewInverse;

float4x4 TT ;
float4x4 NoiseMatrix = {1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1};

//light properties
float3 lPos <string uiname = "Light Position";> = {100.0, 100.0, -100.0};
float4 lCol : COLOR <string UIName =  "Light Color";> = {1.0, 1.0, 1.0, 1};
float4 AmbiCol : COLOR <string UIName =  "Ambient Light Color";> = {0.07, 0.07, 0.07, 1};
float4 SurfCol : COLOR <string UIName =  "Surface Color";> = {0.546, 0.379, 0.218, 1};

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

float4x4 tColor <string uiname="Color Transform";>;

float SpecExpon <string UIName =  "Specular Power";
float UIMin = 1.0;
float UIMax = 128.0;
float UIStep = 1.0;>
 = 80.0;

// typical Kd on metal is low - just as a dirtiness" factor
// typical Kd on plastics is high
float Kd <string UIName =  "Diffuse ";
float UIMin = 0.0;
float UIMax = 1.0;
float UIStep = 0.05;>
 = 0.1;

float Kr <string UIName =  "Reflection";
float UIMin = 0.0;
float UIMax = 1.0;
float UIStep = 0.05;>
 = 0.8;

float FresnelMin <string UIName =  "Fresnel Reflection Scale";
float UIMin = 0.0;
float UIMax = 1.0;
float UIStep = 0.05;>
 = 0.05;

static float KrMin = (Kr * FresnelMin);

//This exponent is used to perform the "Schlick APproximation" to Fresnel's original equation. It is fast and visualy satifying.
//The standard value is 5.0 though different values are also visually interesting.
float FresnelExp<string UIName =  "Fresnel Exponent";
float UIMin = 0.0;
float UIMax = 5.0;
float UIStep = 0.05;>
 = 3.5;

static float InvFrExp = (1.0/FresnelExp);
float timer : TIME;

float TurbDensity <string uiname="Turbulence Density";
float UIMin = 0.01;
float UIStep = 0.001;>
= 2.27;

float Disp <string uiname="Displacement";
float UIMin = 0.0;
float UIStep = 0.01;>
= 1.6;

float Sharp <string uiname="Sharpness";
float UIMin = 0.1;
float UIStep = 0.1;>
= 1.90;

float Speed <string uiname="Speed";
float UIMin = 0.01;
float UIStep = 0.001;>
= 0.3;

float radius = 1;

//float4 dd[5] = {0,2,3,1, 2,2,2,2, 3,3,3,3, 4,4,4,4, 5,5,5,5 };

struct vs2ps
{
    float4 HPosition	: POSITION;
    half4  TexCoord	: TEXCOORD0;
    half3 LightVec	: TEXCOORD1;
    half3 WorldNormal	: TEXCOORD2;
    half3 WorldView	: TEXCOORD3;
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
   // v = v + float3(10000.0, 10000.0, 10000.0);   // hack to avoid negative numbers
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

    OUT.WorldNormal = mul(NormO, tWIT).xyz;
    float4 Po = float4(PosO.xyz,1);
    float3 Pw = mul(Po, tW).xyz;
    OUT.LightVec = normalize(lPos - Pw);
    OUT.TexCoord = UV;
    OUT.WorldView = normalize(tVI[3].xyz - Pw);
    OUT.HPosition = mul(Po, tWVP);
    return OUT;
}
    
// --------------------------------------------------------------------------------------------------
// PIXELSHADERS:
// --------------------------------------------------------------------------------------------------

 void shared_lighting_calculations(vs2ps IN,
		out float3 DiffuseContrib,
		out float3 SpecularContrib,
		out float3 ReflectionContrib)
{
    float3 Ln = normalize(IN.LightVec);
    float3 Nn = normalize(IN.WorldNormal);
    float3 Vn = normalize(IN.WorldView);
    float3 Hn = normalize(Vn + Ln);
    float4 litV = lit(dot(Ln,Nn),dot(Hn,Nn),SpecExpon);
    DiffuseContrib = litV.y * Kd * lCol + AmbiCol;
    SpecularContrib = litV.z * lCol;
    float3 reflVect = -reflect(Vn,Nn);
    ReflectionContrib = Kr * texCUBE(Samp,reflVect).xyz;
}

float4 metalPS(vs2ps IN) : COLOR {
    float3 diffContrib;
    float3 specContrib;
    float3 reflColor;
	shared_lighting_calculations(IN,diffContrib,specContrib,reflColor);
    float3 result = diffContrib +
				(SurfCol * (specContrib + reflColor));
    return mul((float4(result,1)),tColor);
}

float4 plasticPS(vs2ps IN) : COLOR {
    float3 diffContrib;
    float3 specContrib;
    float3 reflColor;
    float3 Nn = normalize(IN.WorldNormal);
    float3 Vn = normalize(IN.WorldView);
	float fresnel = lerp(Kr,KrMin,pow(abs(dot(Nn,Vn)),InvFrExp));
	shared_lighting_calculations(IN,diffContrib,specContrib,reflColor);
    float3 result = (diffContrib * SurfCol) + specContrib + (fresnel*reflColor);
    return mul((float4(result,1)),tColor);
}


// --------------------------------------------------------------------------------------------------
// TECHNIQUES:
// --------------------------------------------------------------------------------------------------

technique vNoise3DMetal
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
        VertexShader = compile vs_3_0 VS_vNoise3D();
        PixelShader = compile ps_2_0 metalPS();
    }
}

technique vNoise3DnoisePlastic
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
        VertexShader = compile vs_3_0 VS_vNoise3D();
        PixelShader = compile ps_2_0 plasticPS();
    }
}
