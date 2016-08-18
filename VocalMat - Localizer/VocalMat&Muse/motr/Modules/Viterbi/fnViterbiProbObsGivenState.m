function fLogProb = fnViterbiProbObsGivenState(aiStatePerm, a2fObs, a2fMu, a2fSig)
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

% Compute probabilities...
iNumMice = length(aiStatePerm);
iNumClassifiers = size(a2fMu,2);
a2fProb = zeros(iNumMice, iNumClassifiers);
for iMouseIter=1:iNumMice
    for iClassIter=1:iNumClassifiers
        a2fProb(iMouseIter,iClassIter) = normpdf(a2fObs(aiStatePerm(iMouseIter),iClassIter), ...
            a2fMu((iMouseIter),iClassIter), a2fSig((iMouseIter),iClassIter));
    end;
end;

fLogProb = sum(log(a2fProb(:)));
return;
