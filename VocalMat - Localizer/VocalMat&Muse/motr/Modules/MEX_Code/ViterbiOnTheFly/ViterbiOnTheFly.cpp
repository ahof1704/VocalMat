#include <stdio.h>
#include "mex.h"
#include <math.h>
#include <memory.h>

/* This dll is the implementation of fnViterbi with on the fly generation of transition matrices .*/

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



bool LineSegmentIntersection(float Ax, float Ay, float Bx, float By,
							 float Cx, float Cy, float Dx, float Dy) {


float fDetMEps = (float)1e-8;

float DetM = (Ax-Bx) * (Dy-Cy) - (Dx-Cx)*(Ay-By);


if (DetM > -fDetMEps && DetM < fDetMEps)
   return false;
            
 float U = ( (Dx-Bx) * (Dy-Cy) - (Dx-Cx)*(Dy-By)) / DetM;
 float V = ( (Ax-Bx) * (Dy-By) - (Dx-Bx)*(Ay-By)) / DetM;

 return (U >= 0 && U <= 1 && V >= 0 && V <= 1 );
}


void GetEllipseBBox(float X, float Y, float A, float B, float T,
float &L0_Ax, float &L0_Ay, float &L0_Bx, float &L0_By,
float &L1_Ax, float &L1_Ay, float &L1_Bx, float &L1_By,
float &L2_Ax, float &L2_Ay, float &L2_Bx, float &L2_By,
float &L3_Ax, float &L3_Ay, float &L3_Bx, float &L3_By) {


float CosTheta = cos(T);
float SinTheta = sin(T);

float P0x,P0y,P1x,P1y,P2x,P2y,P3x,P3y;

P0x = X + A * CosTheta  + B * SinTheta;
P0y = Y + A * -SinTheta + B * CosTheta;

P1x = X - A * CosTheta  + B * SinTheta;
P1y = Y - A * -SinTheta + B * CosTheta;

P2x = X + A * CosTheta  - B * SinTheta;
P2y = Y + A * -SinTheta - B * CosTheta;

P3x = X - A * CosTheta  - B * SinTheta;
P3y = Y - A * -SinTheta - B * CosTheta;


L0_Ax = P0x;
L0_Ay = P0y;
L0_Bx = P1x;
L0_By = P1y;

L1_Ax = P1x;
L1_Ay = P1y;
L1_Bx = P3x;
L1_By = P3y;

L2_Ax = P2x;
L2_Ay = P2y;
L2_Bx = P3x;
L2_By = P3y;

L3_Ax = P2x;
L3_Ay = P2y;
L3_Bx = P0x;
L3_By = P0y;
}

