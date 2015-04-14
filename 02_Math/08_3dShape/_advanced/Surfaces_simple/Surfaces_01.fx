
/* Surfaces formulas from...
http://local.wasp.uwa.edu.au/~pbourke/surfaces_curves/
http://mathworld.wolfram.com/topics/Surfaces.html

2008 by desaxismundi
http://vvvv.org/tiki-index.php?page=UserPageDesaxismundi
http://vvvv.org/tiki-index.php?page=desaxismundi_Shaders */

// --------------------------------------------------------------------------------------------------
// PARAMETERS:
// --------------------------------------------------------------------------------------------------

//transforms
float4x4 tWVP: WORLDVIEWPROJECTION;
float4x4 TT ;

float a = 1;
float b = 1;
float c = 1;
float d = 1;

//light properties
float4 col : COLOR <String uiname="Color";>  = {1, 1, 1, 1};
float3 lpos <String uiname="Light Position";> ;

//texture
texture Tex <string uiname="Texture";>;
sampler Samp = sampler_state    //sampler for doing the texture-lookup
{
    Texture   = (Tex);          //apply a texture to the sampler
    MipFilter = LINEAR;         //sampler states
    MinFilter = LINEAR;
    MagFilter = LINEAR;
};

float4x4 tTex: TEXTUREMATRIX <string uiname="Texture Transform";>;
float4x4 tColor <string uiname="Color Transform";>;

struct vs2ps
{
       float4 PosWVP    : POSITION;
       float4 TexCd     : TEXCOORD0;
       float4 colpos    : TEXCOORD1;
};

#define TWOPI 6.28318531
#define PI    3.14159265

// --------------------------------------------------------------------------------------------------
// VERTEXSHADERS
// --------------------------------------------------------------------------------------------------

vs2ps VS_Paraboloid(
    float4 PosO  : POSITION,
    float4 TexCd : TEXCOORD0)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;
    PosO =  mul(PosO, TT);

   float u = PosO.x  * 2;
   float v = PosO.y  * 2*TWOPI;

    PosO.x = a * pow((u/b),0.5) * cos(v);
    PosO.y = a * pow((u/b),0.5) * sin(v);
    PosO.z = (u);

    Out.colpos = length(PosO+lpos);

    //position (projected)
    Out.PosWVP  = mul(PosO, tWVP);
    Out.TexCd  = mul(TexCd, tTex);

    return Out;
}

////////////////////////////////////////////////////////////////////////////////

vs2ps VS_Hyperboloid(
    float4 PosO  : POSITION,
    float4 TexCd : TEXCOORD0)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;
    PosO =  mul(PosO, TT);

    float u = PosO.x * 2*TWOPI;
    float v = PosO.y  * 2*TWOPI;

     PosO.x = a * pow((1 + pow(u,2)),0.5) * cos(v);
     PosO.y = b * pow((1 + pow(u,2)),0.5) * sin(v);
     PosO.z = c * (u);

    Out.colpos = length(PosO+lpos);

    //position (projected)
    Out.PosWVP  = mul(PosO, tWVP);
    Out.TexCd  = mul(TexCd, tTex);

    return Out;
}

////////////////////////////////////////////////////////////////////////////////

vs2ps VS_LimpetTorus(
    float4 PosO  : POSITION,
    float4 TexCd : TEXCOORD0)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;
    PosO =  mul(PosO, TT);

   float u = PosO.x * 2*PI;
   float v = PosO.y * 2*PI;

     PosO.x = cos(u) / (sqrt(2) + sin(v));
     PosO.y = sin(u) / (sqrt(2) + sin(v));
     PosO.z = 1 / (sqrt(2) + cos(v));

    Out.colpos = length(PosO+lpos);

    //position (projected)
    Out.PosWVP  = mul(PosO, tWVP);
    Out.TexCd  = mul(TexCd, tTex);

    return Out;
}

/////////////////////////////////////////////////////////////////////////////////////////

vs2ps VS_Handkerchief(
    float4 PosO  : POSITION,
    float4 TexCd : TEXCOORD0)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;
    PosO =  mul(PosO, TT);

    float u = PosO.x * 2;
    float v = PosO.y * 2;

     PosO.x = u;
     PosO.y = v;
     PosO.z = pow(u,3) / 3 + u * pow(v,2) + a * (pow(u,2) - pow(v,2));

    Out.colpos = length(PosO+lpos);
    
    //position (projected)
    Out.PosWVP  = mul(PosO, tWVP);
    Out.TexCd  = mul(TexCd, tTex);

    return Out;
}

////////////////////////////////////////////////////////////////////////////////

vs2ps VS_Apple(
    float4 PosO  : POSITION,
    float4 TexCd : TEXCOORD0)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;
    PosO =  mul(PosO, TT);

    float u = PosO.x * 2*TWOPI;
    float v = PosO.y * 2*PI;

      PosO.x = cos(u) * (4 + 3.8 * cos(v));
      PosO.y = sin(u) * (4 + 3.8 * cos(v));
      PosO.z = (cos(v) + sin(v) - 1) * (1 + sin(v)) * log(1 - PI*v / 10) + 7.5 * sin(v);

    Out.colpos = length(PosO+lpos);

    //position (projected)
    Out.PosWVP  = mul(PosO, tWVP);
    Out.TexCd  = mul(TexCd, tTex);

    return Out;
}

////////////////////////////////////////////////////////////////////////////////

