function result = f(data)

% data must be a vector
% result is square root of the "S squared" stat over the "x bar" stat
% I don't really know much about what you can say about how this relates to
% sqrt(Var[X]])/E[X].  Is it biased?  Are there other estimators of this
% quantity that strictly dominate it in terms of squared-error risk?  I have
% no idea... 

n=length(data);
x_bar=mean(data);
std_dev_est=sqrt(sum((data-x_bar).^2)/(n-1));
result=std_dev_est/x_bar;
