function [result,A_per_frame,b_per_frame]=subtract_motion(m,border)

n_rows=size(m,1);
n_cols=size(m,2);
n_frames=size(m,3);

A_per_frame=zeros(2,2,n_frames);
b_per_frame=zeros(2,n_frames);
A_per_frame(:,:,1)=eye(2);

options=zeros(18,1);
options(14)=1000;  % max number of function evals

for k=2:n_frames
  k
  [A_per_frame(:,:,k),b_per_frame(:,k),error]=...
    find_registration(m(:,:,1),m(:,:,k),border,...
                      A_per_frame(:,:,k-1),b_per_frame(:,k-1),...
                      options);
  A_per_frame(:,:,k)
  b_per_frame(:,k)
end

result=zeros(n_rows,n_cols,n_frames);
result(:,:,1)=m(:,:,1);
for k=2:n_frames
  result(:,:,k)=register_frame(m(:,:,k),...
                               A_per_frame(:,:,k),b_per_frame(:,k));
end
                         
