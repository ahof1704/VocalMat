function F=empirical_cdf(x,x_line)

% x is the the samples
% x_line is the values at which we want the CDF computed

n=length(x);
F=zeros(size(x_line));
x0=x_line(1);
n_line=length(x_line);
dx=(x_line(end)-x0)/(n_line-1);
dF=1/n;
for i=1:n
  x_this=x(i);
  j_first=floor((x(i)-x0)/dx)+1;
  for j=j_first:n_line
    F(j)=F(j)+dF;
  end
end

end
