#pragma once
#include "Engine/GameObject.h"

struct CBUFF_STAGESCENE {
    XMFLOAT4	lightPosition;	// ライトの向き
    XMFLOAT4	eyePos;			// カメラの位置
};

//ステージを管理するクラス
class Stage : public GameObject
{
    ID3D11Buffer* pCBStageScene_;		// コンスタントバッファへのポインタ
    void InitConstantBuffer();

    int hModel_[4];
    XMFLOAT4 lightSourcePosition_;

public:
    Stage(GameObject* parent);
    ~Stage();
    void Initialize() override;
    void Update() override;
    void Draw() override;
    void Release() override;

    void SetLightPos(XMFLOAT4& _pos) { lightSourcePosition_ = _pos; }
    XMFLOAT4 GetLightPos() { return lightSourcePosition_; }

};