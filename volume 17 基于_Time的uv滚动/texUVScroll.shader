Shader "Lizhan/texUVScroll"
{
	Properties
	{
		_Color("Line Color", COLOR) = (1,1,1,1)
		_MainTex("Main Texture", 2D) = "white"{}
		_Thickness("Thickness", Range(0,100)) = 3
		_Width("Cull Width", Range(0,1)) = 0.1
		_ScrollSpeed("Scroll Speed", Range(0,10)) = 0.2
	}
		SubShader
		{
			Tags { "RenderType" = "Opaque" }
			LOD 100

			Pass
			{
				Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }

				Blend SrcAlpha OneMinusSrcAlpha
				ZWrite Off
				Cull Off
				LOD 200
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#include "UnityCG.cginc"

				struct v2f
				{
					float2 uv : TEXCOORD0;
					float4 vertex : POSITION;
				};

				float4 _Color;
				float4 _MainTex_ST;
				sampler2D _MainTex;
				half _Thickness;
				half _Width;
				fixed _ScrollSpeed;

				v2f vert(appdata_base v)
				{
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
					return o;
				}				

				float4 frag(v2f i) : COLOR
				{
					fixed scrollValue = fixed2(_ScrollSpeed * _Time.y, _ScrollSpeed * _Time.y);
					float2 scrollUV = i.uv + scrollValue;
					scrollUV = frac(scrollUV);
					float4 targetColor = _Color * tex2D(_MainTex, scrollUV);
					if (scrollUV.x > _Width) {
						targetColor.a = 0;
					}
					return targetColor;
				}
				ENDCG
			}
		}
}
