
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

vs2ps VS_Scherk(
    float4 PosO  : POSITION,
    float4 TexCd : TEXCOORD0)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;
    PosO =  mul(PosO, TT);

    float u = PosO.x  * 8;
    float v = PosO.y  * 12.5;

    PosO.x = u;
    PosO.y = v ;
    PosO.z = log(cos(c*u) / cos(c*v)) / c ;

    Out.colpos = length(PosO+lpos);

    //position (projected)
    Out.PosWVP  = mul(PosO, tWVP);
    Out.TexCd  = mul(TexCd, tTex);

    return Out;
}

//////////////////////////////////////////////

vs2ps VS_Dini(
    float4 PosO  : POSITION,
    float4 TexCd : TEXCOORD0)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;
    PosO =  mul(PosO, TT);

    float u = PosO.x  * 2*TWOPI;
    float v = PosO.y  * 2*PI;

    PosO.x = a * cos(u) * sin(v);
    PosO.y = a * sin(u) * sin(v) ;
    PosO.z = a * (cos(v) + log(tan(v/2))) + b * u ;

    Out.colpos = length(PosO+lpos);
    
    //position (projected)
    Out.PosWVP  = mul(PosO, tWVP);
    Out.TexCd  = mul(TexCd, tTex);

    return Out;
}

/////////////////////////////////////////////////////////

vs2ps VS_Helicoid(
    float4 PosO  : POSITION,
    float4 TexCd : TEXCOORD0)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;
    PosO =  mul(PosO, TT);

    float u = PosO.x * 2 ;
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

///////////////////////////////////////////////////////////

vs2ps VS_Bour(
    float4 PosO  : POSITION,
    float4 TexCd : TEXCOORD0)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;
    PosO =  mul(PosO, TT);

    float u = (PosO.x+0.5)  * PI;
    float v = (PosO.y+0.5)  * TWOPI;

    PosO.x = pow(u,a-1)* cos((a-1)*v)/(2 *(a-1)) - pow(u,a+1)* cos((a+1) *v)/(2 *(a+1));
    PosO.y = pow(u,a-1)* sin((a-1)*v)/(2 *(a-1)) + pow(u,a+1)* sin((a+1)* v)/(2* (a+1));
    PosO.z = pow(u,a) * cos(a * v) / a;

    Out.colpos = length(PosO+lpos);

    //position (projected)
    Out.PosWVP  = mul(PosO, tWVP);
    Out.TexCd  = mul(TexCd, tTex);

    return Out;
}

///////////////////////////////////////////////

vs2ps VS_Catalan(
    float4 PosO  : POSITION,
    float4 TexCd : TEXCOORD0)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;
    PosO =  mul(PosO, TT);

    float u = PosO.x;
    float v = PosO.y;

    PosO.x = c * (u - cosh(v) * sin(u));
    PosO.y = c * (1 - cosh(v) * cos(u)) ;
    PosO.z = -4 * c * sin(u/2) * sinh(v/2) ;

    Out.colpos = length(PosO+lpos);
    
    //position (projected)
    Out.PosWVP  = mul(PosO, tWVP);
    Out.TexCd  = mul(TexCd, tTex);

    return Out;
}

///////////////////////////////////////////////////////

vs2ps VS_Fish(
    float4 PosO  : POSITION,
    float4 TexCd : TEXCOORD0)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;
    PosO =  mul(PosO, TT);

    float u = PosO.x * 2*PI;
    float v = PosO.y * 2*TWOPI;

    PosO.x = (cos(u) - cos(2*u)) * cos(v) / 4;
    PosO.y = (sin(u) - sin(2*u)) * sin(v) / 4 ;
    PosO.z = cos(u) ;

    Out.colpos = length(PosO+lpos);

    //position (projected)
    Out.PosWVP  = mul(PosO, tWVP);
    Out.TexCd  = mul(TexCd, tTex);

    return Out;
}

///////////////////////////////////////////////////

vs2ps VS_DoubleCone(
    float4 PosO  : POSITION,
    float4 TexCd : TEXCOORD0)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;
    PosO =  mul(PosO, TT);

    float u = PosO.x * 2*TWOPI;
    float v = PosO.y * 2;

    PosO.x = v * cos(u) ;
    PosO.y = (v - 1) * cos(u + TWOPI/3) ;
    PosO.z = (1 - v ) * cos(u - TWOPI/3) ;

    Out.colpos = length(PosO+lpos);

    //position (projected)
    Out.PosWVP  = mul(PosO, tWVP);
    Out.TexCd  = mul(TexCd, tTex);

    return Out;
}

///////////////////////////////////////////////////////////

vs2ps VS_TriaxialTeardrop(
    float4 PosO  : POSITION,
    float4 TexCd : TEXCOORD0)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;
    PosO =  mul(PosO, TT);

    float u = PosO.x * PI;
    float v = PosO.y * TWOPI;

    PosO.x = (1 - cos(u)) * cos(u + TWOPI / 3) * cos(v + TWOPI / 3) / 2;
    PosO.y = (1 - cosh(u)) * cos(u + TWOPI /3) * cos(v - TWOPI / 3) / 2;
    PosO.z = cos(u - TWOPI / 3) ;

    Out.colpos = length(PosO+lpos);

    //position (projected)
    Out.PosWVP  = mul(PosO, tWVP);
    Out.TexCd  = mul(TexCd, tTex);

    return Out;
}

////////////////////////////////////////////////////

vs2ps VS_Jet(
    float4 PosO  : POSITION,
    float4 TexCd : TEXCOORD0)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;
    PosO =  mul(PosO, TT);

    float u = (PosO.x+0.5) * PI;
    float v = (PosO.y+0.5) * TWOPI;

    PosO.x = (1 - cosh(u)) * sin(u) * cos(v)/2;
    PosO.y = (1 - cosh(u)) * sin(u) * sin(v)/2;
    PosO.z = cosh(u) ;

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


technique Scherk
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
        VertexShader = compile vs_1_1 VS_Scherk();
        PixelShader = compile ps_2_0 PS();
    }
}

technique Dini
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
        VertexShader = compile vs_1_1 VS_Dini();
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

technique Bour
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
        VertexShader = compile vs_1_1 VS_Bour();
        PixelShader = compile ps_2_0 PS();
    }
}

technique Catalan
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
        VertexShader = compile vs_1_1 VS_Catalan();
        PixelShader = compile ps_2_0 PS();
    }
}

technique Fish
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
        VertexShader = compile vs_1_1 VS_Fish();
        PixelShader = compile ps_2_0 PS();
    }
}

technique DoubleCone
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
        VertexShader = compile vs_1_1 VS_DoubleCone();
        PixelShader = compile ps_2_0 PS();
    }
}

technique TriaxialTeardrop
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
        VertexShader = compile vs_1_1 VS_TriaxialTeardrop();
        PixelShader = compile ps_2_0 PS();
    }
}

technique Jet
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
        VertexShader = compile vs_1_1 VS_Jet();
        PixelShader = compile ps_2_0 PS();
    }
}
