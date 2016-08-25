% Create an identities file from ground truth data
% Used to analyze the old cage11 sequence in which we do not have single
% mice videos

strVideo = 'D:\Data\Janelia Farm\Movies\SeqFiles\10.04.19.390_cropped_120-175.seq';
strResultsFolder = 'D:\Data\Janelia Farm\GroundTruth\10.04.19.390_cropped_120-175.mat';
strOutputFolder = 'E:\JaneliaResults\cage11\Tuning\';
global g_strctGlobalParam
%g_strctGlobalParam = fnLoadAlgorithmsConfigXML(['.' filesep 'Config' filesep 'Algorithms.xml']);
g_strctGlobalParam=fnLoadAlgorithmsConfigNative();
acMovie{1} = fnReadSeqInfo(strVideo);
 fnTrainTdistClassifiers(acMovie, strResultsFolder,strOutputFolder)