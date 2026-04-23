Shader "Custom/PerlinNoiseWater"
{
    Properties
    {
        _StartColor("Start Color", Color) = (0, 0, 0, 0)
        _EndColor("End Color", Color) = (1, 1, 1, 1)
        _Amplitude("Noise Amplitude", Float) = 1.0
        _Scale("Noise Scale", Float) = 2.0
        _Speed("Animation Speed", Float) = 1.0
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" }

        Pass
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float2 objectOS : TEXCOORD1;
            };

            fixed4 _StartColor, _EndColor;
            float _Scale, _Speed, _Amplitude;
            
            float3 hash33(float3 p)
            {
                p = float3(dot(p, float3(127.1, 311.7, 74.7)),
                           dot(p, float3(269.5, 183.3, 246.1)),
                           dot(p, float3(113.5, 271.9, 124.6)));
                return -1.0 + 2.0 * frac(sin(p) * 43758.5453123);
            }

            float perlinNoise3D(float3 p)
            {
                float3 pi = floor(p);
                float3 pf = frac(p);
                float3 w = pf * pf * (3.0 - 2.0 * pf);
                
                float n000 = dot(hash33(pi + float3(0.0, 0.0, 0.0)), pf - float3(0.0, 0.0, 0.0));
                float n100 = dot(hash33(pi + float3(1.0, 0.0, 0.0)), pf - float3(1.0, 0.0, 0.0));
                float n010 = dot(hash33(pi + float3(0.0, 1.0, 0.0)), pf - float3(0.0, 1.0, 0.0));
                float n110 = dot(hash33(pi + float3(1.0, 1.0, 0.0)), pf - float3(1.0, 1.0, 0.0));
                float n001 = dot(hash33(pi + float3(0.0, 0.0, 1.0)), pf - float3(0.0, 0.0, 1.0));
                float n101 = dot(hash33(pi + float3(1.0, 0.0, 1.0)), pf - float3(1.0, 0.0, 1.0));
                float n011 = dot(hash33(pi + float3(0.0, 1.0, 1.0)), pf - float3(0.0, 1.0, 1.0));
                float n111 = dot(hash33(pi + float3(1.0, 1.0, 1.0)), pf - float3(1.0, 1.0, 1.0));
                
                // Nội suy tuyến tính (Lerp) theo trục X
                float nx00 = lerp(n000, n100, w.x);
                float nx10 = lerp(n010, n110, w.x);
                float nx01 = lerp(n001, n101, w.x);
                float nx11 = lerp(n011, n111, w.x);
                
                float nxy0 = lerp(nx00, nx10, w.y);
                float nxy1 = lerp(nx01, nx11, w.y);

                return lerp(nxy0, nxy1, w.z);
            }

            v2f vert(appdata IN)
            {
                v2f OUT;
                float3 noiseUV = float3(IN.vertex.x * _Scale, IN.vertex.z * _Scale, _Time.y * _Speed);
                
                float finalHeight = perlinNoise3D(noiseUV) * _Amplitude;
                IN.vertex.y += finalHeight;

                float normalizedHeight = (finalHeight + _Amplitude) / (2.0 * _Amplitude);
                
                OUT.uv = IN.uv;
                OUT.objectOS.y = saturate(normalizedHeight);
                OUT.pos = UnityObjectToClipPos(IN.vertex);
                
                return OUT;
            }

            fixed4 frag(v2f IN) : SV_Target
            {
                float f = IN.objectOS.y;
                fixed4 color = lerp(_StartColor, _EndColor, f);
                return color;
            }
            ENDCG
        }
    }
}