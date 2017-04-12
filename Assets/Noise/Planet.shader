Shader "Hidden/Planet"
{
    Properties
    {
        _MainTex   ("Texture",     2D)    = "white" {}

        _NoisePower("Noise Power", Float) = 1
        _Color1    ("Color 1",     Color) = (1, 0, 0, 1)
        _Color2    ("Color 2",     Color) = (1, 1, 0, 1)
        _Color3    ("Color 3",     Color) = (0, 0, 0, 1)

        _Color1Threshold("Color 1 Threshold", Range(0, 1)) = 0.5
        _Color3Threshold("Color 2 Threshold", Range(0, 1)) = 0.7
    }

    SubShader
    {
        Tags
        {
           "RenderType" = "Opaque"
        }

        LOD 100

        Pass
        {
            CGPROGRAM

            #pragma target   4.0
            #pragma vertex   vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"
            #include "../Packages/NoiseShader/HLSL/SimplexNoise3D.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv     : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv     : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float  _NoisePower;

            float4 _Color1;
            float4 _Color2;
            float4 _Color3;

            float _Color1Threshold;
            float _Color3Threshold;
            
            float4 simplexNoiseValue(float2 coordinate)
            {
                const float epsilon = 0.0001;
                float2 uv = coordinate * 4.0 + float2(0.2, 1);
                float o = 0.5;
                float s = 1.0;
                float w = 0.25;

                for (int i = 0; i < 6; i++)
                {
                    float3 coord = float3(uv * s, 0);
                    float3 period = float3(s, s, 1.0) * 2.0;
                    o += snoise(coord) * w;
                    s *= 2.0;
                    w *= 0.5;
                }

                return float4(o, o, o, 1);
            }

            v2f vert (appdata v)
            {
                v2f o;

                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                float noiseValue = simplexNoiseValue(o.uv);
                
                o.vertex.xyz = v.vertex.xyz + (v.normal * noiseValue * _NoisePower);
                o.vertex = UnityObjectToClipPos(o.vertex);

                return o;
            }

            fixed4 frag (v2f input) : SV_Target
            {
                float noiseValue = simplexNoiseValue(input.uv);

                float4 color;

                if (noiseValue < _Color3Threshold) 
                {
                    color = _Color3;
                }
                else if (_Color1Threshold < noiseValue)
                {
                    float ratio = smoothstep(0.6, 1, noiseValue);
                          ratio *= 2; // _Color 1 の色を強くする。

                    color = _Color1 * ratio + _Color2 * (1 - ratio);
                }
                else 
                {
                    color = _Color2;
                }

                color *= noiseValue;

                return color;
            }

            ENDCG
        }
    }
}