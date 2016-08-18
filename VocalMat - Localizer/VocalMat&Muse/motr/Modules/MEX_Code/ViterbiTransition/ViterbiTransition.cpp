#include <stdio.h>
#include "mex.h"
#include <math.h>


void mexFunction( int nlhs, mxArray *plhs[], 
				 int nrhs, const mxArray *prhs[] ) {

  /* Check for proper number of input and output arguments. */    
  if (nrhs != 4 || nlhs != 1) {
    mexErrMsgTxt("Usage: [a3fTransition] = fnViterbiLikelihood(a3bEllipseIntersection, a2iPairToCol, a2iSwapLookup, fSwapPenalty)");
	return;
  } 

	unsigned char *a3bIntersections = (unsigned char*)mxGetData(prhs[0]); 
	const int *Dim1 = mxGetDimensions(prhs[0]);
	int iNumMice = Dim1[0];
	int iNumFrames = Dim1[2];

	double *a2iPairToCol = (double*)mxGetPr(prhs[1]);
	double *a2iSwapLookup =(double*) mxGetPr(prhs[2]);
	double fSwapPenalty = *(double*)mxGetPr(prhs[3]);

	const int *Dim = mxGetDimensions(prhs[2]);
	int iNumStates = Dim[0];


	// Create output
  int  dim_array[3];  
  dim_array[0] = iNumStates;
  dim_array[1] = iNumStates;
  dim_array[2] = iNumFrames;
  plhs[0] = mxCreateNumericArray(3, dim_array, mxSINGLE_CLASS, mxREAL);
  float *a3fLogTransition = (float*)mxGetPr(plhs[0]);


  float *a2fLogProb = new float[iNumStates*iNumStates];
  const float fLogZero = -50000;
  
  for (int iFrameIter=0;iFrameIter < iNumFrames;iFrameIter++) {

	  // Initialize a2fTransition to I
	  for (int i = 0; i < iNumStates*iNumStates; i++)
		  a2fLogProb[i] = fLogZero;
	  for (int i = 0; i < iNumStates; i++) {
		  a2fLogProb[i*iNumStates+i] = 0;
	  }


	  // Count number of intersections
	  int iNumIntersections = 0;
	  for (int i = 0; i < iNumMice;i++) 
		  for (int j=i+1; j< iNumMice; j++) 
			  iNumIntersections += (a3bIntersections[iFrameIter*iNumMice*iNumMice + i*iNumMice + j]);

	  if (iNumIntersections > 0) {
		  // fill in...
		  for (int i = 0; i < iNumMice;i++) {
			  for (int j=i+1; j< iNumMice; j++) {
				  if (a3bIntersections[iFrameIter*iNumMice*iNumMice + i*iNumMice + j]) {
					  int iSelectedCol = int(a2iPairToCol[i*iNumMice+j]-1);
					  for (int iStateIter=0;iStateIter<iNumStates;iStateIter++) {
						  int iNewState = int(a2iSwapLookup[iSelectedCol*iNumStates + iStateIter]-1); // col
						  a2fLogProb[iNewState*iNumStates + iStateIter] = log(1.0/float(iNumIntersections));
					  }
				  }
			  }
		  }
	

		  for (int i=0; i<iNumStates;i++) {
			  for (int j=0; j<iNumStates;j++)  {
				  if (i != j)
					  a2fLogProb[i*iNumStates + j] += fSwapPenalty;
			  }
		  }
	  }

	  // Copy to output
	  long offset = iFrameIter * iNumStates*iNumStates;
	  for (int j=0;j < iNumStates*iNumStates; j++)
		a3fLogTransition[offset+j] = a2fLogProb[j];
  }
  
  delete a2fLogProb;
 }

