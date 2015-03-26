
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

vs2ps VS_BentHorns(
    float4 PosO  : POSITION,
    float4 TexCd : TEXCOORD0)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;
    PosO =  mul(PosO, TT);

    float u = PosO.x * 2*PI;
    float v = PosO.y * 2*TWOPI;

    PosO.x = (2 + cos(u)) * (v/3 - sin(v));
    PosO.y = (2 + cos(u - TWOPI/3)) * (cos(v) - 1);
    PosO.z = (2 + cos(u + TWOPI/3)) * (cos(v) - 1);

    Out.colpos = length(PosO+lpos);

    //position (projected)
    Out.PosWVP  = mul(PosO, tWVP);
    Out.TexCd  = mul(TexCd, tTex);

    return Out;
}

//////////////////////////////////////////////////////////////////////

vs2ps VS_Ennepers(
    float4 PosO  : POSITION,
    float4 TexCd : TEXCOORD0)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;
    PosO =  mul(PosO, TT);

    float u = PosO.x * 2;
    float v = PosO.y * 2;

    PosO.x = u - pow(u,3)/3 + u * pow(v,2);
    PosO.y = v - pow(v,3)/3 + v * pow(u,2);
    PosO.z = pow(u,2) - pow(v,2);

    Out.colpos = length(PosO+lpos);

    //position (projected)
    Out.PosWVP  = mul(PosO, tWVP);
    Out.TexCd  = mul(TexCd, tTex);

    return Out;
}

//////////////////////////////////////////////////////////////////////

vs2ps VS_Pillow(
    float4 PosO  : POSITION,
    float4 TexCd : TEXCOORD0)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;
    PosO =  mul(PosO, TT);

    float u = PosO.x * TWOPI;
    float v = PosO.y * TWOPI;

    PosO.x = cos(u);
    PosO.y = cos(v);
    PosO.z = sin(u) * sin(v);
    
    Out.colpos = length(PosO+lpos);

    //position (projected)
    Out.PosWVP  = mul(PosO, tWVP);
    Out.TexCd = mul(TexCd, tTex);

    return Out;
}

//////////////////////////////////////////////////////////////////////

vs2ps VS_MonkeySaddle(
    float4 PosO  : POSITION,
    float4 TexCd : TEXCOORD0)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;
    PosO =  mul(PosO, TT);

    float u = PosO.x * 2*1.1;
    float v = PosO.y * 2*1.1;

    PosO.x = u;
    PosO.y = v;
    PosO.z = pow(u,3) - 3 * u * pow(v,2);

    Out.colpos = length(PosO+lpos);

    //position (projected)
    Out.PosWVP  = mul(PosO, tWVP);
    Out.TexCd = mul(TexCd, tTex);

    return Out;
}

///////////////////////////////////////////////////

vs2ps VS_Henneburg(
    float4 PosO: POSITION,
    float4 TexCd : TEXCOORD0)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;
    PosO =  mul(PosO, TT);
    
    float u = PosO.x * 2;
    float v = PosO.y * 2;
    
    PosO.x = 2 * sinh(u) * cos(v) - 2 * sinh(3*u) * cos(3*v)/3;
    PosO.y = 2 * sinh(u) * sin(v) + 2 * sinh(3*u) * sin(3*v)/3;
    PosO.z = 2 * cosh(2*u) * cos(2*v);
    
    Out.colpos = length(PosO+lpos);

    //position (projected)
    Out.PosWVP  = mul(PosO, tWVP);
    Out.TexCd = mul(TexCd, tTex);

    return Out;
}

///////////////////////////////////////////////////

vs2ps VS_Snail(
    float4 PosO: POSITION,
    float4 TexCd : TEXCOORD0)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;
    PosO =  mul(PosO, TT);

    float u = PosO.x * 2*TWOPI;
    float v = PosO.y * 2*PI/2;

    PosO.x = u * cos(v) * sin(u);
    PosO.y = u * cos(u) * cos(v);
    PosO.z = -u * sin(v);
    
    Out.colpos = length(PosO+lpos);

    //position (projected)
    Out.PosWVP  = mul(PosO, tWVP);
    Out.TexCd = mul(TexCd, tTex);

    return Out;
}

