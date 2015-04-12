//@author: m4d
//@help: interleaved SSAO - ssao pass -- renders the ssao from the previous normal and position passes
//@tags: ssao, interleaved
//@credits: original shader by ArKano22 of gamedev.net -- see thread http://www.gamedev.net/community/forums/topic.asp?topic_id=556187&PageSize=25&WhichPage=1 -- additional HLSL by martinsh of gamedev.net (posted in same thread)

// --------------------------------------------------------------------------------------------------
// PARAMETERS:
// --------------------------------------------------------------------------------------------------

//transforms
float4x4 tW: WORLD;        //the models world matrix
float4x4 tV: VIEW;         //view matrix as set via Renderer (EX9)
float4x4 tP: PROJECTION;
float4x4 tWVP: WORLDVIEWPROJECTION;

//textures
texture TexNorm <string uiname="Texture Normal";>;
sampler SampNorm = sampler_state   //sampler for doing the texture-lookup
{
    Texture   = (TexNorm);          //apply a texture to the sampler
    MipFilter = POINT;              //sampler states
    MinFilter = POINT;
    MagFilter = POINT;
};

texture TexPos <string uiname="Texture Position";>;
sampler SampPos = sampler_state   //sampler for doing the texture-lookup
{
    Texture   = (TexPos);            //apply a texture to the sampler
    MipFilter = POINT;                //sampler states
    MinFilter = POINT;
    MagFilter = POINT;
};

//parameters
float SampleRadius <string uiname="Sample Radius";> = 0.1;
float Intensity <string uiname="Intensity";> = 0.46;
float Scale <string uiname="Scale";> = 0.6;
float Bias <string uiname="Bias";> = 0.04;
float SelfOcclusion <string uiname="Self Occlusion";> = 0.07;
float2 ScreenSize <string uiname="Screen Size";> = 1;
float2 InvScreenSize <string uiname="Inverse Screen Size";> = 1;


//the data structure: "vertexshader to pixelshader"
//used as output data with the VS function
//and as input data with the PS function
struct vs2ps
{
    float4 position  : POSITION;
    float2 uv : TEXCOORD0;
};

// --------------------------------------------------------------------------------------------------
// VERTEXSHADERS
// --------------------------------------------------------------------------------------------------
vs2ps VS(
    float4 position  : POSITION
    )
{
    //declare output struct
    vs2ps Out;

    //transform position
    Out.position = float4(sign(position.xy), 0.0f, 1.0f);

    //transform texturecoordinates
    Out.uv = position.xy * float2(1,-1) + 0.5f;

    Out.position.x -= InvScreenSize.x;
    Out.position.y += InvScreenSize.y;

    return Out;
}

// --------------------------------------------------------------------------------------------------
// PIXELSHADERS:
// --------------------------------------------------------------------------------------------------

float3 getPosition(in float2 uv)
{
  return tex2Dlod(SampPos,float4(uv,0,0)).xyz;
}
float3 getNormal(in float2 uv)
{
  return normalize(tex2D(SampNorm, uv).xyz * 2.0f - 1.0f);
}

float getRandom(in float2 uv)
{
  return ((frac(uv.x * (ScreenSize.x/2.0))*0.25)+(frac(uv.y*(ScreenSize.y/2.0))*0.5));
}

float doAmbientOcclusion(in float2 tcoord,in float2 uv, in float3 p, in float3 cnorm)
{
  float3 diff = getPosition(tcoord + uv) - p;
  const float3 v = normalize(diff);
  const float  d = length(diff)*Scale;
  return max(0.0-SelfOcclusion,dot(cnorm,v)-Bias)*(1.0/(1.0+d*d))*Intensity;

}

float4 SSAO(vs2ps In): COLOR
{
  const float3 vec[14] = {float3(1,1,-1),float3(1,-1,-1),
                         float3(1,1,1),float3(1,-1,1),
                         float3(-1,1,-1),float3(-1,-1,-1),
                         float3(-1,1,1),float3(-1,-1,1),

                         float3(1,0,0),float3(-1,0,0),
                         float3(0,1,0),float3(0,-1,0),
                         float3(0,0,1),float3(0,0,-1),
                       };

  float4 o = (0.0,0.0,0.0,1.0);
  float3 p = getPosition(In.uv);
  float3 n = getNormal(In.uv);
  float rand = getRandom(In.uv);

  float ao = 0.0;
  float rad = SampleRadius/p.z;
  //**SSAO Calculation**//

  for (int j = 0; j < 14; ++j)
  {
    float4 coord = mul(vec[j]*rad*rand,tWVP);
    coord.y = ScreenSize.y-coord.y;
    ao += doAmbientOcclusion(In.uv,coord*InvScreenSize*1000.0, p, n );
  }
  ao/=8;
  ao+=SelfOcclusion;

  o.rgb = ao;
  //**END**//
  return o;
}

// --------------------------------------------------------------------------------------------------
// TECHNIQUES:
// --------------------------------------------------------------------------------------------------

technique TSSAO
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
        VertexShader = compile vs_3_0 VS();
        PixelShader  = compile ps_3_0 SSAO();
    }
}