bool fnEllipseBBoxIntersectAux(float X0, float Y0, float A0, float B0, float T0,
							   float X1, float Y1, float A1, float B1, float T1) {


float L0_Ax, L0_Ay, L0_Bx, L0_By;
float L1_Ax, L1_Ay, L1_Bx, L1_By;
float L2_Ax, L2_Ay, L2_Bx, L2_By;
float L3_Ax, L3_Ay, L3_Bx, L3_By;

float M0_Ax, M0_Ay, M0_Bx, M0_By;
float M1_Ax, M1_Ay, M1_Bx, M1_By;
float M2_Ax, M2_Ay, M2_Bx, M2_By;
float M3_Ax, M3_Ay, M3_Bx, M3_By;

GetEllipseBBox(X0, Y0, A0, B0, T0, 
			   L0_Ax, L0_Ay, L0_Bx, L0_By,L1_Ax, L1_Ay, L1_Bx, L1_By,
			   L2_Ax, L2_Ay, L2_Bx, L2_By,L3_Ax, L3_Ay, L3_Bx, L3_By);

GetEllipseBBox(X1, Y1, A1, B1, T1, 
			   M0_Ax, M0_Ay, M0_Bx, M0_By, M1_Ax, M1_Ay, M1_Bx, M1_By,
			   M2_Ax, M2_Ay, M2_Bx, M2_By, M3_Ax, M3_Ay, M3_Bx, M3_By);

return 
 LineSegmentIntersection(L0_Ax, L0_Ay, L0_Bx, L0_By, M0_Ax, M0_Ay, M0_Bx, M0_By) ||
 LineSegmentIntersection(L0_Ax, L0_Ay, L0_Bx, L0_By, M1_Ax, M1_Ay, M1_Bx, M1_By) ||
 LineSegmentIntersection(L0_Ax, L0_Ay, L0_Bx, L0_By, M2_Ax, M2_Ay, M2_Bx, M2_By) ||
 LineSegmentIntersection(L0_Ax, L0_Ay, L0_Bx, L0_By, M3_Ax, M3_Ay, M3_Bx, M3_By) ||

 LineSegmentIntersection(L1_Ax, L1_Ay, L1_Bx, L1_By, M0_Ax, M0_Ay, M0_Bx, M0_By) ||
 LineSegmentIntersection(L1_Ax, L1_Ay, L1_Bx, L1_By, M1_Ax, M1_Ay, M1_Bx, M1_By) ||
 LineSegmentIntersection(L1_Ax, L1_Ay, L1_Bx, L1_By, M2_Ax, M2_Ay, M2_Bx, M2_By) ||
 LineSegmentIntersection(L1_Ax, L1_Ay, L1_Bx, L1_By, M3_Ax, M3_Ay, M3_Bx, M3_By) ||

 LineSegmentIntersection(L2_Ax, L2_Ay, L2_Bx, L2_By, M0_Ax, M0_Ay, M0_Bx, M0_By) ||
 LineSegmentIntersection(L2_Ax, L2_Ay, L2_Bx, L2_By, M1_Ax, M1_Ay, M1_Bx, M1_By) ||
 LineSegmentIntersection(L2_Ax, L2_Ay, L2_Bx, L2_By, M2_Ax, M2_Ay, M2_Bx, M2_By) ||
 LineSegmentIntersection(L2_Ax, L2_Ay, L2_Bx, L2_By, M3_Ax, M3_Ay, M3_Bx, M3_By)  ||

 LineSegmentIntersection(L3_Ax, L3_Ay, L3_Bx, L3_By, M0_Ax, M0_Ay, M0_Bx, M0_By) ||
 LineSegmentIntersection(L3_Ax, L3_Ay, L3_Bx, L3_By, M1_Ax, M1_Ay, M1_Bx, M1_By) ||
 LineSegmentIntersection(L3_Ax, L3_Ay, L3_Bx, L3_By, M2_Ax, M2_Ay, M2_Bx, M2_By) ||
 LineSegmentIntersection(L3_Ax, L3_Ay, L3_Bx, L3_By, M3_Ax, M3_Ay, M3_Bx, M3_By);

}








void  GenOnTheFlyTransition(double *States, int iNumStates, int iNumMice, int iFrame, 
							double fSwapPenalty,
							int *MouseToConditionTable, int *StateLookup,
							float *X, float *Y, float *A, float *B, float *T, 
							bool bLargeTimeGap, double *LogTransition, bool *Intersect, int iNumFrames, float fJumpThresholdPix) 
{

	if (bLargeTimeGap) {
		// all hell broke loss. Nothing is gauranteed anymore. Any state can go to any other state :(
		float fProb = log(1.0f/float(iNumStates));
		for (int k=0;k<iNumStates*iNumStates;k++)
			LogTransition[k] = fProb;
		return;
	}


	// First, theck for mouse intersections
	double fLogZero = -50000;

	// Initialize Transition Matrix to eye (I)
	for (int i=0;i<iNumStates;i++) {
		for (int j=0;j<iNumStates;j++) {
			LogTransition[i*iNumStates+j] = (i == j) ? 0 : fLogZero;
		}
	}

	int iNumIntersections = 1; // there is always self intersection
	for (int k=0;k<iNumMice*iNumMice;k++)
		Intersect[k] = false;

	for (int I=0;I<iNumMice;I++) {

		float X_1 = X[iNumMice * iFrame + I];
		float Y_1 = Y[iNumMice * iFrame + I];
		float A_1 = A[iNumMice * iFrame + I];
		float B_1 = B[iNumMice * iFrame + I];
		float T_1 = T[iNumMice * iFrame + I];

		bool AJumped = true;
		if (iFrame >= 1) {
			// we can estimate the relative velocity
			float VelX_A = X[iNumMice * iFrame + I] - X[iNumMice * (iFrame-1) + I];
			float VelY_A = Y[iNumMice * iFrame + I] - Y[iNumMice * (iFrame-1) + I];
			AJumped = VelX_A*VelX_A+VelY_A*VelY_A > fJumpThresholdPix*fJumpThresholdPix;
		}

		for (int J = I+1; J < iNumMice;J++) {

			float X_2 = X[iNumMice * iFrame + J];
			float Y_2 = Y[iNumMice * iFrame + J];
			float A_2 = A[iNumMice * iFrame + J];
			float B_2 = B[iNumMice * iFrame + J];
			float T_2 = T[iNumMice * iFrame + J];

			bool BJumped = true;
			if (iFrame >= 1) {
				// we can estimate the relative velocity
				float VelX_B = X[iNumMice * iFrame + J] - X[iNumMice * (iFrame-1) + J];
				float VelY_B = Y[iNumMice * iFrame + J] - Y[iNumMice * (iFrame-1) + J];
				BJumped = VelX_B*VelX_B+VelY_B*VelY_B > fJumpThresholdPix*fJumpThresholdPix;
			}

			if (fnEllipseBBoxIntersectAux(X_1,Y_1,A_1,B_1,T_1,
				X_2,Y_2,A_2,B_2,T_2) && (AJumped || BJumped))  {
					// mouse I and J bounding boxes intersect.
					Intersect[J*iNumMice+I] = true;
					Intersect[I*iNumMice+J] = true;
					iNumIntersections++;
			}
	
		}
	}


	if (iNumIntersections > 1) {
		double fLogProb = log(1.0/double(iNumIntersections));
		// This will take care of off diagonal terms, but we need to update the diagonal
		// from zero to fLogProb
		for (int k=0;k< iNumStates;k++)
			LogTransition[k*iNumStates+k] = fLogProb;

		for (int I=0;I<iNumMice;I++) {
			for (int J = I+1; J < iNumMice;J++) {
				if (Intersect[J*iNumMice+I]) {
					for (int iStateIter = 0; iStateIter < iNumStates; iStateIter++) {
						int iCondition  = MouseToConditionTable[I*iNumMice+J];
						int iFlippedState = StateLookup[iCondition*iNumStates + iStateIter];
						LogTransition[iFlippedState*iNumStates +iStateIter] = fLogProb+fSwapPenalty;
					}
				}
			}
		}
	}

}
	

