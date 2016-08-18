#include <stdio.h>
#include "mex.h"
#include <math.h>
#include "nrutil.h"
unsigned long c_nan[2]={0xffffffff, 0x7ff7ffff};
unsigned long c_infp[2]={0x00000000, 0x7ff00000};
unsigned long c_infn[2]={0x00000000, 0xfff00000};

double NaN = *( double* )c_nan;
double InfP = *( double* )c_infp;
double InfN = *( double* )c_infn;

//const float PI = 3.14159265;

void EllipseExplicitToImplicit(double x0, double y0,double a,double b,double theta, 
							   double &A00, double &A01, double &A10, double &A11, 
							   double &B0, double &B1, double &C) {

								   double ct=cos(theta);
								   double st=sin(theta);
								   double a00 = (-ct*ct*a*a+a*a+b*b*ct*ct);
								   double a01 = 1.0/2.0 * ((-2*b*b*ct*st+2*a*a*ct*st));
								   double b0 = -2*a*a*ct*st*y0-2*b*b*ct*ct*x0-2*a*a*x0+2*b*b*ct*st*y0+2*ct*ct*a*a*x0;
								   double a11 = (-b*b*ct*ct+ct*ct*a*a+b*b);
								   double b1 = (-2*a*a*ct*ct*y0-2*a*a*ct*x0*st-2*b*b*y0+2*b*b*ct*x0*st+2*ct*ct*b*b*y0);
								   double c = -ct*ct*a*a*x0*x0+b*b*ct*ct*x0*x0-a*a*b*b+a*a*x0*x0-ct*ct*b*b*y0*y0+2*a*a*ct*x0*st*y0+a*a*ct*ct*y0*y0+b*b*y0*y0-2*b*b*ct*x0*st*y0;
								   double den = a*a*b*b;

								   A00 = a00 / den;
								   A01 = a01 / den;
								   A10 = A01;
								   A11 = a11 / den;
								   B0 = b0 / den;
								   B1 = b1 / den;
								   C = c / den;
}


void ComputePolynomialCoeff(  double A00_1, double A01_1, double A10_1, double A11_1, double B1_1, double B2_1, double C_1,
							 double A00_2, double A01_2, double A10_2, double A11_2, double B1_2, double B2_2, double C_2,
							 double &U0, double &U1, double &U2, double &U3, double &U4) {

								double V0 = 2 * (A00_1 * A01_2 - A00_2 * A01_1);
								double V1 = A00_1 * A11_2 - A00_2*A11_1;
								double V2 = A00_1*B1_2 - A00_2*B1_1;
								double V3 = A00_1 * B2_2 - A00_2*B2_1;
								double V4 = A00_1*C_2 - A00_2 * C_1;
								double V5 = 2*(A01_1*A11_2 - A01_2*A11_1);
								double V6 = 2 * (A01_1*B2_2 - A01_2*B2_1);
								double V7 = 2 * (A01_1*C_2 - A01_2*C_1);
								double V8 = A11_1*B1_2 - A11_2*B1_1;
								double V9 = B1_1*B2_2 - B1_2*B2_1;
								double V10 = B1_1*C_2 -B1_2*C_1;

								U0 = V2*V10 -V4*V4;
								U1 = V0*V10 +V2*(V7+V9)-2*V3*V4;
								U2 = V0*(V7+V9) + V2*(V6 - V8) - V3*V3 - 2*V1*V4;
								U3 = V0*(V6-V8) + V2*V5 - 2*V1*V3;
								U4 = V0*V5-V1*V1;
}


