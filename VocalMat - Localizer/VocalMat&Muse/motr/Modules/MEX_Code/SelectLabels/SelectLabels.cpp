#include <stdio.h>
#include "mex.h"

/* This dll is the implementation of fnSelectLabels function.
The input to the function is:
a3iLabeledVolume - a 3D labeled volume of type uint16. 
aiList - a list of connected component identifier (type uint16 as well)

The output of the algorithm is
a3iVolume - a 3D volume, containing selected components.
*/

void CreateOutput(unsigned short *input_volume, 
				  long num_voxels, unsigned short *select_array, 
				  long select_length, unsigned short *output_volume) {
	/* first, create a lookup table to increase speed */
	unsigned short max_label_id = 0;
	
	for (int k=0; k < select_length; k++) {
		if (select_array[k] > max_label_id) {
			max_label_id = select_array[k];
		}
	}

	unsigned short *select_lookup = (unsigned short*) malloc((1+max_label_id) * sizeof(unsigned short));
	for (unsigned short i = 0; i <= max_label_id; i++)
		select_lookup[i] = 0;

	for (int j = 0; j < select_length; j++)
		select_lookup[select_array[j]] = 1;

	for (long voxel=0; voxel < num_voxels; voxel++) {
		if ( (input_volume[voxel] <= max_label_id) && 
		     (select_lookup[input_volume[voxel]]) ) {
			output_volume[voxel] = input_volume[voxel];
		}
		else {
			output_volume[voxel] = 0;
		}

	}

	free(select_lookup);
}


/* Entry Points */
void mexFunction( int nlhs, mxArray *plhs[], 
				 int nrhs, const mxArray *prhs[] ) {


  long number_of_dims,  num_voxels;
  const int  *dim_array;  
  unsigned short *input_volume;
  unsigned short *select_array;
  unsigned short *output_volume;
  long select_length;

  /* Check for proper number of input and output arguments. */    
  if (nrhs != 2 || nlhs != 1) {
    mexErrMsgTxt("Usage: [a3iVolume] = fnSelectLabels(a3iLabeledVolume, aiLabelList)");
	return;
  } 

  /* Check data type of labeled volume argument. */
  if (!(mxIsUint16(prhs[0])) || !(mxIsUint16(prhs[1]))) {
    mexErrMsgTxt("Input volume must be of type UINT16. Label List must be of type UINT 16");
	return;
  }
    
  /* Get the number of num_voxels in the mask argument. */
  num_voxels = mxGetNumberOfElements(prhs[0]);
  number_of_dims = mxGetNumberOfDimensions(prhs[0]);
 
   dim_array = mxGetDimensions(prhs[0]);
   input_volume = (unsigned short *)mxGetData(prhs[0]);
   select_array = (unsigned short *)mxGetData(prhs[1]);
   select_length = mxGetNumberOfElements(prhs[1]);

   plhs[0] = mxCreateNumericArray(number_of_dims, dim_array, mxUINT16_CLASS, mxREAL);
   output_volume = (unsigned short*)mxGetPr(plhs[0]);
 
   CreateOutput(input_volume, num_voxels,select_array,select_length,output_volume);
}

