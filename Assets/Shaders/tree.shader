Shader "Custom/tree"
{
    Properties
    {
        _MainTex ("Texture Bảng Màu", 2D) = "white" {}
        _WindSpeed ("Tốc độ gió", Float) = 1.0 
        _WindStrength ("Độ nghiêng của cây", Float) = 0.05
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Cull Off 

        CGPROGRAM
        #pragma surface surf Standard vertex:vert addshadow
        #pragma target 3.0

        sampler2D _MainTex;
        float _WindSpeed;
        float _WindStrength;

        struct Input
        {
            float2 uv_MainTex;
        };

        void vert (inout appdata_full v)
        {
            float4 worldPos = mul(unity_ObjectToWorld, v.vertex);

            // Tạo luồng gió hỗn loạn để cây đung đưa không bị rập khuôn như robot
            float wave1 = sin(_Time.y * _WindSpeed + worldPos.x * 0.5 + worldPos.z * 0.2);
            float wave2 = cos(_Time.y * (_WindSpeed * 0.8) + worldPos.z * 0.8);
            float wind = wave1 * 0.6 + wave2 * 0.4;

            // Lấy chiều cao của đỉnh cây (h), đảm bảo h > 0.1 để tránh lỗi chia cho 0
            float h = max(0.1, v.vertex.y);
            
            // Lực uốn ngang tỉ lệ với chiều cao
            float bend = h * _WindStrength;
            
            // Tính toán lực đẩy ra 2 trục X và Z
            float pushX = wind * bend;
            float pushZ = (wind * 0.5) * bend; // Trục Z nghiêng nhẹ hơn tạo độ xoay 3D

            // Tác động lực đẩy ngang
            v.vertex.x += pushX;
            v.vertex.z += pushZ;

            // BÍ QUYẾT: Rút trục Y chúi xuống dựa trên lực đẩy ngang (Mô phỏng cung tròn)
            // Thuật toán này giúp thân cây nghiêng xuống mà không bị giãn dài ra
            v.vertex.y -= (pushX * pushX + pushZ * pushZ) / h * 0.5;
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
            o.Albedo = c.rgb;
            o.Smoothness = 0.0; 
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}