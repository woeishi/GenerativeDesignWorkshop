//@author: m4d
//@help: interleaved SSAO - combinepass -- blurs the previous ssao pass and combines it with diffuse fill pass and additional cubemap lighting
//@tags: ssao, interleaved, combine, cubemap, lighting
//@credits: original shader by ArKano22 of gamedev.net -- see thread http://www.gamedev.net/community/forums/topic.asp?topic_id=556187&PageSize=25&WhichPage=1

// --------------------------------------------------------------------------------------------------
// PARAMETERS:
// --------------------------------------------------------------------------------------------------

//transforms
float4x4 tW: WORLD;        //the models world matrix
float4x4 tV: VIEW;         //view matrix as set via Renderer (EX9)
float4x4 tP: PROJECTION;
float4x4 tWVP: WORLDVIEWPROJECTION;

//texture
texture TexSSAO <string uiname="Texture SSAO";>;
sampler SampSSAO = sampler_state    //sampler for doing the texture-lookup
{
    Texture   = (TexSSAO);          //apply a texture to the sampler
    MipFilter = none;         //sampler states
    MinFilter = none;
    MagFilter = none;
};

texture TexNorm <string uiname="Texture Normal";>;
sampler SampNorm = sampler_state   //sampler for doing the texture-lookup
{
    Texture   = (TexNorm);          //apply a texture to the sampler
    MipFilter = none;              //sampler states
    MinFilter = none;
    MagFilter = none;
};

texture TexCube <string uiname="Texture Cube";>;
sampler SampCube = sampler_state   //sampler for doing the texture-lookup
{
    Texture   = (TexCube);          //apply a texture to the sampler
    MipFilter = linear;              //sampler states
    MinFilter = linear;
    MagFilter = linear;
};

texture TexDiffuse <string uiname="Texture Diffuse";>;
sampler SampDiffuse = sampler_state    //sampler for doing the texture-lookup
{
    Texture   = (TexDiffuse);          //apply a texture to the sampler
    MipFilter = none;         //sampler states
    MinFilter = none;
    MagFilter = none;
};
float2 InvScreenSize <string uiname="Inverse Screen Size";> = 1;
float Blur <string uiname="Blur";> = 1;
float UseAO <string uiname="Enable AO";> = 1;
float UseCube <string uiname="Enable Cube Map";> = 1;


//the data structure: "vertexshader to pixelshader"
//used as output data with the VS function
//and as input data with the PS function
struct vs2ps
{
    float4 position  : POSITION0;
    float2 uv : TEXCOORD0;
};

// --------------------------------------------------------------------------------------------------
// VERTEXSHADERS
// --------------------------------------------------------------------------------------------------
vs2ps VS(
    float4 position  : POSITION,
    float4 uv : TEXCOORD0)
{
    //declare output struct
    vs2ps Out;

    //transform position
    Out.position = float4(mul(position, tWVP));
    
    //transform texturecoordinates
    Out.uv = uv;

    return Out;
}

// --------------------------------------------------------------------------------------------------
// PIXELSHADERS:
// --------------------------------------------------------------------------------------------------
float3 getNormal(in float2 uv)
{
  return normalize(tex2D(SampNorm,uv).xyz * 2.0f - 1.0f);
}

float4 PS(vs2ps In): COLOR
{
  float4 o = (0.0,0.0,0.0,1.0);
  o = tex2D(SampDiffuse, In.uv);
  const float2 vec[3] = {
   float2(1,1),
   float2(1,0),
   float2(0,1),
   };

  float3 n = getNormal(In.uv);

  float3 ao = tex2D(SampSSAO,In.uv).xyz;
  int samples = 1;
  for (int k=0;k<3;k++){
     float2 tcoord = In.uv+float2(vec[k].x*InvScreenSize.x*Blur,vec[k].y*InvScreenSize.y*Blur);
     ao+=tex2D(SampSSAO,tcoord).xyz;
     samples++;
  }
  ao/=samples;

  float3 ccc = texCUBE(SampCube, n);
  float3 ambient = ccc+0.2;
  if (UseAO)
    ambient -= (saturate(ao));

  if (UseCube)
    o.rgb *= ambient;
  else
    o.rgb = (1.0-saturate(ao));
  return o;
}

// --------------------------------------------------------------------------------------------------
// TECHNIQUES:
// --------------------------------------------------------------------------------------------------

technique TSimpleShader
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
        Sampler[0] = (SampDiffuse);
        TexCoordIndex[0] = 0;
        TextureTransformFlags[0] = COUNT2;
        //Wrap0 = U;  // useful when mesh is round like a sphere
        
        Lighting       = FALSE;

        //shaders
        VertexShader = NULL;
        PixelShader  = NULL;
    }
}
