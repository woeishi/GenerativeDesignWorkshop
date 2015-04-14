
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

vs2ps VS_Stiletto(
    float4 PosO  : POSITION,
    float4 TexCd : TEXCOORD0)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;
    PosO =  mul(PosO, TT);

    float u = PosO.x * 2*TWOPI;
    float v = PosO.y * 2*TWOPI;

     PosO.x = (2 + cos(u)) * pow(cos(v),3) * sin(v);
     PosO.y = (2 + cos(u + TWOPI/3)) * pow(cos(v + TWOPI/3),2) * pow(sin(v + TWOPI/3),2);
     PosO.z = -(2 + cos(u - TWOPI/3)) * pow(cos(v + TWOPI/3),2) * pow(sin(v + TWOPI/3),2);

     Out.colpos = length(PosO+lpos);

    //position (projected)
    Out.PosWVP  = mul(PosO, tWVP);
    Out.TexCd  = mul(TexCd, tTex);

    return Out;
}

////////////////////////////////////////////////////////////////////////////////

vs2ps VS_MaedersOwl(
    float4 PosO  : POSITION,
    float4 TexCd : TEXCOORD0)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;
    PosO =  mul(PosO, TT);

    float u = PosO.x * 2*TWOPI;
    float v = PosO.y ;

    PosO.x = v * cos(u) - 0.5 * pow(v,2) * cos(2 * u);
    PosO.y = - v * sin(u) - 0.5 * pow(v,2) * sin(2 * u);
    PosO.z = 4 * pow(v,1.5) * cos(3 * u / 2) / 3;

    Out.colpos = length(PosO+lpos);

    //position (projected)
    Out.PosWVP  = mul(PosO, tWVP);
    Out.TexCd  = mul(TexCd, tTex);

    return Out;
}

////////////////////////////////////////////////////////////////////////////////

vs2ps VS_TriaxialTritorus(
    float4 PosO  : POSITION,
    float4 TexCd : TEXCOORD0)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;
    PosO =  mul(PosO, TT);

    float u = PosO.x * TWOPI;
    float v = PosO.y * TWOPI;

    PosO.x = sin(u) * (1 + cos(v));
    PosO.y = sin(u + TWOPI / 3) * (1 + cos(v + TWOPI / 3));
    PosO.z = sin(u + 2*TWOPI / 3) * (1 + cos(v + 2*TWOPI / 3));

     Out.colpos = length(PosO+lpos);

    //position (projected)
    Out.PosWVP  = mul(PosO, tWVP);
    Out.TexCd  = mul(TexCd, tTex);

    return Out;
}

////////////////////////////////////////////////////////////////////////////////

vs2ps VS_Tear(
    float4 PosO  : POSITION,
    float4 TexCd : TEXCOORD0)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;
    PosO =  mul(PosO, TT);

    float u = PosO.x * TWOPI;
    float v = PosO.y * PI;

     PosO.x = a * (1- cos(u)) * sin(u) * cos(v);
     PosO.y = a * (1- cos(u)) * sin(u) * sin(v);
     PosO.z = cos(u);

     Out.colpos = length(PosO+lpos);

    //position (projected)
    Out.PosWVP  = mul(PosO, tWVP);
    Out.TexCd  = mul(TexCd, tTex);

    return Out;
}

////////////////////////////////////////////////////////////////////////////////

vs2ps VS_Slippers(
    float4 PosO  : POSITION,
    float4 TexCd : TEXCOORD0)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;
    PosO =  mul(PosO, TT);

    float u = PosO.x * TWOPI;
    float v = PosO.y * TWOPI;

     PosO.x = (2 + cos(u)) * pow(cos(v),3) * sin(v);
     PosO.y = (2 + cos(u+TWOPI/3)) * pow(cos(TWOPI/3+v),2) * pow(sin(TWOPI/3+v),2);
     PosO.z = -(2 + cos(u-TWOPI/3)) * pow(cos(TWOPI/3-v),2) * pow(sin(TWOPI/3-v),3);

     Out.colpos = length(PosO+lpos);

    //position (projected)
    Out.PosWVP  = mul(PosO, tWVP);
    Out.TexCd  = mul(TexCd, tTex);

    return Out;
}

////////////////////////////////////////////////////////////////////////////////

vs2ps VS_Kuen(
    float4 PosO  : POSITION,
    float4 TexCd : TEXCOORD0)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;
    PosO =  mul(PosO, TT);

    float u = (PosO.x + 0.5) * TWOPI;
    float v = (PosO.y + 0.5) * TWOPI;

     PosO.x = (2 * (cos(v) + (v * sin(v))) * sin(u)) / (1 + pow(v,2) * pow(sin(u),2));
     PosO.y = (2 * (sin(v) - (v * cos(v))) * sin(u)) / (1 + pow(v,2) * pow(sin(u),2));
     PosO.z = (log(tan(u/2)) + ((2*cos(u)))) / (1 + pow(v,2) * pow(sin(u),2));

    Out.colpos = length(PosO+lpos);

    //position (projected)
    Out.PosWVP  = mul(PosO, tWVP);
    Out.TexCd  = mul(TexCd, tTex);

    return Out;
}

