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
	float4x4	matW;			//ワールド行列
};

//───────────────────────────────────────
// 頂点シェーダー出力＆ピクセルシェーダー入力データ構造体
//───────────────────────────────────────
struct VS_OUT
{
	float4 pos    : SV_POSITION;	//位置
	float2 uv	  : TEXCOORD;		//uv座標
};

//───────────────────────────────────────
// 頂点シェーダ
//───────────────────────────────────────
VS_OUT VS(float4 pos : POSITION, float4 uv : TEXCOORD)
{
	//ピクセルシェーダーへ渡す情報
	VS_OUT outData;

	//ローカル座標に、ワールド行列をかけて
	//ワールド座標に変換し、ピクセルシェーダーへ
	outData.pos = mul(pos, matW);
	outData.uv = uv;

	//まとめて出力
	return outData;
}

//───────────────────────────────────────
// ピクセルシェーダ
//───────────────────────────────────────
float4 PS(VS_OUT inData) : SV_Target
{
	float4 color = g_texture.Sample(g_sampler, inData.uv);

	//グレースケール
	//return dot(color.rgb, float3(0.298912f, 0.586611f, 0.114478f));

	//ポスタリゼーション
	//float kaityou = 5.0f;
	//return floor(g_texture.Sample(g_sampler, inData.uv) * kaityou) / kaityou;

	//平滑化
	float picSizeX = 1.0f / 800.0f;	//１ピクセルのサイズ
	float picSizeY = 1.0f / 600.0f;	//Yのサイズ
	int size = 3;					//平滑化するサイズ(奇数3以上
	float4 output = float4(0.0f, 0.0f, 0.0f, 0.0f);
	for (int x = -(size - 1) / 2; x <= (size - 1) / 2; x++) {
		for (int y = -(size - 1) / 2; y <= (size - 1) / 2; y++) {
			output += g_texture.Sample(g_sampler, float2(inData.uv.x + (x * picSizeX), inData.uv.y + (y * picSizeY)));
		}
	}
	output /= float(size * size);
	return output;


}