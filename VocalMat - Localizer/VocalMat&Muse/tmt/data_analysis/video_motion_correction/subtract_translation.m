function [result,b_per_frame]=subtract_translation(m,border)

% Motion-correct a movie, m, performing a rigid translation on each frame
% to bring it into register with the first frame.  border specifies the
% number of pixels around the edge of the movie to be ignored.  On return,
% result contains the motion-subtracted movie, and b_per_frame contains
% the vector used to translate each frame.  Note that the y-coord of
% b_per_frame is in image coordinates, i.e. y increases going from top to
% bottom.

n_rows=size(m,1);
n_cols=size(m,2);
n_frames=size(m,3);

b_per_frame=zeros(2,n_frames);

% options=zeros(18,1);
% options(14)=1000;  % max number of function evals
options=optimset('maxfunevals',1000);

% find the translation for each frame
for k=2:n_frames
  [b_per_frame(:,k),error]=...
    find_translation(m(:,:,1),m(:,:,k),border,...
                     b_per_frame(:,k-1),...
                     options);
  %b_per_frame(:,k)
end

% register each frame using the above-determined translation
result=zeros(n_rows,n_cols,n_frames);
result(:,:,1)=m(:,:,1);
for k=2:n_frames
  result(:,:,k)=register_frame(m(:,:,k),...
                               eye(2),b_per_frame(:,k));
end
                         
