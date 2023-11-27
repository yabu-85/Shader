#include "Engine/Model.h"
#include "Stage.h"
#include "Engine/Sprite.h"
#include "Engine/Camera.h"
#include "Engine/Input.h"

namespace {
    Sprite* img = nullptr;

    int hModel[2] = { -1, -1 };
    XMFLOAT3 camPos{};

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

    hModel[0] = Model::Load("Assets/ground.fbx");
    assert(hModel[0] >= 0);
    hModel[1] = Model::Load("Assets/arrow.fbx");
    assert(hModel[1] >= 0);

    //img = new Sprite();
    //img->Initialize("neko.png");

    camPos = XMFLOAT3(0.0f, 3.0f, 5.0f);
    Camera::SetTarget(XMFLOAT3(0.0f, 0.0f, 0.0f));

}

//更新
void Stage::Update()
{
    if (Input::IsKey(DIK_A)) camPos.x += 0.1f;
    if (Input::IsKey(DIK_D)) camPos.x -= 0.1f;
    if (Input::IsKey(DIK_W)) camPos.z -= 0.1f;
    if (Input::IsKey(DIK_S)) camPos.z += 0.1f;
    if (Input::IsKey(DIK_E)) camPos.y += 0.1f;
    if (Input::IsKey(DIK_Q)) camPos.y -= 0.1f;

    Camera::SetPosition(camPos);

}

//描画
void Stage::Draw()
{
    Transform blockTrans;
    blockTrans.position_ = XMFLOAT3(0.0f, 0.8f, 0.0f);
    Model::SetTransform(hModel_, blockTrans);
    Model::Draw(hModel_);

    Transform groundTrans;
    groundTrans.scale_ = XMFLOAT3(6.0f, 6.0f, 6.0f);
    Model::SetTransform(hModel[0], groundTrans);
    Model::Draw(hModel[0]);

    XMFLOAT3 arrowRotate[3] = { XMFLOAT3(90.0f, 0.0f, 0.0f), XMFLOAT3(0.0f, 0.0f, 0.0f), XMFLOAT3(0.0f, 0.0f, 90.0f) };
    for (int i = 0; i < 3; i++) {
        Transform arrowTrans;
        arrowTrans.rotate_ = arrowRotate[i];
        arrowTrans.scale_ = XMFLOAT3(0.2f, 0.2f, 0.2f);
        Model::SetTransform(hModel[1], arrowTrans);
        Model::Draw(hModel[1]);
    }
    
    blockTrans.scale_ = XMFLOAT3(1.5f, 1.5f, 1.5f);
   
    //img->Draw(blockTrans);
    
}

//開放
void Stage::Release()
{
}