int* fnGenStateTransitionLookupTable(double *States, int iNumStates, int iNumMice, int *MouseToConditionTable) {

	int iNumIntersection = iNumMice * (iNumMice-1) / 2;
	int *StateLookup = new int[iNumStates * iNumIntersection];
	
	int *CurrState = new int[iNumMice];
	int *FlippedState = new int[iNumMice];

	int iCondition = 0;
	for (int i=0;i<iNumMice;i++) {
		for (int j=i+1;j<iNumMice;j++) {
			MouseToConditionTable[i*iNumMice+j] = iCondition;
			MouseToConditionTable[j*iNumMice+i] = iCondition;

			for (int iStateIter= 0;iStateIter < iNumStates;iStateIter++) {

				// First, build the flipped state
				int index_i;
				int index_j;
				for (int k=0;k<iNumMice;k++)  {
					FlippedState[k] = (int)States[iStateIter*iNumMice+k];
					if (FlippedState[k] == i+1)
						index_i = k;
					if (FlippedState[k] == j+1)
						index_j = k;
				}


				int tmp = FlippedState[index_i];
				FlippedState[index_i] = FlippedState[index_j];
				FlippedState[index_j] = tmp;


				/* This was the bug...
				int tmp = FlippedState[i];
				FlippedState[i] = FlippedState[j];
				FlippedState[j] = tmp;
				*/

				// now, search it in the state array....

				bool bMatch;
				int iFlippedStateIndex = 0;
				for (int iSearch = 0; iSearch < iNumStates; iSearch++) {
					bMatch = true;
					for (int k=0;k<iNumMice;k++)
						bMatch = bMatch && States[iSearch*iNumMice+k] == FlippedState[k];
					if (bMatch) {
						iFlippedStateIndex = iSearch;
						break;
					}
				}
				//assert(bMatch);

				// This means that when we are in state iStateIter, and mouse I and mouse J intersect,
				// we  might switch to state FlippedState, which has index iSearch in States matrix....
				StateLookup[iCondition*iNumStates + iStateIter] = iFlippedStateIndex;

			}


			iCondition++;
		}
	}
	
	delete [] CurrState;
	delete [] FlippedState;

	return StateLookup;
}

	
	

