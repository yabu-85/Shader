#include "Engine/Model.h"
#include "Stage.h"

//コンストラクタ
Stage::Stage(GameObject* parent)
    :GameObject(parent, "Stage"), hModel_(-1), width_(15), height_(15)
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
    hModel_ = Model::Load("Assets/BoxBrick.fbx");
    assert(hModel_ >= 0);
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
}

//開放
void Stage::Release()
{
}