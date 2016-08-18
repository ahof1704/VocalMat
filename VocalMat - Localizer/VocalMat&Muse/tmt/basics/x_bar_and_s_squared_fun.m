function result = f(data)

% data must be a vector
% result is the column vector [ x_bar ; s_squared ], where
% x_bar is the average of the data, and s_squared is the S^2
% statistic (the one with (n-1) in the denominator)

n=length(data);
x_bar=mean(data);
s_squared=sum((data-x_bar).^2)/(n-1);
result=[x_bar;s_squared];
