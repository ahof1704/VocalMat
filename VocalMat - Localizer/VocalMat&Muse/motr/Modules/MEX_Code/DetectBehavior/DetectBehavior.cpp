#include <stdio.h>
#include "mex.h"
#include <math.h>
#include <string.h>

const float PI = float(3.14159265);
/* This dll implements behavior detection */
#define SQR(x)((x)*(x))
#define ANG2VEC(x){cos(x),-sin(x)}
#define MIN(x,y)((x)<(y) ? (x) : (y) )
#define MAX(x,y)((x)<(y) ? (y) : (x) )
#define NORM2D(x)sqrt(x[0]*x[0]+x[1]*x[1]);
#define DIV(x,y){x[0]/y,x[1]/y}
#define DOT(x,y)(x[0]*y[0]+x[1]*y[1])
#define SUB(x,y){x[0]-y[0],x[1]-y[1]}
typedef struct {
	double SameOrientationAngleThresDeg;
	double VelThresPix;	
	double DistanceThresholdPix;
} FollowingParam;

typedef struct {
	double VelThresPix;
	double HeadToButtDistPix;
	double BodiesAwayMult;
} SniffParam;

typedef struct {
	double VelThresPix;
	double HeadToHeadDistPix;
	double BodiesAwayMult;
} KissParam;

typedef struct {
	double VelThresPix;
	double AtLeastSec;
	double SameOriThresholdDeg;
	double DistancePix;
	double BodiesAwayMult;
	double SameOrientationAngleThresDeg;
} CuddleParam;

typedef struct {
	double VelThresPix;
	double HeadToHeadDistPix;
	double BodiesAwayMult;
} ApproachParam;


// This function detects whether B follows A
void fnDetectBFollowingA(float *X, float *Y, float *A, float *B, float *T, 
					   int MouseA, int MouseB, unsigned char *Output, 
					   int iNumMice, int iNumFrames, const FollowingParam &p) 
{
	for (int iFrameIter=1;iFrameIter < iNumFrames;iFrameIter++) { // Skip frame one
	
		float MouseAVel = sqrt(SQR(X[iNumMice*iFrameIter + MouseA]- X[iNumMice*(iFrameIter-1) + MouseA]) + 
			              SQR(Y[iNumMice*iFrameIter + MouseA]- Y[iNumMice*(iFrameIter-1) + MouseA])); 

		float MouseBVel = sqrt(SQR(X[iNumMice*iFrameIter + MouseB]- X[iNumMice*(iFrameIter-1) + MouseB]) + 
			              SQR(Y[iNumMice*iFrameIter + MouseB]- Y[iNumMice*(iFrameIter-1) + MouseB])); 

		bool bMouseAMoving = MouseAVel > p.VelThresPix;
		bool bMouseBMoving = MouseBVel > p.VelThresPix;

		float fAngleDiffRad = T[iNumMice*iFrameIter + MouseA] - T[iNumMice*iFrameIter + MouseB];
	    float fAngleDiffDeg = MIN(fabs(fAngleDiffRad),2*PI-fabs(fAngleDiffRad))/PI*180;

		float afMouseAHeading[2] = ANG2VEC(T[iNumMice*iFrameIter + MouseA]);
		float afBA_Heading[2] = { X[iNumMice*iFrameIter + MouseA]-X[iNumMice*iFrameIter + MouseB],
								  Y[iNumMice*iFrameIter + MouseA]-Y[iNumMice*iFrameIter + MouseB]};

		float fBA_Heading_Norm = NORM2D(afBA_Heading);

		float afBA_Heading_Norm[2] = DIV(afBA_Heading, fBA_Heading_Norm);
		bool bBehind = acos(DOT(afMouseAHeading,afBA_Heading_Norm))/PI*180 < 90;
		bool  bSameOrientation = fAngleDiffDeg < p.SameOrientationAngleThresDeg;

		float fDistPix = NORM2D(afBA_Heading);
		bool  bClose = fDistPix < p.DistanceThresholdPix;
		bool  bNotTooClose = fDistPix > (B[iNumMice*iFrameIter + MouseA]+B[iNumMice*iFrameIter + MouseB]); 
		// Using B is a conservative measure to catch cases in which the other mouse is to the right/left
		// one can also be less stringent and use A instead

		Output[iFrameIter] = bBehind && bSameOrientation && bClose && bMouseAMoving && bMouseBMoving && bNotTooClose;
	}

}



