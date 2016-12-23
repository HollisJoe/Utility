#include "AsiftCuda_Kernel.h"

#define MAX_C(i,j) ( (i)<(j) ? (j):(i) )
#define MIN_C(i,j) ( (i)<(j) ? (i):(j) )
#define ABS_C(x)   (((x) > 0) ? (x) : (-(x)))

texture<float> texOriImg;

__device__ __constant__ float kernel_c[MAX_KERNEL_SIZE_CU];

using namespace std;

void unbindTexture_texOriImg() {
	cudaUnbindTexture(texOriImg);
}

void bindTexture_texOriImg(float* img_dev, const float const* img_host, int width, int height) {
	cudaBindTexture(NULL, texOriImg, img_dev, width*height*sizeof(float));
	cudaMemcpy(img_dev, img_host, width*height*sizeof(float), cudaMemcpyHostToDevice);
}

__global__ void frot_cu(float* data_out,float s,float c,int xi,int xa,int yi,int ya,int xo,int yo,int xn) {
	__shared__ int xmin, xmax, ymin, ymax;
	__shared__ int nx, ny, sx;
	__shared__ float sa, ca;
	if(threadIdx.x == 0 && threadIdx.y == 0) {
	xmin = xi;	xmax = xa;	ymin = yi;	ymax = ya;
	nx	 = xo;  ny   = yo;  sx   = xn;  sa   = s;	ca   = c;
	}
	__syncthreads();

	int x_bias = xmin + threadIdx.x + blockIdx.x * blockDim.x;
	int y_bias = ymin + threadIdx.y + blockIdx.y * blockDim.y;
	if(x_bias<=xmax && y_bias<=ymax) {
		float xp = ca * (float)x_bias - sa * (float)y_bias;
		float yp = sa * (float)x_bias + ca * (float)y_bias;
		int x1 = (int)floor(xp);
		int y1 = (int)floor(yp);
		float ux = xp - (float)x1;
		float uy = yp - (float)y1;
		int adr = y1 * nx + x1;
		int tx1 = (x1>=0 && x1<nx);
		int tx2 = (x1+1>=0 && x1+1<nx);
		int ty1 = (y1>=0 && y1<ny);
		int ty2 = (y1+1>=0 && y1+1<ny);

		float a11 = (tx1 && ty1? tex1Dfetch(texOriImg, adr) : 128);
		float a12 = (tx1 && ty2? tex1Dfetch(texOriImg, adr+nx) : 128);
		float a21 = (tx2 && ty1? tex1Dfetch(texOriImg, adr+1) : 128);
		float a22 = (tx2 && ty2? tex1Dfetch(texOriImg, adr+nx+1) : 128);

		data_out[(y_bias-ymin)*sx+x_bias-xmin] = 
			(1.0-uy)*((1.0-ux)*a11+ux*a21)+uy*((1.0-ux)*a12+ux*a22);
	}
}

