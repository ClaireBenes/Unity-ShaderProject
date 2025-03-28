Shader "Custom/BallToonShader"
{
    Properties
    {
        [Header(Ball Effect)]
        [Space(10)]_Color("Color", Color) = (1, 0, 0, 1)
        _SecondColor("Second Color", Color) = (1, 0, 0, 1)
        _Width("LineWidth", float) = 0.2
        [IntRange]_Amount("LineAmount", Range (0, 15)) = 2

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

            struct VertexInput
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal: NORMAL;
            };

            struct VertexOutput
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                half3 worldNormal : NORLMAL;
            };

            VertexOutput vert (VertexInput v)
            {
                VertexOutput o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag (VertexOutput i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
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
