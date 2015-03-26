//P-Q_Torus
//Shader by Digital Slaves

// --------------------------------------------------------------------------------------------------
// PARAMETERS:
// --------------------------------------------------------------------------------------------------

//transforms
float4x4 tW: WORLD;
float4x4 tV: VIEW;
float4x4 tP: PROJECTION;
float4x4 tWVP: WORLDVIEWPROJECTION;
float4x4 tWV: WORLDVIEW;

#define TwoPi 6.28318531
#define Pi 3.14159265

float gridOffsetX;
float gridOffsetY;
float gridScaleX = 1;
float gridScaleY = 1;

//Tweak
int P;
int Q;
int E;

float4 cAmb : COLOR <String uiname="Color";>  = {1, 1, 1, 1};

//Texture
texture Tex <string uiname="Texture";>;
sampler Samp = sampler_state    //sampler for doing the texture-lookup
{
    Texture   = (Tex);          //apply a texture to the sampler
    MipFilter = LINEAR;         //sampler states
    MinFilter = LINEAR;
    MagFilter = LINEAR;
};


//P_Q Shape Function

float3 P_Q_Torus(float u, float v)
{
    float r = 0.5 * (2 + (sin (E * u * v))) ;
    
    //Try

    //Add : int F;
    //float r = 0.5 * (F + (sin (E * u * v))) ;
    
    float x = r * cos (P * u * v);
    float y = r * cos (Q * u * v);
    float z = (r * sin (P * u * v));

    return float3(x, y, z);
}


struct vs2ps
{
    float4 Pos : POSITION;
    float4 TexCd : TEXCOORD0;
    float2 UV : TEXCOORD2;

};

// --------------------------------------------------------------------------------------------------
// VERTEXSHADERS
// --------------------------------------------------------------------------------------------------

vs2ps VS(

    float4 Pos : POSITION,
    float4 TexCd : TEXCOORD0)

{
  vs2ps Out = (vs2ps)0;
  
    float u, v;
    
    gridScaleX *= Pi;
    gridScaleY *= TwoPi;
    
    u = (Pos.x + gridOffsetX) * gridScaleX;
    v = (Pos.y + gridOffsetY) * gridScaleY;
    
    Pos.xyz = P_Q_Torus(u, v);
    Pos.w = 1;

    Out.Pos = mul(Pos, tWVP);
    Out.UV = float2(u, v);
    Out.TexCd = TexCd;

    return Out;
}

// --------------------------------------------------------------------------------------------------
// PIXELSHADERS:
// --------------------------------------------------------------------------------------------------

float4 PS(vs2ps In): COLOR
{

    float4 col = tex2D(Samp, In.TexCd) * cAmb;
    
    return col;

}

// --------------------------------------------------------------------------------------------------
// TECHNIQUES:
// --------------------------------------------------------------------------------------------------

technique TP_Q_Torus
{
    pass P0
    {

        VertexShader = compile vs_1_0 VS();
        PixelShader = compile ps_1_0 PS();
    }
}
