Shader "Hidden/CameraMask"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_BaseTex ("wallTexture", 2D) = "white" {}
		_Size("size", Float) = 1.0
		_Smooth("size", Float) = 1.0
		_CarveDepth("CarveDepth", Float) = 0
		_CarveSmooth("CarveSmooth", Float) = 0
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
 
            uniform sampler2D _CameraDepthTexture; //the depth texture
			uniform sampler2D _MainTex;
			uniform sampler2D _BaseTex;
			float4 _MainTex_TexelSize;
			float _Size;
			float _Smooth;
			float _CarveDepth;
			float _CarveSmooth;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

            struct v2f
            {
                float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
                float4 projPos : TEXCOORD1; //Screen position of pos
            };
 
            v2f vert(appdata v)
            {
                v2f o;
                o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
                o.projPos = ComputeScreenPos(o.pos);
				o.uv = v.uv;

                return o;
            }
 
            half4 frag(v2f i) : COLOR
            {
				/*
				//get the pixel on the color wall texture
				float4 colorwall = tex2D(_MainTex, i.uv);

				//get the pixel on the color base texture (invert the uv.y coordinate to get it right)
				float4 colorbase = tex2D(_BaseTex, float2(i.uv.x, 1 - i.uv.y));

				calculate the linear depth of the depth buffer 
				float depth = Linear01Depth(tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.projPos)).r);

				//add contrast to the depth texture, and move it to the right position
				depth = clamp(tanh((1 - depth) - 0.78)*pow(7, 2), 0, 1);

				//calculate a spherical texture centered on the screen's center
				fixed mask = clamp(
					tanh((
						sqrt((
							pow(
							(i.projPos.x - 0.5), 2) * _MainTex_TexelSize.z / _MainTex_TexelSize.w) + (
								pow(
								(i.projPos.y - 0.5), 2)))*_Size) - _Smooth), 0, 1);

				//apply screen mix on the mask with the depth values
				fixed finalalpha = 1 - (1 - mask)*(depth);

				*/

				//return a lerp over the wall texture and the base texture using the screen mask as factor
				//Minified equation
				return lerp(
					tex2D(_BaseTex, float2(i.uv.x, 1 - i.uv.y)), 
					tex2D(_MainTex, i.uv), 
					(1 - (1 - clamp(tanh((sqrt((pow((i.projPos.x - 0.5), 2) * _MainTex_TexelSize.z / _MainTex_TexelSize.w) + (pow((i.projPos.y - 0.5), 2)))*_Size) - _Smooth), 0, 1))*(clamp(tanh((1 - (Linear01Depth(tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.projPos)).r))) - _CarveDepth)*pow(_CarveSmooth, 2), 0, 1))));
            }
				ENDCG
		}
	}
}
