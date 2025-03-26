Shader "Custom/ToonWaterShader"
{
     Properties
    {
        _ShallowColor("Depth Color Shallow", Color) = (0.325, 0.807, 0.971, 0.725)
        _DeepColor("Depth Color Deep", Color) = (0.086, 0.407, 1, 0.749)
        _DepthMaxDistance("Depth Maximum Distance", float) = 1.0 

        _NoiseTex("Noise Texture", 2D) = "white"{}

        _SurfaceNoiseCutoff("Surface Noise Cutoff", Range(0, 1)) = 0.777
        _FoamDistance("Foam Distance", Range(0, 10)) = 0.777
        _Speed("Speed", float) = 5.0
        _Direction("Direction", Vector) = (0.5,0.5,0,0)
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

            fixed4 _ShallowColor;
            fixed4 _DeepColor;
            float _DepthMaxDistance;

            sampler2D _CameraDepthTexture;

            sampler2D _NoiseTex;
            float4 _NoiseTex_ST;

            float _SurfaceNoiseCutoff;
            float _FoamDistance;
            float _Speed;
            fixed4 _Direction;

            struct VertexInput
            {
                float4 vertex : POSITION;
                float4 uv : TEXCOORD0;
            };

            struct VertexOutput
            {
                float4 vertex : SV_POSITION;
                float4 screenPosition : TEXCOORD2;
                float2 noiseUV : TEXCOORD0;
            };

            VertexOutput vert (VertexInput v)
            {
                v.uv.xy += (_Time.x * _Direction) * _Speed;

                VertexOutput o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.screenPosition = ComputeScreenPos(o.vertex);
                o.noiseUV = TRANSFORM_TEX(v.uv, _NoiseTex);
                return o;
            }

            fixed4 frag (VertexOutput i) : SV_Target
            {
                float existingDepth01 = tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.screenPosition)).r;
                float existingDepthLinear = LinearEyeDepth(existingDepth01);

                float depthDifference = existingDepthLinear - i.screenPosition.w;

                float waterDepthDifference01 = saturate(depthDifference / _DepthMaxDistance);
                float4 waterColor = lerp(_ShallowColor, _DeepColor, waterDepthDifference01);

                float foamDepthDifference01 = saturate(depthDifference / _FoamDistance);
                float surfaceNoiseCutoff = foamDepthDifference01 * _SurfaceNoiseCutoff;

                float surfaceNoise = tex2D(_NoiseTex, i.noiseUV) > surfaceNoiseCutoff ? 1 : 0;
                return waterColor + surfaceNoise;
            }
            ENDCG
        }
    }
}
