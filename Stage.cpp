#include "Engine/Model.h"
#include "Stage.h"
#include "Engine/Camera.h"
#include "Engine/Input.h"

namespace {
    const XMFLOAT4 DEF_LIGHT_POSITION = { 0.0f, 0.0f, 0.0f, 0.0f };
    const XMFLOAT3 arrowRotate[3] = { XMFLOAT3(90.0f, 0.0f, 0.0f), XMFLOAT3(0.0f, 0.0f, 0.0f), XMFLOAT3(0.0f, 0.0f, 90.0f) };

    XMFLOAT3 camPos{};
    Transform blockTrans;
    bool isPointLight = false;
}

void Stage::InitConstantBuffer()
{
    D3D11_BUFFER_DESC cb{};
    cb.ByteWidth = sizeof(CBUFF_STAGESCENE);
    cb.Usage = D3D11_USAGE_DEFAULT;  // D311_USAGE_DEFAULT || D3D11_USAGE_DEFAULT
    cb.BindFlags = D3D11_BIND_CONSTANT_BUFFER;
    cb.CPUAccessFlags = 0;  // D3D11_CPU_ACCESS_WRITE
    cb.MiscFlags = 0;
    cb.StructureByteStride = 0;

    //これでバッファの大きさ決めてるんよね、structの構造どうせなら全部XMFLOAT4でintとかはすべて同じ値入れるといい
    HRESULT hr;
    hr = Direct3D::pDevice_->CreateBuffer(&cb, nullptr, &pCBStageScene_);
    if (FAILED(hr))
    {
        MessageBox(NULL, "コンスタントバッファの作成に失敗しました", "エラー", MB_OK);
    }
}

//コンストラクタ
Stage::Stage(GameObject* parent)
    :GameObject(parent, "Stage"), hModel_{-1, -1, -1, -1}, pCBStageScene_(nullptr), lightSourcePosition_(DEF_LIGHT_POSITION)
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
    hModel_[0] = Model::Load("Assets/testTorus.fbx");
    assert(hModel_[0] >= 0);
    hModel_[1] = Model::Load("Assets/ground.fbx");
    assert(hModel_[1] >= 0);
    hModel_[2] = Model::Load("Assets/arrow.fbx");
    assert(hModel_[2] >= 0);
    hModel_[3] = Model::Load("Assets/BoxBrick.fbx");
    assert(hModel_[3] >= 0); 

    camPos = XMFLOAT3(0.0f, 3.0f, 5.0f);
    Camera::SetTarget(XMFLOAT3(0.0f, 0.0f, 0.0f));

    InitConstantBuffer();
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

    if (Input::IsKey(DIK_1)) lightSourcePosition_.y -= 0.2f;
    if (Input::IsKey(DIK_3)) lightSourcePosition_.y += 0.2f;
    if (Input::IsKey(DIK_UPARROW)) lightSourcePosition_.z += 0.2f;
    if (Input::IsKey(DIK_DOWNARROW)) lightSourcePosition_.z -= 0.2f;
    if (Input::IsKey(DIK_LEFTARROW)) lightSourcePosition_.x -= 0.2f;
    if (Input::IsKey(DIK_RIGHTARROW)) lightSourcePosition_.x += 0.2f;

    CBUFF_STAGESCENE cb;
    cb.lightPosition = lightSourcePosition_;
    XMStoreFloat4(&cb.eyePos, Camera::GetPosition());

    Direct3D::pContext_->UpdateSubresource(pCBStageScene_, 0, NULL, &cb, 0, 0);

    //左の番号がどこに送るかの番号 (b1)
    Direct3D::pContext_->VSSetConstantBuffers(1, 1, &pCBStageScene_);
    Direct3D::pContext_->PSSetConstantBuffers(1, 1, &pCBStageScene_);
}

//描画
void Stage::Draw()
{
    if (Input::IsKeyDown(DIK_F))
        isPointLight = !isPointLight;

    blockTrans.position_ = XMFLOAT3(0.0f, 0.0f, 0.0f);
    blockTrans.rotate_.y += 1.0f;
    Model::SetTransform(hModel_[0], blockTrans);
    Model::Draw(hModel_[0], isPointLight + 1);

    for (int i = 0; i < 3; i++) {
        Transform arrowTrans;
        arrowTrans.position_ = XMFLOAT3(0.0f, -0.8f, 0.0f);
        arrowTrans.rotate_ = arrowRotate[i];
        arrowTrans.scale_ = XMFLOAT3(0.2f, 0.2f, 0.2f);
        Model::SetTransform(hModel_[2], arrowTrans);
        Model::Draw(hModel_[2], isPointLight + 1);
    }

    Transform box;
    box.scale_ = XMFLOAT3(0.3f, 0.3f, 0.3f);
    box.position_ = XMFLOAT3(lightSourcePosition_.x, lightSourcePosition_.y, lightSourcePosition_.z);
    Model::SetTransform(hModel_[3], box);
    Model::Draw(hModel_[3], isPointLight + 1);
    
}

//開放
void Stage::Release()
{
}