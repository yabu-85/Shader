//───────────────────────────────────────
// テクスチャ＆サンプラーデータのグローバル変数定義
//───────────────────────────────────────
Texture2D	g_texture : register(t0);		//テクスチャー
SamplerState	g_sampler : register(s0);	//サンプラー

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
	float2 uv	  : TEXCOORD2;		//uv座標
	float4 color  : COLOR;			//色（明るさ）
	float4 eye	  : TEXCOORD1;		//視線
	float4 normal : TEXCOORD0;		//法線
};

//───────────────────────────────────────
// 頂点シェーダ
//───────────────────────────────────────
VS_OUT VS(float4 pos : POSITION, float4 uv : TEXCOORD, float4 normal : NORMAL)
{
	//ピクセルシェーダーへ渡す情報
	VS_OUT outData;

	//法線を回転
	normal.w = 0;
	normal = mul(normal, g_matNormal);
	normal = normalize(normal);
	outData.normal = normal;

	//ローカル座標に、ワールド・ビュー・プロジェクション行列をかけて
	//スクリーン座標に変換し、ピクセルシェーダーへ
	pos = pos + normal * 0.1;
	outData.pos = mul(pos, g_matWVP);

	//まとめて出力
	return outData;
}

//───────────────────────────────────────
// ピクセルシェーダ
//───────────────────────────────────────
float4 PS(VS_OUT inData) : SV_Target
{
	return float4(0,0,0,0);
}