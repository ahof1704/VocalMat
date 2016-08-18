function kernel = f(sigma)

radius=2*ceil(sigma); % make sure even
diameter=2*radius+1;
kernel=zeros(diameter,diameter);
center=(diameter+1)/2;
row_index=repmat((1:diameter)',[1,diameter]);
col_index=repmat(1:diameter,[diameter,1]);
kernel=exp(-0.5*((row_index-center).^2+(col_index-center).^2)./(sigma^2));
% normalize
kernel_mag=sum(sum(kernel));
kernel=kernel/kernel_mag;

