function [classifier, missRate, annotatedFalseRate] = gentleBoost(x, y, Nrounds, lookNoFurtherError, triggerHappyFactor, AnnotatedWeight)
% gentleBoost
%
% features x
% class: y = [-1,1]
%
%

% Implementation of gentleBoost:
% Friedman, J. H., Hastie, T. and Tibshirani, R. 
% "Additive Logistic Regression: a Statistical View of Boosting." (Aug. 1998) 

% atb, 2003

[Nfeatures, Nsamples] = size(x); % Nsamples = Number of thresholds that we will consider
Fx = zeros(1, Nsamples);
w  = ones(1, Nsamples);
annotatedFalseRate = 0;
annotatedFalse = (y < 0 & y ~= -1);
w = abs(y);
if nargin > 5
    w(y>0) =  w(y>0) * AnnotatedWeight(1);
    w(annotatedFalse) = w(annotatedFalse) * AnnotatedWeight(2);
end
y = sign(y);
% s = x(3,:)<5 & y<0;
% w(s) = w(s) * 216./(x(3,s)+1).^3;
w0 = w;
prevError = 1;
for m = 1:Nrounds
    disp(sprintf('Round %d', m))
    
    % Weak regression stump: It is defined by four parameters (a,b,k,th)
    %     f_m = a * (x_k > th) + b
    [k, th, a , b] = selectBestRegressionStump(x, y, w);
    
    % Updating and computing classifier output on training samples
    fm = (a * (x(k,:)>th) + b); % evaluate weak classifier
    Fx = Fx + fm; % update strong classifier
    Error(m) = sum(w0 .* abs(sign(Fx)-y))/sum(w0);
    if nargin > 4 && ~isempty(triggerHappyFactor)
        [k, th, a , b] = selectBestRegressionStump(x, y, w, triggerHappyFactor);
    end
    
    % Reweight training samples
    w = w .* exp(-y.*fm);
    
    % update parameters classifier
    classifier(m).featureNdx = k;
    classifier(m).th = th;
    classifier(m).a  = a;
    classifier(m).b  = b;
    
    if nargin > 3 && ~isempty(lookNoFurtherError)
        if Error(m) < lookNoFurtherError
            display(['gentleBoost converged after ' num2str(m) ' rounds'])
            break;
        end
    end
    
end
pos = (y == 1);
missRate = sum(Fx(pos) < 0)/sum(pos);
if ~isempty(annotatedFalse)
    annotatedFalseRate = sum(Fx(annotatedFalse) > 0)/sum(annotatedFalse);
end
figure(1), plot(Error)

