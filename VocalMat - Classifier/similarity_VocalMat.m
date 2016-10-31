function [tosave] = similarity_VocalMat(folder,id,table)
format compact
format short g
startdir = cd;
%initialize
% fs=250000;

% if exist('type','var')==0;
%     type=input('Please enter AV or Bgal (in single quotes):')
% end

%p tables; located in matlab_functions/similarity
%load ptables
%load MADs

% if strcmp('AV',type)==1 || exist('AV','var')==1;
%     type=1;
%     load AVptables
% elseif strcmp('Bgal',type)==1 || exist('Bgal','var')==1
%     type=2;
%     load Bgalptables
% end
% type=1; %Bgal and AV status does not matter

% winsize=10; %size of windows for SIMILARITY (~10 ms)
mindur=4; %# deviations from diagonal (feature windows are not directly proportional to ms)

%ticID=tic;

savedir=folder;
%if exist(savedir,'dir')==0
%     cd ~/Documents
%     mkdir('SimilarityResults_Mouse');
% end

name=id;
datadir=folder;

% dfiles = dir;
% files = [];

% for i = 1:length(dfiles)
%     if ~isempty(findstr(dfiles(i).name, '.wav')) && dfiles(i).isdir==0
%         files = [files i];
%     end;
% end;
% s1_files = dfiles(files);
% 
%     num=length(s1_files);
%     if num>=10 && num<=99
%         total_digits=2;
%     elseif num>=100 && num<=999
%         total_digits=3;
%     else total_digits=4;
%     end
% 
% if exist('originals','dir')
%     mkdir('originals')
% end
% 
% for i=1:length(s1_files);
%     fn=s1_files(i).name;
%     wv=audioread(fn);
%     movefile(s1_files(i).name,'originals')
%     wvname=sprintf('%0*d',total_digits,i);
%     audiowrite(strcat([wvname,'.wav']),wv,250000);
%     %filenum=filenum+1;  
% end

% sounds1d=uigetdir('','Select the directory with files for Sound 1');
% sound1ID=input('Name this set of sounds (e.g. MouseX_Pre): ','s');
% 
% sounds2d=uigetdir('','Select the directory with files for Sound 2');
% sound2ID=input('Name this set of sounds (e.g. MouseX_Post): ','s');



%% find all .wav files in Sound 1/Sound 2 directories
% save in structure to save time

% [Sound1,Sound2]=createSimStructure_mouse(winsize,datadir,type);
%[Sound1,Sound2]=createSimStructure_mouse(winsize,sounds1d,sounds2d,type);
%save('SoundInfo')
%load SoundInfo
%% preallocate various matrices
%sim_all=cell(1,3,1);
%a{1,1,1}=[zeros(8)]%hint to Nancy for pre-allocation

% fns=cell(1,2,1);

% msize=length(Sound1)*length(Sound2);
msize = size(table,2)^2;
%msizeBIG=1e10;

fns1(msize,1)=0;
fns2(msize,1)=0;

% localDistance(msize,1)=0;
% meanLocalDist(msize,1)=0;
% globalDistance(msize,1)=0;
% meanDistG(msize,1)=0;

% alldist(msizeBIG,1)=0;
% allGDdist(msizeBIG,1)=0;


% diffs=cell(1,5,1);
% Entropy_diff(msize,1)=0;
% AM_diff(msize,1)=0;
% FM_diff(msize,1)=0;
% Pitch_diff(msize,1)=0;
%
%
SimilarityBatch=cell(1,6,1);
% similarity(msize,1)=0;
% accuracy(msize,1)=0;
SeqMatch(msize,1)=0;
% globalSim(msize,1)=0;

% dC_acc(msize,6)=0;
dC_sim(msize,2)=0;

calcnum=0;
% szLDist=1;
% szGDist=1;

%% Start processing similarity
%for loop to process Sound 2, file j against all Sound 1 files(i)

% ext='.wav';
%b=length(Sound2);
%o=randperm(b, 50);
for j=1:length(table)
%     fn2=Sound2(j).fn;
%     cut=strfind(fn2(1,:),ext);
%     filenum2=str2num(fn2(1:cut-1));
    
    %Progress=sprintf('*************Working on all Sound 1 files vs. %s *************',fn2)
    
    %% read in Sound 1 files and scale by MAD
    for i=1:length(table)
        ticID=tic;
        calcnum=calcnum+1;
