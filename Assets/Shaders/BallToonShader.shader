Shader "Custom/BallToonShader"
{
    Properties
    {
        
        _Color("Second Color", Color) = (1, 0, 0, 1)

        [Header(Ball Effect)]
        [Space(10)]_FirstColor("Color", Color) = (1, 0, 0, 1)
        _SecondColor("Second Color", Color) = (1, 0, 0, 1)
        _LineWidth("LineWidth", float) = 0.2
        [IntRange]_LineAmount("LineAmount", Range (0, 15)) = 2  
        //_LineAmount("LineAmount", int) = 2

        [Header(Toon Effect)]
        [Space(10)]_Brightness("Brightness", Range(0, 1)) = 0.3
        _Strenght("Strenght", Range(0, 2)) = 0.5
        _Detail("Detail", Range(0, 1)) = 0.3

        [Header(Outline)]
        [Space(10)]_Outline("Width", Range(0, 0.5)) = 0.02
        _OutlineColor("OutlineColor", Color) = (0, 0, 1, 1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
         
            fixed4 _Color;

            fixed4 _FirstColor;
            fixed4 _SecondColor;
            float _LineWidth;
            int _LineAmount;

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _Brightness;
            float _Strenght;
            float _Detail;

            float Toon(float3 normal, float3 lightDirection)
            {
                float normalDotLight = max(0.0,dot(normalize(normal), normalize(lightDirection)));
                return floor(normalDotLight / _Detail);
            }

            float4 drawLine(float2 uv, float amount, float witdh)
            {
                if(uv.x % (1.0/amount) > 0 && uv.x % (1.0/amount) < witdh )
                {
                    return _FirstColor;
                }
                return _SecondColor;
            };

            struct VertexInput
            {
                float4 vertex : POSITION;
                float4 uv : TEXCOORD0;
                float3 normal: NORMAL;
            };

            struct VertexOutput
            {
                float4 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldNormal : NORLMAL;
            };

            VertexOutput vert (VertexInput v)
            {
                VertexOutput o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = v.uv.xy;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag (VertexOutput i) : SV_Target
            {
                fixed4 col = drawLine(i.uv, _LineAmount, _LineWidth);
                col *= Toon(i.worldNormal, _WorldSpaceLightPos0.xyz) * _Color * _Strenght + _Brightness;
                return col;
            }
            ENDCG
        }
        Pass
        {
            Cull front
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            float _Outline;
            fixed4 _OutlineColor;

            struct VertexInput
            {
                float4 vertex : POSITION;
            };

            struct VertexOutput
            {
                float4 vertex : SV_POSITION;
            };

            VertexOutput vert (VertexInput v)
            {
                VertexOutput o;
                v.vertex = v.vertex * (1 + _Outline);
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (VertexOutput i) : SV_Target
            {
                return _OutlineColor;
            }
            ENDCG
        }
    }
}
