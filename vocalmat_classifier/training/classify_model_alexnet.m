% -- test the trained model using the testset
netTransfer  = load('model_alexnet_trained');
netTransfer  = netTransfer.netTransfer;
labels       = netTransfer.Layers(end).ClassNames;

% dataset_path = '/Users/gustavo/git/ahof_vocalmat/vocalmat_classifier/training/.dataset/18-september';
imds_labeled = imageDatastore([dataset_path], 'IncludeSubfolders', true, 'LabelSource', 'foldernames');
imds         = imageDatastore([dataset_path], 'IncludeSubfolders', true);

[predictedLabels, scores] = classify(netTransfer, imds);

T = [ ...
    cell2table(imds_labeled.Files,'VariableNames',{'Training_file'}) ...
    cell2table(cellstr(imds_labeled.Labels),'VariableNames',{'Training_label'}) ...
    cell2table(imds.Files,'VariableNames',{'Testing_file'}) ...
    cell2table(cellstr(predictedLabels),'VariableNames',{'Testing_label'}) ...
    array2table(scores,'VariableNames',labels)];

save table_performance T

failed  = predictedLabels ~= imds_labeled.Labels;
T_wrong = T(failed,:);

save table_wrong T_wrong