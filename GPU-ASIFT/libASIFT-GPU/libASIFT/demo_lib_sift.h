#pragma once
#include <vector>
#include <iostream>
using namespace std;

#define ABS(x)    (((x) > 0) ? (x) : (-(x)))
#define ROUND_C(i) ( (i)>(0.0) ? (floor((i)+(0.5))) : (ceil((i)-(0.5))) )
#define PI 3.14159

// Keypoints:
#define OriSize  8
#define IndexSize  4
#define VecLength  IndexSize * IndexSize * OriSize

struct keypoint {
	float x;
	float y;
	float scale;
	float angle;
	float tilt;
	float rot;
	float vec[VecLength];
};

typedef std::vector<keypoint> keypointslist;

class siftParam
{
public:
	siftParam();
	~siftParam();
	void set_from_file(char* filename = "", int pysize = 0);
public:
	int		 pysize;
	char**   sift_param;
	int	     num_param;
	int		 num_tilt;
};

struct siftPar
{

int OctaveMax;

int DoubleImSize;

int order;

/* InitSigma gives the amount of smoothing applied to the image at the
   first level of each octave.  In effect, this determines the sampling
   needed in the image domain relative to amount of smoothing.  Good
   values determined experimentally are in the range 1.2 to 1.8.
*/
float  InitSigma /*= 1.6*/;
 

/* Peaks in the DOG function must be at least BorderDist samples away
   from the image border, at whatever sampling is used for that scale.
   Keypoints close to the border (BorderDist < about 15) will have part
   of the descriptor landing outside the image, which is approximated by
   having the closest image pixel replicated.  However, to perform as much
   matching as possible close to the edge, use BorderDist of 4.
*/
int BorderDist /*= 5*/;


/* Scales gives the number of discrete smoothing levels within each octave.
   For example, Scales = 2 implies dividing octave into 2 intervals, so
   smoothing for each scale sample is sqrt(2) more than previous level.
   Value of 2 works well, but higher values find somewhat more keypoints.
*/

int Scales /*= 3*/;


/// Decreasing PeakThresh allows more non contrasted keypoints
/* Magnitude of difference-of-Gaussian value at a keypoint must be above
   this threshold.  This avoids considering points with very low contrast
   that are dominated by noise.  It is divided by Scales because more
   closely spaced scale samples produce smaller DOG values.  A value of
   0.08 considers only the most stable keypoints, but applications may
   wish to use lower values such as 0.02 to find keypoints from low-contast
   regions.
*/

//#define  PeakThreshInit  255*0.04 
//#define  PeakThresh      PeakThreshInit / Scales
float PeakThresh  /*255.0 * 0.04 / 3.0*/;

/// Decreasing EdgeThresh allows more edge points
/* This threshold eliminates responses at edges.  A value of 0.08 means
   that the ratio of the largest to smallest eigenvalues (principle
   curvatures) is below 10.  A value of 0.14 means ratio is less than 5.
   A value of 0.0 does not eliminate any responses.
   Threshold at first octave is different.
*/
float  EdgeThresh  /*0.06*/;
float  EdgeThresh1 /*0.08*/;


/* OriBins gives the number of bins in the histogram (36 gives 10
   degree spacing of bins).
*/
int OriBins  /*36*/;


/* Size of Gaussian used to select orientations as multiple of scale
     of smaller Gaussian in DOG function used to find keypoint.
     Best values: 1.0 for UseHistogramOri = FALSE; 1.5 for TRUE.
*/
float OriSigma  /*1.5*/;


/// Look for local (3-neighborhood) maximum with valuer larger or equal than OriHistThresh * maxval
///  Setting one returns a single peak
/* All local peaks in the orientation histogram are used to generate
   keypoints, as long as the local peak is within OriHistThresh of
   the maximum peak.  A value of 1.0 only selects a single orientation
   at each location.
*/
float OriHistThresh  /*0.8*/;


/// Feature vector is normalized to has euclidean norm 1.
/// This threshold avoid the excessive concentration of information on single peaks
/* Index values are thresholded at this value so that regions with
   high gradients do not need to match precisely in magnitude.
   Best value should be determined experimentally.  Value of 1.0
   has no effect.  Value of 0.2 is significantly better.
*/
float  MaxIndexVal  /*0.2*/;


/* This constant specifies how large a region is covered by each index
   vector bin.  It gives the spacing of index samples in terms of
   pixels at this scale (which is then multiplied by the scale of a
   keypoint).  It should be set experimentally to as small a value as
   possible to keep features local (good values are in range 3 to 5).
*/
int  MagFactor   /*3*/;


/* Width of Gaussian weighting window for index vector values.  It is
   given relative to half-width of index, so value of 1.0 means that
   weight has fallen to about half near corners of index patch.  A
   value of 1.0 works slightly better than large values (which are
   equivalent to not using weighting).  Value of 0.5 is considerably
   worse.
*/
float   IndexSigma  /*1.0*/;

/* If this is TRUE, then treat gradients with opposite signs as being
   the same.  In theory, this could create more illumination invariance,
   but generally harms performance in practice.
*/
int  IgnoreGradSign  /*0*/;



float ratiomax  /*0.6*/;
float distmax;			/*0*/
/*
   In order to constrain the research zone for matches.
   Useful for example when looking only at epipolar lines
*/

float MatchXradius /*= 1000000.0f*/;
float MatchYradius /*= 1000000.0f*/;
float MatchRatio;

int noncorrectlylocalized;

int UseOrsa;	//do filtering	/*1*/
int UseN1;		// do n_1 filtering	/*1*/
int Use1N;		// do 1_nfiltering	/*1*/
float MatchRatio_low;
int lib_verbal;					/*0*/
};

void readCudaDevice();

// FOR SIFTGPU
#if defined(USE_SIFTGPU)
typedef std::vector<unsigned char> siftgpu_keypointslist;

int AsiftGen_Cuda(
	const float const*,
	int, int, int,
	vector<vector<keypointslist>>&);

int AsiftGen_Cuda_Filtered(
	const float const*,
	int,
	int,
	int,
	vector<vector<keypointslist>>&
	);
#endif


