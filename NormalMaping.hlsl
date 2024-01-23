//������������������������������������������������������������������������������
// �e�N�X�`�����T���v���[�f�[�^�̃O���[�o���ϐ���`
//������������������������������������������������������������������������������
Texture2D	g_texture : register(t0);		//�e�N�X�`���[
SamplerState	g_sampler : register(s0);	//�T���v���[

Texture2D	g_normalTexture : register(t1);		//�e�N�X�`���[

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
	bool		g_isNormalmap;		// 
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
	float2 uv	  : TEXCOORD;		//uv���W
	float4 eye	  : POSITION;		//����
	float4 Neyev  : POSITION1;		//�m�[�}���}�b�v�p�̐ڋ�Ԃɕϊ����ꂽ�����x�N�g��
	float4 normal : POSITION2;		//�@���x�N�g��
	float4 light  : POSITION3;		//���C�g��ڋ�Ԃɕϊ������x�N�g��
	float4 color  : POSITION4;		//�F�i���邳�j
};

//������������������������������������������������������������������������������
// ���_�V�F�[�_
//������������������������������������������������������������������������������
VS_OUT VS(float4 pos : POSITION, float4 uv : TEXCOORD, float4 normal : NORMAL, float4 tangent : TANGENT)
{
	//�s�N�Z���V�F�[�_�[�֓n�����
	//�iVS_OUT)0����ł��ׂĂO�ŏ����������炵��
	VS_OUT outData = (VS_OUT)0;

	//���[�J�����W�ɁA���[���h�E�r���[�E�v���W�F�N�V�����s���������
	//�X�N���[�����W�ɕϊ����A�s�N�Z���V�F�[�_�[��
	outData.pos = mul(pos, g_matWVP);
	outData.uv = (float2)uv;

	//�@������]
	normal.w = 0;
	normal = mul(normal, g_matNormal);
	normal = normalize(normal);
	normal.w = 0;
	outData.normal = normal;

	tangent.w = 0;
	tangent = mul(tangent, g_matNormal);
	tangent = normalize(tangent);	//�ڐ��x�N�g�������[�J�����W�ɕϊ��������

	float4 posw = mul(pos, g_matW);		//���[�J�����W�Ƀ��[���h�s��������ă��[���h���W��
	outData.eye = g_eyePosition - posw;	//���_���璸�_�ʒu�������Z�����������߂ăs�N�Z���V�F�[�_�[��

	float3 no = { normal.x, normal.y, normal.z };
	float3 ta = { tangent.x, tangent.y, tangent.z };
	float3 binormal = cross(no, ta);
	binormal = mul(binormal, g_matNormal);
	binormal = normalize(binormal);

	outData.Neyev.x = dot(outData.eye, tangent);
	outData.Neyev.y = dot(outData.eye, binormal);
	outData.Neyev.z = dot(outData.eye, normal);
	outData.Neyev.w = 0;

	float4 light = normalize(g_lightPosition);
	light.w = 0.0f;
	light = normalize(light);

	outData.color = mul(normal, light); 
	outData.color.w = 0.0f;

	outData.light.x = dot(light, tangent); //�ڋ�Ԃ̌����x�N�g��
	outData.light.y = dot(light, binormal);
	outData.light.z = dot(light, normal);
	outData.light.w = 0;

	//�܂Ƃ߂ďo��
	return outData;
}

//������������������������������������������������������������������������������
// �s�N�Z���V�F�[�_
//������������������������������������������������������������������������������
float4 PS(VS_OUT inData) : SV_Target
{
	float4 lightSource = float4(1.0f, 1.0f, 1.0f, 1.0f);
	float4 diffuse;
	float4 ambient;

	if (g_isNormalmap)
	{
		//rgb�̒l��-1�`1�͈̔͂Ŏ擾����
		float4 tmpNormal = g_normalTexture.Sample(g_sampler, inData.uv) * 2.0f - 1.0f;
		tmpNormal.w = 0;
		tmpNormal = normalize(tmpNormal);

		float4 reflection = reflect(-inData.light, tmpNormal);
		float4 specular = pow(saturate(dot(reflection, normalize(inData.Neyev))), g_shuniness) * g_specular;

		float4 NL = clamp(dot(tmpNormal, inData.light), 0, 1);
		if (g_isTexture == true)
		{
			diffuse = g_texture.Sample(g_sampler, inData.uv) * NL;
			ambient = g_texture.Sample(g_sampler, inData.uv) * g_ambientColor;
		}
		else
		{
			diffuse = g_diffuseColor * NL;
			ambient = g_diffuseColor * g_ambientColor;
		}

		float4 result = diffuse + ambient + specular;
		return result;

	}
	else
	{
		float4 reflection = reflect(normalize(-g_lightPosition), inData.normal);
		float4 specular = pow(saturate(dot(reflection, normalize(inData.eye))), g_shuniness) * g_specular;
		
		if (g_isTexture == true)
		{
			diffuse = lightSource * g_texture.Sample(g_sampler, inData.uv) * inData.color;
			ambient = lightSource * g_texture.Sample(g_sampler, inData.uv) * g_ambientColor;
		}
		else
		{
			diffuse = lightSource * g_diffuseColor * inData.color;
			ambient = lightSource * g_diffuseColor * g_ambientColor;
		}
		
		float4 result = diffuse + ambient + specular;
		if (g_isTexture) result.a = inData.uv.x;
		return result;

	}
}