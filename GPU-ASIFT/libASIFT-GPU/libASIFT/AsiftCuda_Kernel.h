#pragma once
#include <stdio.h>
#include <assert.h>
#include <vector>
#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include "nppi.h"


#define PI_CU 3.14159265358979323846
#define MAX_KERNEL_SIZE_CU 100
#define FILTER_TILE_WIDTH 256
#define COLUMNS_HALO_STEPS 1
#define COLUMNS_RESULT_STEPS 8

// Never change this !
static float InitSigma_cu = 1.6;
const float GaussTruncate_cu = 4.0;

void unbindTexture_texOriImg();

void bindTexture_texOriImg(
	float*				img_dev,
	const float const*	img_host,
	int					width,
	int					height
	);

void frotCuda(
	float*&		output_d,
	int			width,
	int			height,
	int&		widthO,
	int&		heightO,
	float*		theta
	);

void gaussianVerticalCuda(
	float*&		rot_d,
	float*&		blurred_d,
	int			width,
	int			height,
	float		sigma
	);

void warpCuda(
	float*& blurred_d,
	float*& warped_d,
	float	t1,
	float	t2,
	int		widthRot,
	int		heightRot,
	int		widthTilt,
	int		heightTilt
	);

void filterPoints(
	float4* keys_host,
	int*	index_host,
	int*	filtered_num_host,
	int		feature_num,
	int		width,
	int		height,
	float	sin_theta1,
	float	cos_theta1,
	float	theta,
	float	t2
	);
