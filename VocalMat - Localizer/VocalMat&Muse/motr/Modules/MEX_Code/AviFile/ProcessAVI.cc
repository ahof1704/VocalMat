/*
%   ProcessAVI          Allows Processing of Frames from an AVI sequence
%
%   -Usage-
%       ProcessAVI(strInFName, strOutFName, strProcFrmFcn, bolMovOrFrame, bolMakeGray, ...
%                  intStartFrm, intNFrms, intQuality, intFps)
%
%   -Input-
%       strInFName:     Full-path, name and extension of the AVI file to be 
%                       used as input. Each Frame is m-by-n-by-3.
%
%       strOutFName:    Full-path, name and extension of the AVI file to be 
%                       used as output. Each Frame is m-by-n-by-3. 
%                       If bolMovOrFrame == 0 then this is the Full-path
%                       and beginning of the name for the JPEG files saved
%                       as strOutFName-999999.jpg containing each frame 
%                       after processing.
%
%       strProcFrmFcn:  name of the matlab function which will process each
%                       frame. The fuction "ProcFrm" must conform to the 
%                       following:
%
%                       [mxaOutFrame] = ProcFrm(mxaInFrame,intK);
%
%                       mxaOutFrame:    Double m-by-n-by-3 array with entries 
%                                       between 0 and 1 representing the frame
%                                       resulting from the processing.
%
%                       mxaInFrame:     Double m-by-n-by-3 array with entries 
%                                       between 0 and 1 representing the frame
%                                       given for processing.
%
%                       intK:           The current frame's number
%
%       bolMovOrFrame:  Create an AVI movie or JPEG files  [>=0, Optional == 0]
%
%       bolMakeGray:    Output format is same as input (RGB/Gray) or Gray  [>=0, Optional == 0]
%
%       intStartFrm:    First frame number to process [>=0, Optional == 0]
%
%       intNFrms:       Number of frames to be processed  [>=1, Optional == ALL]
%
%       intQuality:     Quality in 0.01% Steps  [from 0 to 10,000, Optional == 10,000]
%
%       intFps:         Frames per second  [>0, Optional == 29.97]
%
%
% ProcessAVI open the input file and reads in one frame at a time.
%   For each frame "F", the Matlab function "ProcFrm" specified by 
%   strProcFrmFcn is called with F as an input parameter. 
%   At the end of its execution ProcFrm is expected return a frame 
%   which an identical structure (but not necessarily content) to F.
%   Each output frame is saved sequentially to the output AVI file
%   or into individual JPEG files.
%   The input image can be RGB or gray-scale while the output image
%   is controlled by the bolMakeGray parameter.
%
%   See Also: BGComputeAVI, BGSubAVI
%

%
% Authors:                                                            04/20/04
% Claudio Fanti <cf@caltech.edu>   and   Lihi Zelnik <lihi@vision.caltech.edu>
% Based in part on work by:       Charless Fowlkes <fowlkes@eecs.berkeley.edu>
% ------------------------------------------------------------------------------
*/

/*
  To mexify:    
  
  Including xvid4.so is sufficient for decoding but win32.so is used for compression.
  The codec for compression should be some indeo or fourcc "DIV3" or "MP42"
  
  mex ProcessAVI.cc  -I/usr/include/avifile-0.7  /usr/lib/avifile-0.7/win32.so /usr/lib/avifile-0.7/xvid4.so -L/usr/lib -ljpeg -laviplay;

 */

#include <stdio.h>
#include <stdlib.h>
#include "avifile.h"
#include "aviplay.h"
#include "version.h"
#include "utils.h"
#include <avm_fourcc.h>
#include <avm_except.h>
#include <mex.h>
#include <math.h>
#include <matrix.h>
#include <string.h>
extern "C"
{
#include <jpeglib.h>
#include <jerror.h>
}






 
 
 
 
 
 
 void fillInfo(avm::CImage *image, BITMAPINFOHEADER* bi)
{
  memset(bi, 0, sizeof(*bi));
  bi->biSize = sizeof(*bi);
  bi->biWidth = image->Width();
  bi->biHeight = image->Height();
  bi->biSizeImage = bi->biWidth * bi->biHeight * 3;
  bi->biPlanes = 1;
  bi->biBitCount = 24;
}



 


