Shader "Custom/ToonShader"
{
    Properties
    {
        _Color("Color", Color) = (1, 0, 0, 1)
        _MainTex ("Texture", 2D) = "white" {}
        _Brightness("Brightness", Range(0, 1)) = 0.3
        _Strenght("Strenght", Range(0, 2)) = 0.5
        _Detail("Detail", Range(0, 1)) = 0.3
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
    }
}
