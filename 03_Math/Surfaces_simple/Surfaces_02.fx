
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

vs2ps VS_SteinbachScrew(
    float4 PosO  : POSITION,
    float4 TexCd : TEXCOORD0)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;
    PosO =  mul(PosO, TT);

    float u = PosO.x  * 8;
    float v = PosO.y  * 12.5;

      PosO.x = a * (u) * cos(v);
      PosO.y = a * (u) * sin(v);
      PosO.z = a * (v) * cos(u);

    Out.colpos = length(PosO+lpos);

    //position (projected)
    Out.PosWVP  = mul(PosO, tWVP);
    Out.TexCd  = mul(TexCd, tTex);

    return Out;
}

///////////////////////////////////////////////////////////////////////////////////////////

vs2ps VS_Sine(
    float4 PosO  : POSITION,
    float4 TexCd : TEXCOORD0)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;
    PosO =  mul(PosO, TT);

    float u = PosO.x  * TWOPI;
    float v = PosO.y  * TWOPI;

    PosO.x = a * sin(u);
    PosO.y = a * sin(v);
    PosO.z = a * sin(u+v);

    Out.colpos = length(PosO+lpos);

    //position (projected)
    Out.PosWVP  = mul(PosO, tWVP);
    Out.TexCd  = mul(TexCd, tTex);

    return Out;
}

///////////////////////////////////////////////////////////////////////////////////////////

vs2ps VS_Eight(
    float4 PosO  : POSITION,
    float4 TexCd : TEXCOORD0)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;
    PosO =  mul(PosO, TT);

    float u = PosO.x  * 2*TWOPI;
    float v = PosO.y  * 2*PI/2;

    PosO.x = cos(u) * sin(2*v);
    PosO.y = sin(u) * sin(2*v);
    PosO.z = sin(v);

    Out.colpos = length(PosO+lpos);

    //position (projected)
    Out.PosWVP  = mul(PosO, tWVP);
    Out.TexCd  = mul(TexCd, tTex);

    return Out;
}

///////////////////////////////////////////////////////////////////////////////////////////

vs2ps VS_Corkscrew(
    float4 PosO  : POSITION,
    float4 TexCd : TEXCOORD0)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;
    PosO =  mul(PosO, TT);

    float u = PosO.x  * TWOPI;
    float v = PosO.y  * 2*TWOPI;

    PosO.x = a * cos(u) * cos(v);
    PosO.y = a * sin(u) * cos(v);
    PosO.z = a * sin(v) + b * u;

    Out.colpos = length(PosO+lpos);

    //position (projected)
    Out.PosWVP  = mul(PosO, tWVP);
    Out.TexCd  = mul(TexCd, tTex);

    return Out;
}

///////////////////////////////////////////////////////////////////////////////////////////

vs2ps VS_Roman2Boy(
    float4 PosO  : POSITION,
    float4 TexCd : TEXCOORD0)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;
    PosO =  mul(PosO, TT);

    float u = PosO.x  * PI;
    float v = PosO.y  * PI;

     PosO.x = (pow(2,0.5) * cos(2*u) * pow(cos(v),2) + cos(u) * sin(2*v)) / (2 - a*pow(2,0.5) * sin(3*u) * sin(2*v));
     PosO.y = (pow(2,0.5) * sin(2*u) * pow(cos(v),2) + sin(u) * sin(2*v)) / (2 - a*pow(2,0.5) * sin(3*u) * sin(2*v));
     PosO.z = (3*pow(cos(v),2)) / (2 - a*pow(2,0.5) * sin(3*u) * sin(2*v));

    Out.colpos = length(PosO+lpos);

    //position (projected)
    Out.PosWVP  = mul(PosO, tWVP);
    Out.TexCd  = mul(TexCd, tTex);

    return Out;
}

///////////////////////////////////////////////////////////////////////////////////////////

vs2ps VS_TwistedPipe(
    float4 PosO  : POSITION,
    float4 TexCd : TEXCOORD0)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;
    PosO =  mul(PosO, TT);

    float u = PosO.x  * TWOPI;
    float v = PosO.y  * TWOPI;

     PosO.x = cos(v) * (2 + cos(u)) / sqrt(1 + pow(sin(v),2));
     PosO.y = sin(v + TWOPI/3) * (2 + cos(u + TWOPI/3)) / sqrt(1 + pow(sin(v),2));
     PosO.z = sin(v - TWOPI/3) * (2 + cos(u - TWOPI/3)) / sqrt(1 + pow(sin(v),2));

    Out.colpos = length(PosO+lpos);

    //position (projected)
    Out.PosWVP  = mul(PosO, tWVP);
    Out.TexCd  = mul(TexCd, tTex);

    return Out;
}

