Shader "Custom/HeightTexture"
{
    Properties
    {
        _HeightMap ("Height Map", 2D) = "white" {}
        _Height("Mountain Height", float) = 1

        _GrassTex("Grass Texture", 2D) = "white"{}
        _RockTex("Rock Texture", 2D) = "white"{}
        _SnowTex("Snow Texture", 2D) = "white"{}

        // Các biến mới để tùy chỉnh Bounds và độ hòa trộn
        _RockStart("Rock Start Height", Range(0, 1)) = 0.3
        _SnowStart("Snow Start Height", Range(0, 1)) = 0.7
        _BlendSharpness("Blend Sharpness", Range(1, 20)) = 5.0
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
            // make fog work
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
                float4 vertex : SV_POSITION;
                float h : TEXCOORD1;
                UNITY_FOG_COORDS(2)
            };

            sampler2D _HeightMap;   float4 _HeightMap_ST;
            sampler2D _GrassTex;    float4 _GrassTex_ST;
            sampler2D _RockTex;     float4 _RockTex_ST;
            sampler2D _SnowTex;     float4 _SnowTex_ST;
            float _Height;

            // Khai báo các biến tương ứng với Properties
            float _RockStart;
            float _SnowStart;
            float _BlendSharpness;

            v2f vert (appdata v)
            {
                v2f o;
                o.uv = TRANSFORM_TEX(v.uv, _HeightMap);
                
                fixed4 height = tex2Dlod(_HeightMap, float4(o.uv, 0, 0));
                
                float4 vert = v.vertex;
                vert.y += height.r * _Height;
                
                o.vertex = UnityObjectToClipPos(vert);
                o.h = height.r;

                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 colGrass = tex2D(_GrassTex, i.uv);
                fixed4 colRock  = tex2D(_RockTex, i.uv);
                fixed4 colSnow  = tex2D(_SnowTex, i.uv);

                // Sử dụng các biến tùy chỉnh thay cho số cứng
                float rockWeight = saturate((i.h - _RockStart) * _BlendSharpness);
                float snowWeight = saturate((i.h - _SnowStart) * _BlendSharpness);

                fixed4 finalCol = lerp(colGrass, colRock, rockWeight);
                finalCol = lerp(finalCol, colSnow, snowWeight);

                UNITY_APPLY_FOG(i.fogCoord, finalCol);
                return finalCol;
            }
            ENDCG
        }
    }
}