function patch_h = patch_eb(x,y_eb,c,varargin)

% Draws patch objects to represent an error bar with lower limit y_lo,
% upper limit y_hi, in the current axes.  Returns a col vector of 
% handles to the patches.
%
% We assume x is a col vector of length n
% We assume y_eb is n x 2, with y_eb(i,1) <= y_eb(i,2) for all i

n_max=10^4;  % larger patches than this make matlab slow as of 08/29/2011
n=length(x);
if n==0
  patch_h=cell(0,1);
  return;
end
n_patch=ceil(n/n_max);
patch_h=zeros(n_patch,1);
for k=1:n_patch
  i_first=1+(k-1)*n_max;
  i_last=k*n_max;
  if i_last>n
    i_last=n;
  end
  x_sub=x(i_first:i_last);
  y_eb_sub=y_eb(i_first:i_last,:);
  patch_h(k)=patch([x_sub;flipdim(x_sub,1)],...
                   [y_eb_sub(:,1);flipdim(y_eb_sub(:,2),1)],...
                   c,...
                   'edgecolor','none',...
                   varargin{:});
end

end  % function


