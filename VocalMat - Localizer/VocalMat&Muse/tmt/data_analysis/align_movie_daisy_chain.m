function drs=f(ims)

n_t=size(ims,3);
drs=zeros(2,n_t);
for i_t=2:n_t
  i_t
  dr_this=align_images(ims(:,:,i_t),ims(:,:,i_t-1));
  drs(:,i_t)=drs(:,i_t-1)+dr_this;
end
