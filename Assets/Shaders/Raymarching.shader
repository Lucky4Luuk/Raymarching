Shader "Hidden/Custom/Raymarching"
{
    HLSLINCLUDE

        #include "Packages/com.unity.postprocessing/PostProcessing/Shaders/StdLib.hlsl"
        #include "Assets/Shaders/RtLib.hlsl"

        #define UNITY_MATRIX_MVP mul(unity_MatrixVP, unity_ObjectToWorld)

        TEXTURE2D_SAMPLER2D(_MainTex, sampler_MainTex);
        TEXTURE2D_SAMPLER2D(_CameraDepthTexture, sampler_CameraDepthTexture);

        float4 _CameraPosition;
        float4x4 _ViewProjectInverse;

        struct v2f {
            float4 vertex : SV_POSITION;
            float3 worldPos : TEXCOORD0;
            float2 texcoord : TEXCOORD1;
            float2 texcoordStereo : TEXCOORD2;
        };

        struct appdata {
            float4 vertex : POSITION;
        };

        v2f Vert(appdata v) {
            v2f o;

            o.worldPos = mul (transpose(UNITY_MATRIX_MVP), v.vertex);
            o.vertex = float4(v.vertex.xy, 0.0, 1.0);
            o.texcoord = TransformTriangleVertexToUV(v.vertex.xy);

            #if UNITY_UV_STARTS_AT_TOP
                o.texcoord = o.texcoord * float2(1.0, -1.0) + float2(0.0, 1.0);
            #endif

            o.texcoordStereo = TransformStereoScreenSpaceTex(o.texcoord, 1.0);
            return o;
        }

        float4 Frag(v2f i) : SV_Target
        {
            float3 ro = _CameraPosition.xyz;
            float3 rd = normalize(i.worldPos);
            float4 color = float4(rd, 1.0);
            // float4 color = float4(i.worldPos, 1.0);
            // float4 color = SAMPLE_TEXTURE2D(_CameraDepthTexture, sampler_CameraDepthTexture, i.texcoord);
            // float depth = SAMPLE_TEXTURE2D(_CameraDepthTexture, sampler_CameraDepthTexture, i.texcoord).a;
            // depth = LinearEyeDepth(depth);
            // float4 color = float4(depth, depth, depth, 1.0);
            // float4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord);
            // color = test(color);
            return color;
        }

    ENDHLSL

    SubShader
    {
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            HLSLPROGRAM

                #pragma vertex Vert
                #pragma fragment Frag

            ENDHLSL
        }
    }
}
