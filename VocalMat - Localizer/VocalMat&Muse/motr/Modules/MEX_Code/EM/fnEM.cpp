#include <stdio.h>
#include <string.h>
#include "mex.h"
#include <math.h>
#define SWAP(a,b) {temp=(a);(a)=(b);(b)=temp;}
#define SQR(x)((x)*(x))
#define MAX(x,y) ((x)>(y))?(x):(y)
#define MIN(x,y) ((x)<(y))?(x):(y)
const double PI = 3.141592653589793;
const double REALMIN = 2.225073858507201e-308;

/*
const double MAX_MAJOR_AXIS = 52;
const double MIN_MAJOR_AXIS = 20;
const double MAX_MINOR_AXIS = 20;
const double MIN_MINOR_AXIS = 10;


const double MAX_LARGE_EIG = SQR(MAX_MAJOR_AXIS/2);
const double MIN_LARGE_EIG = SQR(MIN_MAJOR_AXIS/2);
const double MAX_SMALL_EIG = SQR(MAX_MINOR_AXIS/2);
const double MIN_SMALL_EIG = SQR(MIN_MINOR_AXIS/2);
*/

void GaussPDF(double *Data, double *Mu, double *Sigma, double Prior, int N, double *DataOut) {
	// computes multi variate gaussian probability function for the given data points.
	// Data is always 2xN
	// Sigma is always 2x2 
	double Det = Sigma[0]*Sigma[3] - Sigma[1]*Sigma[2];
	double Deno = 2*PI * sqrt(fabs(Det));
	for (int i=0; i < N; i++) {
		double x1 = Data[2*i+0]-Mu[0];
		double x2 = Data[2*i+1]-Mu[1];
		double Dot = (x1*(x1*Sigma[3]+x2*(-Sigma[1])) + x2*(x1*(-Sigma[2])+x2*Sigma[0]))/Det;
		DataOut[i] = Prior * exp(-0.5 * Dot) / Deno;
	}
}

