strRoot = '/groups/egnor/home/ohayons/Data/cage18/Jobs/';
astrctFolders = dir(strRoot);
for k=3:length(astrctFolders)
strSeq = astrctFolders(k).name;%'b6_popcage_18_09.15.11_10.56.24.135';
strJobFoder = ['/groups/egnor/home/ohayons/Data/cage18/Jobs/',strSeq,'/'];
strResultsFolder = ['/groups/egnor/home/ohayons/Data/cage18/Results/',strSeq,'/'];

astrctJobs = dir([strJobFoder,'Jobargin*.mat']);
astrctResults = dir([strResultsFolder,'JobOut*.mat']);

aiJobSubmitted = zeros(1,length(astrctJobs));
for iJobIter=1:length(astrctJobs)
    iIndex1 = find(astrctJobs(iJobIter).name == 'n',1,'last');
    iIndex2 = find(astrctJobs(iJobIter).name == '.',1,'last');
    aiJobSubmitted(iJobIter) = str2num(astrctJobs(iJobIter).name(iIndex1+1:iIndex2-1));
end

aiJobResults = zeros(1,length(astrctResults));
for iJobIter=1:length(astrctResults)
    iIndex1 = find(astrctResults(iJobIter).name == 't',1,'first');
    iIndex2 = find(astrctResults(iJobIter).name == '.',1,'last');
    aiJobResults(iJobIter) = str2num(astrctResults(iJobIter).name(iIndex1+1:iIndex2-1));
end

fprintf('Missing Jobs for seq %s:\n',strSeq);
setdiff(aiJobSubmitted, aiJobResults)
pause
end
