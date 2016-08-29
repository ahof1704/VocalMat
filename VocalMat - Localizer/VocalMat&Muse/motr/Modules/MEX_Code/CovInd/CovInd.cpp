#include <stdio.h>
#include "mex.h"

void mexFunction( int nlhs, mxArray *plhs[], 
				 int nrhs, const mxArray *prhs[] ) 
{

	float *Features = (float *)mxGetData(prhs[0]);
	const int *Dim = mxGetDimensions(prhs[0]);
	int iNumFeatures = Dim[0];
	int iFeatureDim = Dim[1];

	double *Ind_Dbl= (double *)mxGetData(prhs[1]);
	const int *Dim1 = mxGetDimensions(prhs[1]);
	int iNumIndices = Dim1[0] > Dim1[1] ? Dim1[0] : Dim1[1];


	int *Ind = new int[iNumIndices];
	for (int k=0;k<iNumIndices;k++) {
		Ind[k] = (int)(Ind_Dbl[k]-1);
	}

	int  dim_array[2];  
	dim_array[0] = iFeatureDim;
	dim_array[1] = iFeatureDim; 
	plhs[0] = mxCreateNumericArray(2, dim_array, mxDOUBLE_CLASS, mxREAL);
	double *Cov= (double *)mxGetPr(plhs[0]);
 

	int  dim_array1[2];  
	dim_array1[0] = 1;
	dim_array1[1] = iFeatureDim; 
	plhs[1] = mxCreateNumericArray(2, dim_array1, mxDOUBLE_CLASS, mxREAL);
	double *afMean = (double *)mxGetPr(plhs[1]);

	
	// First, compute mean
	int q = 0;
	
	for (int i = 0; i < iFeatureDim; i++) {
		double sum = 0;
		int iOffset = i*iNumFeatures;
		for (int j = 0; j < iNumIndices; j++) {
			sum += Features[iOffset +Ind[j]];
		}
		afMean[i] = sum / iNumIndices;
	}


	for (int i=0;i<iFeatureDim; i++) {
		for (int j=i;j<iFeatureDim; j++) {
			
			double sum = 0;
			int iOffsetI = i * iNumFeatures;
			int iOffsetJ = j * iNumFeatures;
			for (int k=0;k<iNumIndices;k++) { 
				//sum += (Features[k,i] - afMean[i]) *  (Features[k,j] - afMean[j]);;
				sum += (Features[Ind[k] + iOffsetI] - afMean[i]) *  
					   (Features[Ind[k] + iOffsetJ] - afMean[j]);
			}

			Cov[i*iFeatureDim+j] = sum;
			Cov[j*iFeatureDim+i] = sum;
		}
	}


	delete [] Ind;	

}

