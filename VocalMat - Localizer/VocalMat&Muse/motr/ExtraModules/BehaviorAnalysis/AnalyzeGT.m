strctGT = load('D:\Data\Janelia Farm\GroundTruth\Sager\GroundTruth_332251_UnRandomized.mat');
a2iPerms = cat(1,strctGT.astrctGT.m_aiPerm);

%Narrow down to the following interval?
iStartInterval = 941;
iEndInterval = 2216;
aiInterval = iStartInterval:iEndInterval;

abNotChecked = a2iPerms(aiInterval,1) == 0 & a2iPerms(aiInterval,2) == 0 &a2iPerms(aiInterval,3) == 0 &a2iPerms(aiInterval,4) == 0 ;
abChecked = ~abNotChecked;
abCheckedAndMarkedAll =  a2iPerms(aiInterval,1) > 0 & a2iPerms(aiInterval,2) > 0 &a2iPerms(aiInterval,3) > 0 &a2iPerms(aiInterval,4) > 0 ;

abCheckedCorrect =  a2iPerms(aiInterval,1) ==1 & a2iPerms(aiInterval,2) ==2 &a2iPerms(aiInterval,3) ==3  & a2iPerms(aiInterval,4) == 4;

aiIncorrectKeyFrames = aiInterval(find(abCheckedAndMarkedAll & ~abCheckedCorrect));


fprintf('%d key frames not checked\n',sum(abNotChecked));
fprintf('%d key frames checked\n',sum(abChecked));
fprintf('   - Out of those : %d were fully marked\n',sum(abCheckedAndMarkedAll))
fprintf('       - Out of those : %d were correct\n',sum(abCheckedCorrect))
fprintf('\n');
fprintf('Incorrect keyframes according to annotator:\n');

for k=1:length(aiIncorrectKeyFrames)
    fprintf('Key frame %5d (frame %5d)\n',aiIncorrectKeyFrames(k),strctGT.astrctGT(aiIncorrectKeyFrames(k)).m_iFrame);
end
