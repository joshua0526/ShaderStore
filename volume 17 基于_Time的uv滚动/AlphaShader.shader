Shader "Lizhan/AlphaShader"
{
    Properties
    {
		_Color("Color", Color) = (1,1,1,1)
        _MainTex ("MainTex", 2D) = "white" {}
		_Emission("Emmisive Color", Color) = (0,0,0,0)
		_AlphaScale("Alpha Scale", Range(0,1)) = 1
	}
	SubShader
	{
		Tags { "Queue" = "Transparent""IngnoreProjector" = "True""RenderType" = "Transparent" }
		LOD 200

		Pass
		{
			Tags{"LightMode" = "ForwardBase"}
			ZWrite Off
			SeparateSpecular On
			Blend SrcAlpha OneMinusSrcAlpha
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed _AlphaScale;
			fixed4 _Emission;			

			struct a2v {
				float4 vertex:POSITION;
				float4 normal:NORMAL;
				float4 texcoord:TEXCOORD0;
			};

			struct v2f {
				float4 position:SV_POSITION;
				float3 worldNormal:TEXCOORD0;
				float3 worldPos:TEXCOORD1;
				float2 uv:TEXCOORD2;
			};

			v2f vert (a2v v)
			{
				v2f o;
				o.position = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed4 textColor = tex2D(_MainTex, i.uv);

				fixed updateColor = (cos(0.2 * _Time.y) + 2) / 3;
				fixed3 color = fixed3(0, updateColor/2, updateColor);
				fixed3 albedo = textColor.rgb * _Color.rgb;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				fixed3 diffuse = _LightColor0.rgb*albedo*max(0, dot(worldNormal, worldLightDir));
				fixed3 emission = _Emission.rgb * albedo;
				return fixed4(ambient + diffuse + emission + color,textColor.a*_AlphaScale);
			}
            ENDCG
        }
    }
}
