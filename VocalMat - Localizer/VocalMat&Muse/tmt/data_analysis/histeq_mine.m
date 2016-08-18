function im_out=f(im,n_bins,df_max)

n_rows=size(im,1);
n_cols=size(im,2);
n_pels=n_rows*n_cols;
threshs=zeros(1,n_bins);
im_min=min(min(im));
im_max=max(max(im));

