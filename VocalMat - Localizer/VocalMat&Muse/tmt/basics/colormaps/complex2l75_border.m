function [im,z_mag_max]=complex2l75_border(z,z_mag_max)

% z is mxn of complex
% im is mxnx3, RGB image

z_mag=abs(z);
if nargin<2 || isempty(z_mag_max)
  z_mag_max=max(z_mag(:));
end

n_clr=1000;
cmap_outer_rgb=l75_border(n_clr);
cmap_outer_lab=srgb2lab(cmap_outer_rgb);
z_phase=wrap(angle(z));
im_l=75*z_mag./z_mag_max;
ind=round((n_clr-1)*(((z_phase/pi)+1)/2))+1;
im_lab_r_max=reshape(cmap_outer_lab(ind,:),[size(z) 3]);
im_ab_r_max=im_lab_r_max(:,:,2:3);
im_ab=repmat(z_mag./z_mag_max,[1 1 2]).*im_ab_r_max;
%im_ab=im_ab_r_max;
im_lab=zeros([size(z) 3]);
im_lab(:,:,1)=im_l;
im_lab(:,:,2:3)=im_ab;

% convert Lab to sRGB
im_lab_rows=reshape(im_lab,[size(z,1)*size(z,2) 3]);
im_rows=lab2srgb(im_lab_rows);
im=reshape(im_rows,[size(z) 3]);
im=min(max(im,0),1);  % constrain to bounds