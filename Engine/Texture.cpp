#include "Direct3D.h"
#include "Texture.h"

#include <DirectXTex.h>

#pragma comment(lib, "DirectXTex.lib")

Texture::Texture()
	: pSampler_(nullptr), pSRV_(nullptr)
{
}

Texture::~Texture()
{
}

HRESULT Texture::Load(string fileName)
{
	using namespace DirectX;

	//画像読み込み部分
	wchar_t wtext[FILENAME_MAX];
	size_t ret;
	mbstowcs_s(&ret, wtext, fileName.c_str(), fileName.length());

	TexMetadata metadata;
	ScratchImage image;
	HRESULT hr = LoadFromWICFile(wtext, WIC_FLAGS::WIC_FLAGS_NONE, &metadata, image);
	if (FAILED(hr))
	{
		return E_FAIL;
	}

	// サンプラー作成
	D3D11_SAMPLER_DESC SamDesc = {};
	
	//LINEAR / POINT これ保管方法の設定をしている
	//ほとんどかわらないが、ドッド絵の場合だったりする場合に使う
	SamDesc.Filter = D3D11_FILTER_MIN_MAG_MIP_LINEAR;

	//テクスチャの貼り方を決めている
	//今のと別に別の貼り方を使いたいってときは pSampler を配列 pSampler[2]にして
	//Drawの時にインデックスを指定してやれば使えるようになる
	SamDesc.AddressU = D3D11_TEXTURE_ADDRESS_CLAMP;
	SamDesc.AddressV = D3D11_TEXTURE_ADDRESS_CLAMP;
	SamDesc.AddressW = D3D11_TEXTURE_ADDRESS_CLAMP;
	hr = Direct3D::pDevice_->CreateSamplerState(&SamDesc, &pSampler_);
	if (FAILED(hr))
	{
		return E_FAIL;
	}

	// シェーダーリソースビュー作成
	D3D11_SHADER_RESOURCE_VIEW_DESC srvDesc = {};
	srvDesc.Format = DXGI_FORMAT_R8G8B8A8_UNORM;
	srvDesc.ViewDimension = D3D11_SRV_DIMENSION_TEXTURE2D;
	srvDesc.Texture2D.MipLevels = 1;
	hr = CreateShaderResourceView(Direct3D::pDevice_,
		image.GetImages(), image.GetImageCount(), metadata, &pSRV_);
	if (FAILED(hr))
	{
		return S_FALSE;
	}

	return S_OK;
}

void Texture::Release()
{
	SAFE_RELEASE(pSampler_);
	SAFE_RELEASE(pSRV_);
}
