#pragma once
#include "demo_lib_sift.h"

int AsiftGPU(const float const* image, int width, int height, int num_tilt, vector<vector<keypointslist>>& keys_all);
int AsiftGPU_Filtered(const float const* image, int width, int height, int num_tilt, vector<vector<keypointslist>>& keys_all);


