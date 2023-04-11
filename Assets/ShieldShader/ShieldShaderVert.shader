// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Hidden/ShieldShaderVert"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _CameraDepthNormalsTexture("Camera Depth Texture", 2D) = "white"{}
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

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
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };
            sampler2D _MainTex;
            sampler2D _CameraDepthNormalsTexture;
            float4 _MainTex_ST
            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv = ((o.vertex.xy/o.vertex.w)+1)/2;
                o.uv.y = o.uv.y;
                o.uv.y = -mul(UNITY_MATRIX_MV, v.vertex).z*_ProjectionParams.w;
                
                o.uv = v.uv;
                return o;
            }

           

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                float screenDepth = DecodeFloatRG(tex2D(_CameraDepthNormalsTexture,i.uv ).zw);
                float diff = screenDepth-i.uv;
                float intersect = 0;

                if (diff>0)
                    intersect =1-smoothstep(0,_ProjectionParams.w*0.5f,diff);

                col = col *col.a + intersect;
                fixed4 niceColor = fixed4(lerp(col.rgb,fixed3(1,1,1), pow(intersect,4)),1);
                // just invert the colors
                //col.rgb = 1 - col.rgb;
                return niceColor;
            }
            ENDCG
        }
    }
}
