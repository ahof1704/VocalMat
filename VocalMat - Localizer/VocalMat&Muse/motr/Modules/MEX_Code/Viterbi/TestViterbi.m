load('..\..\DebugViterbi.mat');
addpath('..\..\MEX\x64');
aiPath = fnViterbi(a2fTransitionMatrix,a2fLikelihood);
