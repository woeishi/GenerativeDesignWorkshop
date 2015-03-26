
float4x4 tW: WORLD;        //the models world matrix
float4x4 tV: VIEW;         //view matrix as set via Renderer (EX9)
float4x4 tP: PROJECTION;
float4x4 tVP: VIEWPROJECTION;
float4x4 tWVP: WORLDVIEWPROJECTION;
float4x4 tWV: WORLDVIEW;
float4x4 TT <String uiname="transform grid position before formula";>;
float3 lDir <string uiname="Light Direction";> = {0, -5, 2};        //light direction in world space
float4 lAmb  : COLOR <String uiname="Ambient Color";>  = {0.15, 0.15, 0.15, 1};
float4 lDiff : COLOR <String uiname="Diffuse Color";>  = {0.85, 0.85, 0.85, 1};
float4 lSpec : COLOR <String uiname="Specular Color";> = {0.35, 0.35, 0.35, 1};
float lPower <String uiname="Power"; float uimin=0.0;> = 25.0;     //shininess of specular highlight

texture Tex <string uiname="Texture";>;
sampler Samp = sampler_state    //sampler for doing the texture-lookup
{
    Texture   = (Tex);          //apply a texture to the sampler
    MipFilter = LINEAR;         //sampler states
    MinFilter = LINEAR;
    MagFilter = LINEAR;
};

//texture transformation marked with semantic TEXTUREMATRIX to achieve
//symmetric transformations
float4x4 tTex: TEXTUREMATRIX ;

//the data structure: "vertexshader to pixelshader"
//used as output data with the VS function
//and as input data with the PS function



struct vs2ps
{
    float4 Pos  : POSITION;
    float2 TexCd : TEXCOORD0;
    float4 TexCol : TEXCOORD1;
    float4 PosV  : TEXCOORD2;
    float3 ViewDirV: TEXCOORD3;
    float3 LightDirV: TEXCOORD4;
    float4 Bi  : TEXCOORD5;
    float4 Tan  : TEXCOORD6;
};
//
//----------------------------------------------------------------------------
//----------------------
// VERTEXSHADERS
//
//----------------------------------------------------------------------------
//----------------------
struct pd
{
   float p;
   float d; //derivative
};
pd supaformula(float m, float n1, float n2, float n3, float phi)
{
   float2 ret;
   float r;
   float a=1, b=1;
   float t1___ = cos(m * phi / 4);
   float t1__ = t1___ / a;
   float t1_ = abs(t1__);
   float t1 = pow(t1_, n2);
   float t2___ = sin(m * phi / 4);
   float t2__ = t2___ / b;
   float t2_ = abs(t2__);
   float t2 = pow(t2_, n3);
   float T = t1+t2;
   r = pow(T, 1/n1);
   if (abs(r) == 0) {
      r = 0;
   } else {
      r = 1 / r;
   }
   float dt1 = n2 * (t1/t1_) * sign(t1__) * (- m * t2___ / (4 * a));
   float dt2 = n3 * (t2/t2_) * sign(t2__) * (  m * t1___ / (4 * b));
   float dT = dt1 + dt2;
   pd Out;
   Out.p = r;
   Out.d = - (1/n1) * (r/T) * dT;
   return Out;
}
float2 supaformula2D(float m, float n1, float n2, float n3, float phi)
{
   float2 ret;
   float r;
   float t1,t2;
   float a=1, b=1;
   t1 = cos(m * phi / 4) / a;
   t1 = abs(t1);
   t1 = pow(t1,n2);
   t2 = sin(m * phi / 4) / b;
   t2 = abs(t2);
   t2 = pow(t2,n3);
   r = pow(t1+t2, 1/n1);

   if (abs(r) == 0) {
      ret = 0;
   } else {
      r = 1 / r;
      ret.x = r * cos(phi);
      ret.y = r * sin(phi);
   }

   return ret;
}
struct PosBiTan
{
   float3 Pos;
   float3 Bi;
   float3 Tan;
};
PosBiTan sfs3D(float m, float n1, float n2, float n3,float mb, float n1b, float n2b, float n3b, float theta, float
phi){
  pd rt = supaformula(m, n1, n2, n3, theta);
  pd rp = supaformula(mb, n1b, n2b, n3b, phi);
  float st = sin(theta);
  float ct = cos(theta);
  float sp = sin(phi);
  float cp = cos(phi);

  PosBiTan Out;
  Out.Pos.x = rt.p * ct * rp.p * cp;
  Out.Pos.y = rt.p * st * rp.p * cp;
  Out.Pos.z = rp.p * sp;

  Out.Bi.x = (rt.d*ct-rt.p*st) * (rp.p * cp);
  Out.Bi.y = (rt.d*st+rt.p*ct) * (rp.p * cp);
  Out.Bi.z = 0;
  Out.Tan.x = (rt.p * ct) * (rp.d*cp-rp.p*sp);
  Out.Tan.y = (rt.p * st) * (rp.d*cp-rp.p*sp);
  Out.Tan.z = (rp.d*sp+rp.p*cp);
  return Out;
}

float m;
float n1;
float n2;
float n3;

float mb;
float n1b;
float n2b;
float n3b;


vs2ps VS(
    float4 PosO  : POSITION,
    float4 TexCd : TEXCOORD0)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;
    //transform position
      PosO = mul(PosO, TT);
    PosBiTan supa = sfs3D(m, n1, n2, n3,mb, n1b, n2b, n3b, PosO.x, PosO.y);
    PosO.xyz = supa.Pos;
       Out.LightDirV = normalize(-mul(lDir, tV));
        Out.ViewDirV = -normalize(mul(PosO, tWV));
       Out.Pos = mul(PosO, tWVP);
       Out.Bi = mul(float4(supa.Bi, 0), tWV);
       Out.Tan = mul(float4(supa.Tan, 0), tWV);
       Out.TexCol = PosO;
    //transform texturecoordinates
    Out.TexCd = mul(TexCd, tTex);
    return Out;
}

//
//----------------------------------------------------------------------------
//----------------------
// PIXELSHADERS:
//
//----------------------------------------------------------------------------
//----------------------
float4 PS(vs2ps In): COLOR
{


    float3 n = normalize(cross(In.Tan, In.Bi));

    lAmb.a = 1;
    //halfvector
    float3 H = normalize(In.ViewDirV + In.LightDirV);

    //compute blinn lighting
    float3 shades = lit(dot(n, In.LightDirV), dot(n, H), lPower);

    float4 diff = lDiff * shades.y;
    diff.a = 1;

    //reflection vector (view space)
    float3 R = normalize(2 * dot(n, In.LightDirV) * n - In.LightDirV);
    //normalized view direction (view space)
    float3 V = normalize(In.ViewDirV);

    //calculate specular light
    float4 spec = pow(max(dot(R, V),0), lPower*.2) * lSpec;

    float4 col = tex2D(Samp, In.TexCd);
    col.rgb *= (lAmb + diff) + spec;
    return col;
}


//
//----------------------------------------------------------------------------
//----------------------
// TECHNIQUES:
//
//----------------------------------------------------------------------------
//----------------------
technique TSupaFormula_sphere
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
        VertexShader = compile vs_2_0 VS();
        PixelShader  = compile ps_2_0 PS();      //*******
    }
}
