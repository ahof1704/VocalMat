function fnCompareTrackersAfterTime()
% Assume DataPos and DataNeg ave the same size
acOrig = {...
          'D:\Data\Janelia Farm\Movies\bleach_mark_tests_2\new_bleach_marks_stripes_2_antpost_horiz.seq',...
          'D:\Data\Janelia Farm\Movies\bleach_mark_tests_2\new_bleach_marks_stripes_2_latleft_vert.seq',...
          'D:\Data\Janelia Farm\Movies\bleach_mark_tests_2\new_bleach_marks_stripes_2midvert.seq',...
          'D:\Data\Janelia Farm\Movies\bleach_mark_tests_2\new_bleach_marks_stripes_2post_horiz.seq',...
          'D:\Data\Janelia Farm\Movies\bleach_mark_tests_2\new_bleach_marks_stripes_3_antmidpost_horiz.seq',...
          'D:\Data\Janelia Farm\Movies\bleach_mark_tests_2\new_bleach_marks_stripes_2ant_horiz.seq'};

acAfter = {...
          'D:\Data\Janelia Farm\Movies\6Mice\stripes_2nd_2_antpost_horiz.seq',...
          'D:\Data\Janelia Farm\Movies\6Mice\stripes_2nd_2_lat_left_horiz.seq',...
          'D:\Data\Janelia Farm\Movies\6Mice\stripes_2nd_2_mid_vert.seq',...
          'D:\Data\Janelia Farm\Movies\6Mice\stripes_2nd_2_post_horiz.seq',...
          'D:\Data\Janelia Farm\Movies\6Mice\stripes_2nd_3_antmidpost_horiz.seq',...
          'D:\Data\Janelia Farm\Movies\6Mice\stripes_2nd_2_ant_horiz.seq'};



iNumIdentities = 6;
strResultsRootFolder = 'D:\Data\Janelia Farm\Results\';
iMaxSamplesForIdentityTraining= 10000;
iHOG_Dim = 837; 
acOrigStrct = cell(1,length(acOrig));
acAfterStrct = cell(1,length(acAfter));
for k=1:length(acOrig)
    acOrigStrct{k} = fnReadVideoInfo(acOrig{k});
    acAfterStrct{k} = fnReadVideoInfo(acAfter{k});
end;
[a2fFeatures, aiStart, aiEnd, Tmp, a3fRepImagesOrig] = fnCollectExemplars(acOrigStrct,strResultsRootFolder,iMaxSamplesForIdentityTraining,false,iHOG_Dim);

strctIdentityClassifier = fnTrainIdentities(a2fFeatures, aiStart, aiEnd,iHOG_Dim);


clear a2fFeatures

% Now, collect exemplars from test sequences...
iMaxSamplesForIdentityTraining = 20000;
[a2fFeatures, aiStart, aiEnd, Tmp, a3fRepImagesAfter] = fnCollectExemplars(acAfterStrct,strResultsRootFolder,iMaxSamplesForIdentityTraining,false,iHOG_Dim);

iPDFQuantifier = 100;
% Evaluation on test and training sets...
a2fConfusionMatrixTestingSet = zeros(iNumIdentities,iNumIdentities);

for iIdentityIter= 1 : iNumIdentities
    a2fProjPosTest = a2fFeatures(aiStart(iIdentityIter):aiEnd(iIdentityIter),:) * strctIdentityClassifier.m_a2fW; % Projection
    a2fProbTest = zeros(size(a2fProjPosTest));
    for iIter = 1:iNumIdentities
        a2fProbTest(:,iIter) = interp1(  strctIdentityClassifier.m_a2fX(:,iIter), strctIdentityClassifier.m_a2fHistPos(:,iIter), a2fProjPosTest(:,iIter),'linear','extrap');
    end;
    %
    %         % using intervals and not individual frames for classificaion
    %         if bUseIntervalsForTestSet
    %             iIntervalLength = 30;
    %             aiIntervals = 1:iIntervalLength:size(a2fProbTest,1);
    %             iNumIntervals = length(aiIntervals)-1;
    %             a2fSumProb = zeros(iNumIntervals, iNumIdentities);
    %             for k=1:length(aiIntervals)-1
    %                 aiInterval = aiIntervals(k):aiIntervals(k+1);
    %                 a2fSumProb(k,:) = sum(a2fProbTest(aiInterval,:),1);
    %             end;
    %             a2fProbTest = a2fSumProb;
    %         end;

    [afDummy,aiIndicesTest] = max(a2fProbTest,[],2);
    a2fConfusionMatrixTestingSet(iIdentityIter,:) = hist( aiIndicesTest, 1:iNumIdentities);
end;
% normalize each row
a2fConfusionMatrixTestingSet = a2fConfusionMatrixTestingSet ./ repmat(sum(a2fConfusionMatrixTestingSet,2), 1, iNumIdentities);
a2fConfusionMatrixTestingSet * 1e2

figure(12);
clf
for k=1:6
tightsubplot(6,2,2*(k-1)+2);
imshow(a3fRepImagesAfter(:,:,k),[]);
tightsubplot(6,2,2*(k-1)+1);
imshow(a3fRepImagesOrig(:,:,k),[]);

end
return;
% 
%         [n1,c1]= hist(a2fProjPosTrain(:,1),a2fX(:,1));
%         [n2,c2]= hist(a2fProjPosTest(:,1),a2fX(:,1));        
%         n1=n1/sum(n1);
%         n2=n2/sum(n2);
%         
%         v1 = interp1( a2fX(:,1), a2fHistPos(:,1), a2fProjPosTrain(:,1),'linear','extrap');
%         v2 = interp1( a2fX(:,1), a2fHistPos(:,1), a2fProjPosTest(:,1),'linear','extrap');
%          
%         [n3,c3]= hist(v1,500);
%         [n4,c4]= hist(v2,500);
%         n3=n3/sum(n3);
%         n4=n4/sum(n4);
%            
%         figure(1);
%         clf;
%         plot(c1,n1,'b',c2,n2,'r', a2fX(:,1), a2fHistPos(:,1),'c');
%         figure(2);
%         plot(afProb,n3,'b',afProb,n4,'r');

