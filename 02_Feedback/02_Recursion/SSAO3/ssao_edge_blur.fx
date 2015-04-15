//@author: defetto/m4d
//@help: interleaved SSAO - edgeblur pass -- applies edge filtering to composited image to compensate for missing AA (hello DX10 :))
//@tags: ssao, interleaved, edgeblur, deferred
//@credits: original shader by Rusty Koonce of NCsoft Corporation -- see original source http://http.developer.nvidia.com/GPUGems3/gpugems3_ch19.html

// --------------------------------------------------------------------------------------------------
// PARAMETERS:
// --------------------------------------------------------------------------------------------------

//transforms
float4x4 tW: WORLD;        //the models world matrix
float4x4 tV: VIEW;         //view matrix as set via Renderer (EX9)
float4x4 tP: PROJECTION;
float4x4 tWVP: WORLDVIEWPROJECTION;

float BlurMult = 1;
float EdgeValue = 0.4;
bool debug;

//texture
texture TexDiffuse <string uiname="Texture Diffuse";>;
sampler SampDiffuse = sampler_state    //sampler for doing the texture-lookup
{
    Texture   = (TexDiffuse);          //apply a texture to the sampler
    MipFilter = LINEAR;         //sampler states
    MinFilter = LINEAR;
    MagFilter = LINEAR;
};

//texture normal
texture TexNormal <string uiname="Texture Normal";>;
sampler SampNorm = sampler_state    //sampler for doing the texture-lookup
{
    Texture   = (TexNormal);          //apply a texture to the sampler
    MipFilter = NONE;            //sampler states
    MinFilter = NONE;
    MagFilter = NONE;
};

//texture position
texture TexPos <string uiname="Texture Position";>;
sampler s_position = sampler_state    //sampler for doing the texture-lookup
{
    Texture   = (TexPos);          //apply a texture to the sampler
    MipFilter = NONE;            //sampler states
    MinFilter = NONE;
    MagFilter = NONE;
};


   ////////////////////////////
   // Neighbor offset table
   ////////////////////////////
const static float2 offsets[9] = {
   float2( 0.0,  0.0), //Center       0
   float2(-1.0, -1.0), //Top Left     1
   float2( 0.0, -1.0), //Top          2
   float2( 1.0, -1.0), //Top Right    3
   float2( 1.0,  0.0), //Right        4
   float2( 1.0,  1.0), //Bottom Right 5
   float2( 0.0,  1.0), //Bottom       6
   float2(-1.0,  1.0), //Bottom Left  7
   float2(-1.0,  0.0)  //Left         8
};

const static float2 offsets2[4] = {
   float2( 0.5,  0.5), //     0
   float2( 0.5, -0.5), //     1
   float2(-0.5,  0.5), //     2
   float2(-0.5, -0.5), //     3
};

float2 PixelSize <string uiname="1/Resolution XY";>;

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
    Out.TexCd = TexCd;

    return Out;
}

// --------------------------------------------------------------------------------------------------
// PIXELSHADERS:
// --------------------------------------------------------------------------------------------------

float DL_GetEdgeWeight(in float2 screenPos)
{
    float Depth[9];
    float3 Normal[9];
    //Retrieve normal and depth data for all neighbors.
    for (int i=0; i<9; ++i)
    {
        float2 uv = screenPos + offsets[i] * PixelSize;
        Depth[i] = tex2D(s_position, uv);
        Normal[i] = tex2D(SampNorm, uv);
    }
    //Compute Deltas in Depth.
    float4 Deltas1;
    float4 Deltas2;
    Deltas1.x = Depth[1];
    Deltas1.y = Depth[2];
    Deltas1.z = Depth[3];
    Deltas1.w = Depth[4];
    Deltas2.x = Depth[5];
    Deltas2.y = Depth[6];
    Deltas2.z = Depth[7];
    Deltas2.w = Depth[8];
    //Compute absolute gradients from center.
    Deltas1 = abs(Deltas1 - Depth[0]);
    Deltas2 = abs(Depth[0] - Deltas2);
    //Find min and max gradient, ensuring min != 0
    float4 maxDeltas = max(Deltas1, Deltas2);
    float4 minDeltas = max(min(Deltas1, Deltas2), 0.00001);
    // Compare change in gradients, flagging ones that change
    // significantly.
    // How severe the change must be to get flagged is a function of the
    // minimum gradient. It is not resolution dependent. The constant
    // number here would change based on how the depth values are stored
    // and how sensitive the edge detection should be.
    float4 depthResults = step(minDeltas * 25.0, maxDeltas);
    //Compute change in the cosine of the angle between normals.
    Deltas1.x = dot(Normal[1], Normal[0]);
    Deltas1.y = dot(Normal[2], Normal[0]);
    Deltas1.z = dot(Normal[3], Normal[0]);
    Deltas1.w = dot(Normal[4], Normal[0]);
    Deltas2.x = dot(Normal[5], Normal[0]);
    Deltas2.y = dot(Normal[6], Normal[0]);
    Deltas2.z = dot(Normal[7], Normal[0]);
    Deltas2.w = dot(Normal[8], Normal[0]);
    Deltas1 = abs(Deltas1 - Deltas2);
    // Compare change in the cosine of the angles, flagging changes
    // above some constant threshold. The cosine of the angle is not a
    // linear function of the angle, so to have the flagging be
    // independent of the angles involved, an arccos function would be
    // required.
    float4 normalResults = step(EdgeValue, Deltas1);
    normalResults = max(normalResults, depthResults);
    return (normalResults.x + normalResults.y +
           normalResults.z + normalResults.w) * 0.25;
}

float4 PS(vs2ps In): COLOR
{

    float4 s0 = tex2D(SampDiffuse, In.TexCd + (offsets2[0]*PixelSize));
    float4 s1 = tex2D(SampDiffuse, In.TexCd + (offsets2[1]*PixelSize));
    float4 s2 = tex2D(SampDiffuse, In.TexCd + (offsets2[2]*PixelSize));
    float4 s3 = tex2D(SampDiffuse, In.TexCd + (offsets2[3]*PixelSize));
    float4 s4 = tex2D(SampDiffuse, In.TexCd);
    float4 w =  DL_GetEdgeWeight(In.TexCd)*BlurMult;
    float4 col = ((s0 + s1 + s2 + s3) *0.25);
    if (debug) return w;
    else
    return lerp(s4, col, w);
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
