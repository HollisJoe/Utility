// Authors: Unknown. Please, if you are the author of this file, or if you 
// know who are the authors of this file, let us know, so we can give the 
// adequate credits and/or get the adequate authorizations.

// WARNING: 
// This file implements an algorithm possibly linked to the patent
//
// David Lowe  "Method and apparatus for identifying scale invariant 
// features in an image and use of same for locating an object in an 
// image",  U.S. Patent 6,711,293.
//
// This file is made available for the exclusive aim of serving as
// scientific tool to verify of the soundness and
// completeness of the algorithm description. Compilation,
// execution and redistribution of this file may violate exclusive
// patents rights in certain countries.
// The situation being different for every country and changing
// over time, it is your responsibility to determine which patent
// rights restrictions apply to you before you compile, use,
// modify, or redistribute this file. A patent lawyer is qualified
// to make this determination.
// If and only if they don't conflict with any patent terms, you
// can benefit from the following license terms attached to this
// file.
//
// This program is provided for scientific and educational only:
// you can use and/or modify it for these purposes, but you are
// not allowed to redistribute this work or derivative works in
// source or executable form. A license must be obtained from the
// patent right holders for any other use.


#include "demo_lib_sift.h"
#include "AsiftCuda_Kernel.h"
#include "SiftGPU.h"
#include <ctime>
#include <cuda.h>
#include <cuda_runtime_api.h>
extern SiftGPU* sift;

void readCudaDevice()
{
	size_t globalMem_B;
	int device_count;
	float globalMem_MB;
	cudaDeviceProp prop;
	cudaGetDeviceCount(&device_count);
	switch(device_count) {
	case 0: cout << "Fatal error: No CUDA device found, exiting ..." << endl; exit(-1); break;
	case 1: break;
	default:
		cout << "Warning: " << device_count << " CUDA device found, using first device ..." << endl; break;
	}
	cudaGetDeviceProperties(&prop, 0);
	globalMem_B = prop.totalGlobalMem;
	globalMem_MB = globalMem_B / 1048576.0;
	sift->_globalMem_MB = globalMem_MB;
	sift->_computeCap_Major = prop.major;
	sift->_computeCap_Minor = prop.minor;
	cout << "========================================" << endl;
	cout << "CUDA device name: " << prop.name << endl;
	cout << "Compute capability: " << prop.major << "." << prop.minor << endl;
	cout << "Global memory is: " << globalMem_MB << "MB" << endl << endl;
}


template <typename T>
void to_char_array(T tar, char*& out)
{
	out = new char[100];
	sprintf(out, "%f", tar);
}

siftParam::siftParam() {}

siftParam::~siftParam() {
	delete[] sift_param;
}

void siftParam::set_from_file(char* siftParam_name, int pysize )
{
	this->pysize = pysize;
	this->num_param = 12;
	sift_param = (char**)malloc(12*sizeof(char*));
	sift_param[10] = "-cuda";
	sift_param[11] = "-di";

	sift_param[0] = "-fo";
	sift_param[1] = "-1";
	sift_param[2] = "-d";
	sift_param[3] = "3";
	sift_param[4] = "-t";
	sift_param[5] = "0.0020";
	sift_param[6] = "-e";
	sift_param[7] = "15.0";
	sift_param[8] = "-v";
	sift_param[9] = "0";
	num_tilt = 7;
}


#if defined(USE_SIFTGPU)
int sift_genereate_DMA_Filtered(
	void* img_dev,
	int width, int height,
	int widthO, int heightO,
	float t, float theta,
	keypointslist& keypoints)
{
	int filtered_num = 0;
	if(sift->RunSIFT_CU(width, height, img_dev, 0x1909, 0x1406)) {
		int     count			= 0;
		int     feature_num		= sift->GetFeatureNum();
		float   sin_theta1		= sin(theta * PI_CU / 180);
		float   cos_theta1		= cos(theta * PI_CU / 180);
		int*    index			= (int*)   malloc(feature_num * sizeof(int));
		float*  desc			= (float*) malloc(feature_num * VecLength * sizeof(float));
		float4* keys			= (float4*)malloc(feature_num * sizeof(float4));
		sift->GetFeatureVector((float*)keys, desc);
		filterPoints(keys, index, &filtered_num, feature_num, widthO, heightO,
			sin_theta1, cos_theta1, theta, 1.0/t);
		keypoints.resize(filtered_num);
		for(int i=0; i<feature_num; i++) {
			if(index[i]) {
				int desc_counter = 0;
				keypoints[count].x		= keys[i].x;
				keypoints[count].y		= keys[i].y;
				keypoints[count].scale	= keys[i].z;
				keypoints[count].angle	= keys[i].w;
				keypoints[count].tilt	= t;
				keypoints[count].rot	= theta;
				for(int j=i*VecLength; j<(i+1)*VecLength; j++)
					keypoints[count].vec[desc_counter++] = 512 * desc[j];
				count ++;
			}
		}
		delete[] index;
		delete[] desc;
		delete[] keys; 
	}
	return filtered_num;
}

int sift_genereate_DMA(void* img_dev, int width, int height, float t, float theta, keypointslist& keypoints) {
	int feature_num;
	if(sift->RunSIFT_CU(width, height, img_dev, 0x1909, 0x1406)) {
		int count = 0;
		feature_num = sift->GetFeatureNum();
		vector<float> desc(VecLength * feature_num);
		vector<SiftGPU::SiftKeypoint> keys(feature_num);
		sift->GetFeatureVector(&keys[0], &desc[0]);
		keypoints.resize(feature_num);
		for(int i=0; i<feature_num; i++) {
			keypoints[i].angle = keys[i].o;
			keypoints[i].scale = keys[i].s;
			keypoints[i].x	   = keys[i].x;
			keypoints[i].y	   = keys[i].y;
			keypoints[i].tilt  = t;
			keypoints[i].rot   = theta;
			for(int j=0; j<VecLength; j++)
				keypoints[i].vec[j] = 512 * desc[count++];
		}
	}
	return feature_num;
}

