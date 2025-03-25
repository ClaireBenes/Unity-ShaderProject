Shader "Custom/WaterShader"
{
    Properties
    {
        _Color("Color", Color) = (1, 0, 0, 1)
        _SecondColor("Second Color", Color) = (1, 0, 0, 1)
        _MainTex("Main Texture", 2D) = "white"{}
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
            fixed4 _SecondColor;
            uniform sampler2D _MainTex;
            uniform float4 _MainTex_ST;

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
                float4 color = tex2D(_MainTex, i.texcoord);
                return _Color * (1 - color.r) + _SecondColor * color.r ;
            }
            ENDCG
        }
    }
}