// This function detects whether B sniff A's butt
void fnDetectBSniffAButt(float *X, float *Y, float *A, float *B, float *T, 
					   int MouseA, int MouseB, unsigned char *Output, 
					   int iNumMice, int iNumFrames, const SniffParam &p) 
{
	for (int iFrameIter=1;iFrameIter < iNumFrames;iFrameIter++) { // Skip frame one
	
		float MouseAVel = sqrt(SQR(X[iNumMice*iFrameIter + MouseA]- X[iNumMice*(iFrameIter-1) + MouseA]) + 
			              SQR(Y[iNumMice*iFrameIter + MouseA]- Y[iNumMice*(iFrameIter-1) + MouseA])); 

		float MouseBVel = sqrt(SQR(X[iNumMice*iFrameIter + MouseB]- X[iNumMice*(iFrameIter-1) + MouseB]) + 
			              SQR(Y[iNumMice*iFrameIter + MouseB]- Y[iNumMice*(iFrameIter-1) + MouseB])); 

		bool bMouseAMoving = MouseAVel > p.VelThresPix;
		bool bMouseBMoving = MouseBVel > p.VelThresPix;

		float afBA_Vec[2] = { X[iNumMice*iFrameIter + MouseA]-X[iNumMice*iFrameIter + MouseB],
								  Y[iNumMice*iFrameIter + MouseA]-Y[iNumMice*iFrameIter + MouseB]};

		float fDistPix = NORM2D(afBA_Vec);
		bool  bBodyFarAway = fDistPix > p.BodiesAwayMult * (B[iNumMice*iFrameIter+MouseA]+B[iNumMice*iFrameIter+MouseB]);
		
		double Va[2] = ANG2VEC(T[iNumMice*iFrameIter+MouseA]);

		double pt2iMouseATail[2] = {
			X[iNumMice*iFrameIter+MouseA] - Va[0] * A[iNumMice*iFrameIter+MouseA],
			Y[iNumMice*iFrameIter+MouseA] - Va[1] * A[iNumMice*iFrameIter+MouseA]};

		double pt2iMouseAHead[2] = {
			X[iNumMice*iFrameIter+MouseA] + Va[0] * A[iNumMice*iFrameIter+MouseA],
			Y[iNumMice*iFrameIter+MouseA] + Va[1] * A[iNumMice*iFrameIter+MouseA]};

		double Vb[2] = ANG2VEC(T[iNumMice*iFrameIter+MouseB]);

		double pt2iMouseBTail[2] = {
			X[iNumMice*iFrameIter+MouseB] - Vb[0] * A[iNumMice*iFrameIter+MouseB],
			Y[iNumMice*iFrameIter+MouseB] - Vb[1] * A[iNumMice*iFrameIter+MouseB]};

		double pt2iMouseBHead[2] = {
			X[iNumMice*iFrameIter+MouseB] + Vb[0] * A[iNumMice*iFrameIter+MouseB],
			Y[iNumMice*iFrameIter+MouseB] + Vb[1] * A[iNumMice*iFrameIter+MouseB]};

			double Diff[2] = SUB(pt2iMouseATail,pt2iMouseBHead);
			double fHeadBToButtA_Dist = NORM2D(Diff);
			
			bool bHeadCloseToButt = fHeadBToButtA_Dist < p.HeadToButtDistPix;

		Output[iFrameIter] = !bMouseAMoving && !bMouseBMoving && bBodyFarAway && bHeadCloseToButt;
	}

}




