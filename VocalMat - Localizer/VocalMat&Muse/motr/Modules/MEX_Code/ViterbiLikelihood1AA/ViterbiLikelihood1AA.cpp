#include <stdio.h>
#include "mex.h"
#include <math.h>
const float PI = 3.14159265;
/* This dll is implements the computation of state likelihood */

void mexFunction(int nlhs, mxArray *plhs[], 
                 int nrhs, const mxArray *prhs[] ) {

  /* Check for proper number of input and output arguments. */    
  if (nrhs != 2 || nlhs != 1) {
    mexErrMsgTxt("Usage: [a2fLikelihood] = fnViterbiLikelihood1AA(a2iAllStates,a3fLogProb)");
    // a3fLogProb has the size of [iNumFrames, iNumClassifiers, iNumMice ]
    // That is, a3fLogProb(:,:,1), gives the results of applying various classifiers in all frames, for tracker 1
    return;
  } 

  double *a2iAllStates = (double *)mxGetData(prhs[0]);
  float *a3fLogProb = (float*)mxGetData(prhs[1]); // Mice X Classifiers X NumFrames
  const int *Dim = mxGetDimensions(prhs[0]);
  int iNumStates = Dim[1];

  const int *Dim1 = mxGetDimensions(prhs[1]);
  // if iNumMice==1, then the dimension array will be of length 2
  int iNumMice;
  if (mxGetNumberOfDimensions(prhs[1])>=3) {
    iNumMice = Dim1[2];
  }
  else {
    iNumMice = 1;
  }
  int iNumFrames = Dim1[0];
  int iNumClassifiers = Dim1[1];  

  // Create output
  int  dim_array[2];  
  dim_array[0] = iNumStates;
  dim_array[1] = iNumFrames;
  plhs[0] = mxCreateNumericArray(2, dim_array, mxDOUBLE_CLASS, mxREAL);
  double *a2fLikelihood = (double*)mxGetPr(plhs[0]);

  for (int iFrameIter=0;iFrameIter < iNumFrames;iFrameIter++) {
    for (int iStateIter = 0; iStateIter < iNumStates; iStateIter++) {
      float fSumLogLikelihood = 0;
      for (int iMouseIter= 0;iMouseIter < iNumMice; iMouseIter++) {
        int iClass = int(a2iAllStates[  iStateIter*iNumMice+iMouseIter])-1;
        //fSumLogLikelihood += a3fLogProb[iMouseIter * (iNumFrames*iNumClassifiers) + iClass * iNumFrames + iFrameIter];
        fSumLogLikelihood += a3fLogProb[iClass * (iNumFrames*iNumClassifiers) +  iMouseIter* iNumFrames + iFrameIter];
      }
      a2fLikelihood[iStateIter+iFrameIter*iNumStates] = fSumLogLikelihood;
    }
  }
   
}

