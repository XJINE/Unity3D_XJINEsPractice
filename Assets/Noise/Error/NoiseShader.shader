// https://wgld.org/d/glsl/g007.html
// https://gist.github.com/patriciogonzalezvivo/670c22f3966e662d2f83

Shader "Hidden/NoiseShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }

    SubShader
    {
        Cull   Off
        ZWrite Off
        ZTest  Always

        Pass
        {
            CGPROGRAM

            #pragma vertex   vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D   _MainTex;
            const int   oct = 8;
            const float per = 0.5;
            const float PI  = 3.1415926;
            const float cCorners = 1.0 / 16.0;
            const float cSides   = 1.0 / 8.0;
            const float cCenter  = 1.0 / 4.0;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
                o.uv = v.uv;
                return o;
            }

            float getRandomValue(float2 coordinate, int seed)
            {
                return frac(sin(dot(coordinate.xy, float2(12.9898, 78.233)) + seed) * 43758.5453);
                //return frac(sin(dot(coordinate, float2(12.9898, 78.233))) * 43758.5453);
            }

            // 2 つの値を補間するときのある地点(0~1)での値。

            float interpolate(float value1, float value2, float ratio) 
            {
                float value2Ratio = (1.0 - cos(ratio * PI)) * 0.5;
                return value1 * (1.0 - value2Ratio) + value2 * value2Ratio;
            }

            float irnd(float2 p)
            {
                float2 i = floor(p);
                float2 f = frac(p);
                float4 v = float4(getRandomValue(float2(i.x,       i.y),       0),
                                  getRandomValue(float2(i.x + 1.0, i.y),       0),
                                  getRandomValue(float2(i.x,       i.y + 1.0), 0),
                                  getRandomValue(float2(i.x + 1.0, i.y + 1.0), 0));

                return interpolate(interpolate(v.x, v.y, f.x),
                                   interpolate(v.z, v.w, f.x),
                                   f.y);
            }

            float noise(float2 coordinate)
            {
                float t = 0.0;

                for (int i = 0; i < oct; i++) 
                {
                    float freq = pow(2.0, float(i));
                    float amp  = pow(per, float(oct - i));

                    t += irnd(float2(coordinate.x / freq,
                                     coordinate.y / freq)) * amp;
                }

                return t;
            }

            //float snoise(vec2 p, vec2 q, vec2 r) 
            //{
            //    return noise(float2(p.x,       p.y      )) *        q.x  *        q.y  +
            //           noise(float2(p.x,       p.y + r.y)) *        q.x  * (1.0 - q.y) +
            //           noise(float2(p.x + r.x, p.y      )) * (1.0 - q.x) *        q.y  +
            //           noise(float2(p.x + r.x, p.y + r.y)) * (1.0 - q.x) * (1.0 - q.y);
            //}

            fixed4 frag (v2f i) : SV_Target
            {
                float2 coordinate = i.uv;// +float2(_Time.y, _Time.y);
                float  noiseValue = noise(coordinate);

                return float4(noiseValue, noiseValue, noiseValue, 1);
            }

            ENDCG
        }
    }
}