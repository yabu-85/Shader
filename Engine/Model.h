#pragma once
//必要なインクルードを書く
#include <string>
#include <vector>
#include "fbx.h"

namespace Model
{
	struct ModelData
	{
		Fbx* pfbx_;
		Transform transform_;//トランスフォーム
		std::string filename_;

	};
	int Load(std::string fileName, bool isFlatColor = false);
	void SetTransform(int hModel, Transform transform);
	void Draw(int hModel, int type_ = 1);
	void Release();
}