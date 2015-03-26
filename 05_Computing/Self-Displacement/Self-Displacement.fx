// --------------------------------------------------------------------------------------------------
// PARAMETERS:
// --------------------------------------------------------------------------------------------------

float4x4 tWVP: WORLDVIEWPROJECTION;

texture ImageTexture<string uiname="Texture";>;
sampler2D Samp = sampler_state
{
    Texture = <ImageTexture>;
    MipFilter = LINEAR;         //sampler states
    MinFilter = LINEAR;
    MagFilter = LINEAR;
};

float Displacement <
	string UIWidget = "slider";
	float UIMin = 0.0;
	float UIMax = 1.0;
	float UIStep = 0.001;
> = 0.01f;

float4x4 tColor <string uiname="Color Transform";>;

struct vs2ps
{
    float4 Pos  : POSITION;
    float4 TexCd : TEXCOORD0;
};

// --------------------------------------------------------------------------------------------------
// VERTEXSHADERS
// --------------------------------------------------------------------------------------------------

vs2ps VS(
    float4 Pos  : POSITION,
    float4 TexCd : TEXCOORD)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;

    //transform position
    Pos = mul(Pos, tWVP);
    //transform texturecoordinates
    Out.TexCd =TexCd;
    Out.Pos  = Pos;
    return Out;
}

// --------------------------------------------------------------------------------------------------
// PIXELSHADERS:
// --------------------------------------------------------------------------------------------------

float4 dispPS(vs2ps In) : COLOR
{   
    float2 disp = Displacement*(((float4)tex2D(Samp, In.TexCd)));
    float4 texCol = tex2D(Samp,In.TexCd + disp);
    return mul(texCol,tColor);
} 

// --------------------------------------------------------------------------------------------------
// TECHNIQUES:
// --------------------------------------------------------------------------------------------------

technique deformTexture {
	pass TexturePass  {
		VertexShader = compile vs_2_0 VS();
	
		PixelShader  = compile ps_2_a dispPS();
	}
}
