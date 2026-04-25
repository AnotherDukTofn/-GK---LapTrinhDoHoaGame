Shader "CustomRenderTexture/tree"
{
    Properties
    {
        _Color ("Leaf Color", Color) = (0.1, 0.8, 0.2, 1)
        _MainTex("InputTex", 2D) = "white" {}
        _Speed ("Sway Speed", Range(0, 10)) = 2.0
        _Amount ("Sway Amount", Range(0, 0.1)) = 0.05
    }

    SubShader
    {
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            Name "tree"

            CGPROGRAM
            #include "UnityCustomRenderTexture.cginc"
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment frag
            #pragma target 3.0

            float4      _Color;
            sampler2D   _MainTex;
            float       _Speed;
            float       _Amount;

            // Hàm tạo hình tròn đơn giản để làm lá
            float circle(float2 uv, float2 center, float radius)
            {
                return smoothstep(radius, radius - 0.01, length(uv - center));
            }

            float4 frag(v2f_customrendertexture IN) : SV_Target
            {
                float2 uv = IN.localTexcoord.xy;
                
                // 1. Tạo hiệu ứng đung đưa (Swaying) dựa trên trục Y
                // Càng lên cao (uv.y lớn) thì đung đưa càng mạnh
                float sway = sin(_Time.y * _Speed + uv.y * 5.0) * _Amount * uv.y;
                uv.x += sway;

                // 2. Vẽ thân cây (Trunk)
                float trunk = smoothstep(0.02, 0.01, abs(uv.x - 0.5)) * step(uv.y, 0.5);
                float4 trunkColor = float4(0.4, 0.2, 0.1, 1) * trunk;

                // 3. Vẽ tán lá (Leaves) bằng cách kết hợp nhiều hình tròn
                // Chỉnh các vector float2 để thay đổi vị trí các chùm lá
                float leaves = 0;
                leaves += circle(uv, float2(0.5, 0.7), 0.2);   // Chóp cây
                leaves += circle(uv, float2(0.35, 0.55), 0.15); // Trái
                leaves += circle(uv, float2(0.65, 0.55), 0.15); // Phải
                
                float4 leafColor = _Color * leaves;

                // 4. Kết hợp kết quả
                float4 finalColor = leafColor;
                if (trunk > 0) finalColor = trunkColor;
                
                // Trộn với Texture đầu vào nếu có
                float4 tex = tex2D(_MainTex, uv);
                
                // Trả về màu cuối cùng (Alpha dựa trên hình dáng cây)
                return finalColor * tex;
            }
            ENDCG
        }
    }
}