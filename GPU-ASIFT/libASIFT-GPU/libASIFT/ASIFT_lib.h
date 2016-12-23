#pragma once
#include "demo_lib_sift.h"

typedef struct __asift_image_float
{
	float* data;
	int width;
	int height;
} asift_image_float;

int initGPU_detector();

int detectAndcompute
(
	asift_image_float im,
	int* keys_no,
	int num_tilt,
	vector<vector<keypointslist>>& whole_key
);

// Experimental settings for different CUDA device
class GPUMemSettings {
public:
	// For first octave -1
	static int MEM_4096_UP;
	static int MEM_2048_UP;
	static int MEM_1024_UP;

	// For first octave equal or larger than 0
	static int MEM_4096;
	static int MEM_2048;
	static int MEM_1024;

	// For first octave other than - 1 and 0
	static int MEM_4096_UNDEFINED;
	static int MEM_2048_UNDEFINED;
	static int MEM_1024_UNDEFINED;
};

