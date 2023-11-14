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
	float4x4	matW;			//���[���h�s��
};

//������������������������������������������������������������������������������
// ���_�V�F�[�_�[�o�́��s�N�Z���V�F�[�_�[���̓f�[�^�\����
//������������������������������������������������������������������������������
struct VS_OUT
{
	float4 pos    : SV_POSITION;	//�ʒu
	float2 uv	  : TEXCOORD;		//uv���W
};

//������������������������������������������������������������������������������
// ���_�V�F�[�_
//������������������������������������������������������������������������������
VS_OUT VS(float4 pos : POSITION, float4 uv : TEXCOORD)
{
	//�s�N�Z���V�F�[�_�[�֓n�����
	VS_OUT outData;

	//���[�J�����W�ɁA���[���h�s���������
	//���[���h���W�ɕϊ����A�s�N�Z���V�F�[�_�[��
	outData.pos = mul(pos, matW);
	outData.uv = uv;

	//�܂Ƃ߂ďo��
	return outData;
}

//������������������������������������������������������������������������������
// �s�N�Z���V�F�[�_
//������������������������������������������������������������������������������
float4 PS(VS_OUT inData) : SV_Target
{
	float4 color = g_texture.Sample(g_sampler, inData.uv);

	//�O���[�X�P�[��
	//return dot(color.rgb, float3(0.298912f, 0.586611f, 0.114478f));

	//�|�X�^���[�[�V����
	//float kaityou = 5.0f;
	//return floor(g_texture.Sample(g_sampler, inData.uv) * kaityou) / kaityou;

	//������
	float picSizeX = 1.0f / 800.0f;	//�P�s�N�Z���̃T�C�Y
	float picSizeY = 1.0f / 600.0f;	//Y�̃T�C�Y
	int size = 3;					//����������T�C�Y(�3�ȏ�
	float4 output = float4(0.0f, 0.0f, 0.0f, 0.0f);
	for (int x = -(size - 1) / 2; x <= (size - 1) / 2; x++) {
		for (int y = -(size - 1) / 2; y <= (size - 1) / 2; y++) {
			output += g_texture.Sample(g_sampler, float2(inData.uv.x + (x * picSizeX), inData.uv.y + (y * picSizeY)));
		}
	}
	output /= float(size * size);
	return output;


}