function [median_frame,median_abs_diff_frame]=seqMedianFrameFromNonRandomSample(input_file_name,max_n_frames_to_sample)

% process args
if ~exist('max_n_frames_to_sample','var') || isempty(max_n_frames_to_sample)
  max_n_frames_to_sample=100;
end 

% Read the input file information
seqHeader=fnReadSeqInfo(input_file_name);
%vr=VideoReader(input_file_name);
%info=get(vr);
n_frames=seqHeader.m_iNumFrames;
%n_frames=info.NumberOfFrames;
if n_frames==0
  error('.seq file %s says it has zero frames',input_file_name);
end

% get the frame size
first_frame=fnReadFrameFromSeq(seqHeader,1);
[n_rows,n_cols]=size(first_frame);

% figure out which frames will be sampled
if n_frames<=max_n_frames_to_sample
  i_to_be_sampled=(1:n_frames)';
else
  n_between=round(n_frames/max_n_frames_to_sample);
  i_to_be_sampled=(1:n_between:n_frames);
  %i_to_be_sampled=randperm(n_frames,max_n_frames_to_sample);
end
n_to_sample=length(i_to_be_sampled);

% collect all the sample frames
sample_frames=zeros(n_rows,n_cols,n_to_sample);
for i=1:n_to_sample
  %sample_frames(:,:,i)=vr.read(i_to_be_sampled(i));
  sample_frames(:,:,i)=double(fnReadFrameFromSeq(seqHeader,i));
end

% calculate the median at each pixel, over the sampled frames
median_frame=median(sample_frames,3);  % double

% calculate the median absolute difference image, if called for
if nargout>=2
  abs_diff_frames=abs(bsxfun(@minus,sample_frames,median_frame));
  median_abs_diff_frame=median(abs_diff_frames,3);
end
  
end

