function [strctAdditionalInfo, strAdditionalInfoFileName] = ...
  fnCreateSetupFile(strctClass, ...
                    strctBackground, ...
                    strJobFolder, ...
                    strAdditionalInfoFileNameRequested)
%
%Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)
global g_strctGlobalParam

if ~exist('strAdditionalInfoFileNameRequested','var') || isempty(strAdditionalInfoFileNameRequested)
  strAdditionalInfoFileName = fullfile(strJobFolder,'Setup.mat');
else
  strAdditionalInfoFileName=strAdditionalInfoFileNameRequested;
end
        
strctAdditionalInfo.strctBackground = strctBackground;
strctAdditionalInfo.strctAppearance.m_iNumBins = 10;
strctAdditionalInfo.strctAppearance.m_a2fFeatures = strctClass.a2fAppearanceFeatures;
strctAdditionalInfo.m_a3fRepresentativeClassImages = strctClass.strctIdentityClassifier.m_a3fRepImages;
if strcmpi(g_strctGlobalParam.m_strctClassifiers.m_strType,'LDA_Logistic')  || strcmpi(g_strctGlobalParam.m_strctClassifiers.m_strType,'RobustLDA') || ...
        strcmpi(g_strctGlobalParam.m_strctClassifiers.m_strType,'Tdist')
    strctAdditionalInfo.m_strctHeadTailClassifier = strctClass.strctHeadTailClassifier;
    strctAdditionalInfo.m_strctHeadTailClassifier.iNumBins = 10;
    strctAdditionalInfo.m_strctHeadTailClassifierNeg = strctClass.strctHeadTailClassifierNeg;
    strctAdditionalInfo.m_strctMiceIdentityClassifier = strctClass.strctIdentityClassifier;
    strctAdditionalInfo.m_strctMiceIdentityClassifier.iNumBins = 10;

else
    strctAdditionalInfo.m_strctHeadTailClassifier.iNumBins = 10;
    strctAdditionalInfo.m_strctHeadTailClassifier.iNumFeatures = size(strctClass.strctHeadTailClassifier.m_a2fW,1);
    strctAdditionalInfo.m_strctHeadTailClassifier.W = strctClass.strctHeadTailClassifier.m_a2fW;
    strctAdditionalInfo.m_strctHeadTailClassifier.fThres = strctClass.strctHeadTailClassifier.m_afThres;
    strctAdditionalInfo.m_strctHeadTailClassifier.afX = strctClass.strctHeadTailClassifier.m_a2fX;
    strctAdditionalInfo.m_strctHeadTailClassifier.afHistPos = strctClass.strctHeadTailClassifier.m_a2fHistPos;
    strctAdditionalInfo.m_strctHeadTailClassifier.afHistNeg = strctClass.strctHeadTailClassifier.m_a2fHistNeg;
    strctAdditionalInfo.m_strctHeadTailClassifier.afProbPos = strctClass.strctHeadTailClassifier.m_a2fProb;
    strctAdditionalInfo.m_strctMiceIdentityClassifier.iNumMice = size(strctClass.strctIdentityClassifier.m_a2fW,2);
    strctAdditionalInfo.m_strctMiceIdentityClassifier.iNumBins = 10;
    strctAdditionalInfo.m_strctMiceIdentityClassifier.iNumFeatures = size(strctClass.strctIdentityClassifier.m_a2fW,1);
    strctAdditionalInfo.m_strctMiceIdentityClassifier.a2fW = strctClass.strctIdentityClassifier.m_a2fW;
    strctAdditionalInfo.m_strctMiceIdentityClassifier.a2fX = strctClass.strctIdentityClassifier.m_a2fX;
    strctAdditionalInfo.m_strctMiceIdentityClassifier.a2fProb = strctClass.strctIdentityClassifier.m_a2fProb;
    strctAdditionalInfo.m_strctMiceIdentityClassifier.afThres = strctClass.strctIdentityClassifier.m_afThres;
end

% strAdditionalInfoFileName = fullfile(strJobFolder,strAdditionalInfoFileNameRequested);
save(strAdditionalInfoFileName,'strctAdditionalInfo');
return;
