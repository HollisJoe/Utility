#include "mex.h"
#include "libASIFT.h"
#pragma comment(lib, "libASIFT.lib")


/* The gateway function */
void mexFunction(int nlhs, mxArray *plhs[],
	int nrhs, const mxArray *prhs[])
{
	float *data = (float *)mxGetPr(prhs[0]);
	int width = mxGetN(prhs[0]);
	int height = mxGetM(prhs[0]);

	// construct FRAME
	int numTilts = 7,  flag_resize = 0;
	FRAME F = { data, height, width, numTilts, flag_resize, 0, NULL, NULL };

	// extract ASIFT feature
	extractASIFT(F);

	// write f1,d1
	int number = F.num_keys;
	plhs[0] = mxCreateNumericMatrix(4, number, mxSINGLE_CLASS, mxREAL);
	plhs[1] = mxCreateNumericMatrix(128, number, mxSINGLE_CLASS, mxREAL);
	double *f = mxGetPr(plhs[0]), *d = mxGetPr(plhs[1]);
	memcpy(f, F.kpts, 4 * sizeof(float)* number);
	memcpy(d, F.desp, 128 * sizeof(float)* number);
	/* code here */
}