int AsiftGen_Cuda(const float const* img_host, int width, int height, int numTilt, vector<vector<keypointslist>>& single_key) {
	// Timing
	cudaEvent_t start, stop;
	cudaEventCreate(&start);
	cudaEventCreate(&stop);
	cudaEventRecord(start, 0);
	int total_num = 0;
	float * img_dev;
	cudaMalloc((void**)&img_dev, width*height*sizeof(float));
	bindTexture_texOriImg(img_dev, img_host, width, height);

	single_key.resize(numTilt);
	int num_rot_t2 = 10;
	float t_min = 1, t_k = sqrt(2.);
	for(int tt=1; tt<=numTilt; tt++) {
		float t = t_min * pow(t_k, tt-1);
		float t1 = 1;
		float t2 = 1 / t;
		if(t == 1) {
			single_key[tt-1].resize(1);
			total_num += sift_genereate_DMA((void*)img_dev, width, height, 1, 0, single_key[tt-1][0]);
		} else {
			int num_rot1 = ROUND_C(num_rot_t2 * t / 2);
			if(num_rot1 % 2 == 1) num_rot1 ++;
			num_rot1 /= 2;
			float delta_theta = PI_CU / num_rot1;
			single_key[tt-1].resize(num_rot1);

			for(int rr=1; rr<=num_rot1; rr++) {
				int widthRot, heightRot;
				int widthTilt, heightTilt;
				float *rot_dev, *blurred_dev, *warped_dev;
				float theta = delta_theta * (rr-1);
				float sigma = InitSigma_cu * t / 2;
				theta = theta * 180.0 / PI_CU;
				frotCuda(rot_dev, width, height, widthRot, heightRot, &theta);
				gaussianVerticalCuda(rot_dev, blurred_dev, widthRot, heightRot, sigma);
				widthTilt	= (int)(widthRot  * t1);
				heightTilt	= (int)(heightRot * t2);
				warpCuda(blurred_dev, warped_dev, t1, t2, widthRot, heightRot, widthTilt, heightTilt);
				total_num += sift_genereate_DMA((void*)warped_dev, widthTilt, heightTilt, t, theta, single_key[tt-1][rr-1]);
				cudaFree(warped_dev);
			}
		}
	}
	cudaEventRecord(stop, 0);
	cudaEventSynchronize(stop);
	float elapsedTime;
	cudaEventElapsedTime(&elapsedTime, start, stop);
	cout << "GPU Asift time is: " << elapsedTime/1000.0 << " second(s)" << endl;
	cudaEventDestroy(start);
	cudaEventDestroy(stop);
	unbindTexture_texOriImg();
	cudaFree(img_dev);
	return total_num;
}

int AsiftGen_Cuda_Filtered(const float const* img_host, int width, int height, int numTilt, vector<vector<keypointslist>>& single_key) {
	// Timing
	cudaEvent_t start, stop;
	cudaEventCreate(&start);
	cudaEventCreate(&stop);
	cudaEventRecord(start, 0);
	int total_num = 0;
	float * img_dev;
	cudaMalloc((void**)&img_dev, width*height*sizeof(float));
	bindTexture_texOriImg(img_dev, img_host, width, height);

	single_key.resize(numTilt);
	int num_rot_t2 = 10;
	float t_min = 1, t_k = sqrt(2.);
	for(int tt=1; tt<=numTilt; tt++) {
		float t = t_min * pow(t_k, tt-1);
		float t1 = 1;
		float t2 = 1 / t;
		if(t == 1) {
			single_key[tt-1].resize(1);
			total_num += sift_genereate_DMA((void*)img_dev, width, height, 1, 0, single_key[tt-1][0]);
		} else {
			int num_rot1 = ROUND_C(num_rot_t2 * t / 2);
			if(num_rot1 % 2 == 1) num_rot1++;
			num_rot1 /= 2;
			float delta_theta = PI_CU / num_rot1;
			single_key[tt-1].resize(num_rot1);

			for(int rr=1; rr<=num_rot1; rr++) {
				int widthRot, heightRot;
				int widthTilt, heightTilt;
				float *rot_dev, *blurred_dev, *warped_dev;
				float theta = delta_theta * (rr-1);
				float sigma = InitSigma_cu * t / 2;
				theta = theta * 180.0 / PI_CU;
				frotCuda(rot_dev, width, height, widthRot, heightRot, &theta);
				gaussianVerticalCuda(rot_dev, blurred_dev, widthRot, heightRot, sigma);
				widthTilt	= (int)(widthRot  * t1);
				heightTilt	= (int)(heightRot * t2);
				warpCuda(blurred_dev, warped_dev, t1, t2, widthRot, heightRot, widthTilt, heightTilt);
				total_num += sift_genereate_DMA_Filtered((void*)warped_dev, widthTilt, heightTilt,
					width, height, t, theta, single_key[tt-1][rr-1]);
				cudaFree(warped_dev);
			}
		}
	}
	cudaEventRecord(stop, 0);
	cudaEventSynchronize(stop);
	float elapsedTime;
	cudaEventElapsedTime(&elapsedTime, start, stop);
	cout << "GPU Asift time is: " << elapsedTime/1000.0 << " second(s)" << endl;
	cudaEventDestroy(start);
	cudaEventDestroy(stop);
	unbindTexture_texOriImg();
	cudaFree(img_dev);
	return total_num;
}


#endif
