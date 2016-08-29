#include "AviFileInterface.h"

CAviFileInterface::CAviFileInterface(char *strFileName) {
  if (GetAvifileVersion() != AVIFILE_VERSION) {
    char msg[512];
    sprintf(msg, "\nBGSubAVI This binary was compiled for Avifile ver. %d, , but the library is ver. %d.\n",
	    AVIFILE_VERSION,GetAvifileVersion());
    mexErrMsgTxt(msg);
    return;
  }

	inFile = avm::CreateReadFile(strFileName);
    if (!inFile) {
    	mexErrMsgTxt("\n avm::CreateReadFile failed\n");
 	   return;
  	}
  inVidStr = inFile->GetStream(0, avm::IStream::Video);
  if (!inVidStr) {
    mexErrMsgTxt("avm::GetStream failed\n");
    return;
  }
  

    BITMAPINFOHEADER bih;
    inVidStr->GetVideoFormat(&bih, sizeof(bih));
   strctMovieInfo.NumFrames = inVidStr->GetLength();
   strctMovieInfo.Width = bih.biWidth;
   strctMovieInfo.Height = bih.biHeight;   
   strctMovieInfo.BitPerPixel = bih.biBitCount;
   inVidStr->StartStreaming();
   CurrFrame = 0;

}

CAviFileInterface::~CAviFileInterface() {
  inVidStr->StopStreaming();
  inVidStr = NULL;
}

int CAviFileInterface::GetMovieFrame(unsigned char *buffer) {
  image = inVidStr->GetFrame(true);


    int dims[3];
    dims[0] = strctMovieInfo.Height;
    dims[1] = strctMovieInfo.Width;
    dims[2] = strctMovieInfo.BitPerPixel/8;
    for (int i = 0; i < dims[0]; i++){
        for (int j = 0; j < dims[1]; j++) {
        	uint8_t* base = image->At(j,i);
        	for (int k = 0; k < dims[2]; k++) {
               	buffer[i + j*dims[0] + k*(dims[0]*dims[1])] = ((*(base+(dims[2]-1)-k)));
            }
        }
      } 
   image->Release();
  CurrFrame = CurrFrame + 1;  
  return 1;
}

bool CAviFileInterface::Seek(long Frame) {
    framepos_t kframe = inVidStr->GetPrevKeyFrame(Frame);
   // mexPrintf("Seeking to key frame %d \n",kframe);
    if (kframe == -1) {
        mexPrintf("Failed to seek to that position\n");
        return false;
    }
    inVidStr->Seek(kframe);
    for (framepos_t frame = kframe; frame < Frame; frame++){
         image = inVidStr->GetFrame(true);
  }
    CurrFrame = Frame;
    return true;
}


