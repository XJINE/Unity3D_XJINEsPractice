Shader "Unlit/Cloud"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        _Threshold       ("Cloud Threshold",  Range(0, 1)) = 0.6
        _Gain            ("Cloud Gain",       Float)       = 1
        _MoveSpeed       ("Cloud Move Speed", Float)       = 0.1
        _TransitionSpeed ("Transition Speed", Float)       = 0.1
    }

    SubShader
    {
        Tags
        {
           "Queue"      = "Transparent"
           "RenderType" = "Transparent"
        }

        Blend SrcAlpha OneMinusSrcAlpha
        LOD  100
        CULL Off

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

            float _Threshold;
            float _Gain;
            float _MoveSpeed;
            float _TransitionSpeed;

            float4 simplexNoiseValue(float2 coordinate)
            {
                const float epsilon = 0.0001;
                float2 uv = coordinate * 4.0 + float2(_Time.y, 0.2) * _MoveSpeed;
                float o = 0.5;
                float s = 1.0;
                float w = 0.25;

                for (int i = 0; i < 6; i++)
                {
                    float3 coord = float3(uv * s, _Time.y * _TransitionSpeed);
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

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv     = TRANSFORM_TEX(v.uv, _MainTex);

                return o;
            }

            fixed4 frag (v2f input) : SV_Target
            {
                float noiseValue = simplexNoiseValue(input.uv);

                if (noiseValue < _Threshold) 
                {
                    discard;
                }

                float4 color = float4(noiseValue,
                                      noiseValue,
                                      noiseValue,
                                      smoothstep(_Threshold, 1, noiseValue) * _Gain);

                return color;
            }

            ENDCG
        }
    }
}