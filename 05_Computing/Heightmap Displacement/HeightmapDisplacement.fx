// this is a very basic template. use it to start writing your own effects.
// if you want effects with lighting start from one of the GouraudXXXX or PhongXXXX effects

// --------------------------------------------------------------------------------------------------
// PARAMETERS:
// --------------------------------------------------------------------------------------------------

//transforms
float4x4 tW: WORLD;        //the models world matrix
float4x4 tV: VIEW;         //view matrix as set via Renderer (EX9)
float4x4 tP: PROJECTION;
float4x4 tWV : WORLDVIEW;
float4x4 tWVP: WORLDVIEWPROJECTION;

//light properties
float3 lDir <string uiname="Light Direction";> = {0, -5, 2};        //light direction in world space
float4 lAmb  : COLOR <String uiname="Ambient Color";>  = {0.15, 0.15, 0.15, 1};
float4 lDiff : COLOR <String uiname="Diffuse Color";>  = {0.85, 0.85, 0.85, 1};
float4 lSpec : COLOR <String uiname="Specular Color";> = {0.35, 0.35, 0.35, 1};
float lPower <String uiname="Power"; float uimin=0.0;> = 25.0;     //shininess of specular highlight

int texSize ;
float normalStrength = 8;
float amount = 0.5 ;

//textures
texture Tex <string uiname="Texture";>;
texture DispTex <string uiname="Heightmap";>;

float4x4 tTex: TEXTUREMATRIX <string uiname="Texture Transform";>;


sampler Samp = sampler_state    //sampler for doing the texture-lookup
{
    Texture   = (Tex);          //apply a texture to the sampler
    MipFilter = LINEAR;         //sampler states
    MinFilter = LINEAR;
    MagFilter = LINEAR;
};

sampler DispSamp = sampler_state

{
	Texture = <DispTex>;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = LINEAR;
	AddressU = WRAP;
	AddressV = WRAP;
};


struct vs2ps
{
    float4 Pos  : POSITION;
    float2 TexCd : TEXCOORD0;
    float3 LightDirV : TEXCOORD1;
    float3 ViewDirV  : TEXCOORD2;
};

// --------------------------------------------------------------------------------------------------
// VERTEXSHADERS
// --------------------------------------------------------------------------------------------------
vs2ps VS(
    float4 PosO  : POSITION,
    float4 TexCd : TEXCOORD0)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;
    float4 lookup;

    lookup = mul(TexCd, tTex);
    lookup.w = 0;
    float4 tx = tex2Dlod(DispSamp,lookup);
    
    //transform position
    PosO.z =  PosO.z + tx.z * amount ;
    
    //inverse light direction in view space
    Out.LightDirV = normalize(mul(lDir, tV));
    
    Out.Pos = mul(PosO, tWVP);

    //transform texturecoordinates
    Out.TexCd = mul(TexCd, tTex);
    
    Out.ViewDirV = normalize(mul(PosO, tWV));

    return Out;
}

// --------------------------------------------------------------------------------------------------
// PIXELSHADERS:
// -------------------------------- ------------------------------------------------------------------

float4 PS(vs2ps In): COLOR
{   float texelSize =  1.0f / texSize ;
    float tl = abs(tex2D (DispSamp, In.TexCd +texelSize  * float2(-1, -1)).x);   // top left
    float  l = abs(tex2D (DispSamp, In.TexCd +texelSize  * float2(-1,  0)).x);   // left
    float bl = abs(tex2D (DispSamp, In.TexCd +texelSize  * float2(-1,  1)).x);   // bottom left
    float  t = abs(tex2D (DispSamp, In.TexCd +texelSize  * float2( 0, -1)).x);   // top
    float  b = abs(tex2D (DispSamp, In.TexCd +texelSize  * float2( 0,  1)).x);   // bottom
    float tr = abs(tex2D (DispSamp, In.TexCd +texelSize  * float2( 1, -1)).x);   // top right
    float  r = abs(tex2D (DispSamp, In.TexCd +texelSize * float2( 1,  0)).x);   // right
    float br = abs(tex2D (DispSamp, In.TexCd +texelSize  * float2( 1,  1)).x);   // bottom right

    // Compute dx using Sobel:

    //           -1 0 1

    //           -2 0 2

    //           -1 0 1

    float dX = tr + 2*r + br -tl - 2*l - bl;

    // Compute dy using Sobel:

    //           -1 -2 -1

    //            0  0  0

    //            1  2  1

    float dY = bl + 2*b + br -tl - 2*t - tr;

    // Build the normalized normal

    float4 N = float4(normalize(float3(dX, 1.0f / normalStrength, dY)), 1.0f);

    //convert (-1.0 , 1.0) to (0.0 , 1.0), if needed

    float3 NormV;

    //normal in view space
    NormV = mul(N, tWV);
    NormV = normalize(NormV);

    //In.TexCd = In.TexCd / In.TexCd.w; // for perpective texture projections (e.g. shadow maps) ps_2_0

    lAmb.a = 1;
    //halfvector
    float3 H = normalize(In.ViewDirV + In.LightDirV);

    //compute blinn lighting
    float3 shades = lit(dot(NormV, In.LightDirV), dot(NormV, H), lPower);

    float4 diff = lDiff * shades.y;
    diff.a = 1;

    //reflection vector (view space)
    float3 R = normalize(2 * dot(NormV, In.LightDirV) * NormV - In.LightDirV);
    //normalized view direction (view space)
    float3 V = normalize(In.ViewDirV);

    //calculate specular light
    float4 spec = pow(max(dot(R, V),0), lPower*.2) * lSpec;

    float4 col = tex2D(Samp, In.TexCd);
    col.rgb *= (lAmb + diff) + spec;
    return col;

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
