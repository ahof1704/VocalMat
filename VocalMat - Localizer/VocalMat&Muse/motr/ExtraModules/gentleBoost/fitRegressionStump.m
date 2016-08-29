function [th, a , b, error] = fitRegressionStump(x, z, w, triggerHappyFactor);
% [th, a , b] = fitRegressionStump(x, z);
% The regression has the form:
% z_hat = a * (x>th) + b;
%
% where (a,b,th) are so that it minimizes the weighted error:
% error = sum(w * |z - (a*(x>th) + b)|^2) 
%
% x,z and w are vectors of the same length
% x, and z are real values.
% w is a weight of positive values. There is no asumption that it sums to
% one.

% atb, 2003

[Nfeatures, Nsamples] = size(x); % Nsamples = Number of thresholds that we will consider
w = w/sum(w); % just in case...

[x, j] = sort(x); % this now becomes the thresholds. I assume that all the values are different. If the values are repeated you might need to add some noise.
z = z(j); w = w(j);

Szw = cumsum(z.*w); Ezw = Szw(end);
Sw  = cumsum(w);

% This is 'a' and 'b' for all posible thresholds:
b = Szw ./ Sw;
zz = Sw == 1;
Sw(zz) = 0; 
a = (Ezw - Szw) ./ (1-Sw) - b; 
Sw(zz) = 1;

% Now, let's look at the error so that we pick the minimum:
% the error at each threshold is:
% for i=1:Nsamples
%     error(i) = sum(w.*(z - ( a(i)*(x>th(i)) + b(i)) ).^2);
% end
% but with vectorized code it is much faster but also more obscure code:
Error = sum(w.*z.^2) - 2*a.*(Ezw-Szw) - 2*b*Ezw + (a.^2 +2*a.*b) .* (1-Sw) + b.^2;

% Output parameters. Search for best threshold (th):
[error, k] = min(Error);

if k == Nsamples
    th = x(k);
else
    th = (x(k) + x(k+1))/2;
end
a = a(k);
b = b(k);

if nargin>3
    errorTH = abs(triggerHappyFactor) * (max(Error)-error) + error;
    if a*triggerHappyFactor > 0
        i = find(x < th & Error >= errorTH);
    else
        i = find(x > th & Error >= errorTH);
    end
    if ~isempty(i)
        [errorTH, j] = min(Error(i));
        k = i(j);
    end
end
if k == Nsamples
    th = x(k);
else
    th = (x(k) + x(k+1))/2;
end
% a = a(k);
% b = b(k);