/* Entry Points */
void mexFunction( int nlhs, mxArray *plhs[], 
				 int nrhs, const mxArray *prhs[] ) {


					 /* Check for proper number of input and output arguments. */    

					 if (nrhs != 7 || nlhs != 4) {
						 mexErrMsgTxt("Usage: [Mu, Sigma, Priors, LogLiklihood] = fnEM(Data, Mu0, Sigma0, Priors0, fStopRadio, iMaxIterations, afAxisBounds)");
						 return;
					 } 

					 int i,k;

					 double *Data = (double *)mxGetData(prhs[0]);
					 double *Mu0 = (double *)mxGetData(prhs[1]);
					 double *Sigma0 = (double *)mxGetData(prhs[2]);
					 double *Priors0= (double *)mxGetData(prhs[3]);

					 double fStopRatio = *(double *)mxGetData(prhs[4]);
					 int iMaxIterations= int(*(double *)mxGetData(prhs[5]));
					 double *AxisBounds = (double *)mxGetData(prhs[6]);
					 double *AxisEigs = new double[4];
					 for (i=0;  i < 4; i++) {
						AxisEigs[i] = SQR(AxisBounds[i]/2);
					 }

					 const int *dim0 = mxGetDimensions(prhs[0]);
					 int N = dim0[1];

					 const int *dim1 = mxGetDimensions(prhs[1]);
					 plhs[0] = mxCreateNumericArray(2, dim1, mxDOUBLE_CLASS, mxREAL);
					 double *Mu = (double *)mxGetData(plhs[0]);
					 int K = dim1[1];

					 const int *dim2 = mxGetDimensions(prhs[2]);
					 int S = mxGetNumberOfDimensions(prhs[2]);
					 plhs[1] = mxCreateNumericArray(S, dim2, mxDOUBLE_CLASS, mxREAL);

					 double *Sigma = (double *)mxGetData(plhs[1]);

					 const int *dim3 = mxGetDimensions(prhs[3]);
					 plhs[2] = mxCreateNumericArray(2, dim3, mxDOUBLE_CLASS, mxREAL);
					 double *Priors = (double *)mxGetData(plhs[2]);

					 const int dimm[2] = {1,1};
					 plhs[3] = mxCreateNumericArray(2, dimm, mxDOUBLE_CLASS, mxREAL);
					 double *LogLikelihood = (double *)mxGetData(plhs[3]);

					 /////////////////////////////////////////////////////////////////

					 memcpy(Mu, Mu0, sizeof(double) * 2 * K);
					 memcpy(Sigma, Sigma0, sizeof(double) * 2 * 2 * K);
					 memcpy(Priors, Priors0, sizeof(double) * 1 * K);


					 double *SumGammaZnk = new double[N];
					 double *GammaZnk = new double[N * K];
					 double *Nk = new double[K];
					 double loglik_old = -REALMIN;

					 for (int iIter=1; iIter <= iMaxIterations; iIter++) {

						 // M Step
						 for ( k=0; k< K; k++) {
							 GaussPDF(Data, Mu + 2*k, Sigma + 4*k, Priors[k], N, GammaZnk+k*N);
						 }

						 // Likelihood - stopping creteria
						 double loglik = 0;
						 for ( i=0; i < N; i++) {
							 SumGammaZnk[i] = 0;
							 for ( k=0;k<K;k++) {
								 SumGammaZnk[i] += GammaZnk[i + k*N];
							 }
							 loglik += log(SumGammaZnk[i]);
						 }
						 loglik /= N; 
						 *LogLikelihood = loglik;

						 if (fabs((loglik/loglik_old)-1) < fStopRatio)
							 break;

						 loglik_old = loglik;

						 for (k=0; k<K; k++)
							 Nk[k] = 0;

						 for (i=0;  i < N; i++) {
							 for (k = 0; k < K; k ++) {
								 if (SumGammaZnk[i] > 1e-20)
									GammaZnk[i + k*N] /= SumGammaZnk[i];
								 Nk[k] += GammaZnk[i + k*N];
							 }
						 }

						 // E Step
						 for (k=0; k<K; k++) {
							 Priors[k] = Nk[k] / N;

							 Mu[2*k+0] = 0;
							 Mu[2*k+1] = 0;
							 for (i = 0; i < N; i++) {
								 Mu[2*k+0] += Data[2*i+0] * GammaZnk[k*N+i];
								 Mu[2*k+1] += Data[2*i+1] * GammaZnk[k*N+i];
							 }
							 Mu[2*k+0] /= Nk[k];
							 Mu[2*k+1] /= Nk[k];

							 double Cov[4];
							 Cov[0] = Cov[1] = Cov[2] = Cov[3] = 0;
							 for (i = 0; i < N; i++) {
								 double x1 = (Data[2*i+0] - Mu[2*k+0]);
								 double z1 = x1 * GammaZnk[k*N+i];;
								 double x2 = (Data[2*i+1] - Mu[2*k+1]);
								 double z2 = x2 * GammaZnk[k*N+i];;
								 Cov[0] += z1*x1;
								 Cov[1] += z2*x1; 
								 Cov[2] += z1*x2;
								 Cov[3] += z2*x2;
							 }
							 Sigma[4*k + 0] = Cov[0] / Nk[k] + 1e-5;
							 Sigma[4*k + 1] = Cov[1] / Nk[k];
							 Sigma[4*k + 2] = Cov[2] / Nk[k];
							 Sigma[4*k + 3] = Cov[3] / Nk[k] + 1e-5;

							// Constrain solution....
							 // First, decompose Cov matrix to major and minor axis
							double B = -Sigma[4*k + 0] -Sigma[4*k + 3];
							double C = Sigma[4*k + 0]*Sigma[4*k + 3]-Sigma[4*k + 1]*Sigma[4*k + 2];
							double D = sqrt(B*B-4*C);
							double Eig1 = (-B + D)/2;
							double Eig2 = (-B - D)/2;
							double LargeEig = MAX(Eig1,Eig2);
							double SmallEig = MIN(Eig1,Eig2);
							double LargeEigConstrained = MAX(AxisEigs[2], MIN(AxisEigs[3], LargeEig));
							double SmallEigConstrained = MAX(AxisEigs[0], MIN(AxisEigs[1], SmallEig));

							double theta1 = atan((Sigma[4*k + 0]+Sigma[4*k + 2]-LargeEig)/(-Sigma[4*k + 1]-Sigma[4*k + 3]+LargeEig));
							double EigVec1X = cos(theta1);
							double EigVec1Y = sin(theta1);
							double EigVec2X = -EigVec1Y;
							double EigVec2Y = EigVec1X;

							// Reconstruct Cov matrix
							 Sigma[4*k + 0] = LargeEigConstrained*SQR(EigVec1X)+SmallEigConstrained*SQR(EigVec2X);
							 Sigma[4*k + 1] = LargeEigConstrained*EigVec1X*EigVec1Y+SmallEigConstrained*EigVec2X*EigVec2Y;
							 Sigma[4*k + 2] = Sigma[4*k + 1]; // enforce symmetry
							 Sigma[4*k + 3] = LargeEigConstrained*SQR(EigVec1Y)+SmallEigConstrained*SQR(EigVec2Y);

						 }

					 }
					 ////////////////////////////////////////////////////

					 delete GammaZnk;
					 delete SumGammaZnk;
					 delete Nk;
}
/*
#define SWAP(a,b) {temp=(a);(a)=(b);(b)=temp;}
// Adopted from Numerical Recipes and adjusted to 0..N-1 format.
void gaussj(double *a, int n)
{
int indxc[MAX_N+1],indxr[MAX_N+1],ipiv[MAX_N+1];
int i,icol,irow,j,k,l,ll;
double big,dum,pivinv,temp;

for (j=1;j<=n;j++) ipiv[j]=0;
for (i=1;i<=n;i++) {
big=0.0;
for (j=1;j<=n;j++)
if (ipiv[j] != 1)
for (k=1;k<=n;k++) {
if (ipiv[k] == 0) {
if (fabs(a[j-1 + n * (k-1)]) >= big) {
big=fabs(a[j-1 + n*(k-1)]);
irow=j;
icol=k;
}
} else if (ipiv[k] > 1) printf("gaussj: Singular Matrix-1");
}

++(ipiv[icol]);
if (irow != icol) {
for (l=1;l<=n;l++) 
SWAP(a[irow-1 + n * (l-1)],a[icol-1 + n* (l-1)])

}
indxr[i]=irow;
indxc[i]=icol;
if (a[icol-1 + n*(icol-1)] == 0.0) {
printf("gaussj: Singular Matrix-2");
}
pivinv=1.0/a[icol-1 + n*(icol-1)];
a[icol-1 + n * (icol-1)]=1.0;
for (l=1;l<=n;l++) a[icol-1 + n*(l-1)] *= pivinv;

for (ll=1;ll<=n;ll++)
if (ll != icol) {
dum=a[ll-1 + n*(icol-1)];
a[ll-1 + n*(icol-1)]=0.0;
for (l=1;l<=n;l++) a[ll-1 + n*(l-1)] -= a[icol-1 + n*(l-1)]*dum;

}
}

for (l=n;l>=1;l--) {
if (indxr[l] != indxc[l])
for (k=1;k<=n;k++)
SWAP(a[k-1 + n*(indxr[l]-1)],a[k-1 + n*(indxc[l]-1)]);
}

return;
}
*/
