clear all
A=load('D:\Data\Janelia Farm\Classifiers\Training_SeqA.mat');
B=load('D:\Data\Janelia Farm\Classifiers\Training_SeqA2.mat');
for k=1:4
    astrctTrackers(k).m_afX = [A.astrctTrackers(k).m_afX,B.astrctTrackers(k).m_afX];
    astrctTrackers(k).m_afY = [A.astrctTrackers(k).m_afY,B.astrctTrackers(k).m_afY];
    astrctTrackers(k).m_afA = [A.astrctTrackers(k).m_afA,B.astrctTrackers(k).m_afA];
    astrctTrackers(k).m_afB = [A.astrctTrackers(k).m_afB,B.astrctTrackers(k).m_afB];
    astrctTrackers(k).m_afTheta = [A.astrctTrackers(k).m_afTheta,B.astrctTrackers(k).m_afTheta];
end;

szA = size(A.a4iTraining);
szB = size(B.a4iTraining);

a4iTraining = zeros( [szA(1:3),szA(4)+szB(4)],'uint8');
a4iTraining(:,:,:,1:szA(4)) = A.a4iTraining;
a4iTraining(:,:,:,szA(4)+1:end) = B.a4iTraining;

strMovieName = 'D:\Data\Janelia Farm\Movies\ExpA\10.02.24.796.seq';
save('D:\Data\Janelia Farm\Classifiers\Training_SeqA_Merged','astrctTrackers','a4iTraining','strMovieName');
