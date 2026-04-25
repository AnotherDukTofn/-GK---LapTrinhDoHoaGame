Shader "Custom/tree 1"
{
    Properties
    {
        _MainTex ("Texture Bảng Màu", 2D) = "white" {}
        // Thêm cái kéo cắt viền:
        _Cutoff ("Độ cắt viền trong suốt", Range(0,1)) = 0.5 
        
        [Header(Main Tree Sway)] 
        _WindSpeed ("Tốc độ gió chậm", Float) = 1.0 
        _WindStrength ("Độ nghiêng tán cây", Float) = 0.05
        
        [Header(Leaf Strand Flutter)] 
        _FlutterSpeed ("Tốc độ nhấp nhô lá", Float) = 2.5
        _FlutterStrength ("Độ nhấp nhô của lá liễu", Float) = 0.1
        
        [Header(Rigidity Control)] 
        _TrunkRigidity ("Độ cứng thân cây (pow)", Float) = 3.0 
        _ExpectedHeight ("Chiều cao cây (để mask)", Float) = 10.0 
    }
    SubShader
    {
        // Đổi từ Opaque sang TransparentCutout
        Tags { "RenderType"="TransparentCutout" "Queue"="AlphaTest" }
        Cull Off 
        
        CGPROGRAM
        // BÍ QUYẾT: Thêm alphatest:_Cutoff để Shader tự động cắt gọt phần bìa xám
        #pragma surface surf Standard vertex:vert addshadow alphatest:_Cutoff
        #pragma target 3.0

        sampler2D _MainTex;
        float _WindSpeed;
        float _WindStrength;
        float _FlutterSpeed;
        float _FlutterStrength;
        float _TrunkRigidity;
        float _ExpectedHeight;

        struct Input
        {
            float2 uv_MainTex;
        };

        void vert (inout appdata_full v)
        {
            float4 worldPos = mul(unity_ObjectToWorld, v.vertex);

            float normalizedHeight = saturate(v.vertex.y / _ExpectedHeight);
            float moveMask = pow(normalizedHeight, _TrunkRigidity);

            float baseWave = sin(_Time.y * _WindSpeed + worldPos.x + worldPos.z);
            float flutterWave = (sin(_Time.y * _FlutterSpeed + v.vertex.x * 2.0) +
                                  cos(_Time.y * (_FlutterSpeed * 0.8) + v.vertex.z * 3.0)) * 0.5;

            float finalWind = (baseWave * _WindStrength + flutterWave * _FlutterStrength);

            v.vertex.x += finalWind * moveMask;
            v.vertex.z += (finalWind * 0.7) * moveMask; 
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
            o.Albedo = c.rgb;
            o.Smoothness = 0.0; 
            
            // Ép Shader phải đọc kênh Alpha từ tấm ảnh để biết chỗ nào cần tàng hình
            o.Alpha = c.a; 
        }
        ENDCG
    }
    // Fallback cũng phải đổi để đổ bóng không bị thành hình vuông
    FallBack "Transparent/Cutout/VertexLit" 
}