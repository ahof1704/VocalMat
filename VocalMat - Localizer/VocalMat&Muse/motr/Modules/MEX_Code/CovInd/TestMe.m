addpath('D:\Code\Janelia Farm\CurrentVersion\MEX\x64');

A = rand(1000, 26,'single');
aiInd = 1:3:1000;

DataPos = A(aiInd,:);



afMeanPos = mean(DataPos,1);
DataCenteredPos = DataPos - repmat(afMeanPos, size(DataPos,1),1);
a2fCovPos  = DataCenteredPos' * DataCenteredPos;

A(aiInd,:)
[a2fCov_DLL, afMean_DLL] = fndllCovInd(A, aiInd);

afMean_DLL-afMeanPos
norm(a2fCov_DLL-a2fCovPos)