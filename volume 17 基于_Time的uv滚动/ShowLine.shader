Shader "Lizhan/ShowLine"
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
        Tags { "RenderType"="Opaque" }
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
			};

            float4 _Color;
			float4 _MainTex_ST;
			sampler2D _MainTex;
			half _Thickness;
			half _Width;
			fixed _ScrollSpeed;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

			[maxvertexcount(3)]
			void geom(triangle v2f p[3], inout TriangleStream<g2f> triStream) {
				float2 p0 = _ScreenParams.xy * p[0].vertex.xy / p[0].vertex.w;
				float2 p1 = _ScreenParams.xy * p[1].vertex.xy / p[1].vertex.w;
				float2 p2 = _ScreenParams.xy * p[2].vertex.xy / p[2].vertex.w;

				float2 v0 = p2 - p1;
				float2 v1 = p2 - p0;
				float2 v2 = p1 - p0;
				//v1 v2形成的四边形的面积
				float area = abs(v1.x*v2.y - v1.y*v2.x);
				
				float dist0 = area / length(v0);
				float dist1 = area / length(v1);
				float dist2 = area / length(v2);

				g2f pIn;

				pIn.pos = p[0].vertex;
				pIn.uv = p[0].uv;
				pIn.dist = float3(dist0, 0, 0);
				triStream.Append(pIn);

				pIn.pos = p[1].vertex;
				pIn.uv = p[1].uv;
				pIn.dist = float3(0, dist1, 0);
				triStream.Append(pIn);

				pIn.pos = p[2].vertex;
				pIn.uv = p[2].uv;
				pIn.dist = float3(0, 0, dist2);
				triStream.Append(pIn);
			}

            float4 frag (g2f i) : COLOR
            {
				float val = min(i.dist.x, min(i.dist.y, i.dist.z));
				val = exp2(-1 / _Thickness * val*val);

				fixed scrollValue = fixed2(_ScrollSpeed * _Time.y, _ScrollSpeed * _Time.y);
				float2 scrollUV = i.uv + scrollValue;
				scrollUV = frac(scrollUV);
				float4 targetColor = _Color * tex2D(_MainTex, scrollUV);
				if (scrollUV.x > _Width) {
					targetColor.a = 0;
				}
				float4 transCol = _Color * tex2D(_MainTex, scrollUV);
				transCol.a = 0;
				return val * targetColor + (1-val)*transCol;
            }
            ENDCG
        }
    }
}
