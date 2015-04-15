
// -------------------------------------------------------------------------------------------------------------------------------------
// PARAMETERS:
// -------------------------------------------------------------------------------------------------------------------------------------

//transforms
float4x4 tW: WORLD;        //the models world matrix
float4x4 tV: VIEW;         //view matrix as set via Renderer (DX9)
float4x4 tP: PROJECTION;   //projection matrix as set via Renderer (DX9)
float4x4 tWVP: WORLDVIEWPROJECTION;

//texture
texture textrd <string uiname="feedback";>;  // a texture holding the output of the last frame
texture textparam <string uiname="rd param";>;

float4 paramin;
float4 paramax;

sampler samp = sampler_state
{
    Texture   = (textrd);
    MipFilter = NONE;
    MinFilter = point;
    MagFilter = point;

};
 sampler samp2 = sampler_state
{
    Texture   = (textparam);
    MipFilter = NONE;
    MinFilter = point;
    MagFilter = point;

};





float rx <String uiname="Pixel Diameter X";> = 1/1024;
float ry <String uiname="Pixel Diameter Y";> = 1/1024;

// -------------------------------------------------------------------------------------------------------------------------------------
// VERTEXSHADERS
// -------------------------------------------------------------------------------------------------------------------------------------

struct VS_OUTPUT
{
    float4 Pos  : POSITION;
    float2 TexC : TEXCOORD0;
};

VS_OUTPUT VS(
    float4 Pos  : POSITION,
    float2 TexC : TEXCOORD)
{
    //inititalize all fields of output struct with 0
    VS_OUTPUT Out = (VS_OUTPUT)0;

    //transform position
    Pos = mul(Pos, tWVP);
    
    Out.Pos  = Pos;
    Out.TexC = TexC;

    return Out;
}








// -------------------------------------------------------------------------------------------------------------------------------------
// PIXELSHADERS:
// -------------------------------------------------------------------------------------------------------------------------------------

float4 PS(float2 TexC: TEXCOORD0): COLOR
{

    float4 d_1 =  tex2D(samp, TexC);
    float4 parm =  tex2D(samp2, TexC);

     parm.rgba =   lerp(paramin.rgba,paramax.rgba,parm.rgba);





    
     float2 d_1n  =   tex2D(samp, float2(TexC.x-rx, TexC.y));
            d_1n +=   tex2D(samp, float2(TexC.x+rx, TexC.y));
            d_1n +=   tex2D(samp, float2(TexC.x, TexC.y-ry));
            d_1n +=   tex2D(samp, float2(TexC.x, TexC.y+ry));
           
     float2 diffusion = (d_1n / 4) * parm.xy ;

     float2 reaction  =  d_1.xx * d_1.yy* d_1n.yy  ;
            reaction.x *=-1;
            reaction.x += (1- parm.x) * d_1.x   + parm.z * (1 - d_1.x )        ;
            reaction.y += (-parm.z - parm.w   +(1-parm.y))* d_1.y;
      
      float4  result = 1;
      
      result.rg =   diffusion + (reaction);
      result.b= 0.2;
      
      return  result;

}

// -------------------------------------------------------------------------------------------------------------------------------------
// TECHNIQUES:
// -------------------------------------------------------------------------------------------------------------------------------------

technique reaction_diffusion
{
    pass P0
    {
        VertexShader = compile vs_1_1 VS();
        PixelShader  = compile ps_2_0 PS();
    }
}
//shader by : sanch
//http://www.sanchtv.com
