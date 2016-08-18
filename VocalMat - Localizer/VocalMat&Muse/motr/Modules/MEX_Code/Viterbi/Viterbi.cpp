#include <stdio.h>
#include "mex.h"
#include <math.h>
/* This dll is the implementation of fnViterbi function.*/

/*
function [aiPath, a2fLogProb] = fnViterbiForwardBackward(iNumStates, iNumFrames, a3fTransitionMatrices,a2fLikelihood)
% Initialize
a2fLogProb = zeros(iNumStates, iNumFrames);
a2iUpdateLog = zeros(iNumStates, iNumFrames);
a2fLogProb(:,1) = log(1/iNumStates) + a2fLogProb(:, 1);
for iStateIter=1:iNumStates
   a2iUpdateLog(iStateIter,1) = iStateIter;
end;
% Forward algorithm

for iFrameIter=2:iNumFrames
    if size(a3fTransitionMatrices,3) > 1
        a2fLogTransition = a3fTransitionMatrices(:,:,iFrameIter);
    else
        a2fLogTransition  = a3fTransitionMatrices;
    end;
    
    for iStateIter=1:iNumStates
        afLogTransition = a2fLogTransition(iStateIter,:);
         [fMaxLogProb, iMaxIndex] = max( a2fLogProb(:, iFrameIter-1) + afLogTransition');
        a2iUpdateLog(iStateIter, iFrameIter) = iMaxIndex;
        a2fLogProb(iStateIter,iFrameIter) = fMaxLogProb + a2fLikelihood(iStateIter,iFrameIter) ;
    end;
end;
% Backward algorithm
[fDummy, iMaxIndex] = max(a2fLogProb(:, iNumFrames));
aiPath = zeros(1,iNumFrames);
aiPath(iNumFrames) = iMaxIndex;
iCurrPos = iMaxIndex;
for iBacktrack=iNumFrames-1:-1:1
    iCurrPos = a2iUpdateLog(iCurrPos, iBacktrack);
    aiPath(iBacktrack) = iCurrPos;
end;
return;
*/

void mexFunction( int nlhs, mxArray *plhs[], 
				 int nrhs, const mxArray *prhs[] ) {

  /* Check for proper number of input and output arguments. */    
  if (nrhs != 2 || nlhs != 1) {
    mexErrMsgTxt("Usage: [aiPath] = fnViterbi(a3fLogTransitionMatrices,a2fLogLikelihood)");
	return;
  } 

	float *Transition = (float *)mxGetData(prhs[0]);
	double *Likelihood = (double *)mxGetData(prhs[1]);

	const int *Dim = mxGetDimensions(prhs[1]);
	int iNumStates = Dim[0];
	int iNumFrames = Dim[1];
	// Initialize

	double *a2fLogProb = new double[iNumStates * iNumFrames];
	int *a2iUpdateLog= new int[iNumStates * iNumFrames];

	for (int k=0;k<iNumStates;k++) {
		a2fLogProb[k] = log(1.0/double(iNumStates)) + Likelihood[k];
		a2iUpdateLog[k] = k;
	}
  
  // Forward algorithm
  int b3D = mxGetNumberOfDimensions(prhs[0]) == 3;
	  
  for (int iFrameIter=1;iFrameIter < iNumFrames;iFrameIter++) {
	  int FrameOffset = b3D * iNumStates*iNumStates * iFrameIter;

	  for (int iStateIter=0;iStateIter < iNumStates;iStateIter++) {

		  // Find Max
		  double fMaxLogProb = -1e10;
		  double fNewValue;
		  int iMaxIndex = 0;
		  double fLogTransition;
		  for (int k=0;k<iNumStates;k++) {
	          fLogTransition = Transition[iStateIter+k*iNumStates+FrameOffset];
			  fNewValue = a2fLogProb[k+(iFrameIter-1)*iNumStates] + fLogTransition;
			  if (fNewValue > fMaxLogProb) {
				  fMaxLogProb = fNewValue;
				  iMaxIndex = k;
			  }
		  }
		  int iIndex = iStateIter+iFrameIter*iNumStates;
          a2iUpdateLog[iIndex] = iMaxIndex;
          a2fLogProb[iIndex] = fMaxLogProb + Likelihood[iIndex];

	  }
  }

  // Backward algorithm

  // Create output
  int  dim_array[2];  
  dim_array[0] = 1;
  dim_array[1] = iNumFrames;
  plhs[0] = mxCreateNumericArray(2, dim_array, mxDOUBLE_CLASS, mxREAL);
  double *OutputPath = (double*)mxGetPr(plhs[0]);

  // Find maximum on last column...
  int iOffset = (iNumFrames-1)*iNumStates;
  double fMaxLogProb = -1e10;
  int iMaxIndex = 0;
  for (int j=0;j<iNumStates;j++) {
	  if (a2fLogProb[iOffset+j] > fMaxLogProb) {
			fMaxLogProb = a2fLogProb[iOffset+j];
			iMaxIndex = j;
	  }
  }

  OutputPath[iNumFrames-1] = iMaxIndex+1;
  int iCurrPos = iMaxIndex;
  for (int iBacktrack=iNumFrames-2;iBacktrack>=0;iBacktrack--) {
	iCurrPos = a2iUpdateLog[iCurrPos+ (iBacktrack+1)*iNumStates];
    OutputPath[iBacktrack] = iCurrPos+1;
  }

  delete [] a2fLogProb;
  delete [] a2iUpdateLog;
}

