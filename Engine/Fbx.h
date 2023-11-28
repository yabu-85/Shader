﻿#pragma once

#include <d3d11.h>
#include <fbxsdk.h>
#include <string>
#include "Transform.h"
#include <vector>


#pragma comment(lib, "LibFbxSDK-MD.lib")
#pragma comment(lib, "LibXml2-MD.lib")
#pragma comment(lib, "zlib-MD.lib")

using std::vector;

class Texture;

class Fbx
{
	// マテリアル
	struct MATERIAL
	{
		Texture*	pTexture;		// テクスチャへのポインタ
		XMFLOAT4	diffuse;		// ディフューズカラー
	};

	struct CONSTANT_BUFFER
	{
		XMMATRIX	matWVP;			// ワールド行列・ビュー行列・射影行列の合成行列
		XMMATRIX	matW;			// 法線行列 ( ワールド行列だけのやつ
		XMFLOAT4	diffuseColor;   // ディフューズカラー
		XMFLOAT4	lightDirection;	// ライトの向き
		XMFLOAT4	eyePos;			//カメラの位置
		int			isTextured;		// テクスチャを使用するかのフラグ
	};

	struct VERTEX
	{
		XMVECTOR position;			// 頂点座標
		XMVECTOR uv;				// UV座標
		XMVECTOR normal;			// 法線ベクトル
	};

	int vertexCount_;				// 頂点数
	int polygonCount_;				// ポリゴン数
	int materialCount_;				// マテリアルの個数

	ID3D11Buffer* pVertexBuffer_;		// 頂点バッファへのポインタ
	ID3D11Buffer** pIndexBuffer_;		// インデックスバッファへのポインタのポインタ
	ID3D11Buffer* pConstantBuffer_;		// コンスタントバッファへのポインタ
	MATERIAL* pMaterialList_;			// マテリアルリストへのポインタ
	vector<int> indexCount_;			// インデックス数のリスト

	// 頂点バッファの初期化
	void InitVertex(fbxsdk::FbxMesh* mesh);

	// インデックスバッファの初期化
	void InitIndex(fbxsdk::FbxMesh* mesh);

	// コンスタントバッファの初期化
	void InitConstantBuffer();

	// マテリアルの初期化
	void InitMaterial(fbxsdk::FbxNode* pNode, bool isFlatColor);

public:
	Fbx();
	HRESULT Load(std::string fileName, bool isFlatColor);		// FBXファイルの読み込み
	void Draw(Transform& transform);							// FBXモデルの描画
	void Release();												// メモリの解放
};
