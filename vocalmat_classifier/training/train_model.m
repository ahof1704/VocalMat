%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Importing excel file with GT
clear all
close all

T_out   = [];
txt_out = [];
raiz    = pwd;

% list = dir;
% isdir = [list.isdir].';
% list_dir = list(isdir,:); list_dir(1:2)=[];

% Training DL

model_class_DL  = load('Mdl_categorical_DL.mat');
model_class_DL  = model_class_DL.netTransfer;

images_training = imageDatastore([raiz '/.dataset/'],'IncludeSubfolders',true,'LabelSource','foldernames');
tbl             = countEachLabel(images_training)
Total           = sum(tbl.Count)
minSetCount     = min(tbl{:,2}); % determine the smallest amount of images in a category
% Use splitEachLabel method to trim the set.
% images = splitEachLabel(images, minSetCount, 'randomize');
% images = splitEachLabel(images, 0.9, 'randomize');
% Notice that each set now has exactly the same number of images.
% countEachLabel(images_training)
[trainingImages,validationImages] = splitEachLabel(images_training,0.9,'randomized'); %it was 0.95
% trainingImages                    = images_training;
trainingImages_labels   = trainingImages.Labels;
validationImages_labels = validationImages.Labels;

save images_for_training trainingImages
save images_for_validation validationImages

miniBatchSize         = 128;
numIterationsPerEpoch = floor(numel(trainingImages.Labels)/miniBatchSize);
options               = trainingOptions('sgdm',...
                                        'MiniBatchSize',miniBatchSize,...
                                        'MaxEpochs',100,...
                                        'InitialLearnRate',1e-4,...
                                        'ExecutionEnvironment','cpu',...
                                        'Shuffle','every-epoch',...
                                        'ValidationData',validationImages,...
                                        'ValidationPatience',Inf,...
                                        'ValidationFrequency',numIterationsPerEpoch,...
                                        'OutputFcn',@(info)stopIfAccuracyNotImproving(info,3)); % which stops network training if the best classification accuracy on the validation data does not improve for N network validations in a row.
net             = model_class_DL;
layersTransfer  = net.Layers(1:end-3);
numClasses      = numel(categories(trainingImages.Labels));
layers          = [
                    layersTransfer
                    fullyConnectedLayer(numClasses,'WeightLearnRateFactor',20,'BiasLearnRateFactor',20)
                    softmaxLayer
                    classificationLayer];

netTransfer     = trainNetwork(trainingImages,layers,options);
predictedLabels = classify(netTransfer,validationImages);

% cd('F:\RF+DL\All_samples_noise')
save Mdl_categorical_DL netTransfer

accuracy = mean(predictedLabels == validationImages.Labels)
ttt      = netTransfer.Layers(end).ClassNames;
% ttt2 = cellstr(num2str(2*ones(12,1)));
% s = strcat(ttt,ttt2);


aux               = predictedLabels                  == validationImages.Labels;
chevron_stats     = sum(validationImages.Labels(aux) == 'chevron')/sum(validationImages.Labels     == 'chevron')
complex_stats     = sum(validationImages.Labels(aux) == 'complex')/sum(validationImages.Labels     == 'complex')
down_fm_stats     = sum(validationImages.Labels(aux) == 'down_fm')/sum(validationImages.Labels     == 'down_fm')
flat_stats        = sum(validationImages.Labels(aux) == 'flat')/sum(validationImages.Labels        == 'flat')
mult_steps_stats  = sum(validationImages.Labels(aux) == 'mult_steps')/sum(validationImages.Labels  == 'mult_steps')
noise_dist_stats  = sum(validationImages.Labels(aux) == 'noise_dist')/sum(validationImages.Labels  == 'noise_dist')
rev_chevron_stats = sum(validationImages.Labels(aux) == 'rev_chevron')/sum(validationImages.Labels == 'rev_chevron')
short_stats       = sum(validationImages.Labels(aux) == 'short')/sum(validationImages.Labels       == 'short')
step_down_stats   = sum(validationImages.Labels(aux) == 'step_down')/sum(validationImages.Labels   == 'step_down')
step_up_stats     = sum(validationImages.Labels(aux) == 'step_up')/sum(validationImages.Labels     == 'step_up')
two_steps_stats   = sum(validationImages.Labels(aux) == 'two_steps')/sum(validationImages.Labels   == 'two_steps')
up_fm_stats       = sum(validationImages.Labels(aux) == 'up_fm')/sum(validationImages.Labels       == 'up_fm')

% T_out2 = [table_total2(:,[1 2]), table_total2(:,239), array2table(ynewci_RF,'VariableNames',Mdl.ClassNames), array2table(scores,'VariableNames',s'),  array2table(ynew_RF,'VariableNames',{'RF'}),  array2table(predictedLabels,'VariableNames',{'DL'}), table_total2(:,[238])];             
%%
%testing the trained net
disp('Testing the trained network on all the samples used for training...')
images                    = imageDatastore([pwd '/.dataset/'],'IncludeSubfolders',true);
% images.ReadFcn = @(loc)imresize(imread(loc),[224 224]);
[predictedLabels, scores] = classify(netTransfer,images);

T = [cell2table(images_training.Files,'VariableNames',{'Training_file'}) cell2table(cellstr(images_training.Labels),'VariableNames',{'Training_label'})...
    cell2table(images.Files,'VariableNames',{'Testing_file'}) cell2table(cellstr(predictedLabels),'VariableNames',{'Testing_label'}) ...
    array2table(scores,'VariableNames',ttt)];

save table_performance T

aux     = predictedLabels ~= images_training.Labels;
T_wrong = T(aux,:);

save table_wrong T_wrong


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