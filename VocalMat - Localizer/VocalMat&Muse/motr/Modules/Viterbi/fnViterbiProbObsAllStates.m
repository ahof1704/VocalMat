function afLogProb = fnViterbiProbObsAllStates(a2iAllStates, a2fObs, a2fMu, a2fSig)
% Computes the log likelihood of seeing a observation given the system
% state.
%
% Inputes:
%  aiStatePerm - System state, given as a permutation.
%  a2fObs - Observation matrix (NumMice x NumClassifiers)
%  a2fMu, a2fSig - Probability density functions of classifiers response.
%
% Outputs:
%  fLogProb - log likelihood
%
%Copyright (c) 2008 Shay Ohayon, California Institute of Technology. 
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

iNumClassifiers = size(a2fMu,2);
iNumStates = size(a2iAllStates,1);
iNumMice = size(a2iAllStates,2);
afLogProb = zeros(1,iNumStates);
for iStateIter=1:iNumStates
    a2fProb = zeros(iNumMice, iNumClassifiers);
    aiStatePerm = a2iAllStates(iStateIter,:);
    for iMouseIter=1:iNumMice
        for iClassIter=1:iNumClassifiers
            x = a2fObs(aiStatePerm(iMouseIter),iClassIter);
            mu = a2fMu(iMouseIter,iClassIter);
            sigma = a2fSig(iMouseIter,iClassIter);
           y = (-0.5 * ((x - mu)./sigma).^2) - log((sqrt(2*pi) .* sigma));
            a2fProb(iMouseIter,iClassIter) = y;%log(normpdf(x,mu,sigma));
        end;
    end;
%    fThreshold= log(0.024);
%    a2fProb(a2fProb<fThreshold) = -100;
    afLogProb(iStateIter) = sum((a2fProb(:)));%log
end;
    
return;
