#include <stdio.h>
#include <math.h>
#include "mex.h"

#define BILINEAR(x,y,V00,V10,V01,V11)((V00*(1-x)*(1-y)+V10*(x)*(1-y)+V01*(1-x)*(y)+V11*(x)*(y)))
#define MAX(x,y)(x>y)?(x):(y)

#define ACCESS_IMAGE(imag, indx, maxindx,NaNValue)(indx>=0 && indx<maxindx) ? imag[indx] : NaNValue;


template<class T> void CalcInterpolation(T* input_image, float *output_vector, 
			 int iNumPoints, double *rows, double *cols,int in_rows,int in_cols, float NaNValue) {
	float V00,V01,V10,V11;
	int curr_row, curr_col;
	double dx,dy;
	int num_input_voxels = in_rows * in_cols;
	for (int iPointIter = 0; iPointIter < iNumPoints; iPointIter++) {

		curr_row = int(floor(rows[iPointIter]-1));
		curr_col = int(floor(cols[iPointIter]-1));
		dy = (rows[iPointIter]-1) -curr_row; 
		dx = (cols[iPointIter]-1) -curr_col; 
		int in_curpos = curr_col*in_rows + curr_row;
		V00 = ACCESS_IMAGE(input_image,in_curpos+0, num_input_voxels,NaNValue);
		V01 = ACCESS_IMAGE(input_image,in_curpos+1, num_input_voxels,NaNValue);
		V10 = ACCESS_IMAGE(input_image,in_curpos+in_rows, num_input_voxels,NaNValue);
		V11 = ACCESS_IMAGE(input_image,in_curpos+in_rows+1, num_input_voxels,NaNValue);
		output_vector[iPointIter] = float(BILINEAR(dx, dy, V00,V10,V01,V11));
	}
}

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] ) {
	if (nlhs != 1 || nrhs < 3) {
		mexErrMsgTxt("Usage: [afValues] = fndllFastInterp2(a2Image, Cols (Nx1),Rows (Nx1), NaN value (optional))");
		return;
	} 
	float NaNValue = 0;
	if (nrhs == 4) {
		double *pNaNValue = (double *)mxGetData(prhs[3]);
		NaNValue = *pNaNValue;
	}

	/* Get the number of dimensions in the input argument. */
	if (mxGetNumberOfDimensions(prhs[0]) != 2) {
		mexErrMsgTxt("Input volume must be 2D. ");
		return;
	}

	const int *input_dim_array = mxGetDimensions(prhs[0]);
	int in_rows = input_dim_array[0];
	int in_cols = input_dim_array[1];

	double *rows = (double *)mxGetData(prhs[2]);
	double *cols = (double *)mxGetData(prhs[1]);
	
	const int *tmp = mxGetDimensions(prhs[1]);
	int iNumPoints = MAX(tmp[0], tmp[1]);

	int output_dim_array[2];
	output_dim_array[0] = iNumPoints;
	output_dim_array[1] = 1;
	plhs[0] = mxCreateNumericArray(2, output_dim_array, mxSINGLE_CLASS, mxREAL);
	float *output_vector = (float*)mxGetPr(plhs[0]);

	
	if (mxIsSingle(prhs[0])) {
		float *input_image = (float*)mxGetData(prhs[0]);
		CalcInterpolation(input_image, output_vector,iNumPoints, rows, cols, in_rows,in_cols,NaNValue);
	}

	if (mxIsDouble(prhs[0])) {
		double *input_image = (double*)mxGetData(prhs[0]);
		CalcInterpolation(input_image, output_vector,iNumPoints, rows, cols, in_rows,in_cols,NaNValue);
	}

	if (mxIsUint16(prhs[0]) || mxIsInt16(prhs[0])) {
		short *input_image = (short*)mxGetData(prhs[0]);
		CalcInterpolation(input_image, output_vector,iNumPoints, rows, cols, in_rows,in_cols,NaNValue);
	}

	if (mxIsUint8(prhs[0])) {
		unsigned char *input_image = (unsigned char *)mxGetData(prhs[0]);
		CalcInterpolation(input_image, output_vector,iNumPoints, rows, cols,in_rows,in_cols,NaNValue);
	}

}
