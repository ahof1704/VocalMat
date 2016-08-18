#include <stdio.h>
#include "mex.h"
#include <math.h>
const float PI = 3.14159265;
/* This dll is implements the computation of state likelihood */
/*
function afLogProb = fnViterbiProbObsAllStatesExp(a2iAllStates, a3fObs, a2fMu, a2fSig)
% Computes the log likelihood of seeing a observation given the system
% state.
%
% Inputes:
%  aiStatePerm - System state, given as a permutation.
%  a2fObs - Observation matrix (NumMice x NumClassifiers)
%  a2fMu, a2fSig - Probability density functions of classifiers response.
%
% Outputs:
%  fLogProb - log likelihood
%
%Copyright (c) 2008 Shay Ohayon, California Institute of Technology. 
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

iNumClassifiers = size(a2fMu,2);
iNumStates = size(a2iAllStates,1);
iNumMice = size(a2iAllStates,2);
afLogProb = zeros(1,iNumStates);

a2iRelevantClassifiers = [1,2,3;
                          1,4,5;
                          2,4,6;
                          3,5,6];

fUnreliableSample = -50;
for iStateIter=1:iNumStates
    a2bInvalid = zeros(iNumMice, iNumClassifiers) >0;
    a2fProb = zeros(iNumMice, iNumClassifiers);
    aiStatePerm = a2iAllStates(iStateIter,:);
    for iMouseIter=1:iNumMice
        for iClassIter=a2iRelevantClassifiers(iMouseIter,:) % 1:iNumClassifiers
            x = a2fObs(aiStatePerm(iMouseIter),iClassIter);
            mu = a2fMu(iMouseIter,iClassIter);
            sigma = a2fSig(iMouseIter,iClassIter);
            y = (-0.5 * ((x - mu)./sigma).^2) - log((sqrt(2*pi) .* sigma));
            a2bInvalid(iMouseIter,iClassIter) = abs(x-mu) > sigma;
            a2fProb(iMouseIter,iClassIter) = y;%log(normpdf(x,mu,sigma));
        end;
    end;
    a2fProb(a2bInvalid) = fUnreliableSample;
    afLogProb(iStateIter) = sum((a2fProb(:)));%log
end;
    
return;
*/

void mexFunction( int nlhs, mxArray *plhs[], 
				 int nrhs, const mxArray *prhs[] ) {

  /* Check for proper number of input and output arguments. */    
  if (nrhs != 4 || nlhs != 1) {
    mexErrMsgTxt("Usage: [a2fLikelihood] = fnViterbiLikelihood(a2iAllStates,a3fClassifiersResult, a2fMu, a2fSig)");
	return;
  } 

	double *a2iAllStates = (double *)mxGetData(prhs[0]);
	float *a3fClassifiersResult = (float*)mxGetData(prhs[1]); // Mice X Classifiers X NumFrames
	double *a2fMu = (double *)mxGetData(prhs[2]);
	double *a2fSig = (double *)mxGetData(prhs[3]);

	const int *Dim = mxGetDimensions(prhs[0]);
	int iNumStates = Dim[1];

	const int *Dim1 = mxGetDimensions(prhs[1]);
	int iNumMice = Dim1[0];
	int iNumFrames = Dim1[2];
	int iNumClassifiers = Dim1[1];


	int iNumRelevantClassifiers = 3;
 const float fUnreliableSample = -50;

  // Create output
  int  dim_array[2];  
  dim_array[0] = iNumStates;
  dim_array[1] = iNumFrames;
  plhs[0] = mxCreateNumericArray(2, dim_array, mxDOUBLE_CLASS, mxREAL);
  double *a2fLikelihood = (double*)mxGetPr(plhs[0]);



  const int a2iRelevantClassifiers[4][3] = { {1,2,3}, {1,4,5}, {2,4,6}, {3,5,6} };


  for (int iFrameIter=0;iFrameIter < iNumFrames;iFrameIter++) {
	  for (int iStateIter = 0; iStateIter < iNumStates; iStateIter++) {

		  float fSumLogLikelihood = 0;
		  for (int iMouseIter= 0;iMouseIter < iNumMice; iMouseIter++) {
   			  int iSelectedMouse = int(a2iAllStates[ iStateIter*iNumMice+iMouseIter])-1;

			  for (int iClassIter=  0;iClassIter < iNumRelevantClassifiers; iClassIter++) {
				int iSelectedClass = int(a2iRelevantClassifiers[iMouseIter][iClassIter])-1;

				float x = a3fClassifiersResult[iFrameIter * (iNumMice*iNumClassifiers) + iSelectedClass*iNumMice + iSelectedMouse];
				float Mu = float(a2fMu[iSelectedClass*iNumMice+iMouseIter]);
				float Sig = float(a2fSig[iSelectedClass*iNumMice+iMouseIter]);
				fSumLogLikelihood += fabs(x-Mu) > Sig ? fUnreliableSample : (-0.5 * ((x - Mu)/Sig)*((x - Mu)/Sig) ) - log((sqrt(2*PI) * Sig));
			  }
		  }
		  a2fLikelihood[iStateIter+iFrameIter*iNumStates] = fSumLogLikelihood;
	  }
  }

    
}

