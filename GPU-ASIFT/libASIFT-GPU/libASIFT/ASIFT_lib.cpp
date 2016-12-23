#include "ASIFT_lib.h"
#include "demo_lib_sift.h"
#include "compute_asift_keypoints.h"
#include "SiftGPU.h"

siftParam sift_gen_param;
SiftGPU* sift = new SiftGPU;
int siftgpu_detect = 0;

static int g_is_init = 0;
static vector< vector<keypointslist> > g_keys1(0);
static vector< vector<keypointslist> > g_keys2(0);
static int g_keys1_no = 0;
static int g_keys2_no = 0;

int GPUMemSettings::MEM_4096_UP				= 5200;
int GPUMemSettings::MEM_2048_UP				= 3500;
int GPUMemSettings::MEM_1024_UP				= 2000;
int GPUMemSettings::MEM_4096				= 4500;
int GPUMemSettings::MEM_2048				= 2500;
int GPUMemSettings::MEM_1024				= 1800;
int GPUMemSettings::MEM_4096_UNDEFINED		= 3200;
int GPUMemSettings::MEM_2048_UNDEFINED		= 2000;
int GPUMemSettings::MEM_1024_UNDEFINED		= 1200;


int initGPU_detector()
{
	sift->ParseParam(sift_gen_param.num_param, sift_gen_param.sift_param);
	if(sift->CreateContextGL() != SiftGPU::SIFTGPU_FULL_SUPPORTED) g_is_init = 0;
	else g_is_init = 1;
	readCudaDevice();
	int firstOctave = sift->firstOctave();
	switch(firstOctave) {
	case -1: case 0: break;
	default: cout << "Warning: First octaves other than -1 and 0 are not tested, fatal error may occur ..." << endl;
	}

	int pysize = sift_gen_param.pysize;
	if (pysize == 0)
	{
		switch (sift->_globalMem_MB) {
		case 1024:
			switch (firstOctave) {
			case -1: sift->SetMaxDimension(GPUMemSettings::MEM_1024_UP); sift->AllocatePyramid(GPUMemSettings::MEM_1024_UP, GPUMemSettings::MEM_1024_UP); break;
			case  0: sift->SetMaxDimension(GPUMemSettings::MEM_1024); sift->AllocatePyramid(GPUMemSettings::MEM_1024, GPUMemSettings::MEM_1024); break;
			default: sift->SetMaxDimension(GPUMemSettings::MEM_1024_UNDEFINED); sift->AllocatePyramid(GPUMemSettings::MEM_1024_UNDEFINED, GPUMemSettings::MEM_1024_UNDEFINED);
			}
			break;
			/*	case 2048:
					switch(firstOctave) {
					case -1: sift->SetMaxDimension(GPUMemSettings::MEM_2048_UP); sift->AllocatePyramid(GPUMemSettings::MEM_2048_UP, GPUMemSettings::MEM_2048_UP); break;
					case  0: sift->SetMaxDimension(GPUMemSettings::MEM_2048); sift->AllocatePyramid(GPUMemSettings::MEM_2048, GPUMemSettings::MEM_2048); break;
					default: sift->SetMaxDimension(GPUMemSettings::MEM_2048_UNDEFINED); sift->AllocatePyramid(GPUMemSettings::MEM_2048_UNDEFINED, GPUMemSettings::MEM_2048_UNDEFINED);
					}
					break;*/
		case 4096:
			switch (firstOctave) {
			case -1: sift->SetMaxDimension(GPUMemSettings::MEM_4096_UP); sift->AllocatePyramid(GPUMemSettings::MEM_4096_UP, GPUMemSettings::MEM_4096_UP); break;
			case  0: sift->SetMaxDimension(GPUMemSettings::MEM_4096); sift->AllocatePyramid(GPUMemSettings::MEM_4096, GPUMemSettings::MEM_4096); break;
			default: sift->SetMaxDimension(GPUMemSettings::MEM_4096_UNDEFINED); sift->AllocatePyramid(GPUMemSettings::MEM_4096_UNDEFINED, GPUMemSettings::MEM_4096_UNDEFINED);
			}
			break;
		default:
			cout << "Warning: no settings for this device found, please contact the author ..." << endl;
			switch (firstOctave) {
			case -1: sift->SetMaxDimension(GPUMemSettings::MEM_1024_UP); sift->AllocatePyramid(GPUMemSettings::MEM_1024_UP, GPUMemSettings::MEM_1024_UP); break;
			case  0: sift->SetMaxDimension(GPUMemSettings::MEM_1024); sift->AllocatePyramid(GPUMemSettings::MEM_1024, GPUMemSettings::MEM_1024); break;
			default: sift->SetMaxDimension(GPUMemSettings::MEM_1024_UNDEFINED); sift->AllocatePyramid(GPUMemSettings::MEM_1024_UNDEFINED, GPUMemSettings::MEM_1024_UNDEFINED);
			}
			break;
		}
	}
	else
	{
		sift->SetMaxDimension(pysize); sift->AllocatePyramid(pysize, pysize);
	}

	g_keys1.clear();
	g_keys2.clear();
	g_keys1_no = 0;
	g_keys2_no = 0;
	return g_is_init;
}

int detectAndcompute
	(asift_image_float im,
	int* keys_no,
	int num_tilt,
	vector<vector<keypointslist>>& whole_key
	)
{
	if((im.data == NULL) || (im.height <= 0) || (im.width <= 0 )) return 0;
	
	//
	g_keys1.clear();
	g_keys2.clear();
	g_keys1_no = 0;
	g_keys2_no = 0;

	*keys_no = AsiftGPU_Filtered(im.data, im.width, im.height, num_tilt, whole_key);

	if(*keys_no > 0) return 1;
	else return 0;
}

