#define NRANSI
#include "nrutil.h"
#define MAXM 50

void zrhqr(double a[], int m, double rtr[], double rti[])
{
	void balanc(double **a, int n);
	void hqr(double **a, int n, double wr[], double wi[]);
	int j,k;
	double **hess,xr,xi;

	hess=dmatrix(1,MAXM,1,MAXM);
	if (m > MAXM || a[m] == 0.0) nrerror("bad args in zrhqr");
	for (k=1;k<=m;k++) {
		hess[1][k] = -a[m-k]/a[m];
		for (j=2;j<=m;j++) hess[j][k]=0.0;
		if (k != m) hess[k+1][k]=1.0;
	}
	balanc(hess,m);
	hqr(hess,m,rtr,rti);
	for (j=2;j<=m;j++) {
		xr=rtr[j];
		xi=rti[j];
		for (k=j-1;k>=1;k--) {
			if (rtr[k] <= xr) break;
			rtr[k+1]=rtr[k];
			rti[k+1]=rti[k];
		}
		rtr[k+1]=xr;
		rti[k+1]=xi;
	}
	free_dmatrix(hess,1,MAXM,1,MAXM);
}
#undef MAXM
#undef NRANSI
/* (C) Copr. 1986-92 Numerical Recipes Software #. */