bool writeJpeg(avm::CImage* image, const char* filename, int frameno, J_COLOR_SPACE intType)
{
  int planes = 3; //default
  if (intType == JCS_GRAYSCALE) {
        planes = 1;
  }
  if (intType == JCS_RGB) {
        planes = 3;
  }
  int width = image->Width();
  int height = image->Height();
  char fullfile[1000];
  sprintf(fullfile,"%s-%06d.jpg",filename,frameno);
  fprintf(stdout,"\rwriting [%dx%d] to %s",width,height,fullfile);
  FILE* file = fopen(fullfile, "w");
  struct jpeg_error_mgr jerr;
  struct jpeg_compress_struct cinfo;
  cinfo.err = jpeg_std_error (&jerr);
  jpeg_create_compress (&cinfo);
  jpeg_stdio_dest (&cinfo, file);
  cinfo.image_width = width;
  cinfo.image_height = height;
  cinfo.input_components = planes;
  cinfo.in_color_space = intType;
  jpeg_set_defaults (&cinfo);
  jpeg_start_compress (&cinfo, TRUE);
  JSAMPLE * buf = new JSAMPLE[width * planes];

  // Write data one scanline at a time.
  for (int i = 0; i < height; i++)
  {
    for (int j = 0; j < width; j++)
    {
      uint8_t* base = image->At(j,i);
      for (int k = 0; k < planes; k++) {
            buf[planes * j + k] = *(base+(planes-k-1)); 
      }
    }
    int c = jpeg_write_scanlines (&cinfo, &buf, 1);
    assert (c == 1);
  }

  // Clean up.
  jpeg_finish_compress (&cinfo);
  fclose (file);
  jpeg_destroy_compress (&cinfo);
  delete[]buf;
  return true;
}

 
 
 
 
 
 



