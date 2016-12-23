#include "compute_asift_keypoints.h"


void compensate_affine_coor1(float *x0, float *y0, int w1, int h1, float t1, float t2, float Rtheta)
{
  float x_ori, y_ori;	
  float x_tmp, y_tmp;

  float x1 = *x0;
  float y1 = *y0;


  Rtheta = Rtheta*PI/180;

  if ( Rtheta <= PI/2 )
  {
    x_ori = 0;
    y_ori = w1 * sin(Rtheta) / t1;
  }
  else
  {
    x_ori = -w1 * cos(Rtheta) / t2;
    y_ori = ( w1 * sin(Rtheta) + h1 * sin(Rtheta-PI/2) ) / t1;
  }

  float sin_Rtheta = sin(Rtheta);
  float cos_Rtheta = cos(Rtheta);


  /* project the coordinates of im1 to original image before tilt-rotation transform */
  /* Get the coordinates with respect to the 'origin' of the original image before transform */
  x1 = x1 - x_ori;
  y1 = y1 - y_ori;
  /* Invert tilt */
  x1 = x1 * t2;
  y1 = y1 * t1;
  /* Invert rotation (Note that the y direction (vertical) is inverse to the usual concention. Hence Rtheta instead of -Rtheta to inverse the rotation.) */
  x_tmp = cos_Rtheta*x1 - sin_Rtheta*y1;
  y_tmp = sin_Rtheta*x1 + cos_Rtheta*y1;
  x1 = x_tmp;
  y1 = y_tmp;		

  *x0 = x1;
  *y0 = y1;
}

/* -------------- MAIN FUNCTION ---------------------- */

int AsiftGPU(const float const* image, int width, int height, int num_tilt, vector<vector<keypointslist>>& keys_all)
{
	int tt, rr;
	int totalFeatureNum = 0;
	float BorderFact=6*sqrt(2.);
    AsiftGen_Cuda(image, width, height, num_tilt, keys_all);

#pragma omp parallel for private(tt)
	for (tt = 1; tt <= num_tilt; tt++)
	{
		int num_rot1 = keys_all[tt-1].size();
#pragma omp parallel for private(rr)
		for (rr = 1; rr <= num_rot1; rr++) 
		{
			if(keys_all[tt-1][rr-1][0].tilt == 1) cout << "Current round is: " << keys_all[tt-1][rr-1].size() << endl;
			else
			{
				float theta = keys_all[tt-1][rr-1][0].rot;
				float t1	= 1.0;
				float t2    = 1.0 / keys_all[tt-1][rr-1][0].tilt;			
				keypointslist& keypoints = keys_all[tt-1][rr-1];				
				keypointslist keypoints_filtered;

				/* check if the keypoint is located on the boundary of the parallelogram (i.e., the boundary of the distorted input image). If so, remove it to avoid boundary artifacts. */
				if ( keypoints.size() != 0 )
				{
				  for ( int cc = 0; cc < (int) keypoints.size(); cc++ )
				  {		      

					float x0, y0, x1, y1, x2, y2, x3, y3 ,x4, y4, d1, d2, d3, d4, scale1, theta1, sin_theta1, cos_theta1, BorderTh;

					x0 = keypoints[cc].x;
					y0 = keypoints[cc].y;
					scale1= keypoints[cc].scale;

					theta1 = theta * PI / 180;
					sin_theta1 = sin(theta1);
					cos_theta1 = cos(theta1);

					/* the coordinates of the 4 submits of the parallelogram */
					if ( theta <= 90 )
					{
					  x1 = height * sin_theta1;
					  y1 = 0;			 
					  y2 = width * sin_theta1;
					  x3 = width * cos_theta1;
					  x4 = 0;
					  y4 = height * cos_theta1;
					  x2 = x1 + x3;
					  y3 = y2 + y4;

					  /* note that the vertical direction goes from top to bottom!!! 
					  The calculation above assumes that the vertical direction goes from the bottom to top. Thus the vertical coordinates need to be reversed!!! */
					  y1 = y3 - y1;
					  y2 = y3 - y2;
					  y4 = y3 - y4;
					  y3 = 0;

					  y1 = y1 * t2;
					  y2 = y2 * t2;
					  y3 = y3 * t2;
					  y4 = y4 * t2;
					}
					else
					{
					  y1 = -height * cos_theta1;
					  x2 = height * sin_theta1;
					  x3 = 0;
					  y3 = width * sin_theta1;				 
					  x4 = -width * cos_theta1;
					  y4 = 0;
					  x1 = x2 + x4;
					  y2 = y1 + y3;

					  /* note that the vertical direction goes from top to bottom!!! 
					  The calculation above assumes that the vertical direction goes from the bottom to top. Thus the vertical coordinates need to be reversed!!! */
					  y1 = y2 - y1;
					  y3 = y2 - y3;
					  y4 = y2 - y4;
					  y2 = 0;

					  y1 = y1 * t2;
					  y2 = y2 * t2;
					  y3 = y3 * t2;
					  y4 = y4 * t2;
					}		       		    

					/* the distances from the keypoint to the 4 sides of the parallelogram */
					d1 = ABS((x2-x1)*(y1-y0)-(x1-x0)*(y2-y1)) / sqrt((x2-x1)*(x2-x1)+(y2-y1)*(y2-y1));
					d2 = ABS((x3-x2)*(y2-y0)-(x2-x0)*(y3-y2)) / sqrt((x3-x2)*(x3-x2)+(y3-y2)*(y3-y2));
					d3 = ABS((x4-x3)*(y3-y0)-(x3-x0)*(y4-y3)) / sqrt((x4-x3)*(x4-x3)+(y4-y3)*(y4-y3));
					d4 = ABS((x1-x4)*(y4-y0)-(x4-x0)*(y1-y4)) / sqrt((x1-x4)*(x1-x4)+(y1-y4)*(y1-y4));

					BorderTh = BorderFact*scale1;

					if (!((d1<BorderTh) || (d2<BorderTh) || (d3<BorderTh) || (d4<BorderTh) ))
					{				 					   
					  // Normalize the coordinates of the matched points by compensate the simulate affine transformations
					  compensate_affine_coor1(&x0, &y0, width, height, 1/t2, t1, theta);
					  keypoints[cc].x = x0;
					  keypoints[cc].y = y0;

					  keypoints_filtered.push_back(keypoints[cc]);	 
					}				   
				  }
				}			 
				keys_all[tt-1][rr-1] = keypoints_filtered;
			}
		}
	}
	for(tt=0; tt<keys_all.size(); tt++)
		for(rr=0; rr<keys_all[tt].size(); rr++)
			totalFeatureNum += keys_all[tt][rr].size();
	printf("%d ASIFT keypoints are detected. \n", totalFeatureNum);
    return totalFeatureNum;
}

int AsiftGPU_Filtered(const float const* image, int width, int height, int num_tilt, vector<vector<keypointslist>>& keys_all)
{
    int totalFeatureNum = AsiftGen_Cuda_Filtered(image, width, height, num_tilt, keys_all);
	printf("%d ASIFT keypoints are detected. \n", totalFeatureNum);
    return totalFeatureNum;
}

