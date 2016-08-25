addpath('D:\Code\Janelia Farm\CurrentVersion\MEX\x64');

load('D:\Code\Janelia Farm\CurrentVersion\Debug_Vit');
 
    [a2LogfLikelihood] = ...
        fnViterbiLikelihoodForHeadTail(afStateAngles, double(afProbPos), ...
        afTheta, afVel, afVelocityAngle);
