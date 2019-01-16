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

disp('[vocalmat]: starting VocalMat.')

% -- add paths to matlab and setup for later use
root_path       = pwd;
identifier_path = fullfile(root_path, 'vocalmat_identifier');
classifier_path = fullfile(root_path, 'vocalmat_classifier');
addpath(genpath(root_path));

% -- check for updates
vocalmat_github_version = strsplit(webread('https://raw.githubusercontent.com/ahof1704/VocalMat/VocalMat_RC/README.md'));
vocalmat_github_version = vocalmat_github_version{end-1};
vocalmat_local_version  = strsplit(fscanf(fopen(fullfile('.','README.md'), 'r'), '%c'));
vocalmat_local_version  = vocalmat_local_version{end-1};
if ~strcmp(vocalmat_local_version, vocalmat_github_version)    
    
    opts.Interpreter = 'tex';
    opts.Default     = 'Continue';
    btnAnswer        = questdlg('There is a new version of VocalMat available. For more information, visit github.com/ahof1704/VocalMat', ...
                                'New Version of VocalMat Available', ...
                                'Continue', 'Exit', opts);
    switch btnAnswer
        case 'Exit'
            error('[vocalmat]: there is a new version of VocalMat available. For more information, visit our <a href="https://github.com/ahof1704/VocalMat/tree/VocalMat_RC">GitHub page</a>. ') 
        case 'Continue'
            warning('[vocalmat]: there is a new version of VocalMat available. For more information, visit our <a href="https://github.com/ahof1704/VocalMat/tree/VocalMat_RC">GitHub page</a>. ') 
    end
end

% -- check dependencies
disp('[vocalmat]: verifying MATLAB toolboxes needed to run');

try
    verLessThan('signal','1 ');
catch
    error('[vocalmat]: please download the Signal Processing Toolbox')
end

try
    verLessThan('images','1');
catch
    error('[vocalmat]: please download the Image Processing Toolbox')
end

try
    verLessThan('stats','1');
catch
    error('[vocalmat]: please download the Statistics and Machine Learning Toolbox')
end

try
    verLessThan('nnet','1');
catch
    error('[vocalmat]: please download the Deep Learning Toolbox')
end

% -- handle execution over to the identifier
disp(['[vocalmat]: starting VocalMat Identifier...'])
cd(fullfile(root_path, 'audios')); run('vocalmat_identifier.m')

% -- handle execution over to the classifier
disp(['[vocalmat]: starting VocalMat Classifier...'])
cd(classifier_path); run('vocalmat_classifier.m')