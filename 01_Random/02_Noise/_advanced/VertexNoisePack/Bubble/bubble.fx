/*
3D Perlin Noise on the vertex shader
Bubble version//////////////////////

based originally on
vBomb.fx HLSL vertex noise shader,
Glass.fx
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

// include the noise-table
#include "vnoise-table.fxh"

float reflectStrength <string UIName =  "Reflection";
float UIMin = 0.0;
float UIMax = 2.0;
float UIStep = 0.01;>
 = 1.0;

float refractStrength <string UIName =  "Refraction";
float UIMin = 0.0;
float UIMax = 2.0;
float UIStep = 0.01;>
 = 1.0;

half3 etas <string UIName = "Refraction indices";> = { 0.80, 0.82, 0.84 };

float timer : TIME;

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

float Speed <
float UIMin = 0.01;
float UIMax = 1.0;
float UIStep = 0.001;>
= 0.3;

float radius <string uiname="Sphere Radius";> = 1;

//float4 dd[5] = {0,2,3,1, 2,2,2,2, 3,3,3,3, 4,4,4,4, 5,5,5,5 };


///TEXTURES//////////////////////////////////////////////
texture Tex <string uiname="CubeTexture";>;
samplerCUBE Samp = sampler_state
{Texture   = (Tex);

MinFilter = Linear;
MagFilter = Linear;
MipFilter = Linear;
};

texture Tex2 <string uiname="FresnelTexture";>;
sampler2D Samp2 = sampler_state
{Texture   = (Tex2);
MinFilter = Linear;
MagFilter = Linear;
MipFilter = None;
//float2 Dimensions < { 256.0f, 1.0f};
};

struct vs2ps
{
    float4 HPosition	: POSITION;
    float4 TexCoord	: TEXCOORD0;
    float3 WorldNormal	: TEXCOORD1;
    float3 WorldView	: TEXCOORD2;
};

#define TWOPI 6.28318531
#define PI 3.14159265

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

    // we will use our own "normal" vector because the default geom is a sphere
    float4 Nn = float4(normalize(PosO).xyz,0);

    return  PosO - (Nn * (ni-0.5) * Disp);
}

// --------------------------------------------------------------------------------------------------
// VERTEXSHADERS
// --------------------------------------------------------------------------------------------------

vs2ps VS_Bubble3D(
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
    //inverse light direction in view space
    OUT.WorldNormal = mul(NormO, (float3x3) tWIT);
    float3 Pw = mul(PosO, tW).xyz;
    OUT.TexCoord = TexCd;
    OUT.WorldView = tVI[3].xyz - Pw;
    OUT.HPosition = mul(PosO, tWVP);
    return OUT;
}


// --------------------------------------------------------------------------------------------------
// PIXELSHADERS:
// --------------------------------------------------------------------------------------------------

// modified refraction function that returns boolean for total internal reflection
float3
refract2( float3 I, float3 N, float eta, out bool fail )
{
	float IdotN = dot(I, N);
	float k = 1 - eta*eta*(1 - IdotN*IdotN);
//	return k < 0 ? (0,0,0) : eta*I - (eta*IdotN + sqrt(k))*N;
	fail = k < 0;
	return eta*I - (eta*IdotN + sqrt(k))*N;
}

// approximate Fresnel function
float fresnel(float NdotV, float bias, float power)
{
   return bias + (1.0-bias)*pow(1.0 - max(NdotV, 0), power);
}

// function to generate a texture encoding the Fresnel function
float4 generateFresnelTex(float NdotV : POSITION) : COLOR
{
	return fresnel(NdotV, 0.2, 4.0);
}

float4 PS(vs2ps IN) : COLOR
{
    half3  N = normalize(IN.WorldNormal);
    float3 V = normalize(IN.WorldView);

 	// reflection
    half3 R = reflect(-V, N);
    half4 reflColor = texCUBE(Samp, R);

//	half fresnel = fresnel(dot(N, V), 0.2, 4.0);
	half fresnel = tex2D(Samp2, dot(N, V));

	// wavelength colors
	const half4 colors[3] = {
    	{ 1, 0, 0, 0 },
    	{ 0, 1, 0, 0 },
    	{ 0, 0, 1, 0 },
	};

	// transmission
 	half4 transColor = 0;
  	bool fail = false;
    for(int i=0; i<3; i++) {
    	half3 T = refract2(-V, N, etas[i], fail);
    	transColor += texCUBE(Samp, T) * colors[i];
	}

    return lerp(transColor*refractStrength, reflColor*reflectStrength, fresnel);
}


// --------------------------------------------------------------------------------------------------
// TECHNIQUES:
// --------------------------------------------------------------------------------------------------

technique Bubble3Dnoise
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
        VertexShader = compile vs_3_0 VS_Bubble3D();
        PixelShader = compile ps_2_0 PS();
    }
}
