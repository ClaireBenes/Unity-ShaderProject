Shader "Custom/WaterShader"
{
    Properties
    {
        _Color("Color", Color) = (1, 0, 0, 1)
        _SecondColor("Second Color", Color) = (1, 0, 0, 1)
        _MainTex("Main Texture", 2D) = "white"{}
        _Displacement("Displacement", float) = 0.5

        _Speed("Speed", float) = 5.0
        _Frequency("Frequency", float) = 0.5        
        _Amplitude("Amplitude", float) = 2.0
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

            float _Displacement;
            float _Speed;
            float _Frequency;
            float _Amplitude;

            float4 vertexAnimWave(float4 pos, float2 uv)
            {
               pos.y = pos.y + sin((uv.x - _Time.y * _Speed) * _Frequency) * _Amplitude;
               return pos;
            }

            struct VertexInput
            {
                float4 vertex : POSITION;
                float4 texcoord: TEXCOORD0;
                float4 normal: NORMAL;
                float displacement: COLOR;
            };

            struct VertexOutput
            {
                float4 vertex : SV_POSITION;
                float4 texcoord: TEXCOORD0;
                float displacement: COLOR; 
            };

            VertexOutput vert (VertexInput v)
            {
                VertexOutput o;        
                o.displacement = tex2Dlod(_MainTex, v.texcoord * _MainTex_ST) * sin((v.texcoord - _Time.y * _Speed) * _Frequency) * _Amplitude;
                v.vertex = vertexAnimWave(v.vertex + (v.normal * o.displacement * _Displacement) ,v.texcoord.xy ); 
                //v.vertex = vertexAnimWave(v.vertex ,v.texcoord.xy );

                o.vertex = UnityObjectToClipPos(v.vertex + (v.normal * o.displacement * _Displacement));
                o.texcoord.xy = (v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw);
                return o;
            }

            fixed4 frag (VertexOutput i) : SV_Target
            {
                float4 color = tex2D(_MainTex, i.texcoord) * _Color;

                // if(i.displacement > 0)
                // {
                //     color = tex2D(_MainTex, i.texcoord) * -i.vertex.y / 200;
                // }
                
                return _Color * (1 - i.displacement ) + _SecondColor * i.displacement;
            }
            ENDCG
        }
    }
}
