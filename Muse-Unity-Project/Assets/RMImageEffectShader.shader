// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Hidden/RMImageEffectShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#pragma multi_compile __ DEBUG_PERFORMANCE
			#pragma target 3.0
			
			#include "UnityCG.cginc"
			#include "DistanceFunc.cginc"

			// Provided by our script
			uniform float4x4 _FrustumCornersES;
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_TexelSize;
			uniform float4x4 _CameraInvViewMatrix;
			uniform float3 _CameraWS;
			uniform float3 _LightDir;
			uniform float move;
			uniform float eegData;
			uniform float time;
			uniform sampler2D _ColorRamp;

			// Input to vertex shader
			struct appdata
			{
			    // Remember, the z value here contains the index of _FrustumCornersES to use
			    float4 vertex : POSITION;
			    float2 uv : TEXCOORD0;
			};

			// Output of vertex shader / input to fragment shader
			struct v2f
			{
			    float4 pos : SV_POSITION;
			    float2 uv : TEXCOORD0;
			    float3 ray : TEXCOORD1;
			};

			v2f vert (appdata v)
			{
			    v2f o;
			    
			    // Index passed via custom blit function in RaymarchGeneric.cs
			    half index = v.vertex.z;
			    v.vertex.z = 0.1;
			    
			    o.pos = UnityObjectToClipPos(v.vertex);
			    o.uv = v.uv.xy;
			    
			    #if UNITY_UV_STARTS_AT_TOP
			    if (_MainTex_TexelSize.y < 0)
			        o.uv.y = 1 - o.uv.y;
			    #endif

			    // Get the eyespace view ray (normalized)
			    o.ray = _FrustumCornersES[(int)index].xyz;

			    // Transform the ray from eyespace to worldspace
			    // Note: _CameraInvViewMatrix was provided by the script
			    o.ray = mul(_CameraInvViewMatrix, o.ray);
			    return o;
			}

			float2 rot2D(float3 p)
			{
				float c = abs(cos(time));
				float s = abs(sin(time));
				float2 b = mul(float2x2(c,s,-s,c), p.xy); // * p.xy;
				return b;

			}

			float2 map(float3 p) {
			    //return sdTorus(p, float2(1, 0.2));
			    //float3 q =  opTwist(p);
			    //return sdTorus(q, float2(1, 0.2));

			    //float3 q =  opCheapBend( p );
			    //q = opTwist( q );
			   	//return sdBox(float3(rot2D(q), q.z) + float3(-move, 0, -10), float3(move, 0.05, 2));
			   	//return opBlend(p , 2*(abs(sin(eegData))+0.3));
			   	return opBlend(p , abs(sin(time))+0.3);

			}

			float3 calcNormal(in float3 pos)
			{
			    // epsilon - used to approximate dx when taking the derivative
			    const float2 eps = float2(0.001, 0.0);

			    float3 nor = float3(
			        map(pos + eps.xyy).x - map(pos - eps.xyy).x,
			        map(pos + eps.yxy).x - map(pos - eps.yxy).x,
			        map(pos + eps.yyx).x - map(pos - eps.yyx).x);
			    return normalize(nor);
			}

			fixed4 raymarch(float3 ro, float3 rd) {
			    fixed4 ret = fixed4(0,0,0,0);

			    const int maxstep = 100;
			    float t = 0; // current distance traveled along ray
			    for (int i = 0; i < maxstep; ++i) {
			        float3 p = ro + rd * t; // World space position of sample
			        float2 d = map(p);       // Sample of distance field (see map())

			        // If the sample <= 0, we have hit something (see map()).
			        if (d.x < 0.01) {
			            float3 n = calcNormal(p);
			            float light = dot(-_LightDir.xyz, n);
			            // Use y value given by map() to choose a color from our Color Ramp
			            ret = fixed4(tex2D(_ColorRamp, float2(d.y,0)).xyz * light, 1); // * fixed4(sin(eegData), 0.9, 0.8, 1);
			            break;
			        } 
			       
			        t += d;			       
			        
			    }

			    return ret;
			}


			fixed4 frag (v2f i) : SV_Target
			{
			    // ray direction
			    float3 rd = normalize(i.ray.xyz);
			    // ray origin (camera position)
			    float3 ro = _CameraWS;

			    fixed3 col = tex2D(_MainTex,i.uv); // Color of the scene before this shader was run

			    fixed4 add = raymarch(ro, rd);

			    // Returns final color using alpha blending
			    //return fixed4(col*(1.0 - add.w) + add.xyz * add.w,1.0);
			    if (add.w == 0) {
			    	return fixed4(i.ray, 1);
			    } else {
			    	return add;

			    }


			}

			ENDCG
		}
	}
}
