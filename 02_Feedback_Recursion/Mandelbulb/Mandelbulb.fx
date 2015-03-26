// this is a very basic template. use it to start writing your own effects.
// if you want effects with lighting start from one of the GouraudXXXX or PhongXXXX effects

// --------------------------------------------------------------------------------------------------
// PARAMETERS:
// --------------------------------------------------------------------------------------------------

//transforms
float4x4 tW: WORLD;        //the models world matrix
float4x4 tV: VIEW;         //view matrix as set via Renderer (EX9)
float4x4 tP: PROJECTION;
float4x4 tWVP: WORLDVIEWPROJECTION;

//texture
texture Tex <string uiname="Texture";>;
sampler Samp = sampler_state    //sampler for doing the texture-lookup
{
    Texture   = (Tex);          //apply a texture to the sampler
    MipFilter = LINEAR;         //sampler states
    MinFilter = LINEAR;
    MagFilter = LINEAR;
};

//texture transformation marked with semantic TEXTUREMATRIX to achieve symmetric transformations
float4x4 tTex: TEXTUREMATRIX <string uiname="Texture Transform";>;

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
    Out.TexCd = mul(TexCd, tTex);

    return Out;
}

// --------------------------------------------------------------------------------------------------
// PIXELSHADERS:
// --------------------------------------------------------------------------------------------------

float4 PS(vs2ps In): COLOR
{
    float4 col = tex2D(Samp, In.TexCd);
    return col;
}

// --------------------------------------------------------------------------------------------------
// TECHNIQUES:
// --------------------------------------------------------------------------------------------------

float3 light1 <String uiname="Light Position 1";> = float3(  0.577, 0.577, 0.577 );
float3 light2 <String uiname="Light Position 2";> = float3( -0.707, 0.000, 0.707 );
float fov <String uiname="Fov";> = 1.0;
float3 campos <String uiname="Camera Position";> = float3( 0.0,0.0,-5.0 );
float3 camtar <String uiname="Camera Target";> = float3(0.0,0.1,0.0);

float4 bgcolor : COLOR <String uiname="Background Color";> = float4(0.5,0.5,0.5,1.0);

float power <String uiname="Power";> = 8.0;
bool julia <String uiname="Julia Set";> = 0;
float3 cc <String uiname="Julia Center";> = float3 (0.0,0.0,0.0 );



bool isphere( in float4 sph, in float3 ro, in float3 rd, out float2 t )
{
    float3 oc = ro - sph.xyz;
    float b = dot(oc,rd);
    float c = dot(oc,oc) - sph.w*sph.w;

    float h = b*b - c;
    
    bool ret = true;
    
    if( h<0.0 )
        ret = false;

    if (!ret)
    {
      float g = sqrt( h );
      t.x = - b - g;
      t.y = - b + g;
      ret = true;
    }

    return ret;
}

const int NumIte = 7;
const float Bailout = 100.0;

bool iterate( in float3 q, out float resPot, out float4 resColor )
{
    float4 trap = 100.0;
    float3 zz = q;
	float3 c = julia ? cc : q;
    float m = dot(zz,zz);

    bool ret = true;
    
    if( m > Bailout )
    {
        resPot = 0.5*log(m)/pow(8.0,0.0);
        resColor = 1.0;
        ret = false;
    }

    if (ret)
    {
    bool breake = false;
    for( int i=1; !breake && i<NumIte; i++ )
    {
    #if 0
        float zr = sqrt( dot(zz,zz) );
        float zo = acos( zz.y/zr );
        float zi = atan2( zz.x, zz.z );

        zr = pow( zr, power );
        zo = zo * power;
        zi = zi * power;

        zz = c + zr*float3( sin(zo)*sin(zi), cos(zo), sin(zo)*cos(zi) );
    #else
        float x = zz.x; float x2 = x*x; float x4 = x2*x2;
        float y = zz.y; float y2 = y*y; float y4 = y2*y2;
        float z = zz.z; float z2 = z*z; float z4 = z2*z2;

        float k3 = x2 + z2;
        float k2 = rsqrt( k3*k3*k3*k3*k3*k3*k3 );
        float k1 = x4 + y4 + z4 - 6.0*y2*z2 - 6.0*x2*y2 + 2.0*z2*x2;
        float k4 = x2 - y2 + z2;

        zz.x = c.x +  64.0*x*y*z*(x2-z2)*k4*(x4-6.0*x2*z2+z4)*k1*k2;
        zz.y = c.y + -16.0*y2*k3*k4*k4 + k1*k1;
        zz.z = c.z +  -8.0*y*k4*(x4*x4 - 28.0*x4*x2*z2 + 70.0*x4*z4 - 28.0*x2*z2*z4 + z4*z4)*k1*k2;
    #endif
	


        m = dot(zz,zz);

        trap = min( trap, float4(zz.xyz*zz.xyz,m) );

        if( m > Bailout )
        {
            resColor = trap;
            resPot = 0.5*log(m)/pow(8.0,float(i));
            ret = false;
            breake = true;
        }
    }

    if (!breake)
    {
      resColor = trap;
      resPot = 0.0;
    ret = true;
    }
    }
    
    return ret;
}

