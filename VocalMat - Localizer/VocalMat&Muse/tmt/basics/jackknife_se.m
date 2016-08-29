function se=f(estimator,x,varargin)

n=length(x);
estimate=feval(estimator,x,varargin{:});
estimate_tao=zeros(n,1);
for i=1:n
  x_tao=x;  x_tao(i)=[];
  estimate_tao(i)=feval(estimator,x_tao,varargin{:});
end
estimate_tao_mean=mean(estimate_tao);
se2=(n-1)/n*sum((estimate_tao-estimate_tao_mean).^2);
se=sqrt(se2);
