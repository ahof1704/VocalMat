function ims_reg=f(ims)

n_t=size(ims,3);
drs=align_movie_to_first(ims);  % this just calculates the translation 
                                % vectors
ims_reg=zeros(size(ims),class(ims));
for i_t=1:n_t
  ims_reg(:,:,i_t)=register_image(ims(:,:,i_t),drs(:,i_t));
end