///////////////////////////////////////////////////

vs2ps VS_Lemniscape(
    float4 PosO: POSITION,
    float4 TexCd : TEXCOORD0)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;
    PosO =  mul(PosO, TT);

    float u = (PosO.x+ 0.5) * PI ;
    float v = (PosO.y+ 0.5) * PI ;
    float cosvSqrtAbsSin2u = cos(v)*sqrt(abs(sin(2*u)));

    PosO.x = cosvSqrtAbsSin2u*cos(u);
    PosO.y = cosvSqrtAbsSin2u*sin(u);
    PosO.z = pow(PosO.x,2) - pow(PosO.y,2) + 2 * PosO.x * PosO.y * pow(tan(v),2);

    Out.colpos = length(PosO+lpos);

    //position (projected)
    Out.PosWVP  = mul(PosO, tWVP);
    Out.TexCd = mul(TexCd, tTex);

    return Out;
}

///////////////////////////////////////////////////

vs2ps VS_Tranguloid(
    float4 PosO: POSITION,
    float4 TexCd : TEXCOORD0)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;
    PosO =  mul(PosO, TT);
    
    float u = PosO.x * TWOPI ;
    float v = PosO.y * TWOPI ;

    PosO.x = sin(3*u) * 2 / (2 + cos(v));
    PosO.y = (sin(u) + 2 * sin(2*u)) * 2 / (2 + cos(v + TWOPI / a));
    PosO.z = (cos(u) - 2 * cos(2*u)) * (2 + cos(v)) * ((2 + cos(v + TWOPI/3))*0.25);

    Out.colpos = length(PosO+lpos);

    //position (projected)
    Out.PosWVP  = mul(PosO, tWVP);
    Out.TexCd = mul(TexCd, tTex);

    return Out;
}

//////////////////////////////////////////////

vs2ps VS_Cone(
    float4 PosO: POSITION,
    float4 TexCd : TEXCOORD0)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;
    PosO =  mul(PosO, TT);

    float u = (PosO.x+ 0.5);
    float theta = (PosO.y+ 0.5) * TWOPI;
    float ar = ((1-u) / 1) * a;// * (b * (cos(u*c)+1) + 1);

   PosO.x = (ar * cos(theta))+(u * cos(b*TWOPI - u))*d;
   PosO.y = (ar * sin(theta))+(u * cos(c*TWOPI - u))*d;
   PosO.z = u*d ;


    Out.colpos = length(PosO+lpos);

    //position (projected)
    Out.PosWVP = mul(PosO, tWVP);
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

technique BentHorns
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
        VertexShader = compile vs_1_1 VS_BentHorns();
        PixelShader = compile ps_2_0 PS();
    }
}

technique Ennepers
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
        VertexShader = compile vs_1_1 VS_Ennepers();
        PixelShader = compile ps_2_0 PS();
    }
}

technique Pillow
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
        VertexShader = compile vs_1_1 VS_Pillow();
        PixelShader = compile ps_2_0 PS();
    }
}

technique MonkeySaddle
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
        VertexShader = compile vs_1_1 VS_MonkeySaddle();
        PixelShader = compile ps_2_0 PS();
    }
}

technique Henneburg
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
        VertexShader = compile vs_1_1 VS_Henneburg();
        PixelShader = compile ps_2_0 PS();
    }
}
technique Snail
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
        VertexShader = compile vs_1_1 VS_Snail();
        PixelShader = compile ps_2_0 PS();
    }
}

technique Lemniscape
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
        VertexShader = compile vs_1_1 VS_Lemniscape();
        PixelShader = compile ps_2_0 PS();
    }
}

technique Tranguloid
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
        VertexShader = compile vs_1_1 VS_Tranguloid();
        PixelShader = compile ps_2_0 PS();
    }
}

technique Cone
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
        VertexShader = compile vs_1_1 VS_Cone();
        PixelShader = compile ps_2_0 PS();
    }
}
