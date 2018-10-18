% ----------------------------------------------------------------------------------------------
% -- Title       : VocalMat Classifier Network Model Training Using AlexNet
% -- Project     : VocalMat - Automated Tool for Mice Vocalization Detection and Classification
% ----------------------------------------------------------------------------------------------
% -- File        : train_model_alexnet.m
% -- Author      : vocalmat <vocalmat@yale.edu>
% -- Group       : Dietrich Lab - Department of Comparative Medicine @ Yale University
% -- Standard    : <MATLAB 2018a>
% ----------------------------------------------------------------------------------------------
% -- Copyright (c) 2018 Dietrich Lab - Yale University
% ----------------------------------------------------------------------------------------------
% -- Description:
% -- 
% -- 
% -- 
% ----------------------------------------------------------------------------------------------

% -- load AlexNet model pre-trained using ImageNet dataset
network_model = load('model_alexnet.mat');
network_model = network_model.net;

% -- load dataset
imds                 = imageDatastore([dataset_path], 'IncludeSubfolders', true, 'LabelSource', 'foldernames');
% -- get dataset stats (number of images, labels)
dataset_stats        = countEachLabel(imds);
dataset_stats        = sortrows(dataset_stats, 'Count', 'ascend')
dataset_labels_count = numel(dataset_stats(:, 1))
dataset_images_count = numel(imds.Files(:, 1))
dataset_labels       = table2cell(dataset_stats);

% -- split dataset into training (90%) and validation (10%) sets
[trainingImages,validationImages] = splitEachLabel(imds, 0.9, 'randomized'); %it was 0.95
trainingImages                    = imds;

% -- save labels for each set
trainingImages_labels   = trainingImages.Labels;
validationImages_labels = validationImages.Labels;

% -- save reference to images used in each set
save images_for_training.mat   trainingImages
save images_for_validation.mat validationImages

% -- define training options
% -- using TensorFlow parameters for adam
miniBatchSize         = 32;
numIterationsPerEpoch = floor(numel(imds.Labels)/miniBatchSize);
options               = trainingOptions('adam', ...
                                        'GradientDecayFactor', 0.9, ...
                                        'SquaredGradientDecayFactor', 0.999, ...
                                        'Epsilon', 1e-8, ...
                                        'MiniBatchSize', miniBatchSize, ...
                                        'MaxEpochs', 100, ...
                                        'InitialLearnRate', 1e-4, ...
                                        'ExecutionEnvironment', 'gpu', ...
                                        'Shuffle', 'every-epoch', ...
                                        'ValidationData', validationImages, ...
                                        'ValidationPatience', Inf, ...
                                        'ValidationFrequency', numIterationsPerEpoch, ...
                                        'OutputFcn', @(info)stopIfAccuracyNotImproving(info, 3))
                                        % 'Plots','training-progress',...

% -- remove fully-connected layers from AlexNet
lgraph     = network_model.Layers(1:end-3);
numClasses = numel(categories(imds.Labels));

% -- create appropriate fully-connected layers for our dataset
lgraph     = [
                lgraph
                fullyConnectedLayer(numClasses, 'WeightLearnRateFactor', 20, 'BiasLearnRateFactor', 20)
                softmaxLayer
                classificationLayer];

% -- train our model
[netTransfer, tr] = trainNetwork(trainingImages, lgraph, options);

% -- save trained AlexNet model
save model_alexnet_trained.mat netTransfer
save model_alexnet_trained_records.mat tr

% -- save entire MATLAB environment for local debug
save matlab_environment.mat

function stop = stopIfAccuracyNotImproving(info,N)

    stop = false;

    % Keep track of the best validation accuracy and the number of validations for which
    % there has not been an improvement of the accuracy.
    persistent bestValAccuracy
    persistent valLag

    % Clear the variables when training starts.
    if info.State == "start"
        bestValAccuracy = 0;
        valLag = 0;
        
    elseif ~isempty(info.ValidationLoss)
        
        % Compare the current validation accuracy to the best accuracy so far,
        % and either set the best accuracy to the current accuracy, or increase
        % the number of validations for which there has not been an improvement.
        if info.ValidationAccuracy > bestValAccuracy
            valLag = 0;
            bestValAccuracy = info.ValidationAccuracy;
        else
            valLag = valLag + 1;
        end
        
        % If the validation lag is at least N, that is, the validation accuracy
        % has not improved for at least N validations, then return true and
        % stop training.
        if valLag >= N
            stop = true;
        end
        
    end

end