void 
mexFunction (
	     int nlhs, mxArray* plhs[],
	     int nrhs, const mxArray* prhs[])
{



  //mexPrintf("We are in MEX");



  //-------------------------------------------------------------------------------
  // Check INPUT/OUTPUT paramenters
  //-------------------------------------------------------------------------------
  if (nlhs != 0) {
    mexErrMsgTxt("\n\nProcessAVI does NOT have any output arguments.\nProcessAVI(strInFName, strOutFName, strProcFrmFcn, bolMovOrFrame, bolMakeGray, intStartFrm, intNFrms, intQuality, intFps).\n");
    return;
  }
  if (nrhs < 4) {
    mexErrMsgTxt("\n\nProcessAVI requires 4 to 9 input arguments.\nProcessAVI(strInFName, strOutFName, strProcFrmFcn, bolMovOrFrame, bolMakeGray, intStartFrm, intNFrms, intQuality, intFps).\n");
    return;
  }
  if (nrhs > 9) {
    mexErrMsgTxt("\n\nProcessAVI requires 4 to 9 input arguments.\nProcessAVI(strInFName, strOutFName, strProcFrmFcn, bolMovOrFrame, bolMakeGray, intStartFrm, intNFrms, intQuality, intFps).\n");
    return;
  }
  //-------------------------------------------------------------------------------

  

  
  //------------------------------------------------------------------------------
  //get the INPUT filename from the Input parameters
  //-------------------------------------------------------------------------------
  int InFNBufLen = (mxGetM(prhs[0]) * mxGetN(prhs[0])) + 1;
  char* InFileName = (char*)mxCalloc(InFNBufLen, sizeof(char));

  if (mxGetString(prhs[0], InFileName, InFNBufLen) != 0){
    mexErrMsgTxt("\nProcessAVI had Problem extracting the Input filename.\n");
    return;
  }
  //-------------------------------------------------------------------------------
  

  
  

  
  //-------------------------------------------------------------------------------
  //get the OUTPUT filename from the Input parameters
  //-------------------------------------------------------------------------------
  int OutFNBufLen = (mxGetM(prhs[1]) * mxGetN(prhs[1])) + 1;
  char* OutFileName = (char*)mxCalloc(OutFNBufLen, sizeof(char));

  if (mxGetString(prhs[1], OutFileName, OutFNBufLen) != 0){
    mexErrMsgTxt("\nProcessAVI had Problem extracting the Output filename.\n");
    return;
  }
  //-------------------------------------------------------------------------------
  

  
  
  
  
  
  
  
  
  
  //-------------------------------------------------------------------------------
  //get the Subroutine name that will process the frames
  //-------------------------------------------------------------------------------
  int ProcFrmBufLen = (mxGetM(prhs[2]) * mxGetN(prhs[2])) + 1;
  char* ProcFrm = (char*)mxCalloc(ProcFrmBufLen, sizeof(char));

  if (mxGetString(prhs[2], ProcFrm, ProcFrmBufLen) != 0){
    mexErrMsgTxt("\nProcessAVI had Problem extracting the Name of the Processing Function.\n");
    return;
  }
  //-------------------------------------------------------------------------------

  
  
  
  //-------------------------------------------------------------------------------
  //Determine whether we want to output AVI or JPEG
  //-------------------------------------------------------------------------------
  int intWantAVI = 0;
  if (nrhs > 3) {
      intWantAVI = (int) rint(mxGetScalar(prhs[3]));
  }
  //-------------------------------------------------------------------------------

  
  
  //-------------------------------------------------------------------------------
  //Determine whether we want to output format same as input or Gray-scale
  //-------------------------------------------------------------------------------
  int intWantGray = 0;
  if (nrhs > 4) {
      intWantGray = (int) rint(mxGetScalar(prhs[4]));
  }
  //-------------------------------------------------------------------------------
  
  
  
  
  
  //-------------------------------------------------------------------------------
  //get the initial frame and number of frames from the Input parameters
  //-------------------------------------------------------------------------------
  int intStartFrm = 0;
  int intNFrms = 0;
  if (nrhs == 5) {
      intStartFrm = 0;
  }
  if (nrhs >= 6) {
      intStartFrm = (int) rint(mxGetScalar(prhs[5]));
  }
  if (nrhs >= 7) {
      intNFrms = (int) rint(mxGetScalar(prhs[6]));
  }
  //-------------------------------------------------------------------------------

  
  
  
  
  
  
  //-------------------------------------------------------------------------------
  //get the Quality and fps values from the Input parameters
  //-------------------------------------------------------------------------------
  int intQuality = 10000;   //default
  double dblFps = 29.97;    //default
  if (nrhs >= 8) {
      intQuality = (int) rint(mxGetScalar(prhs[7]));
  }
  if (nrhs == 9) {
      dblFps = mxGetScalar(prhs[8]);
  }
  //-------------------------------------------------------------------------------
 


  //-------------------------------------------------------------------------------
  // Setup the Variables for the subroutine, and create local arrays for processing 
  //-------------------------------------------------------------------------------
  int ExitCode ;
  int dims[3];
  //Will store the current frame read from the Input file
  mxArray* CurrentFrame;

  //We pass 2 arrays to the Subroutine and receive 1 back
  mxArray* SubPRHS[2];
  mxArray* SubPLHS[1];

  // C-pointers to the output variables
  double* CurrFrBuf;
  double * intKBuf; 
  double* OutFrBuf;

  // Support variable to convert from RGB to Grayscale
  double YIQ_Y;
  //-------------------------------------------------------------------------------





  
  
  //-------------------------------------------------------------------------------
  // check avifile library version to make sure it's compatible
  //-------------------------------------------------------------------------------
  //mexPrintf("Get Version");
  if (GetAvifileVersion() != AVIFILE_VERSION) {
    char msg[512];
    sprintf(msg, "\nBGSubAVI This binary was compiled for Avifile ver. %d, , but the library is ver. %d.\n",
	    AVIFILE_VERSION,GetAvifileVersion());
    mexErrMsgTxt(msg);
    return;
  }
  //-------------------------------------------------------------------------------

  
  
  //-------------------------------------------------------------------------------
  // Open Input avi file
  //-------------------------------------------------------------------------------
  //mexPrintf("Open FILE");
  avm::IReadFile* inFile = avm::CreateReadFile(InFileName);
  if (!inFile) {
    char msg[512];
    sprintf(msg, "\n\nBGSubAVI Error opening Input file ''%s''.\n",InFileName);
    mexErrMsgTxt(msg);
    return;
  }
  //-------------------------------------------------------------------------------
  

 
  //-------------------------------------------------------------------------------
  // Open the Video stream from the file
  //-------------------------------------------------------------------------------
  //mexPrintf("Open Stream");
  avm::IReadStream* inVidStr = inFile->GetStream(0, avm::IStream::Video);
  if (!inVidStr) {
    char msg[512];
    sprintf(msg, "\n\nBGComputeAVI Error accessing the Video Stream in the Input file ''%s''.\n",InFileName);
    mexErrMsgTxt(msg);
    return;
  }
  //-------------------------------------------------------------------------------

  
  
  
  //-------------------------------------------------------------------------------
  //check and make sure we have valid Starting Frame and Number of Frames
  //-------------------------------------------------------------------------------
  //mexPrintf("Check Length");
  int intTrueLength = inVidStr->GetLength();
  if (nrhs <= 6) {
     intNFrms = intTrueLength-intStartFrm;
  }
  if ((intStartFrm >= intTrueLength) || (intStartFrm < 0)){
     char msg[512];
     sprintf(msg, "\n\nProcessAVI Cannot start from frame %ld.\nA valid range for this file is 0 to %ld.\n",intStartFrm,intTrueLength-1);
     mexErrMsgTxt(msg);
  }
  if (intNFrms < 0){
     char msg[512];
     sprintf(msg, "\n\nProcessAVI Cannot extract %ld frames.\n",intNFrms);
     mexErrMsgTxt(msg);
  }
  if (intStartFrm + intNFrms > intTrueLength){
     char msg[512];
     sprintf(msg, "\n\nProcessAVI Cannot extract %ld frames from this file.\nWill limit processing to %ld frames starting at %ld.\n",intNFrms,intTrueLength-intStartFrm,intStartFrm);
     mexWarnMsgTxt(msg);
     intNFrms = intTrueLength-intStartFrm;
  }
  //-------------------------------------------------------------------------------


  
  
  //-------------------------------------------------------------------------------
  // Start the Video Streaming 
  //-------------------------------------------------------------------------------
  //mexPrintf("Start Streaming");
  inVidStr->StartStreaming();
  //-------------------------------------------------------------------------------
 
  

  
  //-------------------------------------------------------------------------------
  // Decode starting from most recent keyframe 
  //-------------------------------------------------------------------------------
    if (intStartFrm > 0) {
     //   fprintf(stderr,"\n\nSkipping %d frames. Please wait...", intStartFrm);
        for (framepos_t frame = 0; frame < intStartFrm; frame++){
            inVidStr->ReadFrame(true);
     //       if (!((frame+1) % 100)) {
     //           fprintf(stderr,"\n....%06d",frame);
     //       }
        }
     //   fprintf(stderr,"\nDone.\n");
    }
  //-------------------------------------------------------------------------------


  //-------------------------------------------------------------------------------
  // Decode starting from most recent keyframe 
  //-------------------------------------------------------------------------------
  //mexPrintf("Start Decoding");
//  framepos_t kframe = inVidStr->GetPrevKeyFrame(intStartFrm);
//  for (framepos_t frame = kframe; frame < intStartFrm; frame++){
//    inVidStr->Seek(frame);
//    inVidStr->ReadFrame(true);
//  }
//  inVidStr->Seek(intStartFrm);
  //-------------------------------------------------------------------------------


  //-------------------------------------------------------------------------------
  // Here is the first of the desired frames
  //-------------------------------------------------------------------------------
  //mexPrintf("Get First Frame");
  avm::CImage *image = inVidStr->GetFrame(true);
  //-------------------------------------------------------------------------------
  



  //-------------------------------------------------------------------------------
  // Create a new image to store the Processed Frame from MATLAB
  //-------------------------------------------------------------------------------
  BitmapInfo bmi(image->GetFmt());
  avm::CImage *imageOut = new avm::CImage(image, &bmi);
  //-------------------------------------------------------------------------------
    
  
  
  
  
  //-------------------------------------------------------------------------------
  // Setup the Variables for the subroutine, and create local arrays for processing 
  //-------------------------------------------------------------------------------
  dims[0] = image->Height();
  dims[1] = image->Width();
  dims[2] = 3;  //3 colorplanes
  //Will store the current frame read from the Input file
  CurrentFrame = mxCreateNumericArray(3,dims,mxDOUBLE_CLASS,mxREAL);

  //We pass 2 arrays to the Subroutine and receive 1 back
  SubPRHS[0] = CurrentFrame;
  SubPRHS[1] = mxCreateDoubleScalar((double)intStartFrm);

  // C-pointers to the output variables
  CurrFrBuf = (double*)mxGetData(CurrentFrame);
  intKBuf = (double *)mxGetData(SubPRHS[1]); 
  OutFrBuf = NULL;
  //-------------------------------------------------------------------------------


  
  //-------------------------------------------------------------------------------
  // If We want an AVI file the let's open the output file
  //-------------------------------------------------------------------------------
  avm::IWriteFile* outFile = NULL;
  avm::IVideoWriteStream* outVidStr = NULL;
  if (intWantAVI == 1) {
          //-------------------------------------------------------------------------------
          // Open Output avi file
          //-------------------------------------------------------------------------------
          outFile = avm::CreateWriteFile(OutFileName);
          if (!outFile) {
            char msg[512];
            sprintf(msg, "\n\nPocessAVI Error opening Output file ''%s''.\n",OutFileName);
            mexErrMsgTxt(msg);
            return;
          }
          //-------------------------------------------------------------------------------
          
		
          //-------------------------------------------------------------------------------
          // Setup output Video Stream with appropriate quality, fps and codec
          // Use the first input image to pick the image size
          //-------------------------------------------------------------------------------
          BITMAPINFOHEADER bi;
          fillInfo (image, &bi);
          fourcc_t codec = fccMP42;
//          fourcc_t codec = fccDX50;
          outVidStr = outFile->AddVideoStream(codec, &bi, int(1000000/dblFps));
          if (!outVidStr) {
            char msg[512];
            sprintf(msg, "\n\nProcessAVI Error creating the Video Stream in the Output file ''%s''.\n",OutFileName);
            mexErrMsgTxt(msg);
            return;
          }
          outVidStr->SetQuality(intQuality);
          //outVidStr->SetKeyFrame(100);
          //-------------------------------------------------------------------------------
         	
          
          
          //-------------------------------------------------------------------------------
          // Start the Output Stream
          //-------------------------------------------------------------------------------
          outVidStr->Start();
          //-------------------------------------------------------------------------------
  }
  //-------------------------------------------------------------------------------


  
  //-------------------------------------------------------------------------------
  // Process the First Frame by converting in Double
  //-------------------------------------------------------------------------------
  for (int i = 0; i < dims[0]; i++){
        for (int j = 0; j < dims[1]; j++) {
        	uint8_t* base = image->At(j,i);
        	for (int k = 0; k < dims[2]; k++) {
               	CurrFrBuf[i + j*dims[0] + k*(dims[0]*dims[1])] = (double(*(base+(dims[2]-1)-k)))/255;
            }
        }
  } 
  //-------------------------------------------------------------------------------

  
  
  
  //-------------------------------------------------------------------------------
  // Pass the Frame to MATLAB
  //-------------------------------------------------------------------------------
  mexSetTrapFlag(0);
  ExitCode = mexCallMATLAB(1,SubPLHS,2,SubPRHS,ProcFrm);
  //mexPrintf("\nErrorCode = %d",ExitCode);
  OutFrBuf = (double*)mxGetData(SubPLHS[0]);
  //-------------------------------------------------------------------------------


  //-------------------------------------------------------------------------------
  // Only if we actually want an output of some type
  //-------------------------------------------------------------------------------
  if (intWantAVI > 0) {
      //-------------------------------------------------------------------------------
      // Convert the output frame to be Gray or Like the original one
      //-------------------------------------------------------------------------------
      if (intWantGray) {

            // Convert the Frame back to UINT8 and into GrayScale
            for (int i = 0; i < dims[0]; i++){
                for (int j = 0; j < dims[1]; j++) {
                    uint8_t* base = imageOut->At(j,i);

                    // Convert to NTSC Compute only luminance == Y
                    YIQ_Y = (0.299)*(OutFrBuf[i + j*dims[0] + 0*(dims[0]*dims[1])]) + (0.587)*(OutFrBuf[i + j*dims[0] + 1*(dims[0]*dims[1])]) + (0.114)*(OutFrBuf[i + j*dims[0] + 2*(dims[0]*dims[1])]);
                    // convert back to RGB
                    for (int k = 0; k < dims[2]; k++) {
                        *(base+2-k) = uint8_t(255*YIQ_Y);
                    }
                }
            } 

      } else {
            for (int i = 0; i < dims[0]; i++){
                for (int j = 0; j < dims[1]; j++) {
                    uint8_t* base = imageOut->At(j,i);
                    for (int k = 0; k < dims[2]; k++) {
                        *(base+2-k) = uint8_t(255*OutFrBuf[i + j*dims[0] + k*(dims[0]*dims[1])]);
                    }
                }
            } 
      }
      //-------------------------------------------------------------------------------
  }
  //-------------------------------------------------------------------------------
  
  
  
  
  

  
  
  //-------------------------------------------------------------------------------
  //Destroy MATLAB Array and Save the result
  //-------------------------------------------------------------------------------
  mxDestroyArray(SubPLHS[0]);
  
  if (intWantAVI == 1) {
        //Save Frame in the output file
        outVidStr->AddFrame(imageOut);
  } else if (intWantAVI == 2) {
        // Adjust the Frame Properties to the right Depth
        if (intWantGray) {
            writeJpeg(imageOut,OutFileName,intStartFrm,JCS_GRAYSCALE);
        } else {
            writeJpeg(imageOut,OutFileName,intStartFrm,JCS_RGB);
        }
  }
  //-------------------------------------------------------------------------------

  
  
  
  //-------------------------------------------------------------------------------
  // Free Input Image
  //-------------------------------------------------------------------------------
  image->Release();
  //-------------------------------------------------------------------------------


  
  
  //-------------------------------------------------------------------------------
  // Add the remaining frames to the mean
  //-------------------------------------------------------------------------------
  for (framepos_t frame = intStartFrm + 1; frame < intStartFrm + intNFrms; frame++) {
        //Get the next Frame

  //      inVidStr->ReadFrame(true);
  //      inVidStr->Seek(frame);
        image = inVidStr->GetFrame(true);
        

        // convert the Frame in Double
        for (int i = 0; i < dims[0]; i++){
            for (int j = 0; j < dims[1]; j++) {
        	    uint8_t* base = image->At(j,i);
        	    for (int k = 0; k < dims[2]; k++) {
                    CurrFrBuf[i + j*dims[0] + k*(dims[0]*dims[1])] = (double(*(base+(dims[2]-1)-k)))/255;
                }
            }
        } 

        
        
        //-------------------------------------------------------------------------------
        // Pass the Frame to MATLAB
        //-------------------------------------------------------------------------------
        *intKBuf = frame;
        mexSetTrapFlag(0);
        ExitCode = mexCallMATLAB(1,SubPLHS,2,SubPRHS,ProcFrm);
        //mexPrintf("\nErrorCode = %d",ExitCode);
        const int *DimOut = mxGetDimensions(SubPLHS[0]);

        // Quit Processing??
        if (DimOut[0] == 0) {
            image->Release();
            mxDestroyArray(SubPLHS[0]);
            break;
        }

        OutFrBuf = (double*)mxGetData(SubPLHS[0]);
        //-------------------------------------------------------------------------------
	
        //-------------------------------------------------------------------------------
        // Only if we actually want an output of some type
        //-------------------------------------------------------------------------------
        if (intWantAVI > 0) {
        
            //-------------------------------------------------------------------------------
            // Convert the output frame to be Gray or Like the original one
            //-------------------------------------------------------------------------------
            // Adjust the Frame Properties to the right Depth
            if (intWantGray) {

                // Convert the Frame back to UINT8 and into GrayScale
                for (int i = 0; i < dims[0]; i++){
                    for (int j = 0; j < dims[1]; j++) {
                        uint8_t* base = imageOut->At(j,i);

                        // Convert to NTSC Compute only luminance == Y
                        YIQ_Y = (0.299)*(OutFrBuf[i + j*dims[0] + 0*(dims[0]*dims[1])]) + (0.587)*(OutFrBuf[i + j*dims[0] + 1*(dims[0]*dims[1])]) + (0.114)*(OutFrBuf[i + j*dims[0] + 2*(dims[0]*dims[1])]);
                        // convert back to RGB
                        for (int k = 0; k < dims[2]; k++) {
                            *(base+2-k) = uint8_t(255*YIQ_Y);
                        }
                    }
                } 

            } else {

                for (int i = 0; i < dims[0]; i++){
                    for (int j = 0; j < dims[1]; j++) {
                        uint8_t* base = imageOut->At(j,i);
                        for (int k = 0; k < dims[2]; k++) {
                            *(base+2-k) = uint8_t(255*OutFrBuf[i + j*dims[0] + k*(dims[0]*dims[1])]);
                        }
                    }
                } 
            }
            //-------------------------------------------------------------------------------
        }
        //-------------------------------------------------------------------------------
        
        //-------------------------------------------------------------------------------
        //Destroy MATLAB Array and Save the result
        //-------------------------------------------------------------------------------
        mxDestroyArray(SubPLHS[0]);
  
        if (intWantAVI == 1) {
            //Save Frame in the output file
            outVidStr->AddFrame(imageOut);
        } else if (intWantAVI == 2) {
            // Adjust the Frame Properties to the right Depth
            if (intWantGray) {
                writeJpeg(imageOut,OutFileName,frame,JCS_GRAYSCALE);
            } else {
                writeJpeg(imageOut,OutFileName,frame,JCS_RGB);
            }
        }
        //-------------------------------------------------------------------------------


        
        
        //-------------------------------------------------------------------------------
        // Free Input Image
        //-------------------------------------------------------------------------------
        image->Release();
        //-------------------------------------------------------------------------------
  }        
  //-------------------------------------------------------------------------------

  
  //-------------------------------------------------------------------------------
  // Free Output Images
  //-------------------------------------------------------------------------------
  imageOut->Release();
  //-------------------------------------------------------------------------------
  
  
  
  
  
  
  
  //-------------------------------------------------------------------------------
  // If we want an AVI then we need to close the file
  //-------------------------------------------------------------------------------
  if (intWantAVI == 1) {
      outVidStr->Stop();
      delete outFile;
      outVidStr = 0;
  }
  //-------------------------------------------------------------------------------


  //-------------------------------------------------------------------------------
  //Close the INPUT Stream
  //-------------------------------------------------------------------------------
  inVidStr->StopStreaming();
  delete inFile;
  inVidStr = 0;
  //-------------------------------------------------------------------------------
  
  //-------------------------------------------------------------------------------
  //Destroy Matlab Arrays
  //-------------------------------------------------------------------------------
   mxDestroyArray(SubPRHS[0]);
   mxDestroyArray(SubPRHS[1]);
  //-------------------------------------------------------------------------------
}