////////////////////////////////////////////////////////////////////////////////

vs2ps VS_KleinCycloid(
    float4 PosO  : POSITION,
    float4 TexCd : TEXCOORD0)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;
    PosO =  mul(PosO, TT);

    float u = PosO.x * TWOPI;
    float v = PosO.y * TWOPI;

    PosO.x = cos(u/c) * cos(u/b) * (a + cos(v)) + sin(u/b) * sin(v) * cos(v);
    PosO.y = sin(u/c) * cos(u/b) * (a + cos(v)) + sin(u/b) * sin(v) * cos(v);
    PosO.z = -sin(u/b) * (a + cos(v)) + cos(u/b) * sin(v) * cos(v);

     Out.colpos = length(PosO+lpos);

    //position (projected)
    Out.PosWVP  = mul(PosO, tWVP);
    Out.TexCd  = mul(TexCd, tTex);

    return Out;
}

////////////////////////////////////////////////////////////////////////////////

vs2ps VS_KleinBottle(
    float4 PosO  : POSITION,
    float4 TexCd : TEXCOORD0)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;
    PosO =  mul(PosO, TT);

    float u = PosO.x * TWOPI;
    float v = PosO.y * TWOPI;

    float r = 4 * (1 - cos(u) / 2);
    
      PosO.x = 6 * cos(u) * (1 + sin(u)) + r * cos(v + PI);
      PosO.y = 16 * sin(u);
      PosO.z = r * sin(v);

    Out.colpos = length(PosO+lpos);

    //position (projected)
    Out.PosWVP  = mul(PosO, tWVP);
    Out.TexCd  = mul(TexCd, tTex);

    return Out;
}

////////////////////////////////////////////////////////////////////////////////

vs2ps VS_Tractrix(
    float4 PosO  : POSITION,
    float4 TexCd : TEXCOORD0)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;
    PosO =  mul(PosO, TT);

    float u = PosO.x * TWOPI;
    float v = PosO.y * TWOPI;

    PosO.x = cos(u) * (v - tanh(v));
    PosO.y = cos(u) / cosh(v) ;
    PosO.z = pow(PosO.x,2) - pow(PosO.y,2) + 2*PosO.x*PosO.y*pow(tanh(u),2);

    Out.colpos = length(PosO+lpos);

    //position (projected)
    Out.PosWVP  = mul(PosO, tWVP);
    Out.TexCd  = mul(TexCd, tTex);

    return Out;
}

////////////////////////////////////////////////////////////////////////////////

vs2ps VS_Helicoid(
    float4 PosO  : POSITION,
    float4 TexCd : TEXCOORD0)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;
    PosO =  mul(PosO, TT);

    float u = PosO.x * 2;
    float v = PosO.y * 2;

    PosO.x = c * v * cos(u);
    PosO.y = c * v * sin(u) ;
    PosO.z = u;

    Out.colpos = length(PosO+lpos);

    //position (projected)
    Out.PosWVP  = mul(PosO, tWVP);
    Out.TexCd  = mul(TexCd, tTex);

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

technique Stiletto
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
        VertexShader = compile vs_1_1 VS_Stiletto();
        PixelShader = compile ps_2_0 PS();
    }
}

technique MaedersOwl
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
        VertexShader = compile vs_1_1 VS_MaedersOwl();
        PixelShader = compile ps_2_0 PS();
    }
}

technique TriaxialTritorus
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
        VertexShader = compile vs_1_1 VS_TriaxialTritorus();
        PixelShader = compile ps_2_0 PS();
    }
}

technique Tear
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
        VertexShader = compile vs_1_1 VS_Tear();
        PixelShader = compile ps_2_0 PS();
    }
}

technique Slippers
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
        VertexShader = compile vs_1_1 VS_Slippers();
        PixelShader = compile ps_2_0 PS();
    }
}

technique Kuen
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
        VertexShader = compile vs_1_1 VS_Kuen();
        PixelShader = compile ps_2_0 PS();
    }
}

technique KleinCycloid
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
        VertexShader = compile vs_1_1 VS_KleinCycloid();
        PixelShader = compile ps_2_0 PS();
    }
}

technique KleinBottle
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
        VertexShader = compile vs_1_1 VS_KleinBottle();
        PixelShader = compile ps_2_0 PS();
    }
}

technique Tractrix
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
        VertexShader = compile vs_1_1 VS_Tractrix();
        PixelShader = compile ps_2_0 PS();
    }
}

technique Helicoid
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
        VertexShader = compile vs_1_1 VS_Helicoid();
        PixelShader = compile ps_2_0 PS();
    }
}
