imds = imageDatastore(['/Users/gustavo/git/ahof_vocalmat/vocalmat_classifier/training/.dataset/18-october-dirty '], 'IncludeSubfolders', true, 'LabelSource', 'foldernames');

dataset_stats        = countEachLabel(imds);
dataset_stats        = sortrows(dataset_stats,'Count','ascend')
dataset_labels_count = numel(dataset_stats(:,1))
dataset_images_count = numel(imds.Files(:,1))
datastore_by_label   = cell(dataset_labels_count, 1);

for current_label = 1:dataset_labels_count
    datastore_by_label{current_label} = splitEachLabel(imds, 0.9999, 'Include', dataset_stats{current_label,1});
end

augmenter = imageDataAugmenter( ...
                                'RandRotation', [-20,20], ...
                                'RandXTranslation', [-3 3], ...
                                'RandYTranslation', [-3 3], ...
                                'RandXScale', [0.5 1] ...
                                );

