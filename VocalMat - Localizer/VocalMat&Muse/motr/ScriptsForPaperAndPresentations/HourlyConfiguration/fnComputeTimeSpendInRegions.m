function a4fTimePerc= fnComputeTimeSpendInRegions(acCage)

afSampleTimeHours = 0:0.1/6:120;
iNumDwellingPlaces = 7;
fFPS=30;
iNumMice=4;
iNumFramesPerMinute = fFPS * 60;
iNumCages = length(acCage);
a4fTimePerc = zeros(1+iNumDwellingPlaces,length(afSampleTimeHours),iNumMice,iNumCages);
 strFolder = 'D:\Data\Janelia Farm\ResultsFromNewTrunk\';
 
for iCageIter=1:iNumCages
    strDatfile = [strFolder,acCage{iCageIter}];
    strctData = load(strDatfile);
    strRegionFile = ['D:\Data\Janelia Farm\Final_Data_For_Paper\Regions\',acCage{iCageIter}(1:6),'_Regions.mat'];
    strTimeSpentInRegionFile = ['D:\Data\Janelia Farm\Final_Data_For_Paper\Regions\',acCage{iCageIter}(1:6),'_TimeInRegions.mat'];
    strctTmp = load(strRegionFile);
    a2iRegions = zeros(size(strctTmp.acRegions{1}));
    for iRegionIter=1:length(strctTmp.acRegionNames)
        if iRegionIter<= 6
            a2iRegions(strctTmp.acRegions{iRegionIter} > 0 & a2iRegions == 0) = iRegionIter;
        else
            a2iRegions(strctTmp.acRegions{iRegionIter} > 0 & a2iRegions == 0) = 7;
        end
    end;
    acRegionNames = {'All Other Regions',strctTmp.acRegionNames{1:6},'Tube entrance'};
    iTimeSmoothingKernelFrames = iNumFramesPerMinute*4;
    iNumFrames = size(strctData.X,1);
    afTimeHours = [0:iNumFrames-1]/fFPS/60/60;
 
    a3fTimePerc = zeros(iNumDwellingPlaces,length(afSampleTimeHours),iNumMice);
    for iMouseIter = 1:4
        
        X=strctData.X(:,iMouseIter);
        Y=strctData.Y(:,iMouseIter);
        abNaN=isnan(X)|isnan(Y);
        % Interp missing values...
        X(abNaN) = interp1(find(~abNaN),X(~abNaN), find(abNaN));
        Y(abNaN) = interp1(find(~abNaN),Y(~abNaN), find(abNaN));
        
        aiPlaces = interp2(a2iRegions, X,Y,'nearest');
        for k=0:iNumDwellingPlaces
            fprintf('Computing stats for mouse %d at location %d\n',iMouseIter,k);
            abInPlace = aiPlaces == k;
            afTimerPercentage = conv2(double(abInPlace)', ones(1,iTimeSmoothingKernelFrames )/iTimeSmoothingKernelFrames ,'same');
            afTimePerc = interp1(afTimeHours,afTimerPercentage,  afSampleTimeHours);
%             plot(afSampleTimeHours, double((k))+afTimePerc,'color',a2fColors(1+k,:)/255);
            a3fTimePerc(1+k, :,iMouseIter) = afTimePerc;
        end
    end
    save(strTimeSpentInRegionFile,'a3fTimePerc','a2iRegions','acRegionNames');
    
    a4fTimePerc(:,:,:,iCageIter) = a3fTimePerc;
    
%     a2fTotalTime = squeeze(sum(a3fTimePerc,2));
%     fTotalTime = sum(a2fTotalTime(:,1));
%     a2fTotalTimeNormalized = a2fTotalTime / fTotalTime;
end

return
