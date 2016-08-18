function success=fnTrain(hFig)

global g_strctGlobalParam g_iLogLevel;  %#ok
global g_bMouseHouse;
global g_strMouseStuffRootDirName;

% If g_bMouseHouse hasn't been set, or has been set empty, make it false.
% This is not strictly necessary, since empty counts as false in an if 
% statement, but is more explicit.
if isempty(g_bMouseHouse)
    g_bMouseHouse=false;
end

% Let's be optimistic about success
success=true;

% get the userdata
u=get(hFig,'userdata');

% If there are no single-mouse clips, return
clipSMFNAbs=u.clipSMFNAbs;
if isempty(clipSMFNAbs)
    return;
end

% get vars we need from userdata
clusterMode=u.clusterMode;
expDirName = u.expDirName;
tuningDirName = fullfile(expDirName, 'Tuning');

% make sure the tuning dir exists
if ~exist(tuningDirName,'dir')
    mkdir(tuningDirName);
end

% Decide about which of the per-mouse classifiers we'll do.
nClip = length(clipSMFNAbs);  
  % drop the "SM" affix, b/c there are only single-mouse clips in training
decidedAboutGenerating=false(nClip,1);
willGenerate=false(nClip,1);  % just to pre-allocate
userSaidToNotGenerateExisting=false;
outputFN=cell(nClip,1);
for i=1:nClip
  clipSMFNAbsThis=clipSMFNAbs{i};
  [dummy,clipBaseName] = fileparts(clipSMFNAbsThis);  %#ok
  outputFN{i} = fullfile(tuningDirName, clipBaseName, 'Identities.mat');
  if exist(outputFN{i}, 'file')
    if userSaidToNotGenerateExisting
      decidedAboutGenerating(i)=true;  %#ok
      willGenerate(i)=false;
    elseif ~decidedAboutGenerating(i)
      answer = questdlg(['Identity file ' outputFN{i} ...
                         ' already exists. Regenerating it may take a ' ...
                         'few minutes. Do you want to proceed?'], ...
                        'Question', ...
                        'No, use existing file', ...
                        'Yes, overwrite existing file', ...
                        'Yes, overwrite existing file and all others', ...
                        'No, use existing file');
      switch answer
        case 'No, use existing file',
          decidedAboutGenerating(i)=true;
          willGenerate(i)=false;
        case 'Yes, overwrite existing file',
          decidedAboutGenerating(i)=true;
          willGenerate(i)=true;
        case 'Yes, overwrite existing file and all others',
          decidedAboutGenerating(:)=true;
          willGenerate(:)=true;
        case 'No, use existing file and and any others that exist',
          % this was going to be an option, but questdlg() complained about
          % too many buttons
          decidedAboutGenerating(i)=true;  %#ok
          willGenerate(i)=false;
          userSaidToNotGenerateExisting=true;  %#ok
          break;
      end
    end
  else
    % per-mouse classifier doesn't exist, so we have to generate it
    decidedAboutGenerating(i)=true;    
    willGenerate(i)=true;
  end
end

% At this point willGenerate(i) says which clips we'll generate a
% classifier for, and which not.

% Actually track the single-mouse clips, and calculate HOG vectors for all 
% of the registered patch images
bCreatedSubmitFile=false;
outputFN=cell(nClip,1);
acVideoInfos=cell(nClip,1);
for i=1:nClip
  clipSMFNAbsThis=clipSMFNAbs{i};
  [dummy,clipBaseName,clipExt] = fileparts(clipSMFNAbsThis);  %#ok
  outputFN{i} = fullfile(tuningDirName, clipBaseName, 'Identities.mat');
  acVideoInfos{i} = fnReadVideoInfo(clipSMFNAbsThis);
  if willGenerate(i)
    if exist(outputFN{i}, 'file')
      movefile(outputFN{i}, [outputFN{i} '.backup']);
    end
    if ~clusterMode
      % local mode
      strctBootstrap=[];
      %fnLearnMouseIdentity(clipSMFNAbsThis, strctBootstrap, outputFN{i});
      set(hFig,'pointer','watch');
      drawnow('expose');  drawnow('update');
      try
       fnLearnMouseIdentity(clipSMFNAbsThis, strctBootstrap, outputFN{i});
      catch excp
        %excp.identifier
        set(hFig,'pointer','arrow');
        drawnow('expose');  drawnow('update');
        if strcmp(excp.identifier,'fnLearnMouseIdentity:noReliableFrames') || ...
           strcmp(excp.identifier,'fnHOGFeaturesFromSMClip:noReliableFrames')
          h=errordlg(sprintf(['No reliable frames found in %s.  ' ...
                              'Maybe try training on it again?'], ...
                             [clipBaseName clipExt]), ...
                     'No reliable frames', ...
                     'modal');
          uiwait(h);
          success=false;
          return
        else
          rethrow(excp);
        end
      end
      set(hFig,'pointer','arrow');
      drawnow('expose');  drawnow('update');
    else
      % cluster mode
      jobDirName = fullfile(expDirName, 'Jobs');
      if ~exist(jobDirName,'dir')
        mkdir(jobDirName);
      end;
      strJobName = sprintf('%s/SingleJobargin%d.mat',jobDirName, i);
      aiFrames = 1:acVideoInfos{i}.m_iNumFrames;
      fnCreateJob(clipSMFNAbsThis, ...
                  acVideoInfos{i}, ...
                  aiFrames, ...
                  [], ...
                  [], ...
                  outputFN{i}, ...
                  i, ...
                  strJobName, ...
                  true);
      if ~bCreatedSubmitFile
        bCreatedSubmitFile = true;
        submitFN = [jobDirName,'/submitscript',num2str(i)];
        fprintf('Generating Submit file at %s\n', submitFN);
        hFileID = fopen(submitFN,'w');
        fprintf(hFileID,'#!/bin/bash\n');
        fprintf(hFileID,'echo Input file is:  $InputFile\n');
        %fprintf(hFileID,'%s/Deploy/MouseTrackProj/src/MouseTrackProj $InputFile\n', pwd());
        fprintf(hFileID, ...
                ['%s/Deploy/MouseTrackProj/src/MouseTrackProj ' ...
                 '$InputFile\n'], ...
                g_strMouseStuffRootDirName);
        fclose(hFileID);
        %fprintf('Changing permissions\n');
        system(['chmod 755 ',submitFN]);
      end
      strJobInputFile = sprintf('%s/SingleJobargin%d.mat',jobDirName,i);
      strCmd = ...
        sprintf('qsub -V -v InputFile=%s  -N MouseSingleJob -e %s -o %s -b y -cwd ''%s''', ...
                strJobInputFile, ...
                jobDirName, ...
                jobDirName, ...
                submitFN);
      fprintf('%s\n',strCmd);
      system(strCmd);
    end  % if ~clusterMode
  end  % if willGenerate(i)
