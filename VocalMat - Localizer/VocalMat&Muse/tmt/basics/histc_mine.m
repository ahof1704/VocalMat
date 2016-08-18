function counts=f(x,x_edges)

x_serial=x(:);
counts=histc(x_serial,x_edges);
counts(end-1,:)=counts(end-1,:)+counts(end,:);
counts=counts(1:end-1,:);  % drop stupid end guy
