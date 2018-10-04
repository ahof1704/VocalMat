%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Importing excel file with GT
clear all
close all

T_out = [];
txt_out = [];
raiz = pwd;
training = 0;

% list = dir;
% isdir = [list.isdir].';
% list_dir = list(isdir,:); list_dir(1:2)=[];

% Training DL

% model_class_DL = load('C:\Users\ahf38\Documents\GitHub\VocalMat\VocalMat - Classifier\Mdl_categorical_DL_noise.mat');
% model_class_DL = model_class_DL.netTransfer;
load('Mdl_categorical_DL_strains')

if training
    images_training = imageDatastore('G:\Reference_strains','IncludeSubfolders',true,'LabelSource','foldernames');
    tbl = countEachLabel(images_training)
    Total = sum(tbl.Count)
    minSetCount = min(tbl{:,2}); % determine the smallest amount of images in a category
    % Use splitEachLabel method to trim the set.
    % images = splitEachLabel(images, minSetCount, 'randomize');
    % images = splitEachLabel(images, 0.9, 'randomize');
    % Notice that each set now has exactly the same number of images.
    % countEachLabel(images_training)
    [trainingImages,validationImages] = splitEachLabel(images_training,0.9,'randomized'); %it was 0.95
    trainingImages = images_training;
    save images_for_validation validationImages
    
    miniBatchSize = 128;
    numIterationsPerEpoch = floor(numel(trainingImages.Labels)/miniBatchSize);
    options = trainingOptions('sgdm',...
        'MiniBatchSize',miniBatchSize,...
        'MaxEpochs',100,...
        'InitialLearnRate',1e-4,...
        'ExecutionEnvironment','gpu',...
        'Shuffle','every-epoch',...
        'ValidationData',validationImages,...
        'ValidationPatience',Inf,...
        'ValidationFrequency',numIterationsPerEpoch,...
        'OutputFcn',@(info)stopIfAccuracyNotImproving(info,3)); % which stops network training if the best classification accuracy on the validation data does not improve for N network validations in a row.
    net = model_class_DL;
    layersTransfer = net.Layers(1:end-3);
    numClasses = numel(categories(trainingImages.Labels));
    layers = [
        layersTransfer
        fullyConnectedLayer(numClasses,'WeightLearnRateFactor',20,'BiasLearnRateFactor',20)
        softmaxLayer
        classificationLayer];
    
    netTransfer = trainNetwork(trainingImages,layers,options);
    predictedLabels = classify(netTransfer,validationImages);
    
    % cd('F:\RF+DL\All_samples_noise')
    save Mdl_categorical_DL_strains netTransfer
    
    accuracy = mean(predictedLabels == validationImages.Labels)
    ttt = netTransfer.Layers(25).ClassNames;
    % ttt2 = cellstr(num2str(2*ones(12,1)));
    % s = strcat(ttt,ttt2);
    
    aux = predictedLabels == validationImages.Labels;
    AJ_stats = sum(validationImages.Labels(aux)=='AJ')/sum(validationImages.Labels=='AJ')
    B6_stats = sum(validationImages.Labels(aux)=='B6')/sum(validationImages.Labels=='B6')
    NZO_stats = sum(validationImages.Labels(aux)=='NZO')/sum(validationImages.Labels=='NZO')
    PWK_stats = sum(validationImages.Labels(aux)=='PWK')/sum(validationImages.Labels=='PWK')
else
     ttt = netTransfer.Layers(25).ClassNames;
end

% T_out2 = [table_total2(:,[1 2]), table_total2(:,239), array2table(ynewci_RF,'VariableNames',Mdl.ClassNames), array2table(scores,'VariableNames',s'),  array2table(ynew_RF,'VariableNames',{'RF'}),  array2table(predictedLabels,'VariableNames',{'DL'}), table_total2(:,[238])];

%testing the trained net
disp('Testing the trained network on all the samples used for training...')
images = imageDatastore('Z:\Dietrich_Server\Gabriela\2018_9_3_B6_validation\702_isolation1\All','IncludeSubfolders',true);
[predictedLabels, scores] = classify(netTransfer,images);
ratio_pwk = sum(strcmp(cellstr(predictedLabels),'PWK'))/size(predictedLabels,1)
ratio_b6 = sum(strcmp(cellstr(predictedLabels),'B6'))/size(predictedLabels,1)
ratio_nzo = sum(strcmp(cellstr(predictedLabels),'NZO'))/size(predictedLabels,1)
ratio_aj = sum(strcmp(cellstr(predictedLabels),'AJ'))/size(predictedLabels,1)
% output = [cellstr(predictedLabels), num2cell(scores)];

[stats,txt,raw] = xlsread('Z:\Dietrich_Server\Gabriela\2018_9_3_B6_validation\702_isolation1\702_isolation1.xlsx');
raw(1,:)=[];

T = [cell2table(cellstr(predictedLabels),'VariableNames',{'Testing_label'}) ...
    array2table(scores,'VariableNames',ttt) cell2table(raw(:,[1,19]),'VariableNames',{'NumVocal','class'})];

aux = strcmp(T.class,'noise_dist');
T2 = T(~aux,:);
ratio_pwk = sum(strcmp(T2.Testing_label,'PWK'))/size(T2,1)
ratio_b6 = sum(strcmp(T2.Testing_label,'B6'))/size(T2,1)
ratio_nzo = sum(strcmp(T2.Testing_label,'NZO'))/size(T2,1)
ratio_aj = sum(strcmp(T2.Testing_label,'AJ'))/size(T2,1)

correct = sum(strcmp(T2.Testing_label,'PWK'));
chevrons = sum(strcmp(T2.Testing_label,'PWK') & strcmp(T2.class,'chevron'))/correct
flats = sum(strcmp(T2.Testing_label,'PWK') & strcmp(T2.class,'flat'))/correct
down_fm = sum(strcmp(T2.Testing_label,'PWK') & strcmp(T2.class,'down_fm'))/correct
short = sum(strcmp(T2.Testing_label,'PWK') & strcmp(T2.class,'short'))/correct
up_fm = sum(strcmp(T2.Testing_label,'PWK') & strcmp(T2.class,'up_fm'))/correct
% T = [cell2table(images_training.Files,'VariableNames',{'Training_file'}) cell2table(cellstr(images_training.Labels),'VariableNames',{'Training_label'})...
%     cell2table(images.Files,'VariableNames',{'Testing_file'}) cell2table(cellstr(predictedLabels),'VariableNames',{'Testing_label'}) ...
%     array2table(scores,'VariableNames',ttt)];

% save table_performance T

% aux = predictedLabels ~= images_training.Labels;
% T_wrong = T(aux,:);
% 
% save table_wrong T_wrong