template<int COLUMNS_BLOCKDIM_X, int COLUMNS_BLOCKDIM_Y>
__global__ void convolutionColumnsKernel(
    float *d_Dst,
    float *d_Src,
    int imageW,
    int imageH,
    int pitch
)
{
	__shared__ int image_size;
    __shared__ float s_Data[COLUMNS_BLOCKDIM_X][(COLUMNS_RESULT_STEPS + 2 * COLUMNS_HALO_STEPS) * COLUMNS_BLOCKDIM_Y + 1];
	int tmp;
	if(threadIdx.x == 0 && threadIdx.y == 0) image_size = imageW * imageH;
	__syncthreads();

    //Offset to the upper halo edge
    const int baseX = blockIdx.x * COLUMNS_BLOCKDIM_X + threadIdx.x;
	if(baseX >= imageW) goto out_of_bound;
    const int baseY = (blockIdx.y * COLUMNS_RESULT_STEPS - COLUMNS_HALO_STEPS) * COLUMNS_BLOCKDIM_Y + threadIdx.y;
	const int upper_initial = baseY * pitch + baseX;
	d_Src += upper_initial;
	d_Dst += upper_initial;

    //Main data
#pragma unroll

    for (int i = COLUMNS_HALO_STEPS; i < COLUMNS_HALO_STEPS + COLUMNS_RESULT_STEPS; i++)
    {
		tmp = i * COLUMNS_BLOCKDIM_Y * pitch;
		s_Data[threadIdx.x][threadIdx.y + i * COLUMNS_BLOCKDIM_Y] = (upper_initial + tmp < image_size)? d_Src[tmp] : 0;
    }

    //Upper halo
#pragma unroll

    for (int i = 0; i < COLUMNS_HALO_STEPS; i++)
    {
        s_Data[threadIdx.x][threadIdx.y + i * COLUMNS_BLOCKDIM_Y] = (baseY >= -i * COLUMNS_BLOCKDIM_Y) ? d_Src[i * COLUMNS_BLOCKDIM_Y * pitch] : 0;
    }

    //Lower halo
#pragma unroll

    for (int i = COLUMNS_HALO_STEPS + COLUMNS_RESULT_STEPS; i < COLUMNS_HALO_STEPS + COLUMNS_RESULT_STEPS + COLUMNS_HALO_STEPS; i++)
    {
		tmp = i * COLUMNS_BLOCKDIM_Y * pitch;
        s_Data[threadIdx.x][threadIdx.y + i * COLUMNS_BLOCKDIM_Y] = (upper_initial + tmp < image_size)? d_Src[tmp] : 0;
    }

    //Compute and store results
    __syncthreads();
#pragma unroll

    for (int i = COLUMNS_HALO_STEPS; i < COLUMNS_HALO_STEPS + COLUMNS_RESULT_STEPS; i++)
    {
		tmp = i * COLUMNS_BLOCKDIM_Y * pitch;
		if(upper_initial + tmp >= image_size) break;
        float sum = 0;
#pragma unroll

        for (int j = -COLUMNS_BLOCKDIM_Y; j <= COLUMNS_BLOCKDIM_Y; j++)
        {
            sum += kernel_c[COLUMNS_BLOCKDIM_Y - j] * s_Data[threadIdx.x][threadIdx.y + i * COLUMNS_BLOCKDIM_Y + j];
        }

        d_Dst[tmp] = sum;
    }
out_of_bound:
}

__device__ void compensate_affine_coor_CU(float* x0, float* y0, int w1, int h1, float t1, float t2, float Rtheta) {
	float x_ori, y_ori;
	float x1 = *x0, y1 = *y0;
	Rtheta = Rtheta * PI_CU / 180;
	if(Rtheta <= 1.57079632679489661923) {
		x_ori = 0;
		y_ori = w1 * sin(Rtheta) / t1;
	} else {
		x_ori = -w1 * cos(Rtheta) / t2;
		y_ori = ( w1 * sin(Rtheta) + h1 * sin(Rtheta-1.57079632679489661923) ) / t1;
	}
	float sin_Rtheta = sin(Rtheta);
	float cos_Rtheta = cos(Rtheta);
	x1	= (x1 - x_ori) * t2;
	y1	= (y1 - y_ori) * t1;
	*x0 = cos_Rtheta * x1 - sin_Rtheta * y1;
	*y0 = sin_Rtheta * x1 + cos_Rtheta * y1;
}

