#pragma once


// kpts : x, y, scale, rotation
// desp : 128 float

struct FRAME{
	float *img; size_t w; size_t h; int numTilts; int flag_resize;
	int num_keys;  float *kpts;  float *desp;
};