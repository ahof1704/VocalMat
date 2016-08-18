

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File Paths
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

strInVideoPath = ['/home/shayo/JaneliaFarm/Data/Movies/'];
strOutVideoPath = ['~/'];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Video File Names
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

strVideoFExt = ['avi'];
strInVideoFName = ['pera_mf_081030_D_XVID'];
strOutVideoFName = ['DeleteME'];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Settings for ProcessAVI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

strInFName = [strInVideoPath '/' strInVideoFName '.' strVideoFExt];
strOutFName = [strOutVideoPath '/' strOutVideoFName '.' strVideoFExt];
strProcFrmFcn = ['ProcessFrameTest'];          % Use this function to do the processing
bolMovOrFrame = 0;                                      % Get an AVI Movie out
bolMakeGray = 0;                                        % Leave RGB as is.
intStartFrm = 0;                                        % Start from this Frame
intNFrms = 30000;                                     % Number of Frames to Process 
intQuality = 10000;                                     % Highest Quality
%intFps = 29.97;                                         % 30 Frame per Second
intFps = 59.94;                                         % 60 Frame per Second


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check Existence of Input/Output Files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist(strInFName,'file'),
    disp(['ERROR: The Following Video-In file was not found']);
    disp(['NAME: ', strInVideoFName '.' strVideoFExt]);
    disp(['PATH: ', strInVideoPath '/']);
    return
end
if exist(strOutFName,'file') & bolMovOrFrame == 1,
    disp(['ERROR: The Following Video-Out file already exists']);
    disp(['         NAME: ', strOutVideoFName '.' strVideoFExt]);
    disp(['         PATH: ', strOutVideoPath '/']);
    return
end








%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Call ProcessAVI to start processing Frames
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


ProcessAVI(strInFName, strOutFName, strProcFrmFcn, bolMovOrFrame, ...
    bolMakeGray, intStartFrm, intNFrms, intQuality, intFps);

disp(['DONE!']);
