#pragma once
#include <d3d11.h>
#include <string>
#include <wrl.h>
#include <DirectXMath.h>

using namespace DirectX;
using namespace Microsoft::WRL;
using std::string;

class Texture
{
	ID3D11SamplerState* pSampler_;
	ID3D11ShaderResourceView* pSRV_;
	XMFLOAT2 imgSize_;
public:
	Texture();
	~Texture();
	XMFLOAT2 GetTextureSize() { return imgSize_; }
	HRESULT Load(string filename);
	void Release();
	ID3D11SamplerState* GetSampler() { return pSampler_; }
	ID3D11ShaderResourceView* GetSRV() { return pSRV_; }
};