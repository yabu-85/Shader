#pragma once
#include "Engine/GameObject.h"

struct CBUFF_STAGESCENE {
    XMFLOAT4	lightPosition;	// ���C�g�̌���
    XMFLOAT4	eyePos;			// �J�����̈ʒu
};

//�X�e�[�W���Ǘ�����N���X
class Stage : public GameObject
{
    ID3D11Buffer* pCBStageScene_;		// �R���X�^���g�o�b�t�@�ւ̃|�C���^
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