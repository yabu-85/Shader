//───────────────────────────────────────
// テクスチャ＆サンプラーデータのグローバル変数定義
//───────────────────────────────────────
Texture2D	g_texture : register(t0);		//テクスチャー
SamplerState	g_sampler : register(s0);	//サンプラー

//───────────────────────────────────────
// コンスタントバッファ
// DirectX 側から送信されてくる、ポリゴン頂点以外の諸情報の定義
//───────────────────────────────────────
cbuffer global
{
	float4x4	g_matWVP;			// ワールド・ビュー・プロジェクションの合成行列
	float4x4	g_matW;				// ワールド行列
	float4x4	g_matNormal;		// 
	float4		g_diffuseColor;		// ディフューズカラー（マテリアルの色）
	float4		g_lightPosition;	// ライトの向き
	float4		g_eyePosition;		// カメラの向き
	bool		g_isTexture;		// テクスチャ貼ってあるかどうか
};

//───────────────────────────────────────
// 頂点シェーダー出力＆ピクセルシェーダー入力データ構造体
//───────────────────────────────────────
struct VS_OUT
{
	float4 pos    : SV_POSITION;	//位置
	float4 normal : TEXCOORD0;			//法線
	float4 eye	  : TEXCOORD1;		//視線
	float2 uv	  : TEXCOORD2;		//uv座標
};

//───────────────────────────────────────
// 頂点シェーダ
//───────────────────────────────────────
VS_OUT VS(float4 pos : POSITION, float4 uv : TEXCOORD, float4 normal : NORMAL)
{
	//ピクセルシェーダーへ渡す情報
	VS_OUT outData;

	//ローカル座標に、ワールド・ビュー・プロジェクション行列をかけて
	//スクリーン座標に変換し、ピクセルシェーダーへ
	outData.pos = mul(pos, g_matWVP);
	outData.uv = uv;

	//法線を回転
	normal.w = 0;
	normal = mul(normal, g_matNormal);
	outData.normal = normal;

	//視線ベクトル（ハイライトの計算に必要
	float4 worldPos = mul(pos, g_matW);					//ローカル座標にワールド行列をかけてワールド座標へ
	outData.eye = normalize(g_eyePosition - worldPos);	//視点から頂点位置を引き算し視線を求めてピクセルシェーダーへ

	//まとめて出力
	return outData;
}

//───────────────────────────────────────
// ピクセルシェーダ
//───────────────────────────────────────
float4 PS(VS_OUT inData) : SV_Target
{
	float4 lightSource = float4(1.0f, 1.0f, 1.0f, 1.0f);
	float4 ambientSource = float4(0.2f, 0.2f, 0.2f, 1.0f);

	float4 light = g_lightPosition;
	light = normalize(light);
	light = clamp(dot(inData.normal, light), 0, 1);

	float4 diffuse;
	float4 ambient;
	if (g_isTexture == false)
	{
		diffuse = lightSource * g_diffuseColor * light;
		ambient = lightSource * g_diffuseColor * ambientSource;
	}
	else
	{
		diffuse = lightSource * g_texture.Sample(g_sampler, inData.uv) * light;
		ambient = lightSource * g_texture.Sample(g_sampler, inData.uv) * ambientSource;
	}

	//鏡面反射光（スペキュラー）
	float shuniness = 8.0;										//スペキュラーの強さトリマ係数
	float4 speculerColor = float4(1.0, 1.0, 1.0, 1.0);			//スペキュラーの色これも係数
	float4 lightDir = normalize(g_lightPosition);
	inData.normal = normalize(inData.normal);

	float nR = 2.0f * inData.normal * dot(inData.normal, lightDir) - lightDir;
	float nI = pow(saturate(dot(nR, inData.eye)), shuniness) * speculerColor;
	nR = reflect(lightDir, inData.normal);
	nI = pow(saturate(dot(nR, inData.eye)), shuniness) * speculerColor;
	if(nI < 0) nI = 0.0f;

	return (diffuse + ambient + nI);
}