// This function detects whether B kiss A
void fnDetectKiss(float *X, float *Y, float *A, float *B, float *T, 
					   int MouseA, int MouseB, unsigned char *Output, 
					   int iNumMice, int iNumFrames, const KissParam &p) 
{
	for (int iFrameIter=1;iFrameIter < iNumFrames;iFrameIter++) { // Skip frame one
	
		float MouseAVel = sqrt(SQR(X[iNumMice*iFrameIter + MouseA]- X[iNumMice*(iFrameIter-1) + MouseA]) + 
			              SQR(Y[iNumMice*iFrameIter + MouseA]- Y[iNumMice*(iFrameIter-1) + MouseA])); 

		float MouseBVel = sqrt(SQR(X[iNumMice*iFrameIter + MouseB]- X[iNumMice*(iFrameIter-1) + MouseB]) + 
			              SQR(Y[iNumMice*iFrameIter + MouseB]- Y[iNumMice*(iFrameIter-1) + MouseB])); 

		bool bMouseAMoving = MouseAVel > p.VelThresPix;
		bool bMouseBMoving = MouseBVel > p.VelThresPix;

		float afBA_Vec[2] = { X[iNumMice*iFrameIter + MouseA]-X[iNumMice*iFrameIter + MouseB],
								  Y[iNumMice*iFrameIter + MouseA]-Y[iNumMice*iFrameIter + MouseB]};

		float fDistPix = NORM2D(afBA_Vec);
		bool  bBodyFarAway = fDistPix > p.BodiesAwayMult * (B[iNumMice*iFrameIter+MouseA]+B[iNumMice*iFrameIter+MouseB]);
		
		double Va[2] = ANG2VEC(T[iNumMice*iFrameIter+MouseA]);

		double pt2iMouseATail[2] = {
			X[iNumMice*iFrameIter+MouseA] - Va[0] * A[iNumMice*iFrameIter+MouseA],
			Y[iNumMice*iFrameIter+MouseA] - Va[1] * A[iNumMice*iFrameIter+MouseA]};

		double pt2iMouseAHead[2] = {
			X[iNumMice*iFrameIter+MouseA] + Va[0] * A[iNumMice*iFrameIter+MouseA],
			Y[iNumMice*iFrameIter+MouseA] + Va[1] * A[iNumMice*iFrameIter+MouseA]};

		double Vb[2] = ANG2VEC(T[iNumMice*iFrameIter+MouseB]);

		double pt2iMouseBTail[2] = {
			X[iNumMice*iFrameIter+MouseB] - Vb[0] * A[iNumMice*iFrameIter+MouseB],
			Y[iNumMice*iFrameIter+MouseB] - Vb[1] * A[iNumMice*iFrameIter+MouseB]};

		double pt2iMouseBHead[2] = {
			X[iNumMice*iFrameIter+MouseB] + Vb[0] * A[iNumMice*iFrameIter+MouseB],
			Y[iNumMice*iFrameIter+MouseB] + Vb[1] * A[iNumMice*iFrameIter+MouseB]};

			double Diff[2] = SUB(pt2iMouseAHead,pt2iMouseBHead);
			double fHeadBToHeadA_Dist = NORM2D(Diff);
			
			bool bHeadCloseToHead = fHeadBToHeadA_Dist < p.HeadToHeadDistPix;

		Output[iFrameIter] = !bMouseAMoving && !bMouseBMoving && bBodyFarAway && bHeadCloseToHead;
	}

}







// This function detects whether B kiss A
void fnDetectCuddle(float *X, float *Y, float *A, float *B, float *T, 
					   int MouseA, int MouseB, unsigned char *Output, 
					   int iNumMice, int iNumFrames, const CuddleParam &p) 
{
	for (int iFrameIter=1;iFrameIter < iNumFrames;iFrameIter++) { // Skip frame one
	
		float MouseAVel = sqrt(SQR(X[iNumMice*iFrameIter + MouseA]- X[iNumMice*(iFrameIter-1) + MouseA]) + 
			              SQR(Y[iNumMice*iFrameIter + MouseA]- Y[iNumMice*(iFrameIter-1) + MouseA])); 

		float MouseBVel = sqrt(SQR(X[iNumMice*iFrameIter + MouseB]- X[iNumMice*(iFrameIter-1) + MouseB]) + 
			              SQR(Y[iNumMice*iFrameIter + MouseB]- Y[iNumMice*(iFrameIter-1) + MouseB])); 

		bool bMouseAMoving = MouseAVel > p.VelThresPix;
		bool bMouseBMoving = MouseBVel > p.VelThresPix;

		float afBA_Vec[2] = { X[iNumMice*iFrameIter + MouseA]-X[iNumMice*iFrameIter + MouseB],
								  Y[iNumMice*iFrameIter + MouseA]-Y[iNumMice*iFrameIter + MouseB]};

		float fDistPix = NORM2D(afBA_Vec);
		bool  bBodyFarAway = fDistPix > p.BodiesAwayMult * (B[iNumMice*iFrameIter+MouseA]+B[iNumMice*iFrameIter+MouseB]);
		

		float fAngleDiffRad = T[iNumMice*iFrameIter + MouseA] - T[iNumMice*iFrameIter + MouseB];
	    float fAngleDiffDeg = MIN(fabs(fAngleDiffRad),2*PI-fabs(fAngleDiffRad))/PI*180;
		bool  bSameOrientation = fAngleDiffDeg < p.SameOrientationAngleThresDeg;

		Output[iFrameIter] = !bMouseAMoving && !bMouseBMoving && !bBodyFarAway && bSameOrientation;
	}
// Now go over and close gaps

	// Now remove all intervals that are smaller than X

}


