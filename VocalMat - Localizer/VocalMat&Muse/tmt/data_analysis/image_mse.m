function mse=f(im1,im0,dr)

% we assume dr is in cartesian coords
% we assume im0 is one frame, im1 is the next frame, that we're observing
% translation, and when we get the right dr, that will yield a near-zero
% mse

% since image coords aren't cartesian, need to negate dr y
dr(2)=-dr(2);

w_x=size(im0,1);
w_y=size(im0,2);

im1_x_min=max(0,dr(1));
im1_y_min=max(0,dr(2));
im0_x_max=min(w_x-1,w_x-1-dr(1));
im0_y_max=min(w_y-1,w_y-1-dr(2));

im0_x_min=max(0,-dr(1));
im0_y_min=max(0,-dr(2));
im1_x_max=min(w_x-1,w_x-1+dr(1));
im1_y_max=min(w_y-1,w_y-1+dr(2));

im0_common=im0(im0_x_min+1:im0_x_max+1,im0_y_min+1:im0_y_max+1);
im1_common=im1(im1_x_min+1:im1_x_max+1,im1_y_min+1:im1_y_max+1);

mse=mean(mean((double(im1_common)-double(im0_common)).^2));
