#pragma once
#include "Engine/GameObject.h"

//�X�e�[�W���Ǘ�����N���X
class Stage : public GameObject
{

    ID3D11Buffer* pConstantBuffer_;		// �R���X�^���g�o�b�t�@�ւ̃|�C���^
    struct CONSTANT_BUFFER {
        XMFLOAT4	lightPosition;	// ���C�g�̌���
        XMFLOAT4	eyePos;			// �J�����̈ʒu
    };

	// �R���X�^���g�o�b�t�@�̏���
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