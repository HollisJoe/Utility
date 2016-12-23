// stdafx.h : include file for standard system include files,
// or project specific include files that are used frequently, but
// are changed infrequently
//

#pragma once
#include <stdio.h>
#include <tchar.h>

// TODO: reference additional headers your program requires here
#include <opencv2/opencv.hpp>
#include <opencv2/xfeatures2d.hpp>
using namespace cv;
#ifdef _DEBUG
#define lnkLIB(name) name "d"
#else
#define lnkLIB(name) name
#endif

#define CV_VERSION_ID CVAUX_STR(CV_MAJOR_VERSION) CVAUX_STR(CV_MINOR_VERSION) CVAUX_STR(CV_SUBMINOR_VERSION)
#define cvLIB(name) lnkLIB("opencv_" name CV_VERSION_ID)
#pragma comment( lib, cvLIB("core"))
#pragma comment( lib, cvLIB("imgproc"))
#pragma comment( lib, cvLIB("highgui"))

#pragma comment(lib,  cvLIB("imgcodecs"))
#pragma comment(lib, cvLIB("features2d"))
#pragma comment(lib, cvLIB("xfeatures2d"))	
#pragma comment( lib, cvLIB("calib3d"))
#pragma comment( lib, cvLIB("flann"))
#pragma comment( lib, cvLIB("videoio"))


#include <vector>
#include <iostream>
#include <ctime>
#include <iomanip>
#include <fstream>
#include <map>
#include <io.h>
#include <fcntl.h>
using namespace std;

// opencv-cuda
#include <opencv2/cudafeatures2d.hpp>
#pragma comment( lib, cvLIB("cudafeatures2d"))
#pragma comment( lib, cvLIB("cudaarithm"))
#pragma comment( lib, cvLIB("cudaimgproc"))
#pragma comment( lib, cvLIB("cudev"))


// cuda
#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#pragma comment(lib, "cuda.lib")
#pragma comment(lib, "cudart.lib")
#pragma comment(lib, "nppi.lib")

#include "ASIFT_lib.h"