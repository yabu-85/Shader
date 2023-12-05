#pragma once
#include "Engine/GameObject.h"

//ステージを管理するクラス
class Stage : public GameObject
{

    ID3D11Buffer* pConstantBuffer_;		// コンスタントバッファへのポインタ
    struct CONSTANT_BUFFER {
        XMFLOAT4	lightPosition;	// ライトの向き
        XMFLOAT4	eyePos;			// カメラの位置
    };

	// コンスタントバッファの準備
    void InitConstantBuffer();

    int hModel_;

public:
    Stage(GameObject* parent);
    ~Stage();
    void Initialize() override;
    void Update() override;
    void Draw() override;
    void Release() override;

};