function dr=f(im1,im0,dr_guess)

% offset is an x,y pair, in pels

if nargin<3
  dr_guess=[0 0]';
end

neighbors=[ -1 +1  0  0 ; ...
             0  0 -1 +1 ];
n_neighbors=size(neighbors,2);
dr=dr_guess
mse_last=Inf;
tic
mse=image_mse(im1,im0,dr)
toc
while mse<mse_last
  mse_neighbors=zeros(1,n_neighbors);
	for i=1:n_neighbors
    dr_try=dr+neighbors(:,i);
    mse_neighbors(i)=image_mse(im1,im0,dr_try);
  end
  [mse_neighbor_min,i_neighbor_min]=min(mse_neighbors);
  mse_last=mse;
  if mse_neighbor_min<mse
    mse=mse_neighbor_min;
    dr=dr+neighbors(:,i_neighbor_min);
	end
  dr
  mse
end
