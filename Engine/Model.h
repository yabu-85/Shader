#pragma once
//�K�v�ȃC���N���[�h������
#include <string>
#include <vector>
#include "fbx.h"

namespace Model
{
	struct ModelData
	{
		Fbx* pfbx_;
		Transform transform_;//�g�����X�t�H�[��
		std::string filename_;

	};
	int Load(std::string fileName, bool isFlatColor = false);
	void SetTransform(int hModel, Transform transform);
	void Draw(int hModel, int type_ = 1);
	void Release();
}