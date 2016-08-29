function [readframe,nframes,fid,headerinfo] = get_readframe_fcn(filename)
% [readframe,nframes,fid,headerinfo] = get_readframe_fcn(filename)
% get_readframe_fcn inputs the name of a video, opens this video, and creates a
% function that can be used for random access to frames in the video. it can
% input files of type fmf, sbfmf, and avi. if videoio is installed on your
% machine, then get_readframe_fcn will use videoio to read all types of avi
% supported by videoio. otherwise, it uses mmreader to open any type of avi
% supported by mmreader. Run "help mmreader" to determine what types of avi
% files are readable through mmreader on your OS.
%
% Input:
% filename is the name of the video to read. The type of video is determined
% based on the extension, so be sure the extension of your movie is correct. 
%
% Outputs:
% readframe is the handle to a function which inputs a frame number, reads this
% frame from filename, and outputs the corresponding frame. 
% nframes is the number of frames in the video. For avis, this may be
% approximate, as it is computed from the duration and framerate. 
% fid is the file identifier for filename. get_readframe_fcn will open the file
% filename. you must close fid yourself when you are done using the returned
% readframe. 
% headerinfo is a struct with fields depending on the type of movie

[~,ext] = splitext(filename);
if strcmpi(ext,'.fmf'),
  [header_size,version,nr,nc,bytes_per_chunk,nframes,data_format] = fmf_read_header(filename);
  fid = fopen(filename);
  readframe = @(f) fmfreadframe(fid,header_size+(f-1)*bytes_per_chunk,nr,nc,bytes_per_chunk,data_format);
  headerinfo = struct('header_size',header_size,'version',version,'nr',nr,'nc',nc,...
    'bytes_per_chunk',bytes_per_chunk,'nframes',nframes,'data_format',data_format,'type','fmf');
elseif strcmpi(ext,'.sbfmf'),
  [nr,nc,nframes,bgcenter,bgstd,frame2file] = sbfmf_read_header(filename);
  fid = fopen(filename);
  readframe = @(f) sbfmfreadframe(f,fid,frame2file,bgcenter);
  headerinfo = struct('nr',nr,'nc',nc,'nframes',nframes,'bgcenter',bgcenter,...
    'bgstd',bgstd,'frame2file',frame2file,'type','sbfmf');
elseif strcmpi(ext,'.ufmf'),
  headerinfo = ufmf_read_header(filename);
  readframe = ufmf_get_readframe_fcn(headerinfo);
  nframes = headerinfo.nframes;
  fid = headerinfo.fid;
elseif strcmpi(ext,'.seq'),
  headerinfo = fnReadSeqInfo(filename);
  readframe = @(i)fnReadFrameFromSeq(headerinfo,i);
  nframes = headerinfo.m_iNumFrames;
  fid = fopen(filename,'r');
else
  fid = 0;
  % fprintf( 1, 'reading AVI with VideoReader\n' );
  vr = VideoReader(filename);
  headerinfo = get( vr );
  nframes = get( vr, 'numberofframes' );
  readframe = @(f) vr.read(f);
end

end  % function