// This function detects whether B Approaches A (which is stationary)
void fnDetectApproach(float *X, float *Y, float *A, float *B, float *T, 
					   int MouseA, int MouseB, unsigned char *Output, 
					   int iNumMice, int iNumFrames,const ApproachParam &p) 
{
	for (int iFrameIter=1;iFrameIter < iNumFrames;iFrameIter++) { // Skip frame one
	
		float MouseAVel = sqrt(SQR(X[iNumMice*iFrameIter + MouseA]- X[iNumMice*(iFrameIter-1) + MouseA]) + 
			              SQR(Y[iNumMice*iFrameIter + MouseA]- Y[iNumMice*(iFrameIter-1) + MouseA])); 

		float MouseBVel = sqrt(SQR(X[iNumMice*iFrameIter + MouseB]- X[iNumMice*(iFrameIter-1) + MouseB]) + 
			              SQR(Y[iNumMice*iFrameIter + MouseB]- Y[iNumMice*(iFrameIter-1) + MouseB])); 

		bool bMouseAMoving = MouseAVel > p.VelThresPix;
		bool bMouseBMoving = MouseBVel > p.VelThresPix;

		float afBA_Vec[2] = { X[iNumMice*iFrameIter + MouseA]-X[iNumMice*iFrameIter + MouseB],
								  Y[iNumMice*iFrameIter + MouseA]-Y[iNumMice*iFrameIter + MouseB]};

		float fDistPix = NORM2D(afBA_Vec);
		bool  bBodyFarAway = fDistPix > p.BodiesAwayMult * (B[iNumMice*iFrameIter+MouseA]+B[iNumMice*iFrameIter+MouseB]);
		
		double Va[2] = ANG2VEC(T[iNumMice*iFrameIter+MouseA]);

		double pt2iMouseATail[2] = {
			X[iNumMice*iFrameIter+MouseA] - Va[0] * A[iNumMice*iFrameIter+MouseA],
			Y[iNumMice*iFrameIter+MouseA] - Va[1] * A[iNumMice*iFrameIter+MouseA]};

		double pt2iMouseAHead[2] = {
			X[iNumMice*iFrameIter+MouseA] + Va[0] * A[iNumMice*iFrameIter+MouseA],
			Y[iNumMice*iFrameIter+MouseA] + Va[1] * A[iNumMice*iFrameIter+MouseA]};

		double Vb[2] = ANG2VEC(T[iNumMice*iFrameIter+MouseB]);

		double pt2iMouseBTail[2] = {
			X[iNumMice*iFrameIter+MouseB] - Vb[0] * A[iNumMice*iFrameIter+MouseB],
			Y[iNumMice*iFrameIter+MouseB] - Vb[1] * A[iNumMice*iFrameIter+MouseB]};

		double pt2iMouseBHead[2] = {
			X[iNumMice*iFrameIter+MouseB] + Vb[0] * A[iNumMice*iFrameIter+MouseB],
			Y[iNumMice*iFrameIter+MouseB] + Vb[1] * A[iNumMice*iFrameIter+MouseB]};

			double Diff[2] = SUB(pt2iMouseAHead,pt2iMouseBHead);
			double fHeadBToHeadA_Dist = NORM2D(Diff);
			
			bool bHeadCloseToHead = fHeadBToHeadA_Dist < p.HeadToHeadDistPix;

		Output[iFrameIter] = !bMouseAMoving && !bMouseBMoving && bBodyFarAway && bHeadCloseToHead;
	}

}


