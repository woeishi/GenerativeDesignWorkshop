
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

vs2ps VS_sphere(
    float4 PosO  : POSITION,
    float4 TexCd : TEXCOORD0)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;
    PosO =  mul(PosO, TT);

    float u = (PosO.x) * TWOPI;
    float v = (PosO.y) * PI;

     PosO.x = a * cos(v) * sin(u) ;
     PosO.y = a * sin(v) * sin(u) ;
     PosO.z = a * cos(u) ;

     Out.colpos = length(PosO+lpos);

    //position (projected)
    Out.PosWVP  = mul(PosO, tWVP);
    Out.TexCd  = mul(TexCd, tTex);

    return Out;
}

///////////////////////////////////////////////////////////////////////////////////////////

vs2ps VS_CrossCap(
    float4 PosO  : POSITION,
    float4 TexCd : TEXCOORD0)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;
    PosO =  mul(PosO, TT);

   float u = (PosO.x+0.5)  * TWOPI;
   float v = (PosO.y +0.5) * PI/2;

    PosO.x = cos(u) * sin(2*v);
    PosO.y = sin(u) * sin(2*v);
    PosO.z = pow(cos(v), 2) - pow(cos(u),2) * pow (sin(v),2);

     Out.colpos = length(PosO+lpos);

    //position (projected)
    Out.PosWVP  = mul(PosO, tWVP);
    Out.TexCd  = mul(TexCd, tTex);

    return Out;
}

///////////////////////////////////////////////////////////////////////////////////////////

vs2ps VS_Bow(
    float4 PosO  : POSITION,
    float4 TexCd : TEXCOORD0)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;
    PosO =  mul(PosO, TT);

    float u = PosO.x ;
    float v = PosO.y ;

     PosO.x = (2 + a * sin(TWOPI * u)) * sin(2 * TWOPI * v);
     PosO.y = (2 + a * sin(TWOPI * u)) * cos(2 * TWOPI * v);
     PosO.z = a * cos(TWOPI * u) + 3 * cos(TWOPI * v);

     Out.colpos = length(PosO+lpos);

    //position (projected)
    Out.PosWVP  = mul(PosO, tWVP);
    Out.TexCd  = mul(TexCd, tTex);

    return Out;
}

////////////////////////////////////////////////////

vs2ps VS_Tear(
    float4 PosO  : POSITION,
    float4 TexCd : TEXCOORD0)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;
    PosO =  mul(PosO, TT);

    float u = (PosO.x)  * TWOPI;
    float v = (PosO.y) * PI;

       PosO.x = a * (1- cos(u)) * sin(u) * cos(v);
       PosO.y = a * (1- cos(u)) * sin(u) * sin(v);
       PosO.z = cos(u);

     Out.colpos = length(PosO+lpos);
     
    //position (projected)
    Out.PosWVP  = mul(PosO, tWVP);
    Out.TexCd  = mul(TexCd, tTex);

    return Out;
}

///////////////////////////////////////////////////////////////////////////////////////////

vs2ps VS_Moebius(
    float4 PosO  : POSITION,
    float4 TexCd : TEXCOORD0)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;
    PosO =  mul(PosO, TT);

    float u = PosO.x  * TWOPI;
    float v = PosO.y  * 0.4;

      PosO.x = cos(u) + v * cos(u/2) * cos(u);
      PosO.y = sin(u) + v * cos(u/2) * sin(u);
      PosO.z = v * sin(u/2);

      Out.colpos = length(PosO+lpos);

    //position (projected)
    Out.PosWVP  = mul(PosO, tWVP);
    Out.TexCd  = mul(TexCd, tTex);

    return Out;
}

///////////////////////////////////////////////////////////////////////////////////////////

vs2ps VS_Horn(
    float4 PosO  : POSITION,
    float4 TexCd : TEXCOORD0)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;
    PosO =  mul(PosO, TT);

    float u = (PosO.x+0.5)  * 3/2;
   float v = (PosO.y +0.5) * TWOPI;
  // float u = (PosO.x+0.5)  ;
  // float v = (PosO.y+0.5) ;

     PosO.x = (2 + u * cos(v)) * sin(TWOPI * u);
     PosO.y = (2 + u * cos(v)) * cos(TWOPI * u) + 2 * u ;
     PosO.z = u * sin(v);

     Out.colpos = length(PosO+lpos);

    //position (projected)
    Out.PosWVP  = mul(PosO, tWVP);
    Out.TexCd  = mul(TexCd, tTex);

    return Out;
}

///////////////////////////////////////////////////////////////////////////////////////////

