load('..\..\ViterbiOnTheDly.mat');
addpath('..\..\MEX\x64');
[aiPath,a2fLogProb, a2iUpdateLog, a3bIntersections] = fndllViterbiOnTheFly(a2iAllStates', a2fLikelihood, ...
    a2fX, a2fY, a2fA, a2fB, a2fTheta, fSwapPenalty, abLargeTimeGap);
