function kernel = f(sigma,n)

% returns a column vector

if nargin<2
  radius=4*ceil(sigma); % make sure even
  n=2*radius+1;
end
% make n odd
if mod(n,2)==0
  n=n+1;
end
kernel=zeros(n,1);
center=ceil(n/2);  % this is s.t. ifftshift(kernel) will put the
                   %   center element at the beginning of the array
                   % if n is odd, this is the center element
row_index=(1:n)';
kernel=exp(-0.5*((row_index-center).^2)./(sigma^2));
% normalize
kernel_mag=sum(kernel);
kernel=kernel/kernel_mag;

