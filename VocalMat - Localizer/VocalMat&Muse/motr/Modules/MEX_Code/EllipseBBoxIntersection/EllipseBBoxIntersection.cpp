#include <stdio.h>
#include <math.h>
#include <mex.h>
#include <memory.h>

/*
X=cat(1,strctGT.astrctTrackers(:).m_afX);
Y=cat(1,strctGT.astrctTrackers(:).m_afY);
A=cat(1,strctGT.astrctTrackers(:).m_afA);
B=cat(1,strctGT.astrctTrackers(:).m_afB);
T=cat(1,strctGT.astrctTrackers(:).m_afTheta);

a3bIntersections = fnEllipseBBoxIntersection(X,Y,A,B,T)
*/

bool LineSegmentIntersection(float Ax, float Ay, float Bx, float By,
							 float Cx, float Cy, float Dx, float Dy) {


float fDetMEps = 1e-8;

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

void mexFunction( int nlhs, mxArray *plhs[], 
				 int nrhs, const mxArray *prhs[] ) 
{
	/* Check for proper number of input and output arguments. */    
	if ((nrhs != 5) || (nlhs < 1))  {
		mexErrMsgTxt("Usage: [a3bIntersections] = fndllEllipseBBoxIntersection(X,Y,A,B,Theta)");
		return;
	} 
	const int *input_dim_array = mxGetDimensions(prhs[0]);
	int NumMice = input_dim_array[0];
	int NumFrames = input_dim_array[1];
	int NumMiceSqr = NumMice*NumMice;

	float *X = (float *)mxGetData(prhs[0]);
	float *Y = (float *)mxGetData(prhs[1]);
	float *A = (float *)mxGetData(prhs[2]);
	float *B = (float *)mxGetData(prhs[3]);
	float *T = (float *)mxGetData(prhs[4]);


	int output_dim_array[3];
	output_dim_array[0] = NumMice;
	output_dim_array[1] = NumMice;
	output_dim_array[2] = NumFrames;
	plhs[0] = mxCreateNumericArray(3, output_dim_array, mxLOGICAL_CLASS, mxREAL);
	unsigned char *a3bIntersections = (unsigned char *)mxGetPr(plhs[0]);

	for (int iFrameIter=0;iFrameIter < NumFrames; iFrameIter++) {

		for (int iMouse1 = 0; iMouse1 < NumMice;iMouse1++) {

			float X_1 = X[NumMice * iFrameIter + iMouse1];
			float Y_1 = Y[NumMice * iFrameIter + iMouse1];
			float A_1 = A[NumMice * iFrameIter + iMouse1];
			float B_1 = B[NumMice * iFrameIter + iMouse1];
			float T_1 = T[NumMice * iFrameIter + iMouse1];

			for (int iMouse2 = iMouse1+1; iMouse2 < NumMice;iMouse2++) {

				float X_2 = X[NumMice * iFrameIter + iMouse2];
				float Y_2 = Y[NumMice * iFrameIter + iMouse2];
				float A_2 = A[NumMice * iFrameIter + iMouse2];
				float B_2 = B[NumMice * iFrameIter + iMouse2];
				float T_2 = T[NumMice * iFrameIter + iMouse2];
		
				
				a3bIntersections[iFrameIter * NumMiceSqr + iMouse1 * NumMice + iMouse2] = 
					fnEllipseBBoxIntersectAux(X_1,Y_1,A_1,B_1,T_1,
					                          X_2,Y_2,A_2,B_2,T_2);

			}
		}
	}
}