%         fn1=Sound1(1).fn;
%         cut=strfind(fn1(1,:),ext);
%         filenum1=str2num(fn1(1:cut-1));
        
        %         %% calculate corr, diffs for Pitch & Entropy
        %         [dC_l]=diffCoef(Sound1(i).scaled,Sound2(j).scaled,mindur);
        %         dC_acc(calcnum,:)=dC_l;
        %         %% calculate local distance using matlab's pdist2
        %
        %           localDist=pdist2(Sound1(i).scaled,Sound2(j).scaled);
        %
        %         Entropy_dist=pdist2(Sound1(i).scaled(:,1),Sound2(j).scaled(:,1));
        %         AM_dist=pdist2(Sound1(i).scaled(:,2),Sound2(j).scaled(:,2));
        %         FM_dist=pdist2(Sound1(i).scaled(:,3),Sound2(j).scaled(:,3));
        %         Pitch_dist=pdist2(Sound1(i).scaled(:,4),Sound2(j).scaled(:,4));
        %
        %         [localDistScore,feature_diffs]=calculateDistance_mouse(localDist,mindur,1,Entropy_dist,AM_dist,FM_dist,Pitch_dist);
        %
        %         %accuracy distance
        %         localDistance(calcnum)=localDistScore;
        %
        %         %         % save lots of window by window distance measurements to calculate p value
        %         %         szLD=numel(localDist);
        %         %         allLDist=reshape(localDist,szLD,1);
        %         %         alldist(szLDist:szLDist+szLD-1)=allLDist;
        %         %         szLDist=szLDist+szLD;
        %
        %         % Keep track of  feature distances
        %         Entropy_diff(calcnum)=feature_diffs{1};
        %         AM_diff(calcnum)=feature_diffs{2};
        %         FM_diff(calcnum)=feature_diffs{3};
        %         Pitch_diff(calcnum)=feature_diffs{4};
        
        %% calculate corr, diffs for Pitch & Entropy (GLOBAL)
        [dC_g]=diffCoef(table{i},table{j},mindur);
        dC_sim(calcnum,:)=dC_g;
        %         %% calculate global distance
        %
        %         globalDist=pdist2(Sound1(i).Dl,Sound2(j).Dl);
        %         %globalDistScore=mean(diag(globalDist))
        %
        %         [globalDistScore]=calculateDistance_mouse(globalDist,mindur,0,Entropy_dist,AM_dist,FM_dist,Pitch_dist);
        %
        %         %similarity distance
        %         globalDistance(calcnum)=globalDistScore;
        %
        %         %         %save lots of window by window distance measurements to calculate p value
        %         %         szGD=numel(globalDist);
        %         %         allGDist=reshape(globalDist,szGD,1);
        %         %         allGDdist(szGDist:szGDist+szGD-1)=allGDist;
        %         %         szGDist=szGDist+szGD;
        %
        %         %% Assign p-value to distance scores & calculate global similarity
        %
        %         overallDistanceACC=p_accuracy(:,1);
        %         %distance score corresponding to p-value table
        %         %[C I] = min(abs(a - k)); %ignore C %k=Euclidean distance score
        %         [C I] = min(abs(overallDistanceACC-localDistScore));
        %         acc=1-p_accuracy(I,2);
        %
        %         overallDistanceSIM=p_similarity(:,1);
        %         [C I] = min(abs(overallDistanceSIM-globalDistScore));
        %         sim=1-p_similarity(I,2);
        %
        %         % Determine sequential match score % ratio of Sound 1 to Sound 2
        %
        maxwv=max(table{i}(end,1)-table{i}(1,1),table{j}(end,1)-table{j}(1,1));
        minwv=min(table{i}(end,1)-table{i}(1,1),table{j}(end,1)-table{j}(1,1));
        SequentialMatch=minwv/maxwv;
        %
        %         %Determine global similarity
        %         gloSim=acc*sim*SequentialMatch;
        
        %% stuff to save
        fns1(calcnum)=i;
        fns2(calcnum)=j;
        
        %the good stuff
        %         similarity(calcnum)=sim;
        %         accuracy(calcnum)=acc;
        SeqMatch(calcnum)=SequentialMatch;
        %
        %         globalSim(calcnum)=gloSim;
        
        %toc(ticID)
        
    end
end
%% Save!
%sprintf('Saving!')
%save('inprogress.mat','-v7.3')
%alldist=alldist(1:szLDist,:);   % remove excess
%allGDdist=allGDdist(1:szGDist,:);   % remove excess
% globalDistance=globalDistance(1:calcnum,:);
% localDistance=localDistance(1:calcnum,:);
%save('Distances','alldist','allGDdist','-v7.3')%'globalDistance','localDistance',)%,'diffs')


cd(folder);
savenameSB=strcat('SimilarityBatch_',name,'.csv');
%savenameInfo=strcat('Info_',name);
% savenameSB=strcat('SimilarityBatch_',sound1ID,'_', sound2ID);
% savenameInfo=strcat('Info_',sound1ID,'_', sound2ID);

fns1=fns1(1:calcnum);
fns2=fns2(1:calcnum);

% similarity=similarity(1:calcnum,:);
% accuracy=accuracy(1:calcnum,:);
SeqMatch=SeqMatch(1:calcnum,:);
%globalSim=globalSim(1:calcnum,:).*100;

% dC_acc=dC_acc(1:calcnum,:);
dC_sim=dC_sim(1:calcnum,:);

% diffs={Entropy_diff AM_diff FM_diff Pitch_diff};

%SimilarityBatch={fns1 fns2 similarity accuracy SeqMatch globalSim dC_l dC_g};
%SimilarityBatch={fns1 fns2 SeqMatch dC_g};


%save(savenameSB,'SimilarityBatch','fns1','fns2','similarity','accuracy' ,'SeqMatch', 'globalSim','dC_acc','dC_sim');
%save(strcat(id,'_simbatch'),'SimilarityBatch','fns1','fns2','SeqMatch','dC_sim');

%tosave=[fns1 fns2 similarity accuracy SeqMatch globalSim dC_acc dC_sim];% Entropy_diff AM_diff FM_diff Pitch_diff PGood_diff];
tosave=[fns1 fns2 SeqMatch dC_sim];

%save(savenameInfo,'fns1', 'fns2','calcnum','mindur','winsize','dC_g');
%save(savenameInfo,'globalDistance','localDistance','fns1', 'fns2','diffs','calcnum','mindur','winsize','dC_l','dC_g')%'tosave')%'alldist','allGDdist','szLDist','szGDist',
%toc(ticID)

% dlmwrite(savenameSB,tosave);
%delete inprogress.mat
cd(startdir);
end
