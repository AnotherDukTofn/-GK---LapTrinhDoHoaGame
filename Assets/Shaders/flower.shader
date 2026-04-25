Shader "Custom/flower"
{
    Properties
    {
        _MainTex ("Texture Palette", 2D) = "white" {}
        _WindSpeed ("Wind Speed", Float) = 2.0
        _WindStrength ("Wind Strength", Float) = 0.1
        _PlantHeight ("Estimated Plant Height", Float) = 0.5 // Chiều cao ước tính để tính toán độ nghiêng
        _Cutoff ("Alpha Cutoff", Range(0,1)) = 0.5 // Dùng cho độ trong suốt của hoa
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Transparent+1" } 
        Cull Off // Vẫn giữ 2 mặt
        Lighting Off // Tắt đèn để giữ màu gốc chuẩn xác nhất

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog // Hỗ trợ sương mù
            
            // Cần thiết để nhận diện màu vẽ từ Terrain Detail
            #pragma multi_compile_instancing 

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 color : COLOR; // Nhận màu từ hệ thống Detail
                UNITY_VERTEX_INPUT_INSTANCE_ID // Cần cho instancing
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float4 color : COLOR;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _WindSpeed;
            float _WindStrength;
            float _PlantHeight;
            fixed _Cutoff;

            v2f vert (appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                
                // Giữ lại màu tô của Terrain
                o.color = v.color; 

                // --- Thuật toán nghiêng thân, giữ nguyên cấu trúc hoa ---
                // Lấy tọa độ thế giới của gốc hoa
                float4 worldPos = mul(unity_ObjectToWorld, float4(0,0,0,1)); 

                // Tính toán góc gió
                float windAngle = sin(_Time.y * _WindSpeed + worldPos.x + worldPos.z) * _WindStrength;

                // Tạo ma trận xoay (nghiêng thân xoay xung quanh gốc)
                float cosAngle = cos(windAngle);
                float sinAngle = sin(windAngle);
                
                // Ma trận xoay đơn giản quanh gốc (0,0,0) trong không gian local
                float3 localPos = v.vertex.xyz;
                float3 rotatedPos = localPos;

                // Chỉ nghiêng phần hoa trên mặt đất (y > 0.01) để gốc không bị nhổ lên
                if (v.vertex.y > 0.01) {
                    float y = localPos.y;
                    float z = localPos.z;
                    // Xoay quanh gốc, giữ form cứng
                    rotatedPos.y = y * cosAngle - z * sinAngle;
                    rotatedPos.z = y * sinAngle + z * cosAngle;
                }

                o.vertex = UnityObjectToClipPos(float4(rotatedPos, 1.0));
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // Lấy màu từ ảnh bảng màu
                fixed4 col = tex2D(_MainTex, i.uv);
                
                // NHÂN VỚI MÀU GỐC: Đảm bảo giữ đúng màu hoa vẽ
                col *= i.color;

                // Xử lý độ trong suốt (Alpha Clipping)
                clip(col.a - _Cutoff);

                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}