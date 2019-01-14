% ----------------------------------------------------------------------------------------------
% -- Title       : VocalMat
% -- Project     : VocalMat - Automated Tool for Mice Vocalization Detection and Classification
% ----------------------------------------------------------------------------------------------
% -- File        : VocalMat.m
% -- Author      : vocalmat <vocalmat@yale.edu>
% -- Group       : Dietrich Lab - Department of Comparative Medicine @ Yale University
% -- Standard    : <MATLAB 2018a>
% ----------------------------------------------------------------------------------------------
% -- Copyright (c) 2018 Dietrich Lab - Yale University
% ----------------------------------------------------------------------------------------------

disp('[vocalmat]: Starting VocalMat')

% -- add paths to matlab and setup for later use
root_path    = pwd;
identifier_path = fullfile(root_path, 'vocalmat_identifier');
classifier_path = fullfile(root_path, 'vocalmat_classifier');
addpath(genpath(root_path));

% -- check for updates
vocalmat_github_version = strsplit(webread('https://raw.githubusercontent.com/ahof1704/VocalMat/VocalMat_RC/README.md'));
vocalmat_github_version = vocalmat_version{end-1};
vocalmat_local_version  = strsplit(fscanf(fopen(fullfile('.','README.md'), '%c')));
vocalmat_local_version  = vocalmat_local_version{end-1};
if ~strcmp(vocalmat_local_version, vocalmat_github_version)
    disp(['[vocalmat]: There is a new version of VocalMat available'])
    disp(['[vocalmat]: Update by running git pull from the terminal or visit our github page: https://github.com/ahof1704/VocalMat/tree/VocalMat_RC'])
end

% -- check dependencies
try
    verLessThan('nnet','1');
catch
    error('Please download the Deep Learning Toolbox')
end

disp(['[vocalmat]: Starting VocalMat Identifier...'])
cd(fullfile(root_path, 'audios')); run('vocalmat_identifier.m')

disp(['[vocalmat]: Starting VocalMat Classifier...'])
cd(classifier_path); srun('vocalmat_classifier.m')