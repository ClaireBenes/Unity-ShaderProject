Shader "Custom/BallShader"
{
    Properties
    {
        _Color("Color", Color) = (1, 0, 0, 1)
        _SecondColor("Second Color", Color) = (1, 0, 0, 1)
        _Width("Width", float) = 0.2
        _Amount("LineAmount", int) = 2
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
            float _Width;
            int _Amount;

            float4 drawLine(float2 uv, float amount, float witdh)
            {
                if(uv.x % (1.0/amount) > 0 && uv.x % (1.0/amount) < witdh )
                {
                    return _Color;
                }
                return _SecondColor;
            };

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
                o.texcoord.xy = (v.texcoord.xy);
                return o;
            }

            fixed4 frag (VertexOutput i) : SV_Target
            {
                float4 color = drawLine(i.texcoord, _Amount, _Width);

                return color;
            }
            ENDCG
        }
    }
}
