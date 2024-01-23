//───────────────────────────────────────
// テクスチャ＆サンプラーデータのグローバル変数定義
//───────────────────────────────────────
Texture2D	g_texture : register(t0);		//テクスチャー
SamplerState	g_sampler : register(s0);	//サンプラー

Texture2D	g_normalTexture : register(t1);		//テクスチャー

//───────────────────────────────────────
// コンスタントバッファ
// DirectX 側から送信されてくる、ポリゴン頂点以外の諸情報の定義
//───────────────────────────────────────
cbuffer global : register(b0)
{
	float4x4	g_matWVP;			// ワールド・ビュー・プロジェクションの合成行列
	float4x4	g_matW;				// ワールド行列
	float4x4	g_matNormal;		// 
	float4		g_diffuseColor;		// ディフューズカラー（マテリアルの色）
	float4		g_ambientColor;		// 環境光の色
	float4		g_specular;			// 鏡面反射光の色
	float		g_shuniness;		// 鏡面反射光の強さ
	bool		g_isTexture;		// テクスチャ貼ってあるかどうか
	bool		g_isNormalmap;		// 
};

cbuffer light : register(b1)
{
	float4		g_lightPosition;	// ライトの向き
	float4		g_eyePosition;		// カメラの向き
};

//───────────────────────────────────────
// 頂点シェーダー出力＆ピクセルシェーダー入力データ構造体
//───────────────────────────────────────
struct VS_OUT
{
	float4 pos    : SV_POSITION;	//位置
	float2 uv	  : TEXCOORD;		//uv座標
	float4 eye	  : POSITION;		//視線
	float4 Neyev  : POSITION1;		//ノーマルマップ用の接空間に変換された視線ベクトル
	float4 normal : POSITION2;		//法線ベクトル
	float4 light  : POSITION3;		//ライトを接空間に変換したベクトル
	float4 color  : POSITION4;		//色（明るさ）
};

//───────────────────────────────────────
// 頂点シェーダ
//───────────────────────────────────────
VS_OUT VS(float4 pos : POSITION, float4 uv : TEXCOORD, float4 normal : NORMAL, float4 tangent : TANGENT)
{
	//ピクセルシェーダーへ渡す情報
	//（VS_OUT)0これですべて０で初期化されるらしい
	VS_OUT outData = (VS_OUT)0;

	//ローカル座標に、ワールド・ビュー・プロジェクション行列をかけて
	//スクリーン座標に変換し、ピクセルシェーダーへ
	outData.pos = mul(pos, g_matWVP);
	outData.uv = (float2)uv;

	//法線を回転
	normal.w = 0;
	normal = mul(normal, g_matNormal);
	normal = normalize(normal);
	normal.w = 0;
	outData.normal = normal;

	tangent.w = 0;
	tangent = mul(tangent, g_matNormal);
	tangent = normalize(tangent);	//接線ベクトルをローカル座標に変換したやつ

	float4 posw = mul(pos, g_matW);		//ローカル座標にワールド行列をかけてワールド座標へ
	outData.eye = g_eyePosition - posw;	//視点から頂点位置を引き算し視線を求めてピクセルシェーダーへ

	float3 no = { normal.x, normal.y, normal.z };
	float3 ta = { tangent.x, tangent.y, tangent.z };
	float3 binormal = cross(no, ta);
	binormal = mul(binormal, g_matNormal);
	binormal = normalize(binormal);

	outData.Neyev.x = dot(outData.eye, tangent);
	outData.Neyev.y = dot(outData.eye, binormal);
	outData.Neyev.z = dot(outData.eye, normal);
	outData.Neyev.w = 0;

	float4 light = normalize(g_lightPosition);
	light.w = 0.0f;
	light = normalize(light);

	outData.color = mul(normal, light); 
	outData.color.w = 0.0f;

	outData.light.x = dot(light, tangent); //接空間の光源ベクトル
	outData.light.y = dot(light, binormal);
	outData.light.z = dot(light, normal);
	outData.light.w = 0;

	//まとめて出力
	return outData;
}

//───────────────────────────────────────
// ピクセルシェーダ
//───────────────────────────────────────
float4 PS(VS_OUT inData) : SV_Target
{
	float4 lightSource = float4(1.0f, 1.0f, 1.0f, 1.0f);
	float4 diffuse;
	float4 ambient;

	if (g_isNormalmap)
	{
		//rgbの値を-1～1の範囲で取得する
		float4 tmpNormal = g_normalTexture.Sample(g_sampler, inData.uv) * 2.0f - 1.0f;
		tmpNormal.w = 0;
		tmpNormal = normalize(tmpNormal);

		float4 reflection = reflect(-inData.light, tmpNormal);
		float4 specular = pow(saturate(dot(reflection, normalize(inData.Neyev))), g_shuniness) * g_specular;

		float4 NL = clamp(dot(tmpNormal, inData.light), 0, 1);
		if (g_isTexture == true)
		{
			diffuse = g_texture.Sample(g_sampler, inData.uv) * NL;
			ambient = g_texture.Sample(g_sampler, inData.uv) * g_ambientColor;
		}
		else
		{
			diffuse = g_diffuseColor * NL;
			ambient = g_diffuseColor * g_ambientColor;
		}

		float4 result = diffuse + ambient + specular;
		return result;

	}
	else
	{
		float4 reflection = reflect(normalize(-g_lightPosition), inData.normal);
		float4 specular = pow(saturate(dot(reflection, normalize(inData.eye))), g_shuniness) * g_specular;
		
		if (g_isTexture == true)
		{
			diffuse = lightSource * g_texture.Sample(g_sampler, inData.uv) * inData.color;
			ambient = lightSource * g_texture.Sample(g_sampler, inData.uv) * g_ambientColor;
		}
		else
		{
			diffuse = lightSource * g_diffuseColor * inData.color;
			ambient = lightSource * g_diffuseColor * g_ambientColor;
		}
		
		float4 result = diffuse + ambient + specular;
		if (g_isTexture) result.a = inData.uv.x;
		return result;

	}
}