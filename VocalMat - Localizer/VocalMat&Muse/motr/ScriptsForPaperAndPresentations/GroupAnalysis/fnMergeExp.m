clear all

aiCages = 24;
for iCageIter=1:length(aiCages)
    strCage = sprintf('cage%d',aiCages(iCageIter));
    fprintf('Merging results for cage %s\n',strCage);
    strRoot = 'D:\Data\Janelia Farm\ResultsFromNewTrunk\';
    strInputFolder = [strRoot,strCage,'\'];
    
    astrctFiles = dir([strInputFolder,'*.mat']);
    iNumFiles = length(astrctFiles);
    
    
    clear astrctResults astrctMovInfo
    for iFileIter=1:iNumFiles
        strFile = [strInputFolder,astrctFiles(iFileIter).name];
        fprintf('Loading %s \n',strFile);
        strSeqInfoFile = [strInputFolder,'SEQ\',astrctFiles(iFileIter).name];
        astrctResults(iFileIter) = load(strFile);
        astrctMovInfo(iFileIter) = load(strSeqInfoFile);
    end
    
    afTimeStamps = zeros(1,iNumFiles);
    aiNumSamples = zeros(1,iNumFiles);
    a2iRange = zeros(iNumFiles,2);
    acMovieFileName =cell(1,iNumFiles);
    
    
    for iFileIter=1:iNumFiles
        acMovieFileName{iFileIter} = astrctFiles(iFileIter).name;
        afTimeStamps(iFileIter) = astrctMovInfo(iFileIter).afTimestamp(1);
    end;
    [afDummy, aiSortInd]=sort(afTimeStamps);
    
    astrctResults = astrctResults(aiSortInd);
    acMovieFileName = acMovieFileName(aiSortInd);
    astrctMovInfo = astrctMovInfo(aiSortInd);
    iCounter = 1;
    for iFileIter=1:iNumFiles
        aiNumSamples(iFileIter) = length(astrctMovInfo(iFileIter).afTimestamp);
        a2iRange(iFileIter,:) = [iCounter, iCounter+aiNumSamples(iFileIter)-1];
        iCounter=iCounter+aiNumSamples(iFileIter);
    end
    
    iNumMice = length(astrctResults(1).astrctTrackers);
    % Merge....
    iNumSamples = sum(aiNumSamples);
    
    % Represent things as arrays
    for iMouseIter=1:iNumMice
        astrctTrackers(iMouseIter).m_afX = zeros(1, iNumSamples,'single');
        astrctTrackers(iMouseIter).m_afY = zeros(1, iNumSamples,'single');
        astrctTrackers(iMouseIter).m_afA = zeros(1, iNumSamples,'single');
        astrctTrackers(iMouseIter).m_afB = zeros(1, iNumSamples,'single');
        astrctTrackers(iMouseIter).m_afTheta = zeros(1, iNumSamples,'single');
        
        for iFileIter=1:iNumFiles
            astrctTrackers(iMouseIter).m_afX(a2iRange(iFileIter,1):a2iRange(iFileIter,2)) = ...
                astrctResults(iFileIter).astrctTrackers(iMouseIter).m_afX;
            astrctTrackers(iMouseIter).m_afY(a2iRange(iFileIter,1):a2iRange(iFileIter,2)) = ...
                astrctResults(iFileIter).astrctTrackers(iMouseIter).m_afY;
            astrctTrackers(iMouseIter).m_afA(a2iRange(iFileIter,1):a2iRange(iFileIter,2)) = ...
                astrctResults(iFileIter).astrctTrackers(iMouseIter).m_afA;
            astrctTrackers(iMouseIter).m_afB(a2iRange(iFileIter,1):a2iRange(iFileIter,2)) = ...
                astrctResults(iFileIter).astrctTrackers(iMouseIter).m_afB;
            astrctTrackers(iMouseIter).m_afTheta(a2iRange(iFileIter,1):a2iRange(iFileIter,2)) = ...
                astrctResults(iFileIter).astrctTrackers(iMouseIter).m_afTheta;
        end
    end
    
    fprintf('Saving summary as arrays:\n');
    tic
    save([strRoot,strCage,'_array'],'astrctTrackers','a2iRange','acMovieFileName');
    toc
    
    % Represent things as matrices.
    X = zeros(iNumSamples, iNumMice,'single');
    Y = zeros(iNumSamples, iNumMice,'single');
    A = zeros(iNumSamples, iNumMice,'single');
    B = zeros(iNumSamples, iNumMice,'single');
    Theta = zeros(iNumSamples, iNumMice,'single');
    
    for iMouseIter=1:iNumMice
        for iFileIter=1:iNumFiles
            X(a2iRange(iFileIter,1):a2iRange(iFileIter,2),iMouseIter) = ...
                astrctResults(iFileIter).astrctTrackers(iMouseIter).m_afX;
            Y(a2iRange(iFileIter,1):a2iRange(iFileIter,2),iMouseIter) = ...
                astrctResults(iFileIter).astrctTrackers(iMouseIter).m_afY;
            
            A(a2iRange(iFileIter,1):a2iRange(iFileIter,2),iMouseIter) = ...
                astrctResults(iFileIter).astrctTrackers(iMouseIter).m_afA;
            
            B(a2iRange(iFileIter,1):a2iRange(iFileIter,2),iMouseIter) = ...
                astrctResults(iFileIter).astrctTrackers(iMouseIter).m_afB;
            
            Theta(a2iRange(iFileIter,1):a2iRange(iFileIter,2),iMouseIter) = ...
                astrctResults(iFileIter).astrctTrackers(iMouseIter).m_afTheta;
            
        end
    end
    
    fprintf('Saving summary as matrices:\n');
    
    tic
    save([strRoot,strCage,'_matrix'],'X','Y','A','B','Theta','a2iRange','acMovieFileName');
    toc
    fprintf('Done.\n');
end