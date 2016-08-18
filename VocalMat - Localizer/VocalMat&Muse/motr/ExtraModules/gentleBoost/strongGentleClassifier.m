function [Cx, Fx] = strongGentleClassifier(x, classifier)
% [Cx, Fx] = strongLogitClassifier(x, classifier)
%
% Cx is the predicted class 
% Fx is the output of the additive model
% Cx = sign(Fx)
%
% In general, Fx is more useful than Cx.
%
% The weak classifiers are stumps

% Friedman, J. H., Hastie, T. and Tibshirani, R. 
% "Additive Logistic Regression: a Statistical View of Boosting." (Aug. 1998) 

% atb, 2003
% torralba@ai.mit.edu

Nstages = length(classifier);
[Nfeatures, Nsamples] = size(x); % Nsamples = Number of thresholds that we will consider

Fx = zeros(1, Nsamples);
for m = 1:Nstages
    featureNdx = classifier(m).featureNdx;
    th = classifier(m).th;
    a = classifier(m).a;
    b = classifier(m).b;
    
    Fx = Fx + (a * (x(featureNdx,:)>th) + b); %add regression stump
end

Cx = sign(Fx) .* max(abs(x(1,:)), 0.000001);
