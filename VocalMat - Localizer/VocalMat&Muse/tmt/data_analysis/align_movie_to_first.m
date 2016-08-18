function drs=f(ims)

% This function takes a movie [n_rows n_cols n_frames], and returns an
% matrix of col vectors, the ith of which tells you how to translate the 
% first frame to get the best match with the ith frame.  Thus the output is
% [2 n_frames].  The first column of drs is guaranteed to be [0 0]'.  It
% doesn't do sub-pixel alignment, so all the elements of drs are integers.
%

n_t=size(ims,3);
drs=zeros(2,n_t);
for i_t=2:n_t
  i_t
  drs(:,i_t)=align_images(ims(:,:,i_t),ims(:,:,1),drs(:,i_t-1));
end
