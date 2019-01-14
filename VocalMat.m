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

% todo for paper
% check dependencies
% check paths
% check github for update

disp('[vocalmat]: Starting VocalMat')

current_path = pwd;

path_identifier = fullfile(current_path, 'vocalmat_identifier');
path_classifier = fullfile(current_path, 'vocalmat_classifier');

addpath(genpath(current_path));

disp(['[vocalmat]: Starting VocalMat Identifier...'])
run('vocalmat_identifier.m')

disp(['[vocalmat]: Starting VocalMat Classifier...'])
srun('vocalmat_classifier.m')