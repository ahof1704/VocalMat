#include <stdio.h>
#include "mex.h"

void mexFunction( int nlhs, mxArray *plhs[], 
				 int nrhs, const mxArray *prhs[] ) 
{

	float *Features = (float *)mxGetData(prhs[0]);
	const int *Dim = mxGetDimensions(prhs[0]);
	int iNumFeatures = Dim[0];
	int iFeatureDim = Dim[1];

	double *W = (double *)mxGetData(prhs[1]);

	double *Ind_Dbl= (double *)mxGetData(prhs[2]);
	const int *Dim1 = mxGetDimensions(prhs[2]);
	int iNumIndices = Dim1[0] > Dim1[1] ? Dim1[0] : Dim1[1];

	int *Ind = new int[iNumIndices];
	for (int k=0;k<iNumIndices;k++) {
		Ind[k] = (int)(Ind_Dbl[k]-1);
	}


	int  dim_array[2];  
	dim_array[0] = 1;
	dim_array[1] = iNumIndices; 
	plhs[0] = mxCreateNumericArray(2, dim_array, mxDOUBLE_CLASS, mxREAL);
	double *Mult= (double *)mxGetPr(plhs[0]);
 
	for (int i =0; i<iNumIndices;i++) {

		double sum = 0;
		for (int k = 0; k < iFeatureDim;k++) {
			sum += W[k] * Features[k*iNumFeatures +Ind[i]];
		}
		Mult[i]= sum;
	}


	delete [] Ind;	

}

