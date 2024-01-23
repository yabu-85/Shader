//������������������������������������������������������������������������������
// �e�N�X�`�����T���v���[�f�[�^�̃O���[�o���ϐ���`
//������������������������������������������������������������������������������
Texture2D	g_texture : register(t0);		//�e�N�X�`���[
SamplerState	g_sampler : register(s0);	//�T���v���[

Texture2D	g_toon_texture : register(t2);		//�e�N�X�`���[

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

	//���[�J�����W�ɁA���[���h�E�r���[�E�v���W�F�N�V�����s���������
	//�X�N���[�����W�ɕϊ����A�s�N�Z���V�F�[�_�[��
	outData.pos = mul(pos, g_matWVP);
	outData.uv = uv;

	//�@������]
	normal.w = 0;
	normal = mul(normal, g_matNormal);
	normal = normalize(normal);
	outData.normal = normal;

	float4 light = normalize(g_lightPosition);
	outData.color = saturate(dot(normal, light)); //saturate�� 0�`�P�Ɏ��߂�clamp

	//�����x�N�g���i�n�C���C�g�̌v�Z�ɕK�v
	float4 worldPos = mul(pos, g_matW);					//���[�J�����W�Ƀ��[���h�s��������ă��[���h���W��
	outData.eye = g_eyePosition - worldPos;	//���_���璸�_�ʒu�������Z�����������߂ăs�N�Z���V�F�[�_�[��

	//�܂Ƃ߂ďo��
	return outData;
}

//������������������������������������������������������������������������������
// �s�N�Z���V�F�[�_
//������������������������������������������������������������������������������
float4 PS(VS_OUT inData) : SV_Target
{
	float4 lightSource = float4(1.0f, 1.0f, 1.0f, 1.0f);
	float4 lightDir = normalize(-g_lightPosition);

	float2 uvT = float2(inData.color.x, 1.0f);
	inData.color = g_toon_texture.Sample(g_sampler, uvT);

	float4 diffuse;
	float4 ambient;
	if (g_isTexture == false)
	{
		diffuse = lightSource * g_diffuseColor * inData.color;
		ambient = lightSource * g_diffuseColor * g_ambientColor;
	}
	else
	{
		diffuse = lightSource * g_texture.Sample(g_sampler, inData.uv) * inData.color;
		ambient = lightSource * g_texture.Sample(g_sampler, inData.uv) * g_ambientColor;
	}

	//���ʔ��ˌ��i�X�y�L�����[�j
	float4 NL = dot(lightDir, inData.normal);
	float4 reflection = lightDir - 2.0 * NL * inData.normal;
	float4 specular = pow(saturate(dot(reflection, normalize(inData.eye))), g_shuniness) * g_specular;

	return (diffuse + ambient + specular);
}