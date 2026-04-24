Shader "Unlit/ColorByHeight"
{
    Properties
    {
        _LowTex("Low Texture", 2D) = "white"{}
        _MidTex("Mid Texture", 2D) = "white"{}
        _HighTex("High Texture", 2D) = "white"{}
        _MidStart("Mid Start Height", float) = 1
        _HighStart("High Start Height", float) = 1.5
        _BlendSharpness("Blend Sharpness", float) = 5.0
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
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float height : TEXCOORD1;
                UNITY_FOG_COORDS(2)
                float4 vertex : SV_POSITION;
            };

            sampler2D _LowTex;      float4 _LowTex_ST;
            sampler2D _MidTex;      float4 _MidTex_ST;
            sampler2D _HighTex;     float4 _HighTex_ST;

            float _MidStart;
            float _HighStart;
            float _BlendSharpness;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                
                o.uv = TRANSFORM_TEX(v.uv, _LowTex); 
                o.height = v.vertex.y;

                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 colLow  = tex2D(_LowTex, i.uv);
                fixed4 colMid  = tex2D(_MidTex, i.uv);
                fixed4 colHigh = tex2D(_HighTex, i.uv);

                float midWeight = saturate((i.height - _MidStart) * _BlendSharpness);
                float highWeight = saturate((i.height - _HighStart) * _BlendSharpness);

                fixed4 finalCol = lerp(colLow, colMid, midWeight);
                finalCol = lerp(finalCol, colHigh, highWeight);

                UNITY_APPLY_FOG(i.fogCoord, finalCol);
                return finalCol;
            }
            ENDCG
        }
    }
}