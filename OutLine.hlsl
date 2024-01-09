//������������������������������������������������������������������������������
// �e�N�X�`�����T���v���[�f�[�^�̃O���[�o���ϐ���`
//������������������������������������������������������������������������������
Texture2D	g_texture : register(t0);		//�e�N�X�`���[
SamplerState	g_sampler : register(s0);	//�T���v���[

//������������������������������������������������������������������������������
// �R���X�^���g�o�b�t�@
// DirectX �����瑗�M����Ă���A�|���S�����_�ȊO�̏����̒�`
//������������������������������������������������������������������������������
cbuffer global : register(b0)
{
	float4x4	g_matWVP;			// ���[���h�E�r���[�E�v���W�F�N�V�����̍����s��
	float4x4	g_matW;				// ���[���h�s��
	float4x4	g_matNormal;		// 
	float4		g_diffuseColor;		// �f�B�t���[�Y�J���[�i�}�e���A���̐F�j
	float4		g_ambientColor;		// �����̐F
	float4		g_specular;			// ���ʔ��ˌ��̐F
	float		g_shuniness;		// ���ʔ��ˌ��̋���
	bool		g_isTexture;		// �e�N�X�`���\���Ă��邩�ǂ���
};

cbuffer light : register(b1) 
{
	float4		g_lightPosition;	// ���C�g�̌���
	float4		g_eyePosition;		// �J�����̌���
};

//������������������������������������������������������������������������������
// ���_�V�F�[�_�[�o�́��s�N�Z���V�F�[�_�[���̓f�[�^�\����
//������������������������������������������������������������������������������
struct VS_OUT
{
	float4 pos    : SV_POSITION;	//�ʒu
	float2 uv	  : TEXCOORD2;		//uv���W
	float4 color  : COLOR;			//�F�i���邳�j
	float4 eye	  : TEXCOORD1;		//����
	float4 normal : TEXCOORD0;		//�@��
};

//������������������������������������������������������������������������������
// ���_�V�F�[�_
//������������������������������������������������������������������������������
VS_OUT VS(float4 pos : POSITION, float4 uv : TEXCOORD, float4 normal : NORMAL)
{
	//�s�N�Z���V�F�[�_�[�֓n�����
	VS_OUT outData;

	//�@������]
	normal.w = 0;
	normal = mul(normal, g_matNormal);
	normal = normalize(normal);
	outData.normal = normal;

	//���[�J�����W�ɁA���[���h�E�r���[�E�v���W�F�N�V�����s���������
	//�X�N���[�����W�ɕϊ����A�s�N�Z���V�F�[�_�[��
	pos = pos + normal * 0.1;
	outData.pos = mul(pos, g_matWVP);

	//�܂Ƃ߂ďo��
	return outData;
}

//������������������������������������������������������������������������������
// �s�N�Z���V�F�[�_
//������������������������������������������������������������������������������
float4 PS(VS_OUT inData) : SV_Target
{
	return float4(0,0,0,0);
}