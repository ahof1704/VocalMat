#include <stdio.h>
#include "mex.h"

void mexFunction( int nlhs, mxArray *plhs[], 
				 int nrhs, const mxArray *prhs[] ) 
{

	// This function takes as input a set of intervals of the form [StartTime,EndTime]
	// and computes the time spend in each of a given time bin [t0,t1,t2,...tn]
	// very similar to histc...

	double *Start = (double *)mxGetData(prhs[0]);
	double *End = (double *)mxGetData(prhs[1]);

	double *TimeEdges = (double *)mxGetData(prhs[2]);

	const int *Dim = mxGetDimensions(prhs[2]);
	int iNumEdges = Dim[0] > Dim[1] ? Dim[0] : Dim[1];

	const int *Dim1 = mxGetDimensions(prhs[0]);
	int iNumIntervals = Dim1[0] > Dim1[1] ? Dim1[0] : Dim1[1];

	int iNumBins = iNumEdges-1;
	int  dim_array[2];  
	dim_array[0] = 1;
	dim_array[1] = iNumBins; // number of bins = # edges - 1

	plhs[0] = mxCreateNumericArray(2, dim_array, mxDOUBLE_CLASS, mxREAL);
	double *afTimeHist = (double*)mxGetPr(plhs[0]);    
	for (int k=0;k<iNumBins;k++) afTimeHist[k] = 0;

	for (int iIter=0;iIter<iNumIntervals;iIter++) {


		double fStartTime = Start[iIter];
		double  fEndTime = End[iIter];

		if (fEndTime < TimeEdges[0] || fStartTime > TimeEdges[iNumEdges-1])
			continue;

		// find the bin the interval starts and ends
		// optimally, this would have been done using some fancy binary search, but its midnight....
		int iStartBin = -1;
		for (int iStartBinIter = 0; iStartBinIter < iNumBins; iStartBinIter++) {
			if (fStartTime >= TimeEdges[iStartBinIter] && fStartTime <= TimeEdges[iStartBinIter+1]) {
				iStartBin = iStartBinIter;
				break;
			}
		}

		int iEndBin = -1;
		int iEndBinIter ;
		if (iStartBin == -1) {
			// this means that it started before TimeEdges[0]
			iEndBinIter = 0;
			fStartTime = TimeEdges[0]; // crop start time
			iStartBin = 0;
		} else {
			iEndBinIter = iStartBin;
		}

		for (; iEndBinIter < iNumBins; iEndBinIter++) {
			if (fEndTime >= TimeEdges[iEndBinIter] && fEndTime <= TimeEdges[iEndBinIter+1]) {
				iEndBin = iEndBinIter;
				break;
			}
		}

		if (iEndBin == -1) {
			// this means that it ended after TimeEdges[end]
			fEndTime = TimeEdges[iNumEdges-1]; // crop to end
			iEndBin = iNumBins-1;
		}

		// now we know iStartBin and iEndBin, and fStartTime and fEndTime are cropped 

		if (iStartBin == iEndBin) // easy case
			afTimeHist[iStartBin] += fEndTime-fStartTime;
		else {
			// spread across several bins

			// handle start bin
			afTimeHist[iStartBin] += TimeEdges[iStartBin+1] - fStartTime;


			// handle end bin
			afTimeHist[iEndBin] += fEndTime - TimeEdges[iEndBin];

			// handle any other bins in the middle...
			for (int k = iStartBin+1; k < iEndBin; k++) {
				afTimeHist[k] += TimeEdges[k+1]-TimeEdges[k];
			}

		}
	}
}