__global__ void filterKernel(
	float4* keys,
	int* index, int* filtered_num,
	int feature_numG, int widthG, int heightG,
	float sin_thetaG, float cos_thetaG, float thetaG, float t2G
	) 
{
	__shared__ int   blockCounter;
	__shared__ int	 feature_num, width, height;
	__shared__ float sin_theta1, cos_theta1, theta, t2;
	if(threadIdx.x == 0) {
		feature_num = feature_numG; blockCounter = 0;
		width		= widthG;		height		 = heightG;
		sin_theta1	= sin_thetaG;	cos_theta1	 = cos_thetaG;
		theta		= thetaG;		t2			 = t2G;
	}
	__syncthreads();

	int x_id = blockIdx.x * blockDim.x + threadIdx.x;
	if(x_id < feature_num) {
		float x0, y0, x1, y1, x2, y2, x3, y3, x4, y4, d1, d2, d3, d4, BorderTh;
		float4 current_key = keys[x_id];
		x0 = current_key.x;
		y0 = current_key.y;
		if(theta <= 90) {
			x1 = height * sin_theta1;
			y1 = 0;			 
			y2 = width * sin_theta1;
			x3 = width * cos_theta1;
			x4 = 0;
			y4 = height * cos_theta1;
			x2 = x1 + x3;
			y3 = y2 + y4;
			y1 = y3 - y1;
			y2 = y3 - y2;
			y4 = y3 - y4;
			y3 = 0;
			y1 = y1 * t2;
			y2 = y2 * t2;
			y3 = y3 * t2;
			y4 = y4 * t2;
		} else {
			y1 = -height * cos_theta1;
			x2 = height * sin_theta1;
			x3 = 0;
			y3 = width * sin_theta1;				 
			x4 = -width * cos_theta1;
			y4 = 0;
			x1 = x2 + x4;
			y2 = y1 + y3;
			y1 = y2 - y1;
			y3 = y2 - y3;
			y4 = y2 - y4;
			y2 = 0;
			y1 = y1 * t2;
			y2 = y2 * t2;
			y3 = y3 * t2;
			y4 = y4 * t2;
		}
		d1 = ABS_C((x2-x1)*(y1-y0)-(x1-x0)*(y2-y1)) / sqrt((x2-x1)*(x2-x1)+(y2-y1)*(y2-y1));
		d2 = ABS_C((x3-x2)*(y2-y0)-(x2-x0)*(y3-y2)) / sqrt((x3-x2)*(x3-x2)+(y3-y2)*(y3-y2));
		d3 = ABS_C((x4-x3)*(y3-y0)-(x3-x0)*(y4-y3)) / sqrt((x4-x3)*(x4-x3)+(y4-y3)*(y4-y3));
		d4 = ABS_C((x1-x4)*(y4-y0)-(x4-x0)*(y1-y4)) / sqrt((x1-x4)*(x1-x4)+(y1-y4)*(y1-y4));
		BorderTh = 8.4852813 * current_key.z;
		if (!((d1<BorderTh) || (d2<BorderTh) || (d3<BorderTh) || (d4<BorderTh) )) {
			compensate_affine_coor_CU(&x0, &y0, width, height, 1/t2, 1.0, theta);
			keys[x_id].x = x0;
			keys[x_id].y = y0;
			index[x_id]	 = 1;
			atomicAdd(&blockCounter, 1);
		}
		else index[x_id] = 0;
	}
	__syncthreads();
	if(threadIdx.x == 0)
		atomicAdd(filtered_num, blockCounter);
}

void generate_kernel(float*& kernel_h, int& ksize, float sigma) {
	float x, sum = 0.0;
	ksize = (int)(2.0 * GaussTruncate_cu * sigma + 1.0);
	ksize = MAX_C(3, ksize);
	if(ksize%2 == 0) ksize++;
	assert(ksize < MAX_KERNEL_SIZE_CU);
	kernel_h = (float*)malloc(ksize * sizeof(float));
	for(int i=0; i<ksize; i++) {
		x = i - ksize / 2;
		kernel_h[i] = exp(-x * x / (2.0 * sigma * sigma));
		sum += kernel_h[i];
	}
	for(int i=0; i<ksize; i++) kernel_h[i] /= sum;
}

void bound_CU(int x, int y, float ca, float sa, int *xmin, int *xmax, int *ymin, int *ymax)
{   
    int rx,ry;
	
    rx = (int)floor(ca*(float)x+sa*(float)y);
    ry = (int)floor(-sa*(float)x+ca*(float)y);
    if (rx<*xmin) *xmin=rx; if (rx>*xmax) *xmax=rx;
    if (ry<*ymin) *ymin=ry; if (ry>*ymax) *ymax=ry;
}

template<int COLUMNS_BLOCKDIM_X, int COLUMNS_BLOCKDIM_Y>
void convolutionVerticalCuda(float*& rot_d, float*& blurred_d, int width, int height) {
	cudaMalloc((void**)&blurred_d, height*width*sizeof(float));
	dim3 blocks((width+COLUMNS_BLOCKDIM_X-1)/COLUMNS_BLOCKDIM_X, (height+COLUMNS_RESULT_STEPS*COLUMNS_BLOCKDIM_Y-1)/(COLUMNS_RESULT_STEPS*COLUMNS_BLOCKDIM_Y));
	dim3 threads(COLUMNS_BLOCKDIM_X, COLUMNS_BLOCKDIM_Y);
	convolutionColumnsKernel<COLUMNS_BLOCKDIM_X,COLUMNS_BLOCKDIM_Y><<<blocks, threads>>>(blurred_d, rot_d, width, height, width);
	cudaFree(rot_d);
}

