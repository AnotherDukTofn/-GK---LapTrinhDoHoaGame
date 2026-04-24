Shader "CustomRenderTexture/grass 1"
{
    Properties
    {
        _MainTex ("Texture Bảng Màu", 2D) = "white" {}
        _WindSpeed ("Tốc độ gió", Float) = 1.5
        _WindStrength ("Độ cong ngọn cỏ", Float) = 0.15
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Cull Off // Tắt culling để thấy cả mặt sau của lá cỏ

        CGPROGRAM
        // Khai báo Surface Shader: Dùng ánh sáng chuẩn (Standard), cho phép tạo gió (vertex:vert) 
        // và QUAN TRỌNG NHẤT: ép tạo bóng đổ đung đưa theo cỏ (addshadow)
        #pragma surface surf Standard vertex:vert addshadow
        #pragma target 3.0

        sampler2D _MainTex;
        float _WindSpeed;
        float _WindStrength;

        struct Input
        {
            float2 uv_MainTex;
        };

        // 1. HÀM VERTEX: Xử lý gió đung đưa
        void vert (inout appdata_full v)
        {
            // Lấy tọa độ thế giới
            float4 worldPos = mul(unity_ObjectToWorld, v.vertex);

            // Thuật toán gió mượt
            float wave1 = sin(_Time.y * _WindSpeed + worldPos.x * 0.5 + worldPos.z * 0.5);
            float wave2 = cos(_Time.y * (_WindSpeed * 1.3) + worldPos.x * 1.2);
            float wind = (wave1 * 0.7 + wave2 * 0.3) * _WindStrength;

            // Lắc lư trục X và Z, giữ chặt gốc
            v.vertex.x += wind * v.vertex.y;
            v.vertex.z += (wind * 0.5) * v.vertex.y;
        }

        // 2. HÀM SURF: Xử lý màu sắc và ánh sáng
        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Lấy đúng màu chính xác từ tấm ảnh Texture_01
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
            
            o.Albedo = c.rgb; // Áp màu vào bề mặt
            
            // Giảm độ nhẵn bóng về 0 để cỏ trông chân thực, không bị bóng loáng như nhựa
            o.Smoothness = 0.0; 
            o.Alpha = c.a;
        }
        ENDCG
    }
    
    // Fallback giúp dự phòng khi máy yếu, đảm bảo bóng đổ luôn hoạt động
    FallBack "Diffuse" 
}