bool ifractal( in float3 ro, in float3 rd, out float rest, in float maxt, out float3 resnor, out float4 rescol, float fov )
{
    float4 sph = float4( 0.0, 0.0, 0.0, 1.25 );
    float2 dis;

    bool ret = true;

    // bounding sphere
    if( !isphere(sph,ro,rd,dis) )
        ret = false;

    if (ret)
    {
    // early skip
    if( dis.y<0.001 ) ret = false;

    if(ret)
    {
    // clip to near!
    if( dis.x<0.001 )dis.x = 0.001;

    if( dis.y>maxt) dis.y = maxt;

    float dt;
    float3 gra;
    float4 color;

    float fovfactor = 1.0/sqrt(1.0+fov*fov);

    // raymarch!
    bool breake = false;
    for( float t=dis.x; !breake && (t<dis.y);  )
    {
        float3 p = ro + rd*t;

        float Surface = clamp( 0.001*t*fovfactor, 0.000001, 0.005 );

        float eps = Surface*0.1;
        float4 col2;

        float pot1;

        if( iterate(p,pot1,color) )
        {
        rest = t;
        resnor=normalize(gra);
        rescol = color;
        ret = true;
        breake = true;
        }

        if (!breake)
        {
        float pot2; iterate(p+float3(eps,0.0,0.0),pot2,col2);
        float pot3; iterate(p+float3(0.0,eps,0.0),pot3,col2);
        float pot4; iterate(p+float3(0.0,0.0,eps),pot4,col2);

        gra = float3( pot2-pot1, pot3-pot1, pot4-pot1 );
        dt = 0.5*pot1*eps/length(gra);

        if( dt<Surface )
        {
            rescol = color;
            resnor = normalize( gra );
            rest = t;
            ret = true;
            breake = true;
        }

        t+=dt;
        }
    }

    if(!breake)
      ret = false;
    }
    }
    
    return ret;
}

float4 main(vs2ps In): COLOR
{
    float2 p = -1.0 + 2.0 * In.TexCd.xy;
    float2 s = p*float2(1.33,1.0);

    //camera matrix
    float3 cw = normalize(camtar-campos);
    float3 cp = float3(0.0,1.0,0.0);
    float3 cu = normalize(cross(cw,cp));
    float3 cv = normalize(cross(cu,cw));
    // ray dir
    float3 rd = normalize( s.x*cu + s.y*cv + 1.5*cw );


    float3 nor, rgb;
    float4 col;
    float t;
    if( !ifractal(campos,rd,t,1e20,nor,col,fov) )
    {
     	rgb = bgcolor.rgb;
    }
    else
    {
        float3 xyz = campos + t*rd;

        // sun light
        float dif1 = clamp( 0.2 + 0.8*dot( light1, nor ), 0.0, 1.0 ); dif1=dif1*dif1;
        // back light
        float dif2 = clamp( 0.3 + 0.7*dot( light2, nor ), 0.0, 1.0 );
        // ambient occlusion
        float ao = clamp(1.25*col.w-.4,0.0,1.0); ao=ao*ao*0.5+0.5*ao;
        // shadow
        float lt1; float3 ln; float4 lc;
        if( dif1>0.001 ) if( ifractal(xyz,light1,lt1,1e20,ln,lc,fov) ) dif1 = 0.1;

        // material color
        rgb = float3(1.0,1.0,1.0);
        rgb = lerp( rgb, float3(0.8,0.6,0.2), sqrt(col.x)*1.25 );
        rgb = lerp( rgb, float3(0.8,0.3,0.3), sqrt(col.y)*1.25 );
        rgb = lerp( rgb, float3(0.7,0.4,0.3), sqrt(col.z)*1.25 );

        // lighting
        rgb *= (0.5+0.5*nor.y)*float3(.14,.15,.16)*0.8 +  dif1*float3(1.0,.85,.4) + 0.5*dif2*float3(.08,.10,.14);
        rgb *= float3( pow(ao,0.8), pow(ao,1.00), pow(ao,1.1) );

        // gamma
        rgb = 1.5*(rgb*0.15 + 0.85*sqrt(rgb));
    }

    float2 uv = p*0.5+0.5;
    rgb *= 0.7 + 0.3*16.0*uv.x*uv.y*(1.0-uv.x)*(1.0-uv.y);

    rgb = clamp( rgb, 0.0, 1.0 );
    return float4(rgb,1.0);
}

technique TSimpleShader
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
        VertexShader = compile vs_1_1 VS();
        PixelShader  = compile ps_3_0 main();
    }
}
