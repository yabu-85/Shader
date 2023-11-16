#include "Engine/Model.h"
#include "Stage.h"
#include "Engine/Sprite.h"

namespace {
    Sprite* img = nullptr;
}

//コンストラクタ
Stage::Stage(GameObject* parent)
    :GameObject(parent, "Stage"), hModel_(-1)
{
}

//デストラクタ
Stage::~Stage()
{
}

//初期化
void Stage::Initialize()
{
    //モデルデータのロード
    hModel_ = Model::Load("Assets/numberCube.fbx");
    assert(hModel_ >= 0);

    img = new Sprite();
    img->Initialize("neko.png");
}

//更新
void Stage::Update()
{
}

//描画
void Stage::Draw()
{
    Transform blockTrans;

    Model::SetTransform(hModel_, blockTrans);
    Model::Draw(hModel_);

    blockTrans.scale_ = XMFLOAT3(1.5f, 1.5f, 1.5f);
    //img->Draw(blockTrans);
}

//開放
void Stage::Release()
{
}