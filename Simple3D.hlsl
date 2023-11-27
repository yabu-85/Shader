//������������������������������������������������������������������������������
// �e�N�X�`�����T���v���[�f�[�^�̃O���[�o���ϐ���`
//������������������������������������������������������������������������������
Texture2D	g_texture : register(t0);		//�e�N�X�`���[
SamplerState	g_sampler : register(s0);	//�T���v���[

//������������������������������������������������������������������������������
// �R���X�^���g�o�b�t�@
// DirectX �����瑗�M����Ă���A�|���S�����_�ȊO�̏����̒�`
//������������������������������������������������������������������������������
cbuffer global
{
	float4x4	g_matWVP;			// ���[���h�E�r���[�E�v���W�F�N�V�����̍����s��
	float4x4	g_matNormal;		// ���[���h�s��
	float4		g_lightDirection;	// ���C�g�̌���
	float4		g_cameraPosition;	// �J�����̌���
	float4		g_diffuseColor;		// �f�B�t���[�Y�J���[�i�}�e���A���̐F�j
	bool		g_isTexture;		// �e�N�X�`���\���Ă��邩�ǂ���
};

//������������������������������������������������������������������������������
// ���_�V�F�[�_�[�o�́��s�N�Z���V�F�[�_�[���̓f�[�^�\����
//������������������������������������������������������������������������������
struct VS_OUT
{
	float4 pos    : SV_POSITION;	//�ʒu
	float4 normal : TEXCOORD0;		//�@��
	float4 eye	  : TEXCOORD1;		//����
	float2 uv	  : TEXCOORD2;		//uv���W
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
	normal = mul(normal, g_matNormal);

	float4 light = g_lightDirection;
	light = normalize(light);
	outData.normal = clamp(dot(normal, light), 0, 1);

	//�����x�N�g���i�n�C���C�g�̌v�Z�ɕK�v
	float4 worldPos = mul(pos, g_matNormal);					//���[�J�����W�Ƀ��[���h�s��������ă��[���h���W��
	outData.eye = normalize(g_cameraPosition - worldPos);	//���_���璸�_�ʒu�������Z�����������߂ăs�N�Z���V�F�[�_�[��

	//�܂Ƃ߂ďo��
	return outData;
}

//������������������������������������������������������������������������������
// �s�N�Z���V�F�[�_
//������������������������������������������������������������������������������
float4 PS(VS_OUT inData) : SV_Target
{
	float4 lightSource = float4(1.0f, 1.0f, 1.0f, 1.0f);
	float4 ambientSource = float4(0.2f, 0.2f, 0.2f, 1.0f);

	float4 diffuse;
	float4 ambient;
	if (g_isTexture == false)
	{
		diffuse = lightSource * g_diffuseColor * inData.normal;
		ambient = lightSource * g_diffuseColor * ambientSource;
	}
	else
	{
		diffuse = lightSource * g_texture.Sample(g_sampler, inData.uv) * inData.normal;
		ambient = lightSource * g_texture.Sample(g_sampler, inData.uv) * ambientSource;
	}

	//���ʔ��ˌ��i�X�y�L�����[�j
	float shuniness = 30.0f;						//�X�y�L�����[�̋����g���}�W��
	float4 speculerColor = float4(1, 0.1, 1, 1);		//�X�y�L�����[�̐F������W��
	speculerColor = normalize(speculerColor);
	float4 lightDir = normalize(g_lightDirection);	//�́[�܂炢�����ꂽ�l

	float4 R = reflect(lightDir, inData.normal);										//�����˃x�N�g��
	float4 speculer = pow(saturate(dot(R, inData.eye)), shuniness) * speculerColor;		//�n�C���C�g�����߂�

	return (diffuse + ambient + speculer);
}