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

	//�摜�ǂݍ��ݕ���
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

	// �T���v���[�쐬
	D3D11_SAMPLER_DESC SamDesc = {};
	
	//LINEAR / POINT ����ۊǕ��@�̐ݒ�����Ă���
	//�قƂ�ǂ����Ȃ����A�h�b�h�G�̏ꍇ�������肷��ꍇ�Ɏg��
	SamDesc.Filter = D3D11_FILTER_MIN_MAG_MIP_LINEAR;

	//�e�N�X�`���̓\��������߂Ă���
	//���̂ƕʂɕʂ̓\������g���������ĂƂ��� pSampler ��z�� pSampler[2]�ɂ���
	//Draw�̎��ɃC���f�b�N�X���w�肵�Ă��Ύg����悤�ɂȂ�
	SamDesc.AddressU = D3D11_TEXTURE_ADDRESS_CLAMP;
	SamDesc.AddressV = D3D11_TEXTURE_ADDRESS_CLAMP;
	SamDesc.AddressW = D3D11_TEXTURE_ADDRESS_CLAMP;
	hr = Direct3D::pDevice_->CreateSamplerState(&SamDesc, &pSampler_);
	if (FAILED(hr))
	{
		return E_FAIL;
	}

	// �V�F�[�_�[���\�[�X�r���[�쐬
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
