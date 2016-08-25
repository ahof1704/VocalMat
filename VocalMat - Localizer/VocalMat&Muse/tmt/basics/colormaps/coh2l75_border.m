function im=coh2l75_border(z,z_thresh)

% z is mxn of complex, assumed to have mag(z)<=1
% im is mxnx3, RGB image

if nargin<2 || isempty(z_thresh)
  z_thresh=0;
end

n_clr=1000;
cmap_outer_rgb=l75_border(n_clr);
cmap_outer_lab=srgb2lab(cmap_outer_rgb);
z_mag=abs(z);
z_phase=wrap(angle(z));
% deal with NaN's, infs, etc.
messed=~isfinite(z_mag);
z_mag(messed)=0;
z_phase(messed)=0;
% deal with values that might be (hopefully only slightly) out of bounds
z_mag=min(max(z_mag,0),1);
im_l=75*z_mag;
im_l(z_mag<z_thresh)=0;
ind=round((n_clr-1)*(((z_phase/pi)+1)/2))+1;
im_lab_r_max=reshape(cmap_outer_lab(ind,:),[size(z) 3]);
im_ab_r_max=im_lab_r_max(:,:,2:3);
im_ab=repmat(z_mag,[1 1 2]).*im_ab_r_max;
%im_ab=im_ab_r_max;
im_lab=zeros([size(z) 3]);
im_lab(:,:,1)=im_l;
im_lab(:,:,2:3)=im_ab;

% convert Lab to sRGB
im_lab_rows=reshape(im_lab,[size(z,1)*size(z,2) 3]);
im_rows=lab2srgb(im_lab_rows);
im=reshape(im_rows,[size(z) 3]);
im=min(max(im,0),1);  % some things might be a little bit out-of-bounds
