#include <stdio.h>
#include "mex.h"

/* This dll is the implementation of fnLabelsHist function.
The input to the function is:
a3iLabeledVolume - a 3D labeled volume of type uint16. 

The output of the algorithm is
afHist - a histogram of occurence values of labels
*/

template<class T> int FindMaxComponent(T* input_volume, int num_voxels) {
  int MaxComponent = 0;
  int component;
  for (long k=0;k<num_voxels;k++) {
    // added explicit to conversion to int --ALT, 2011/10/19
	component = int(input_volume[k]);
	if (component>MaxComponent)
		MaxComponent = component;
  }
  return MaxComponent;
}

template<class T> void CalcHistogram(float *ComponentHistogram, T* input_volume, int num_voxels) {
  for (long k=0;k<num_voxels;k++) 
		ComponentHistogram[(unsigned int)(input_volume[k])]++;
}

/* Entry Points */
void mexFunction( int nlhs, mxArray *plhs[], 
				 int nrhs, const mxArray *prhs[] ) {

  int MaxComponent;
  int  dim_array[2];  
  float *ComponentHistogram;

  /* Check for proper number of input and output arguments. */    
  if (nrhs != 1 || nlhs != 1) {
    mexErrMsgTxt("Usage: [aiHist] = fnLabelsHist(X)");
	return;
  } 

  if (mxIsUint16(prhs[0])) 
	  MaxComponent = FindMaxComponent((unsigned short *)mxGetData(prhs[0]), mxGetNumberOfElements(prhs[0]));
  else if (mxIsUint32(prhs[0]))
	  MaxComponent = FindMaxComponent((int *)mxGetData(prhs[0]), mxGetNumberOfElements(prhs[0]));
  else if (mxIsSingle(prhs[0]))
	  MaxComponent = FindMaxComponent((float *)mxGetData(prhs[0]), mxGetNumberOfElements(prhs[0]));
  else if (mxIsDouble(prhs[0]))
	  MaxComponent = FindMaxComponent((double *)mxGetData(prhs[0]), mxGetNumberOfElements(prhs[0]));
  else {
		mexErrMsgTxt("Use uint16, uint32, float or double only");
		return;
  }

  dim_array[0] = 1;
  dim_array[1] = MaxComponent+1;
  plhs[0] = mxCreateNumericArray(2, dim_array, mxSINGLE_CLASS, mxREAL);
  ComponentHistogram = (float*)mxGetPr(plhs[0]);
  
  if (mxIsUint16(prhs[0])) 
	  CalcHistogram(ComponentHistogram, (unsigned short *)mxGetData(prhs[0]), mxGetNumberOfElements(prhs[0]));
  else if (mxIsUint32(prhs[0]))
	  CalcHistogram(ComponentHistogram, (int *)mxGetData(prhs[0]), mxGetNumberOfElements(prhs[0]));
  else if (mxIsSingle(prhs[0]))
	  CalcHistogram(ComponentHistogram, (float *)mxGetData(prhs[0]), mxGetNumberOfElements(prhs[0]));
  else if (mxIsDouble(prhs[0]))
	  CalcHistogram(ComponentHistogram, (double *)mxGetData(prhs[0]), mxGetNumberOfElements(prhs[0]));
  else {
		mexErrMsgTxt("Use uint16, uint32, float or double only");
		return;
  }

}

