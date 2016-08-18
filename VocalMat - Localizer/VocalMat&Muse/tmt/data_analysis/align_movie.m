function drs=f(ims)

n_t=size(ims,3);
drs=zeros(2,n_t-1);
for i_t=2:n_t
  i_t
  drs(:,i_t-1)=align_images(ims(:,:,i_t),ims(:,:,i_t-1));
end
