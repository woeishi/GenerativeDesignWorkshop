/*
3D Perlin Noise on the vertex shader
Velvety version/////////////////////

based originally on :
vBomb.fx HLSL vertex noise shader
velvety.fx
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

float3 lPos <string uiname="Light Position";> ={0, -5, 2};
float4 lDiff : COLOR <string uiname="Diffuse Color";> = {0.5, 0.5, 0.5,1};
float4 lSpec : COLOR <String uiname="Specular Color";> = {0.7, 0.7, 0.75,1};
float4 lSub  : COLOR <String uiname="Under-Color";> =  {0.2, 0.2, 1.0,1};
float lRollOff <String uiname="Edge Rolloff";
float UIMin = 0.0; float UIMax = 1.0; float UIStep = 0.05;> = 0.3;

// include the noise-table
#include "vnoise-table.fxh"

//texture
texture Tex <string uiname="Texture";>;
float4x4 tTex: TEXTUREMATRIX <string uiname="Texture Transform";>;
sampler Samp = sampler_state    //sampler for doing the texture-lookup
{
    Texture   = (Tex);          //apply a texture to the sampler
    MipFilter = LINEAR;         //sampler states
    MinFilter = LINEAR;
    MagFilter = LINEAR;
};


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
    half4  TexCoord	: TEXCOORD0;
    half3 LightVec	: TEXCOORD1;
    half3 WorldNormal	: TEXCOORD2;
    half3 WorldView	: TEXCOORD3;
    float4 diffCol	: COLOR0;
    float4 specCol	: COLOR1;
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
    float4 TexCd : TEXCOORD0)
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
    half4 Po = half4(PosO.xyz,1);
    half3 Pw = mul(Po, tW).xyz;
    OUT.LightVec = normalize(lPos - Pw);
    OUT.TexCoord = TexCd.xyxx;
    OUT.WorldView = normalize(tVI[3].xyz - Pw);
    OUT.HPosition = mul(Po, tWVP);
    return OUT;
}

// --------------------------------------------------------------------------------------------------
// PIXELSHADERS:
// --------------------------------------------------------------------------------------------------
 void velvet_shared(vs2ps IN,
			out half3 DiffuseContrib,
			out half3 SpecularContrib)
{
    half3 Ln = normalize(IN.LightVec);
    half3 Nn = normalize(IN.WorldNormal);
    half3 Vn = normalize(IN.WorldView);
    half3 Hn = normalize(Vn + Ln);
    float ldn = dot(Ln,Nn);
    float diffComp = max(0,ldn);
    float3 diffContrib = diffComp * lDiff;
    float subLamb = smoothstep(-lRollOff,1.0,ldn) - smoothstep(0.0,1.0,ldn);
    subLamb = max(0.0,subLamb);
    float3 subContrib = subLamb * lSub;
    float vdn = 1.0-dot(Vn,Nn);
    float3 vecColor = float4(vdn.xxx,1.0);
    DiffuseContrib = float4((subContrib+diffContrib).xyz,1);
    SpecularContrib = float4((vecColor*lSpec).xyz,1);
}

half4 PS(vs2ps IN) : COLOR {
    half3 diffContrib;
    half3 specContrib;
	velvet_shared(IN,diffContrib,specContrib);
    half3 map = tex2D(Samp,IN.TexCoord.xy).xyz;
    half3 result = specContrib + (map * diffContrib);
    return mul((half4(result,1)),tColor);
}


// --------------------------------------------------------------------------------------------------
// TECHNIQUES:
// --------------------------------------------------------------------------------------------------

technique vNoiseVelvety
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
        VertexShader = compile vs_3_0 VS_vNoise3D();
        PixelShader = compile ps_2_0 PS();
    }
}