void mexFunction( int nlhs, mxArray *plhs[], 
				 int nrhs, const mxArray *prhs[] ) {

  /* Check for proper number of input and output arguments. */    
  if (nrhs <  7 || nlhs != 1) {
    mexErrMsgTxt("Usage: [abDetected] = fnDetectBehavior(strBehavior, a2fX,a2fY,a2fA,a2fB,a2fTheta, iMouseA, iMouseB,strctParams)");
	return;
  } 

	int StringLength = int(mxGetNumberOfElements(prhs[0])) + 1;
	char* Command = (char*)mxCalloc(StringLength, sizeof(char));

	if (mxGetString(prhs[0], Command, StringLength) != 0){
		mexErrMsgTxt("\nError extracting the command.\n");
		return;
	}


	for (int k=1; k<=5;k++) {
		if (!mxIsSingle(prhs[k])) {
		  mexErrMsgTxt("a2fX,a2fY,a2fA,a2fB,a2fTheta must be single");
		return;
		}
	} 
	for (int k=6; k<=7;k++) {
		if (!mxIsDouble(prhs[k])) {
		  mexErrMsgTxt("MouseA and Mouse B must be double");
		return;
		}
	} 



	float *X = (float *)mxGetData(prhs[1]);
	float *Y = (float *)mxGetData(prhs[2]);
	float *A = (float *)mxGetData(prhs[3]);
	float *B = (float *)mxGetData(prhs[4]);
	float *T = (float *)mxGetData(prhs[5]);

	int MouseA = int(*(double*)mxGetData(prhs[6]))-1; // Pay attention. Indices reduced 0..iNumMice-1
	int MouseB = int(*(double*)mxGetData(prhs[7]))-1;


	const int *input_dim_array = mxGetDimensions(prhs[1]);
	int iNumMice = input_dim_array[0];
	int iNumFrames = input_dim_array[1];

  // Create output
  int  dim_array[2];  
  dim_array[0] = 1;
  dim_array[1] = iNumFrames;
  plhs[0] = mxCreateNumericArray(2, dim_array, mxLOGICAL_CLASS, mxREAL);
  unsigned char *Output = (unsigned char *)mxGetPr(plhs[0]);

  if   (strcmp(Command, "Following") == 0) {
	FollowingParam param;
	param.VelThresPix = *(double*) mxGetData(mxGetField(prhs[8],0,"m_fVelocityThresholdPix"));
	param.SameOrientationAngleThresDeg = *(double*)  mxGetData(mxGetField(prhs[8],0,"m_fSameOrientationAngleThresDeg"));
	param.DistanceThresholdPix = *(double*)  mxGetData(mxGetField(prhs[8],0,"m_fDistanceThresholdPix"));
	fnDetectBFollowingA(X,Y,A,B,T, MouseA, MouseB, Output, iNumMice, iNumFrames, param);
  } else  if   (strcmp(Command, "SniffButt") == 0) {
	SniffParam param;
	param.VelThresPix = *(double*) mxGetData(mxGetField(prhs[8],0,"m_fVelocityThresholdPix"));
	param.HeadToButtDistPix = *(double*)  mxGetData(mxGetField(prhs[8],0,"m_fHeadToButtDistPix"));
	param.BodiesAwayMult = *(double*)  mxGetData(mxGetField(prhs[8],0,"m_fBodiesAwayMult"));
	fnDetectBSniffAButt(X,Y,A,B,T, MouseA, MouseB, Output, iNumMice, iNumFrames, param);
  } else  if   (strcmp(Command, "Kiss") == 0) {
	KissParam param;
	param.VelThresPix = *(double*) mxGetData(mxGetField(prhs[8],0,"m_fVelocityThresholdPix"));
	param.HeadToHeadDistPix = *(double*)  mxGetData(mxGetField(prhs[8],0,"m_fHeadToHeadDistPix"));
	param.BodiesAwayMult = *(double*)  mxGetData(mxGetField(prhs[8],0,"m_fBodiesAwayMult"));
	fnDetectKiss(X,Y,A,B,T, MouseA, MouseB, Output, iNumMice, iNumFrames, param);
  } else  if   (strcmp(Command, "Cuddle") == 0) {
	CuddleParam param;
	param.AtLeastSec		= *(double*) mxGetData(mxGetField(prhs[8],0,"m_fLengthSec"));
	param.BodiesAwayMult= *(double*)  mxGetData(mxGetField(prhs[8],0,"m_fBodiesAwayMult"));
	param.SameOriThresholdDeg= *(double*)  mxGetData(mxGetField(prhs[8],0,"m_fSameOrientationAngleThresDeg"));
	param.VelThresPix= *(double*)  mxGetData(mxGetField(prhs[8],0,"m_fVelocityThresholdPix"));
	fnDetectCuddle(X,Y,A,B,T, MouseA, MouseB, Output, iNumMice, iNumFrames, param);
  } else  if   (strcmp(Command, "Approach") == 0) {
	ApproachParam param;
	param.VelThresPix = *(double*) mxGetData(mxGetField(prhs[8],0,"m_fVelocityThresholdPix"));
	param.HeadToHeadDistPix = *(double*)  mxGetData(mxGetField(prhs[8],0,"m_fHeadToHeadDistPix"));
	param.BodiesAwayMult = *(double*)  mxGetData(mxGetField(prhs[8],0,"m_fBodiesAwayMult"));
	fnDetectApproach(X,Y,A,B,T, MouseA, MouseB, Output, iNumMice, iNumFrames, param);
  } else {
		  mexErrMsgTxt("Unknown behavior");
		return;
  }

    
}