void mexFunction( int nlhs, mxArray *plhs[], 
				 int nrhs, const mxArray *prhs[] ) {

  /* Check for proper number of input and output arguments. */    
  if (nrhs != 10 || nlhs < 1) {
    mexErrMsgTxt("Usage: [aiPath, a2fLogProb, a2iUpdateLog, a3bIntersections] = fnViterbi(a2iStates, a2fLogLikelihood, a2fX, a2fY, a2fA, a2fB, a2fTheta, fSwapPenalty, abLargeTimeGap,fJumpThresholdPix)");
	return;
  } 

	double *States = (double *)mxGetData(prhs[0]);
	const int *Dim1 = mxGetDimensions(prhs[0]);
	int iNumMice = Dim1[0];

	double *Likelihood = (double *)mxGetData(prhs[1]);

	const int *Dim = mxGetDimensions(prhs[1]);
	int iNumStates = Dim[0];
	int iNumFrames = Dim[1];


	float *X = (float *)mxGetData(prhs[2]);
	float *Y = (float *)mxGetData(prhs[3]);
	float *A = (float *)mxGetData(prhs[4]);
	float *B = (float *)mxGetData(prhs[5]);
	float *T = (float *)mxGetData(prhs[6]);

	double fSwapPenalty = *(double *)mxGetData(prhs[7]);
	unsigned char *abLargeTimeGap = (unsigned char *)mxGetData(prhs[8]);
	double fJumpThresholdPix = *(double *)mxGetData(prhs[9]);

	/**********************************************************/
	// Initalizations for on-the-fly transition matrices

	// Generate a lookup table, that knows how to map a state and a mouse intersection (I,J) to a new state index.
	int *MouseToConditionTable = new int[iNumMice*iNumMice];
	int *StateLookup = fnGenStateTransitionLookupTable(States, iNumStates, iNumMice,MouseToConditionTable);
	bool *Intersect = new bool[iNumMice*iNumMice];

	/**********************************************************/


  unsigned char * Transition_Matlab;
  if (nlhs >= 4) {
	  // Create output
	  int  dim_array[3];  
	  dim_array[0] = iNumMice;
	  dim_array[1] = iNumMice;
	  dim_array[2] = iNumFrames;
	  plhs[3] = mxCreateNumericArray(3, dim_array, mxLOGICAL_CLASS, mxREAL);
	  Transition_Matlab = (unsigned char*)mxGetPr(plhs[3]);
  }




	// Initialize

	double *a2fLogProb = new double[iNumStates * iNumFrames];
	int *a2iUpdateLog= new int[iNumStates * iNumFrames];

	// All states have equal probability to be the initial state
	double fPrior = log(1.0/double(iNumStates)) ;
	for (int k=0;k<iNumStates;k++) {
		a2fLogProb[k] = fPrior + Likelihood[k];
		a2iUpdateLog[k] = k;
	}
  
  // Forward algorithm
   
	double *Transition = new double[iNumStates*iNumStates];
  
	
	for (int iFrameIter=1;iFrameIter < iNumFrames;iFrameIter++) {

	  // On the fly generation of transition matrix from positional data
	  GenOnTheFlyTransition(States, iNumStates, iNumMice, iFrameIter, fSwapPenalty,
		  MouseToConditionTable, StateLookup,  X,Y,A,B,T, (bool)(abLargeTimeGap[iFrameIter]), Transition,Intersect,iNumFrames,fJumpThresholdPix);

	  if (nlhs >= 4) {
		  int Offset = iNumMice*iNumMice*iFrameIter;
		  for (int k=0;k<iNumMice*iNumMice;k++)
			Transition_Matlab[k + Offset] = Intersect[k];
	  }



	  for (int iStateIter=0;iStateIter < iNumStates;iStateIter++) {

		  // Find Max
		  double fMaxLogProb = -1e10;
		  double fNewValue;
		  int iMaxIndex = 0;
		  double fLogTransition;
		  for (int k=0;k<iNumStates;k++) {
	          fLogTransition = Transition[k*iNumStates+iStateIter];
			  fNewValue = a2fLogProb[(iFrameIter-1)*iNumStates+k] + fLogTransition;
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



  if (nlhs >= 2) {
	  // Create output
	  int  dim_array[2];  
	  dim_array[0] = iNumStates;
	  dim_array[1] = iNumFrames;
	  plhs[1] = mxCreateNumericArray(2, dim_array, mxDOUBLE_CLASS, mxREAL);
	  double *a2fLogProb_Matlab = (double*)mxGetPr(plhs[1]);
	  for (long k =0; k < iNumStates*iNumFrames;k++)
		  a2fLogProb_Matlab[k] = a2fLogProb[k];
  }
  if (nlhs >= 3) {
	  // Create output
	  int  dim_array[2];  
	  dim_array[0] = iNumStates;
	  dim_array[1] = iNumFrames;
	  plhs[2] = mxCreateNumericArray(2, dim_array, mxDOUBLE_CLASS, mxREAL);
	  double *a2iUpdateLog_Matlab = (double*)mxGetPr(plhs[2]);
	  for (long k =0; k < iNumStates*iNumFrames;k++)
		  a2iUpdateLog_Matlab[k] = a2iUpdateLog[k];
  }




  // release allocated memory
  delete [] a2fLogProb;
  delete [] a2iUpdateLog;
  delete [] Transition;
  delete [] StateLookup;
  delete [] MouseToConditionTable;
  delete [] Intersect;
}

