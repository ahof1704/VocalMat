function [afMu,a2fCov] = fnFitGaussian(X)
% Fit a 2D gaussian to a set of observations, given as Nx2 matrix
% Maximum likelihood...same as PCA
%
%
%Copyright (c) 2008 Shay Ohayon, California Institute of Technology. 
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

afMu = mean(X,1)';
Xt = [X(:,1)-afMu(1), X(:,2)-afMu(2)];
a2fCov=Xt'*Xt * 1/size(X,1);


