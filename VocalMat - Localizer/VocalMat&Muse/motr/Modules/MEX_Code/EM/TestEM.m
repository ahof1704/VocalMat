load('D:\Code\Janelia Farm\CurrentVersion\DebugEM');
addpath('D:\Code\Janelia Farm\CurrentVersion\MEX\x64');

[a2fOptMu, a3fOptCov, Priors, fLogLikelihood] = fnEM(Data, Mu0, Sigma0, Priors0, 1e-15, iNumEMIterations);

TrueMu = Mu;
TrueSigma = Sigma;
TruePriors = Priors;
tic
[Mu, Sigma, Priors, Tmp] = fnEM(Data, Mu0, Sigma0, Priors0, fStopRadio,iMaxIterations);
toc


[Mu, Sigma, Priors] = fnConstrainedEM2(Data, Mu0, Sigma0, Priors0, fStopRadio,iMaxIterations);