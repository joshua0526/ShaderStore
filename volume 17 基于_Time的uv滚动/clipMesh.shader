// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Lizhan/clipMesh"
{
	Properties
	{
		_Color("Line Color", COLOR) = (1,1,1,1)
		_MainTex("Main Texture", 2D) = "white"{}
		_Thickness("Thickness", Range(0,100)) = 3
		_Width("Cull Width", Float) = 30
		_ScrollSpeed("Scroll Speed", Float) = 0.2
		_maxX("Max X", Float) = 0
		_minX("Min X", Float) = 0
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
				#pragma geometry geom
				#include "UnityCG.cginc"

				struct v2f
				{
					float2 uv : TEXCOORD0;
					float4 vertex : POSITION;					
				};

				struct g2f
				{
					float4 pos:POSITION;
					float2 uv:TEXCOORD0;
					float3 dist:TEXCOORD1;	
					float width:Float;
				};

				float4 _Color;
				float4 _MainTex_ST;
				sampler2D _MainTex;
				half _Thickness;
				half _Width;
				fixed _ScrollSpeed;
				float _maxX;
				float _minX;

				v2f vert(appdata_base v)
				{
					v2f o;
					o.vertex = mul(unity_ObjectToWorld, v.vertex);
					o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
					return o;
				}


				[maxvertexcount(3)]
				void geom(triangle v2f p[3], inout TriangleStream<g2f> triStream) {
					float4 vertex0 = mul(UNITY_MATRIX_VP, p[0].vertex);
					float4 vertex1 = mul(UNITY_MATRIX_VP, p[1].vertex);
					float4 vertex2 = mul(UNITY_MATRIX_VP, p[2].vertex);
					float2 p0 = _ScreenParams.xy * vertex0.xy / vertex0.w;
					float2 p1 = _ScreenParams.xy * vertex1.xy / vertex1.w;
					float2 p2 = _ScreenParams.xy * vertex2.xy / vertex2.w;

					float2 v0 = p2 - p1;
					float2 v1 = p2 - p0;
					float2 v2 = p1 - p0;
					//v1 v2形成的四边形的面积
					float area = abs(v1.x*v2.y - v1.y*v2.x);

					float dist0 = area / length(v0);
					float dist1 = area / length(v1);
					float dist2 = area / length(v2);

					g2f pIn;

					pIn.pos = vertex0;
					pIn.uv = p[0].uv;
					pIn.dist = float3(dist0, 0, 0);
					pIn.width = p[0].vertex.x;
					triStream.Append(pIn);

					pIn.pos = vertex1;
					pIn.uv = p[1].uv;
					pIn.dist = float3(0, dist1, 0);
					pIn.width = p[1].vertex.x;
					triStream.Append(pIn);

					pIn.pos = vertex2;
					pIn.uv = p[2].uv;
					pIn.dist = float3(0, 0, dist2);
					pIn.width = p[2].vertex.x;
					triStream.Append(pIn);
				}

				float4 frag(g2f i) : COLOR
				{
					float val = min(i.dist.x, min(i.dist.y, i.dist.z));
					val = exp2(-1 / _Thickness * val*val);

					i.width = i.width + fixed2(_ScrollSpeed * _Time.y, _ScrollSpeed * _Time.y);
	
					clip(i.width%(_maxX-_minX) - _maxX + _minX + _Width);
					

					float4 targetColor = _Color * tex2D(_MainTex, i.uv);
					float4 transCol = _Color * tex2D(_MainTex, i.uv);
					transCol.a = 0;
					float4 uvcolor = val * targetColor + (1 - val)*transCol;
					
					return uvcolor;
				}
				ENDCG
			}
    }
}
