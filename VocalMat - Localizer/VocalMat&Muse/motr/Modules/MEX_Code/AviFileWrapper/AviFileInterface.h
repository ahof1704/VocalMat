#ifndef AVIFILEINTERFACE_H_
#define AVIFILEINTERFACE_H_

#include <mex.h>
#include <avifile.h>
#include <aviplay.h>
#include <version.h>
#include <memory.h>

struct MovieInfo {
	double Fps;
	int NumFrames;
	int Width;
	int Height;
	int BitPerPixel;
};

class CAviFileInterface {
public:
	CAviFileInterface(char *strFileName);
	struct MovieInfo GetMovieInfo() {return strctMovieInfo;}
	int GetMovieFrame(unsigned char *buffer);
	bool Seek(long Frame);
	~CAviFileInterface();
	struct MovieInfo strctMovieInfo;
    long GetCurrFrame() {return CurrFrame;}
private:
	avm::IReadFile* inFile;
	avm::IReadStream* inVidStr;
	avm::CImage *image;
    long CurrFrame;
};

#endif /*AVIFILEINTERFACE_H_*/
