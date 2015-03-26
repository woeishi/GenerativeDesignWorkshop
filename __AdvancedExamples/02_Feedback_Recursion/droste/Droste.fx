//@author: tonfilm
//@help: an infinite zoom into an image.
//@tags: escher
//@credits: Dag Ågren

// --------------------------------------------------------------------------------------------------
// PARAMETERS:
// --------------------------------------------------------------------------------------------------

//transforms
float4x4 tW: WORLD;        //the models world matrix
float4x4 tV: VIEW;         //view matrix as set via Renderer (EX9)
float4x4 tP: PROJECTION;
float4x4 tWVP: WORLDVIEWPROJECTION;

//texture
texture Tex <string uiname="Texture";>;
sampler Samp = sampler_state    //sampler for doing the texture-lookup
{
    Texture   = (Tex);          //apply a texture to the sampler
    MipFilter = LINEAR;         //sampler states
    MinFilter = LINEAR;
    MagFilter = LINEAR;
};

//texture transformation marked with semantic TEXTUREMATRIX to achieve symmetric transformations
float4x4 tTex: TEXTUREMATRIX <string uiname="Texture Transform";>;

//the data structure: "vertexshader to pixelshader"
//used as output data with the VS function
//and as input data with the PS function
struct vs2ps
{
    float4 Pos  : POSITION;
    float2 TexCd : TEXCOORD0;
};

// --------------------------------------------------------------------------------------------------
// VERTEXSHADERS
// --------------------------------------------------------------------------------------------------
vs2ps VS(
    float4 PosO  : POSITION,
    float4 TexCd : TEXCOORD0)
{
    //declare output struct
    vs2ps Out;

    //transform position
    Out.Pos = mul(PosO, tWVP);
    
    //transform texturecoordinates
    Out.TexCd = mul(TexCd, tTex);

    return Out;
}

// --------------------------------------------------------------------------------------------------
// PIXELSHADERS:
// --------------------------------------------------------------------------------------------------

#include "bicubic.fxh"

#define pi 3.1415926535

float2 center;
float2 t;
int2 p=1;
float logbase = 0.2;

float4 PS(vs2ps In): COLOR
{

	float lo = 1/logbase;
	float2 tc = In.TexCd - center;

	float u_corner=2.0*pi*p.y;
	float v_corner=lo*p.x;
	float diag=sqrt(u_corner*u_corner+v_corner*v_corner);
	
	float sin_a=v_corner/diag;
	float cos_a=u_corner/diag;
	float scale=diag/2.0/pi;

	float a=atan2(-tc.y,tc.x);
	float r=sqrt(tc.x*tc.x+tc.y*tc.y);

	float fu=a;
	float fv=log(r);

	float tmp=(fu*cos_a+fv*sin_a)*scale;
	fv=(-fu*sin_a+fv*cos_a)*scale;
	fu=tmp;

	fu/=2.0*pi;
	fv/=lo;
	
    float4 col = tex2Dbicubic(Samp,float2(fu,fv) - t);
    return col;
}

// --------------------------------------------------------------------------------------------------
// TECHNIQUES:
// --------------------------------------------------------------------------------------------------

technique TDroste
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
        VertexShader = compile vs_3_0 VS();
        PixelShader  = compile ps_3_0 PS();
    }
}

technique TFixedFunction
{
    pass P0
    {
        //transforms
        WorldTransform[0]   = (tW);
        ViewTransform       = (tV);
        ProjectionTransform = (tP);

        //texturing
        Sampler[0] = (Samp);
        TextureTransform[0] = (tTex);
        TexCoordIndex[0] = 0;
        TextureTransformFlags[0] = COUNT2;
        //Wrap0 = U;  // useful when mesh is round like a sphere
        
        Lighting       = FALSE;

        //shaders
        VertexShader = NULL;
        PixelShader  = NULL;
    }
}