vs2ps VS_Cresent(
    float4 PosO  : POSITION,
    float4 TexCd : TEXCOORD0)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;
    PosO =  mul(PosO, TT);

    float u = (PosO.x+0.5);
    float v = (PosO.y +0.5);

     PosO.x = (2 + sin(TWOPI * u) * sin(TWOPI * v)) * sin(3 * PI * v);
     PosO.y = (2 + sin(TWOPI * u) * sin(TWOPI * v)) * cos(3 * PI * v);
     PosO.z= cos(TWOPI * u) * sin(TWOPI * v) + 4 * v - 2;

    Out.colpos = length(PosO+lpos);

    //position (projected)
    Out.PosWVP  = mul(PosO, tWVP);
    Out.TexCd  = mul(TexCd, tTex);

    return Out;
}

///////////////////////////////////////////////////////////////////////////////////////////

vs2ps VS_Shell(
    float4 PosO  : POSITION,
    float4 TexCd : TEXCOORD0)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;
    PosO =  mul(PosO, TT);

   float u = PosO.x  * 2*TWOPI;
   float v = PosO.y * TWOPI;

      PosO.x = a * (1 - (u / (TWOPI))) * cos(d*u) * (1 + cos(v)) + c * cos(d*u);
      PosO.y = a * (1 - (u / (TWOPI))) * sin(d*u) * (1 + cos(v)) + c * sin(d*u);
      PosO.z = b * (u / (TWOPI)) + a * (1 - (u / (TWOPI))) * sin(v);

     Out.colpos = length(PosO+lpos);

    //position (projected)
    Out.PosWVP  = mul(PosO, tWVP);
    Out.TexCd  = mul(TexCd, tTex);

    return Out;
}

///////////////////////////////////////////////////////////////////////////////////////////

vs2ps VS_PisotTriaxial(
    float4 PosO  : POSITION,
    float4 TexCd : TEXCOORD0)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;
    PosO =  mul(PosO, TT);

    float u = PosO.x * TWOPI;
    float v = PosO.y * TWOPI;

    PosO.x = 0.655866 * cos(1.03002 + u) * (2 + cos(v));
    PosO.y = 0.754878 * cos(1.40772 - u) * (2 + 0.868837 * cos(2.43773 + v));
    PosO.z = 0.868837 * cos(2.43773 + u) * (2 + 0.495098 * cos(0.377696 - v));

     Out.colpos = length(PosO);

    //position (projected)
    Out.PosWVP  = mul(PosO, tWVP);
    Out.TexCd  = mul(TexCd, tTex);

    return Out;
}

///////////////////////////////////////////////////////////////////////////////////////////

vs2ps VS_Hyperhelicoid(
    float4 PosO  : POSITION,
    float4 TexCd : TEXCOORD0)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;
    PosO =  mul(PosO, TT);

    float u = PosO.x * TWOPI;
    float v = PosO.y * TWOPI;

    PosO.x = a * (sin(v) * cos(c * u)) / (1 + cosh(u) * cosh(v));
    PosO.y = a * (sin(v) * sin(c * u)) / (1 + cosh(u) * cosh(v));
    PosO.z = (cosh(v) * sinh(u)) / (1 + cosh(u) * cosh(v));

     Out.colpos = length(PosO);

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
       float4 col1 =  (In.colpos * src * col);
       col1.a = 1 ;
       return mul(col1,tColor);
}

// --------------------------------------------------------------------------------------------------
// TECHNIQUES:
// --------------------------------------------------------------------------------------------------
technique sphere
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
        VertexShader = compile vs_1_1 VS_sphere();
        PixelShader = compile ps_2_0 PS();
    }
}

technique CrossCap
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
        VertexShader = compile vs_1_1 VS_CrossCap();
        PixelShader = compile ps_2_0 PS();
    }
}

technique Bow
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
        VertexShader = compile vs_1_1 VS_Bow();
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

technique Moebius
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
        VertexShader = compile vs_1_1 VS_Moebius();
        PixelShader = compile ps_2_0 PS();
    }
}

technique Horn
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
        VertexShader = compile vs_1_1 VS_Horn();
        PixelShader = compile ps_2_0 PS();
    }
}

technique Cresent
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
        VertexShader = compile vs_1_1 VS_Cresent();
        PixelShader = compile ps_2_0 PS();
    }
}

technique Shell
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
        VertexShader = compile vs_1_1 VS_Shell();
        PixelShader = compile ps_2_0 PS();
    }
}

technique PisotTriaxial
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
        VertexShader = compile vs_1_1 VS_PisotTriaxial();
        PixelShader = compile ps_2_0 PS();
    }
}

technique Hyperhelicoid
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
        VertexShader = compile vs_1_1 VS_Hyperhelicoid();
        PixelShader = compile ps_2_0 PS();
    }
}