vs2ps VS_Springs(
    float4 PosO  : POSITION,
    float4 TexCd : TEXCOORD0)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;
    PosO =  mul(PosO, TT);

    float u = PosO.x  * 2*TWOPI;
    float v = PosO.y  * 2*0.898;

     PosO.x = (1-a * cos(v)) * cos(u);
     PosO.y = (1-a * cos(v)) * sin(u);
     PosO.z = b * (sin(v) + c * u /PI);

    Out.colpos = length(PosO+lpos);

    //position (projected)
    Out.PosWVP  = mul(PosO, tWVP);
    Out.TexCd  = mul(TexCd, tTex);

    return Out;
}

////////////////////////////////////////////////////////////////////////////////

vs2ps VS_Figure8Torus(
    float4 PosO  : POSITION,
    float4 TexCd : TEXCOORD0)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;
    PosO =  mul(PosO, TT);

    float u = PosO.x * (-PI*2);
    float v = PosO.y * 2*PI;

    PosO.x = cos(u) * (c + sin(v) * cos(u) - sin(2*v) * sin(u) / 2);
    PosO.y = sin(u) * (c + sin(v) * cos(u) - sin(2*v) * sin(u) / 2) ;
    PosO.z = sin(u) * sin(v) + cos(u) * sin(2*v) / 2;

    Out.colpos = length(PosO+lpos);

    //position (projected)
    Out.PosWVP  = mul(PosO, tWVP);
    Out.TexCd  = mul(TexCd, tTex);

    return Out;
}

////////////////////////////////////////////////////////////////////////////////

vs2ps VS_EllipticTorus(
    float4 PosO  : POSITION,
    float4 TexCd : TEXCOORD0)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;
    PosO =  mul(PosO, TT);

    float u = PosO.x * 2*PI;
    float v = PosO.y * 2*PI;

    PosO.x = (c + cos(v)) * cos(u);
    PosO.y = (c + cos(v)) * sin(u) ;
    PosO.z = sin(v) + cos(v);

    Out.colpos = length(PosO+lpos);

    //position (projected)
    Out.PosWVP  = mul(PosO, tWVP);
    Out.TexCd  = mul(TexCd, tTex);

    return Out;
}

////////////////////////////////////////////////////////////////////////////////

vs2ps VS_Catenoid(
    float4 PosO  : POSITION,
    float4 TexCd : TEXCOORD0)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;
    PosO =  mul(PosO, TT);

    float u = PosO.x * 2*TWOPI;
    float v = PosO.y * 2;

    PosO.x = c * cosh(v/c) * cos(u);
    PosO.y = c * cosh(v/c) * sin(u) ;
    PosO.z = v;

    Out.colpos = length(PosO+lpos);

    //position (projected)
    Out.PosWVP  = mul(PosO, tWVP);
    Out.TexCd  = mul(TexCd, tTex);

    return Out;
}

//////////////////////////////////////////////////////////////////////

vs2ps VS_Kidney(
    float4 PosO: POSITION,
    float4 TexCd : TEXCOORD0)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;
    PosO =  mul(PosO, TT);

    float u = PosO.x * 2*TWOPI;
    float v = PosO.y * 2*PI/2;

    PosO.x = cos(u) * (3*cos(v) - cos(3*v));
    PosO.y = sin(u) * (3*cos(v) - cos(3*v));
    PosO.z = 3 * sin(v) - sin(3*v);

    Out.colpos = length(PosO+lpos);

    //position (projected)
    Out.PosWVP  = mul(PosO, tWVP);
    Out.TexCd = mul(TexCd, tTex);

    return Out;
}

// --------------------------------------------------------------------------------------------------
// PIXELSHADERS:
// --------------------------------------------------------------------------------------------------

float4 PS(vs2ps In): COLOR
{
    float4 src = tex2D(Samp, In.TexCd);
       float4 col1 = (In.colpos * src * col);
       col1.a = 1 ;
       return mul(col1,tColor);
}

// --------------------------------------------------------------------------------------------------
// TECHNIQUES:
// --------------------------------------------------------------------------------------------------


technique Paraboloid
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
        VertexShader = compile vs_1_1 VS_Paraboloid();
        PixelShader = compile ps_2_0 PS();
    }
}

technique Hyperboloid
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
        VertexShader = compile vs_1_1 VS_Hyperboloid();
        PixelShader = compile ps_2_0 PS();
    }
}

technique LimpetTorus
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
        VertexShader = compile vs_1_1 VS_LimpetTorus();
        PixelShader = compile ps_2_0 PS();
    }
}

technique Handkerchief
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
        VertexShader = compile vs_1_1 VS_Handkerchief();
        PixelShader = compile ps_2_0 PS();
    }
}

technique Apple
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
        VertexShader = compile vs_1_1 VS_Apple();
        PixelShader = compile ps_2_0 PS();
    }
}

technique Springs
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
        VertexShader = compile vs_1_1 VS_Springs();
        PixelShader = compile ps_2_0 PS();
    }
}

technique Figure8Torus
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
        VertexShader = compile vs_1_1 VS_Figure8Torus();
        PixelShader = compile ps_2_0 PS();
    }
}

technique EllipticTorus
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
        VertexShader = compile vs_1_1 VS_EllipticTorus();
        PixelShader = compile ps_2_0 PS();
    }
}

technique Catenoid
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
        VertexShader = compile vs_1_1 VS_Catenoid();
        PixelShader = compile ps_2_0 PS();
    }
}

technique Kidney
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
        VertexShader = compile vs_1_1 VS_Kidney();
        PixelShader = compile ps_2_0 PS();
    }
}
