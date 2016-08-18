#include <stdio.h>
#include "mex.h"

void CreateOutput(double *input_image, 
				  const int  *dim_array, 
				  double *output_image) {

	long NumPixels = dim_array[0]*dim_array[1];
	long CenterIndex, LeftIndex, RightIndex, TopIndex, BottomIndex;
	double Ixx,Iyy, CenterTwice;
	for (long PixelIter= 0; PixelIter < NumPixels; PixelIter++) {
		if (input_image[PixelIter] > 0) {
			CenterIndex = PixelIter;
			LeftIndex = PixelIter-dim_array[0];
			RightIndex = PixelIter+dim_array[0];
			TopIndex = PixelIter- 1;
			BottomIndex = PixelIter+ 1;
			if (LeftIndex < 0  || LeftIndex >= NumPixels ||
				RightIndex < 0 || RightIndex >= NumPixels ||
			    TopIndex < 0   || TopIndex  >= NumPixels ||
				BottomIndex < 0 || BottomIndex  >= NumPixels)
					continue;
			CenterTwice = 2 * input_image[CenterIndex];
			Ixx = input_image[RightIndex] -CenterTwice + input_image[LeftIndex];
			Iyy = input_image[TopIndex] - CenterTwice + input_image[BottomIndex];
			output_image[PixelIter] = Ixx+Iyy;
		}
	}
}


void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] ) {

  long num_pixels;
  const int  *dim_array;  
  double *input_image, *output_image;
  
  if (nrhs != 1 || nlhs != 1) {
    mexErrMsgTxt("Usage: [a2fFlux] = fnFastFlux(a2fDistanceMap)");
	return;
  } 
  
  num_pixels = long(mxGetNumberOfElements(prhs[0]));
  dim_array = mxGetDimensions(prhs[0]);
  input_image = (double*)mxGetData(prhs[0]);

  plhs[0] = mxCreateNumericArray(2, dim_array, mxDOUBLE_CLASS, mxREAL);
  output_image = (double*)mxGetPr(plhs[0]);
 
  CreateOutput(input_image, dim_array,output_image);
}

