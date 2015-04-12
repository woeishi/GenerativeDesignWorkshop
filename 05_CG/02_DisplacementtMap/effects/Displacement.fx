//@author: woei
//@help: 
//@tags: demo, basic
// PARAMETERS ------------------------------------------------------------------
//transforms
float4x4 tWVP: WORLDVIEWPROJECTION;

float amount <string uiname="Displacement Amount";> = 0.3333;

//material properties
float4 cAmb : COLOR <String uiname="Color";>  = {1, 1, 1, 1};
float Alpha = 1;

//texture
texture Tex <string uiname="Texture";>;
sampler Samp = sampler_state    //sampler for doing the texture-lookup
{
    Texture   = (Tex);          //apply a texture to the sampler
    Filter = MIN_MAG_MIP_LINEAR;
};
// VERTEXSHADERS ---------------------------------------------------------------
void VS(inout float4 Pos : POSITION, inout float4 TexCd : TEXCOORD0)
{
	Pos.z -= tex2Dlod(Samp,TexCd).b*amount;
    Pos = mul(Pos, tWVP);
}
// PIXELSHADERS ----------------------------------------------------------------
float4 PS(float4 TexCd : TEXCOORD0): COLOR
{
    float4 col = tex2D(Samp,TexCd) * cAmb;
	col.a *= Alpha;
    return col;
}
// TECHNIQUES ------------------------------------------------------------------
technique TDisplaceSimple
{
    pass P0
    {
        VertexShader = compile vs_3_0 VS();
        PixelShader = compile ps_3_0 PS();
    }
}