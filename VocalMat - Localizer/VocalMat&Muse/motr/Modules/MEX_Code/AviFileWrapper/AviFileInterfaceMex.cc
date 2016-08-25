#include "mex.h"
#include "string.h"
#include "AviFileInterface.h" 

/* Shay Ohayon, Copyright (c) California Institute of Technology 2008 */
/* Based on Claudio Fanti code */

mxArray* mxCreateScalar(double x) {
    mxArray* p = mxCreateDoubleMatrix(1,1,mxREAL);
    double*  ptr = mxGetPr(p);
    ptr[0] = x;
    return p;
}

void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
 

	if (nrhs < 2) {
        mexPrintf("Usage:\n");
        mexPrintf("AviFileInterfaceMex(command, param)\n");
        mexPrintf("\n");
        mexPrintf("Commands are: Open, Close, GetFrame, Seek, Info\n");
        mexPrintf("\n");
        mexPrintf("Simple example:\n");

        mexPrintf("     hHandle = AviFileInterfaceMex('Open','SomeFile.avi');\n");
        mexPrintf("     strcInfo = AviFileInterfaceMex('Info',hHandle);\n");
        mexPrintf("     AviFileInterfaceMex('Seek',hHandle,142);\n");
        mexPrintf("     I=AviFileInterfaceMex('GetFrame',hHandle);\n");
        mexPrintf("     testmex('Close',hHandle);\n");
        mexPrintf("\n");
        mexPrintf("Notes:\n");
        mexPrintf("1) do not use ~ when referring to filenames.\n");
        mexPrintf("2) Getframe gets a frame and increase current frame counter\n");
        mexPrintf("3) Seeking is exact. It seeks to the nearest keyframe and then read frames until the reaching required one\n");

		return;
	}

  int StringLength = int(mxGetNumberOfElements(prhs[0])) + 1;
  char* Command = (char*)mxCalloc(StringLength, sizeof(char));

  if (mxGetString(prhs[0], Command, StringLength) != 0){
    mexErrMsgTxt("\nError extracting the command.\n");
    return;
  }
  
mexPrintf("%s\n",Command);
  if (strcmp(Command, "Open") == 0) {

	  int FileNameLength = int(mxGetNumberOfElements(prhs[1])) + 1;	
	  char* FileName = (char*)mxCalloc(FileNameLength, sizeof(char));

	  if (mxGetString(prhs[1], FileName, FileNameLength) != 0){
   		 mexErrMsgTxt("\nError extracting the Input filename.\n");
    	return;
 	  }

    mexPrintf("%s\n",FileName);
    CAviFileInterface *pAviFileInterface = new CAviFileInterface(FileName);
    mexPrintf("%d %d %d\n",pAviFileInterface->strctMovieInfo.Width, pAviFileInterface->strctMovieInfo.Height, pAviFileInterface->strctMovieInfo.NumFrames);
mexPrintf("Reached Here\n");
		const unsigned int dim_array[2] = {1,1};
		plhs[0] = mxCreateNumericArray(2,(const mwSize*)dim_array, mxSINGLE_CLASS, mxREAL);
		float *buffer = (float*)mxGetPr(plhs[0]);
		memcpy(buffer, &pAviFileInterface, 4);
		return;
	}

	if (strcmp(Command, "Info") == 0) {
			CAviFileInterface *pAviFileInterface = 
			* (CAviFileInterface **) mxGetPr(prhs[1]);

    const char *keys[] = { "NumFrames", "Width","Height","BitsPerPixel" };
       mxArray *v = mxCreateStructMatrix (1, 1, 4, keys);
      
       mxSetFieldByNumber (v, 0, 0, mxCreateScalar(pAviFileInterface->strctMovieInfo.NumFrames));
       mxSetFieldByNumber (v, 0, 1, mxCreateScalar(pAviFileInterface->strctMovieInfo.Width));
       mxSetFieldByNumber (v, 0, 2, mxCreateScalar(pAviFileInterface->strctMovieInfo.Height));
       mxSetFieldByNumber (v, 0, 3, mxCreateScalar(pAviFileInterface->strctMovieInfo.BitPerPixel));
//       mxSetFieldByNumber (v, 0, 1, mxCreateString("that1"));
     
       if (nlhs)
         plhs[0] = v;
  
        return;
    }

	if (strcmp(Command, "Close") == 0) {
			CAviFileInterface *pAviFileInterface = 
			* (CAviFileInterface **) mxGetPr(prhs[1]);
			delete pAviFileInterface;
			pAviFileInterface = NULL;
            mexPrintf("Object Destroye\nd");
			return;
		}
  

	if (strcmp(Command, "GetFrame")==0) {
		CAviFileInterface *pAviFileInterface = 
			* (CAviFileInterface **) mxGetPr(prhs[1]);
        int dims[3];
	    dims[0] = pAviFileInterface->GetMovieInfo().Height;
     	dims[1] = pAviFileInterface->GetMovieInfo().Width;
    	dims[2] = pAviFileInterface->GetMovieInfo().BitPerPixel / 8;
	    plhs[0] = mxCreateNumericArray(3,(const mwSize*) dims,mxUINT8_CLASS,mxREAL);
		unsigned char *buffer = (unsigned char *)mxGetPr(plhs[0]);
	    int Result = pAviFileInterface->GetMovieFrame(buffer); 
	}



	if (strcmp(Command, "Seek") == 0) {
		CAviFileInterface *pAviFileInterface = 
			* (CAviFileInterface **) mxGetPr(prhs[1]);

       long iNewFrame = long( *(double*)mxGetPr(prhs[2]));
        mexPrintf("Seeking to %d\n",iNewFrame);
	    pAviFileInterface->Seek(iNewFrame); 
	}


 }
 to another pos\n");
            plhs[0] = mxCreateNumericArray(0,NULL,mxUINT8_CLASS,mxREAL);
        }

	}



	if (strcmp(Command, "Seek") == 0) {
		CAviFileInterface *pAviFileInterface = 
			* (CAviFileInterface **) mxGetPr(prhs[1]);

       long iNewFrame = long( *(double*)mxGetPr(prhs[2]));
//        mexPrintf("Seeking to %d\n",iNewFrame);
	    bool bSucc = pAviFileInterface->Seek(iNewFrame); 

        mxArray* v = mxCreateScalar(bSucc);
        if (nlhs)
         plhs[0] = v;
  
	}


 }
