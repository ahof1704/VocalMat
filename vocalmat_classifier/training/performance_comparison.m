% -- compare performance for each model using each dataset
% -- expected directory structure:
% -- [raw_data]/[model_name]/[dataset_name]/[model_name|model_name_records|matlab_environment].mat
% -- [testset_path]: path to dataset used for the test classification

raw_data     = '/Users/gustavo/git/ahof_vocalmat/vocalmat_classifier/training/.rawdata';
testset_path = '/Users/gustavo/git/ahof_vocalmat/vocalmat_classifier/training/.testset';
imds         = imageDatastore([testset_path], 'IncludeSubfolders', true);
imds_resnet  = augmentedImageDatastore([224 224], imds);


% --
% -- section I : get all models
% --

% -- list model directory and convert results to strings
model_ls = dir(raw_data);
model_ls = struct2cell(model_ls);
model_ls = cellfun(@num2str, model_ls, 'UniformOutput', false);

% -- keep only directories (remove files)
dirs       = strcmp(model_ls(5,:), '1');
dirs       = model_ls(1:2, dirs);
% -- remove '.' and '..' dirs
dirs       = dirs(:,3:end);

% -- show number of models found
models_found = size(dirs,2)
models       = cell(models_found,1);

for current_model=1:models_found
    models{current_model,1}(1) = string(fullfile(dirs{2,current_model}, dirs{1,current_model}));
end

% -- show path for found models
models

% --
% -- section II : get datasets used with dataset
% --

for current_model=1:models_found
    % -- cycle through each model directory and get datasets (directory names)
    % disp(models{current_dataset, 1}(1))

    % -- list dataset directory and convert results to strings
    dataset_ls = dir(models{current_model,1}(1));
    dataset_ls = struct2cell(dataset_ls);
    dataset_ls = cellfun(@num2str, dataset_ls, 'UniformOutput', false);

    % -- keep only directories (remove files)
    dirs       = strcmp(dataset_ls(5,:), '1');
    dirs       = dataset_ls(:, dirs);
    % -- remove '.' and '..' dirs
    datasets     = dirs(1,3:end);

    % -- number of datasets found for current dataset
    datasets_found = size(datasets,2);
    for current_dataset=1:datasets_found
        % -- save dataset names for each model
        models{current_model,1}(1,current_dataset+1) = datasets{1, current_dataset};
    end
end

% -- show path for found models and models found for each model
models


% --
% -- section III : get statistics on each model for each dataset
% --

% for current_dataset=1:datasets_found
%     disp(current_dataset);
%     % -- open each trained model
%     % -- save from each model:
%     % -- dataset size, images per label, training options, training time, validation accuracy
%     % -- classify test dataset using each model and save:
%     % -- predictions, scores, classification time

%     % [predictedLabels                                 , scores                                          ] = classify(netTransfer, imds);
%     % [datasets{current_dataset, 1}(current_dataset, 2), datasets{current_dataset, 1}(current_dataset, 3)] = classify(netTransfer, imds);
% end