void frotCuda(float*& output_d, int width, int height, int& widthO, int& heightO, float* theta) {
	int xmin=0, xmax=0, ymin=0, ymax=0;
	float ca = (float)cos((double)(*theta)*PI_CU/180.0);
	float sa = (float)sin((double)(*theta)*PI_CU/180.0);
	bound_CU(width-1,0,ca,sa,&xmin,&xmax,&ymin,&ymax);
	bound_CU(0,height-1,ca,sa,&xmin,&xmax,&ymin,&ymax);
	bound_CU(width-1,height-1,ca,sa,&xmin,&xmax,&ymin,&ymax);
	widthO = xmax - xmin + 1;
	heightO = ymax - ymin + 1;
	cudaMalloc((void**)&output_d, heightO*widthO*sizeof(float));

	dim3 blocks((widthO+15)/16, (heightO+15)/16);
	dim3 threads(16, 16);
	frot_cu<<<blocks, threads>>>(output_d, sa, ca, xmin, xmax, ymin, ymax, width, height, widthO);
}

void gaussianVerticalCuda(float*& rot_d, float*& blurred_d, int width, int height, float sigma) {
	int size_kernel;
	float* kernel_h;
	generate_kernel(kernel_h, size_kernel, sigma);
	cudaMemcpyToSymbol(kernel_c, kernel_h, size_kernel*sizeof(float));
	free(kernel_h);

	switch(size_kernel) {
	case 11:	convolutionVerticalCuda<32,5>(rot_d, blurred_d, width, height); break;
	case 13:	convolutionVerticalCuda<32,6>(rot_d, blurred_d, width, height); break;
	case 19:	convolutionVerticalCuda<16,9>(rot_d, blurred_d, width, height); break;
	case 27:	convolutionVerticalCuda<16,13>(rot_d, blurred_d, width, height); break;
	case 37:	convolutionVerticalCuda<16,18>(rot_d, blurred_d, width, height); break;
	case 53:	convolutionVerticalCuda<8,26>(rot_d, blurred_d, width, height); break;
	default:	break;
	}
}

void warpCuda(float*& blurred_d, float*& warped_d, float t1, float t2, int widthRot, int heightRot, int widthTilt, int heightTilt) {
	NppiSize src_size = {widthRot, heightRot};
	NppiRect src_roi  = {0,0,widthRot,heightRot};
	NppiRect dst_roi  = {0,0,widthTilt,heightTilt};
	int pitchIn  = widthRot * sizeof(float);
	int pitchOut = widthTilt * sizeof(float);
	double coeffs[2][3] = {{t1,0,0},{0,t2,0}};
	cudaMalloc((void**)&warped_d, heightTilt*widthTilt*sizeof(float));
	nppiWarpAffine_32f_C1R((Npp32f*)blurred_d, src_size, pitchIn, src_roi, (Npp32f*)warped_d, pitchOut, dst_roi, coeffs, NPPI_INTER_LINEAR);
	cudaFree(blurred_d);
}

void filterPoints(
	float4* keys_host,
	int* index_host, int* filtered_num_host,
	int feature_num, int width, int height,
	float sin_theta1, float cos_theta1, float theta, float t2
	)
{
	int*	index_dev, *filtered_num_dev;
	float4* keys_dev;
	cudaMalloc((void**)&filtered_num_dev	, sizeof(int));
	cudaMalloc((void**)&index_dev			, feature_num * sizeof(int));
	cudaMalloc((void**)&keys_dev			, feature_num * sizeof(float4));
	cudaMemcpy(keys_dev, keys_host, feature_num * sizeof(float4), cudaMemcpyHostToDevice);
	cudaMemcpy(filtered_num_dev, filtered_num_host, sizeof(int), cudaMemcpyHostToDevice);
	filterKernel<<<(feature_num+255)/256, 256>>>(keys_dev, index_dev, filtered_num_dev,
		feature_num, width, height, sin_theta1, cos_theta1, theta, t2);
	cudaMemcpy(keys_host, keys_dev, feature_num * sizeof(float4), cudaMemcpyDeviceToHost);
	cudaMemcpy(index_host, index_dev, feature_num * sizeof(int), cudaMemcpyDeviceToHost);
	cudaMemcpy(filtered_num_host, filtered_num_dev, sizeof(int), cudaMemcpyDeviceToHost);
	cudaFree(index_dev);
	cudaFree(filtered_num_dev);
	cudaFree(keys_dev);
}