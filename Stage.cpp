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

void Stage::InitConstantBuffer()
{
    D3D11_BUFFER_DESC cb{};
    cb.ByteWidth = sizeof(CONSTANT_BUFFER);
    cb.Usage = D3D11_USAGE_DYNAMIC;
    cb.BindFlags = D3D11_BIND_CONSTANT_BUFFER;
    cb.CPUAccessFlags = D3D11_CPU_ACCESS_WRITE;
    cb.MiscFlags = 0;
    cb.StructureByteStride = 0;

    //これでバッファの大きさ決めてるんよね、structの構造どうせなら全部XMFLOAT4でintとかはすべて同じ値入れるといい
    HRESULT hr;
    hr = Direct3D::pDevice_->CreateBuffer(&cb, nullptr, &pConstantBuffer_);
    if (FAILED(hr))
    {
        MessageBox(NULL, "コンスタントバッファの作成に失敗しました", "エラー", MB_OK);
    }
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

    InitConstantBuffer();
}

namespace {
    XMFLOAT4 lightPosition{};
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

    if (Input::IsKey(DIK_Q)) lightPosition.y -= 0.2f;
    if (Input::IsKey(DIK_E)) lightPosition.y += 0.2f;
    if (Input::IsKey(DIK_UPARROW)) lightPosition.z += 0.2f;
    if (Input::IsKey(DIK_DOWNARROW)) lightPosition.z -= 0.2f;
    if (Input::IsKey(DIK_LEFTARROW)) lightPosition.x -= 0.2f;
    if (Input::IsKey(DIK_RIGHTARROW)) lightPosition.x += 0.2f;

    CONSTANT_BUFFER cb;
    cb.lightPosition = lightPosition;
    XMStoreFloat4(&cb.eyePos, Camera::GetPosition());

    D3D11_MAPPED_SUBRESOURCE pdata;
    Direct3D::pContext_->Map(pConstantBuffer_, 0, D3D11_MAP_WRITE_DISCARD, 0, &pdata);	// GPUからのデータアクセスを止める
    memcpy_s(pdata.pData, pdata.RowPitch, (void*)(&cb), sizeof(cb));	// データを値を送る
    Direct3D::pContext_->Unmap(pConstantBuffer_, 0);	//再開

}

//描画
void Stage::Draw()
{
    Transform blockTrans;
    blockTrans.position_ = XMFLOAT3(0.0f, 0.0f, 0.0f);
    Model::SetTransform(hModel_, blockTrans);
    Model::Draw(hModel_);

    Transform groundTrans;
    groundTrans.scale_ = XMFLOAT3(6.0f, 6.0f, 6.0f);
    groundTrans.position_ = XMFLOAT3(0.0f, -0.8f, 0.0f);
    Model::SetTransform(hModel[0], groundTrans);
    Model::Draw(hModel[0]);

    XMFLOAT3 arrowRotate[3] = { XMFLOAT3(90.0f, 0.0f, 0.0f), XMFLOAT3(0.0f, 0.0f, 0.0f), XMFLOAT3(0.0f, 0.0f, 90.0f) };
    for (int i = 0; i < 3; i++) {
        Transform arrowTrans;
        arrowTrans.position_ = XMFLOAT3(0.0f, -0.8f, 0.0f);
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