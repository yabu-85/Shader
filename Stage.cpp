#include "Engine/Model.h"
#include "Stage.h"
#include "Engine/Sprite.h"

namespace {
    Sprite* img = nullptr;
}

//�R���X�g���N�^
Stage::Stage(GameObject* parent)
    :GameObject(parent, "Stage"), hModel_(-1)
{
}

//�f�X�g���N�^
Stage::~Stage()
{
}

//������
void Stage::Initialize()
{
    //���f���f�[�^�̃��[�h
    hModel_ = Model::Load("Assets/numberCube.fbx");
    assert(hModel_ >= 0);

    img = new Sprite();
    img->Initialize("neko.png");
}

//�X�V
void Stage::Update()
{
}

//�`��
void Stage::Draw()
{
    Transform blockTrans;

    Model::SetTransform(hModel_, blockTrans);
    Model::Draw(hModel_);

    blockTrans.scale_ = XMFLOAT3(1.5f, 1.5f, 1.5f);
    //img->Draw(blockTrans);
}

//�J��
void Stage::Release()
{
}