end  % for i=1:nClip

% Determine whether the final classifier file should be generated, based
% on whether the file exists or not, whether any single-mouse files were
% just generated, and possibly questioning the user.
bAtLeastOneSingleMouseFileGenerated=any(willGenerate);
classifierOutputFN=fullfile(tuningDirName,'Identities.mat');
if exist(classifierOutputFN, 'file')
  if bAtLeastOneSingleMouseFileGenerated
    % implies the classifier file is out-of-date, and should be
    % regenerated
    bGenerateClassifier = true;
    % rename the file, to keep it around
    movefile(classifierOutputFN, ...
             [classifierOutputFN '.backup']);
  else 
    answer = ...
      questdlg(...
        sprintf(['Classifier file %s already exists. Regenerating '...
                 'it may take a few minutes. Do you want to ' ...
                 'proceed?'],...
                classifierOutputFN),...
        'Question', ...
        'No, use existing file', ...
        'Yes, overwrite existing file', ...
        'No, use existing file');
    switch answer
      case 'Yes, overwrite existing file'
        bGenerateClassifier = true;
        % rename the file, to keep it around
        movefile(classifierOutputFN, ...
                 [classifierOutputFN '.backup']);
      case 'No, use existing file'
        bGenerateClassifier = false;
    end
  end
else
  bGenerateClassifier = true;
end    

% If appropriate, generate the identity classifiers, and the (multi-mouse) 
% head-tail classifier, and store them in a file.
if bGenerateClassifier
  if ~clusterMode
    % local mode
    tuningDirName = fullfile(expDirName, 'Tuning');
    fnLog(['Training classifiers at ' tuningDirName]);
    set(hFig,'pointer','watch');
    drawnow('expose');  drawnow('update');  
    fnTrainTdistClassifiers(acVideoInfos, tuningDirName, tuningDirName);
    set(hFig,'pointer','arrow');
    drawnow('expose');  drawnow('update');  
  else
    % cluster mode: submit an extra job that does the actual learning.
    i=nClip+1;
    % append the classifier job to the list of jobs
    outputFN{i}=classifierOutputFN;
    %[iStatus, expDirName] = fnGetExpInfo();
    jobDirName = fullfile(expDirName, 'Jobs');
    if ~exist(jobDirName,'dir')
      mkdir(jobDirName);
    end;
    if ~bCreatedSubmitFile
      submitFN = [jobDirName,'/submitscript',num2str(i)];
      fprintf('Generating Submit file at %s\n', submitFN);
      hFileID = fopen(submitFN,'w');
      fprintf(hFileID,'#!/bin/bash\n');
      fprintf(hFileID,'echo Input file is:  $InputFile\n');
      %fprintf(hFileID,'%s/Deploy/MouseTrackProj/src/MouseTrackProj $InputFile\n', pwd());
      fprintf(hFileID, ...
              ['%s/Deploy/MouseTrackProj/src/MouseTrackProj ' ...
               '$InputFile\n'], ...
              g_strMouseStuffRootDirName);
      fclose(hFileID);
      %fprintf('Changing Permissions\n');
      system(['chmod 755 ',submitFN]);
    end
    strJobFile = fullfile(jobDirName,'IdentitiesJob.mat');
    strctJob.m_sFunction     = 'TrainIdentities';
    strctJob.m_acVideoInfos = acVideoInfos;
    strctJob.m_sTuningDir = tuningDirName;
    strctJob.m_iUID = i;  %#ok
    save(strJobFile, ...
         'strctJob','g_strctGlobalParam','g_iLogLevel','g_bMouseHouse')
    strCmd = ...
      sprintf(['qsub -hold_jid MouseSingleJob -V -v InputFile=%s  ' ...
      '-N MouseID_Job -e %s -o %s -b y -cwd ''%s'''],...
      strJobFile, jobDirName, jobDirName, submitFN);
    fprintf('%s\n',strCmd);
    system(strCmd);
  end
end

% Need something to hold off exiting until the classifiers have finished
% training, and all the output files are in place.
% This makes sure the "Train" button doesn't get set to
% red (i.e. completed) too soon.
if clusterMode
  set(hFig,'pointer','watch');
  drawnow('expose');  drawnow('update');  
  fnWaitForAllJobsToFinish(outputFN);  
  set(hFig,'pointer','arrow');
  drawnow('expose');  drawnow('update');  
end

end  % function 


