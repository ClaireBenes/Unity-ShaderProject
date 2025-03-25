Shader "Custom/GradientShader"
{
    Properties
    {
        _Color("Color", Color) = (1, 0, 0, 1)
        _MainTex("Main Texture", 2D) = "white"{}
        _SecondColor("Second Color", Color) = (1, 0, 0, 1)
        _SecondTex("Second Texture", 2D) = "white"{}
    }
    SubShader
    {
        Tags{
        "Queue" = "Transparent"
        "RenderType" = "Transparent"
        "IgnoreProjector" = "True"
        }
        LOD 100
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            fixed4 _Color;
            uniform sampler2D _MainTex;
            uniform float4 _MainTex_ST;

            fixed4 _SecondColor;
            uniform sampler2D _SecondTex;
            uniform float4 _SecondTex_ST;

            struct VertexInput
            {
                float4 vertex : POSITION;
                float4 texcoord: TEXCOORD0;
            };

            struct VertexOutput
            {
                float4 vertex : SV_POSITION;
                float4 texcoord: TEXCOORD0;
            };

            VertexOutput vert (VertexInput v)
            {
                VertexOutput o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.texcoord.xy = (v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw);
                return o;
            }

            fixed4 frag (VertexOutput i) : SV_Target
            {
                float4 color = tex2D(_MainTex, i.texcoord) * _Color;
                color.a = tex2D(_SecondTex, i.texcoord) * _SecondColor * i.texcoord;
                return color;
            }
            ENDCG
        }
    }
}