///////////////////////////////////////////////////////////////////////////////////////////

vs2ps VS_BohemianDome(
    float4 PosO  : POSITION,
    float4 TexCd : TEXCOORD0)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;
    PosO =  mul(PosO, TT);

    float u = PosO.x  * TWOPI;
    float v = PosO.y  * TWOPI;

    PosO.x = a * cos(u);
    PosO.y = a * sin(u) + b * cos(v);
    PosO.z = c * sin(v);

    Out.colpos = length(PosO+lpos);

    //position (projected)
    Out.PosWVP  = mul(PosO, tWVP);
    Out.TexCd  = mul(TexCd, tTex);

    return Out;
}


///////////////////////////////////////////////////////////////////////////////////////////

vs2ps VS_Folium(
    float4 PosO  : POSITION,
    float4 TexCd : TEXCOORD0)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;
    PosO =  mul(PosO, TT);

    float u = PosO.x  * TWOPI;
    float v = PosO.y  * TWOPI;

    PosO.x = cos(u) * (2 * v/ PI - tanh(v));
    PosO.y = cos(u + TWOPI / 3) / cosh(v);
    PosO.z = cos(u - TWOPI / 3) / cosh(v);

    Out.colpos = length(PosO+lpos);

    //position (projected)
    Out.PosWVP  = mul(PosO, tWVP);
    Out.TexCd  = mul(TexCd, tTex);

    return Out;
}

///////////////////////////////////////////////////////////////////////////////////////////

vs2ps VS_AstroidalEllipsoid(
    float4 PosO  : POSITION,
    float4 TexCd : TEXCOORD0)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;
    PosO =  mul(PosO, TT);
    
    float u = PosO.x  * PI;
    float v = PosO.y  * TWOPI;

    PosO.x = pow(cos(u)*cos(v),3);
    PosO.y = pow(sin(u)*cos(v),3);
    PosO.z = pow(sin(v),3);

    Out.colpos = length(PosO+lpos);

    //position (projected)
    Out.PosWVP  = mul(PosO, tWVP);
    Out.TexCd  = mul(TexCd, tTex);

    return Out;
}

///////////////////////////////////////////////////////////////////////////////////////////

vs2ps VS_TriaxialHexatorus(
    float4 PosO  : POSITION,
    float4 TexCd : TEXCOORD0)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;
    PosO =  mul(PosO, TT);

    float u = PosO.x  * 2*PI;
    float v = PosO.y  * 2*TWOPI;

     PosO.x = sin(u) / (sqrt(2) + cos(v));
     PosO.y = sin(u + TWOPI/3) / (sqrt(2) + cos(v + TWOPI/3));
     PosO.z = cos(u - TWOPI/3) / (sqrt(2) + cos(v - TWOPI/3));

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


technique SteinbachScrew
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
        VertexShader = compile vs_1_1 VS_SteinbachScrew();
        PixelShader = compile ps_2_0 PS();
    }
}

technique Sine
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
        VertexShader = compile vs_1_1 VS_Sine();
        PixelShader = compile ps_2_0 PS();
    }
}

technique Eight
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
        VertexShader = compile vs_1_1 VS_Eight();
        PixelShader = compile ps_2_0 PS();
    }
}

technique Corkscrew
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
        VertexShader = compile vs_1_1 VS_Corkscrew();
        PixelShader = compile ps_2_0 PS();
    }
}

technique Roman2Boy
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
        VertexShader = compile vs_1_1 VS_Roman2Boy();
        PixelShader = compile ps_2_0 PS();
    }
}

technique TwistedPipe
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
        VertexShader = compile vs_1_1 VS_TwistedPipe();
        PixelShader = compile ps_2_0 PS();
    }
}

technique BohemianDome
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
        VertexShader = compile vs_1_1 VS_BohemianDome();
        PixelShader = compile ps_2_0 PS();
    }
}

technique Folium
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
        VertexShader = compile vs_1_1 VS_Folium();
        PixelShader = compile ps_2_0 PS();
    }
}

technique AstroidalEllipsoid
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
        VertexShader = compile vs_1_1 VS_AstroidalEllipsoid();
        PixelShader = compile ps_2_0 PS();
    }
}

technique TriaxialHexatorus
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
        VertexShader = compile vs_1_1 VS_TriaxialHexatorus();
        PixelShader = compile ps_2_0 PS();
    }
}
