Shader "Custom/UnlitShader"
{
    Properties
    {
        _Color("Color", Color) = (1, 0, 0, 1)
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
            uniform sampler2D _MainTex;

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
                o.texcoord.xy = v.texcoord;
                return o;
            }

            fixed4 frag (VertexOutput i) : SV_Target
            {
                return tex2D(_MainTex, i.texcoord) * _Color;
            }
            ENDCG
        }
    }
}