void mexFunction( int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[] ) {

	/*
	float a[3] = {1,2,-1};
	float rtr[5], rti[5];
	zrhqr(a, 2, rtr, rti); // finds the roots of -1*x^2+2*x+1
	*/

	/* Check for proper number of input and output arguments. */    
	if (nrhs != 5 || nlhs != 1) {
		mexErrMsgTxt("Usage: [a3bIntersections] = fnViterbiLikelihood(X,Y,A,B,Theta)");
		return;
	} 

	float *X = (float*)mxGetData(prhs[0]);
	float *Y = (float*)mxGetData(prhs[1]);
	float *A = (float*)mxGetData(prhs[2]);
	float *B = (float*)mxGetData(prhs[3]);
	float *Theta = (float*)mxGetData(prhs[4]);

	const int *Dim = mxGetDimensions(prhs[0]);
	int iNumMice = Dim[0];
	int iNumFrames = Dim[1];


	// Create output
	int  dim_array[3];  
	dim_array[0] = iNumMice;
	dim_array[1] = iNumMice;
	dim_array[2] = iNumFrames;
	plhs[0] = mxCreateNumericArray(3, dim_array, mxLOGICAL_CLASS, mxREAL);
	unsigned char *Intersections = (unsigned char*)mxGetPr(plhs[0]);


	double A00_1, A01_1, A10_1, A11_1, B1_1, B2_1, C_1;
	double A00_2, A01_2, A10_2, A11_2, B1_2, B2_2, C_2;
	double Poly[5];
	double rtr[6], rti[6];
	
	for (int iFrameIter=0;iFrameIter < iNumFrames;iFrameIter++) {

//		printf("%d\n",iFrameIter);
	
		for (int i = 0; i< iNumMice;i++) {
			// convert ellipse 1 to implicit representation

			if (mxIsNaN(X[i + iFrameIter*iNumMice]))
				continue;

			EllipseExplicitToImplicit(
				X[i + iFrameIter*iNumMice],
				Y[i + iFrameIter*iNumMice],
				A[i + iFrameIter*iNumMice],
				B[i + iFrameIter*iNumMice],
				Theta[i + iFrameIter*iNumMice], 
				A00_1, A01_1, A10_1, A11_1, B1_1, B2_1, C_1);

			for (int j=i+1;j<iNumMice ;j++) {

			if (mxIsNaN(X[j + iFrameIter*iNumMice]))
				continue;

				EllipseExplicitToImplicit(
					X[j + iFrameIter*iNumMice],
					Y[j + iFrameIter*iNumMice],
					A[j + iFrameIter*iNumMice],
					B[j + iFrameIter*iNumMice],
					Theta[j + iFrameIter*iNumMice], 
					A00_2, A01_2, A10_2, A11_2, B1_2, B2_2, C_2);

				ComputePolynomialCoeff(A00_1,  A01_1,  A10_1,  A11_1,  B1_1,  B2_1,  C_1,
									   A00_2,  A01_2,  A10_2,  A11_2,  B1_2,  B2_2,  C_2,
									   Poly[0], Poly[1],Poly[2],Poly[3],Poly[4]);
					
			if (fabs(Poly[0]) + fabs(Poly[1]) + fabs(Poly[2]) + fabs(Poly[3]) + fabs(Poly[4]) == 0.0) {

					Intersections[i * iNumMice + j  + iFrameIter*iNumMice*iNumMice] = 1;
					Intersections[j * iNumMice + i  + iFrameIter*iNumMice*iNumMice] = 1;
					continue;
				}

				if (mxIsNaN(Poly[0]) || 
				   mxIsNaN(Poly[1]) || 
				   mxIsNaN(Poly[2]) || 
				   mxIsNaN(Poly[3]) || 
				   mxIsNaN(Poly[4]) || 
				   mxIsInf(Poly[0]) || 
				   mxIsInf(Poly[1]) || 
				   mxIsInf(Poly[2]) || 
				   mxIsInf(Poly[3]) || 
				   mxIsInf(Poly[4]))
				   continue;

				zrhqr(Poly, 4, rtr, rti); 
				for (int k=1;k<4;k++) {
					// At least one real root exists means there is an intersection
					if  (fabs(rti[k]) < 1e-20)  {
						Intersections[i * iNumMice + j  + iFrameIter*iNumMice*iNumMice] = 1;
						Intersections[j * iNumMice + i  + iFrameIter*iNumMice*iNumMice] = 1;
						break;
					}
				}

			}
		}

	}


}

