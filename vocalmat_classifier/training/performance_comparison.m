% -- compare performance for each model using each dataset
% -- expected directory structure:
% -- [raw_data]/[model_name]/[dataset_name]/[model_name|model_name_records|matlab_environment].mat
% -- [testset_path]: path to dataset used for the test classification

whereami     = pwd;
raw_data     = '/Users/gustavo/git/ahof_vocalmat/vocalmat_classifier/training/.rawdata';
% testset_path = '/Users/gustavo/git/ahof_vocalmat/vocalmat_classifier/training/.testset';
% imds         = imageDatastore([testset_path], 'IncludeSubfolders', true);
% imds_resnet  = augmentedImageDatastore([224 224], imds);

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
% -- section II : get datasets used with each model
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
        models{current_model,1}(current_dataset+1,1) = datasets{1, current_dataset};
    end
end

% --
% -- section III : get statistics on each dataset for each model
% --

% -- TODO
% -- training options, training time
% -- predictions, scores, classification time
% -- Plot the ratio of probability between most likely and second most likely to see how confident is the machine about this classification


for current_model=1:models_found
    % -- load table_performance.mat
    % -- save for each dataset in each model:
    % -- dataset size, images per label, top1 accuracy, top2 accuracy

    % -- get number of datasets for current model
    datasets_for_this_model = size(models{current_model,1}, 1) - 1;

    % -- cycle through datasets for the current model
    for current_dataset=1:datasets_for_this_model

        % -- write headers
        if current_dataset == 1
            models{current_model,1}(1,2)  = "images";
            models{current_model,1}(1,3)  = "correct1";
            models{current_model,1}(1,4)  = "correct2";
            models{current_model,1}(1,5)  = "wrong1";
            models{current_model,1}(1,6)  = "wrong2";
            models{current_model,1}(1,7)  = "top1";
            models{current_model,1}(1,8)  = "top2";
            models{current_model,1}(1,9) = "chevron_accuracy";
            models{current_model,1}(1,10) = "complex_accuracy";
            models{current_model,1}(1,11) = "down_fm_accuracy";
            models{current_model,1}(1,12) = "flat_accuracy";
            models{current_model,1}(1,13) = "mult_steps_accuracy";
            models{current_model,1}(1,14) = "noise_dist_accuracy";
            models{current_model,1}(1,15) = "rev_chevron_accuracy";
            models{current_model,1}(1,16) = "short_accuracy";
            models{current_model,1}(1,17) = "step_down_accuracy";
            models{current_model,1}(1,18) = "step_up_accuracy";
            models{current_model,1}(1,19) = "two_steps_accuracy";
            models{current_model,1}(1,20) = "up_fm_accuracy";
        end

        % -- get path to dataset and load the performance table
        current_dataset_path = fullfile(models{current_model,1}(1,1), models{current_model,1}(current_dataset+1,1));
        cd(current_dataset_path);

        try
            load('table_performance');

            % -- top1 statistics
            num_images = size(T,1);
            correct1   = sum(strcmp(T.Training_label, T.Testing_label));
            wrong1     = size(T,1) - correct1;
            top1       = correct1*100/num_images;

            Tlabel = table2cell(T(:,2));
            Tlabel = categorical (Tlabel);

            Tpred  = table2cell(T(:,4));
            Tpred  = categorical(Tpred);

            failed = Tlabel ~= Tpred;
            Twrong = T(failed,:);

            % -- move things around to get top2 statistics
            scores          = Twrong(:,5:16);
            scores_labels   = scores.Properties.VariableNames;
            scores          = table2array(scores);
            % [value_highest idx_highest] = max(scores');
            [value_highest idx_highest] = max(scores, [], 2);
            % scores(value_highest) = NaN;

            % -- this is very slow :)
            for current_highest=1:size(idx_highest,1)
                scores(current_highest, idx_highest(current_highest)) = 0;
            end

            [value_highest idx_highest] = max(scores, [], 2);

            % -- slow again
            for current_highest=1:size(idx_highest,1)
                Twrong.Top2(current_highest) = string(scores_labels(1, idx_highest(current_highest)));
            end

            Tlabel = table2cell(Twrong(:,2));
            Tlabel = categorical(Tlabel);

            Tpred  = table2cell(Twrong(:,end));
            Tpred  = categorical(string(Tpred));

            correct_top2 = Tlabel == Tpred;
            Ttop2        = Twrong(correct_top2,:);

            % -- sort scores and get ratio for top2 accurary
            scores        = table2array(Ttop2(:,5:16));
            sorted_scores = sort(scores,2);
            ratio         = 1 - (sorted_scores(:,end-1)./sorted_scores(:,end));
            ratios{current_model,1}{current_dataset,1} = ratio;
            % scatter(1:1:size(ratio,1), ratio);

            % -- top2 statistics
            correct2   = sum(strcmp(Twrong.Training_label, Twrong.Top2));
            correct2   = correct1 + correct2;
            wrong2     = size(T,1) - correct2;
            top2       = correct2*100/num_images;

            % get top1 accuracy by label
            Tlabel = table2cell(T(:,2));
            Tlabel = categorical (Tlabel);

            Tpred  = table2cell(T(:,4));
            Tpred  = categorical(Tpred);

            idx    = Tlabel == Tpred;

            flat_accuracy        = sum(strcmp(T.Training_label(idx), 'flat'))/sum(strcmp(T.Training_label, 'flat'));
            short_accuracy       = sum(strcmp(T.Training_label(idx), 'short'))/sum(strcmp(T.Training_label, 'short'));
            chevron_accuracy     = sum(strcmp(T.Training_label(idx), 'chevron'))/sum(strcmp(T.Training_label, 'chevron'));
            rev_chevron_accuracy = sum(strcmp(T.Training_label(idx), 'rev_chevron'))/sum(strcmp(T.Training_label, 'rev_chevron'));
            up_fm_accuracy       = sum(strcmp(T.Training_label(idx), 'up_fm'))/sum(strcmp(T.Training_label, 'up_fm'));
            down_fm_accuracy     = sum(strcmp(T.Training_label(idx), 'down_fm'))/sum(strcmp(T.Training_label, 'down_fm'));
            step_down_accuracy   = sum(strcmp(T.Training_label(idx), 'step_down'))/sum(strcmp(T.Training_label, 'step_down'));
            step_up_accuracy     = sum(strcmp(T.Training_label(idx), 'step_up'))/sum(strcmp(T.Training_label, 'step_up'));
            two_steps_accuracy   = sum(strcmp(T.Training_label(idx), 'two_steps'))/sum(strcmp(T.Training_label, 'two_steps'));
            mult_steps_accuracy  = sum(strcmp(T.Training_label(idx), 'mult_steps'))/sum(strcmp(T.Training_label, 'mult_steps'));
            complex_accuracy     = sum(strcmp(T.Training_label(idx), 'complex'))/sum(strcmp(T.Training_label, 'complex'));
            noise_dist_accuracy  = sum(strcmp(T.Training_label(idx), 'noise_dist'))/sum(strcmp(T.Training_label, 'noise_dist'));


            models{current_model,1}(current_dataset+1,2)  = num2str(num_images);
            models{current_model,1}(current_dataset+1,3)  = num2str(correct1);
            models{current_model,1}(current_dataset+1,4)  = num2str(correct2);
            models{current_model,1}(current_dataset+1,5)  = num2str(wrong1);
            models{current_model,1}(current_dataset+1,6)  = num2str(wrong2);
            models{current_model,1}(current_dataset+1,7)  = num2str(top1);
            models{current_model,1}(current_dataset+1,8)  = num2str(top2);
            models{current_model,1}(current_dataset+1,9)  = num2str(chevron_accuracy);
            models{current_model,1}(current_dataset+1,10) = num2str(complex_accuracy);
            models{current_model,1}(current_dataset+1,11) = num2str(down_fm_accuracy);
            models{current_model,1}(current_dataset+1,12) = num2str(flat_accuracy);
            models{current_model,1}(current_dataset+1,13) = num2str(mult_steps_accuracy);
            models{current_model,1}(current_dataset+1,14) = num2str(noise_dist_accuracy);
            models{current_model,1}(current_dataset+1,15) = num2str(rev_chevron_accuracy);
            models{current_model,1}(current_dataset+1,16) = num2str(short_accuracy);
            models{current_model,1}(current_dataset+1,17) = num2str(step_down_accuracy);
            models{current_model,1}(current_dataset+1,18) = num2str(step_up_accuracy);
            models{current_model,1}(current_dataset+1,19) = num2str(two_steps_accuracy);
            models{current_model,1}(current_dataset+1,20) = num2str(up_fm_accuracy);


        catch
            models{current_model,1}(current_dataset+1,2)  = "table_performance.mat not found";
            models{current_model,1}(current_dataset+1,3)  = "table_performance.mat not found";
            models{current_model,1}(current_dataset+1,4)  = "table_performance.mat not found";
            models{current_model,1}(current_dataset+1,5)  = "table_performance.mat not found";
            models{current_model,1}(current_dataset+1,6)  = "table_performance.mat not found";
            models{current_model,1}(current_dataset+1,7)  = "table_performance.mat not found";
            models{current_model,1}(current_dataset+1,8)  = "table_performance.mat not found";
            models{current_model,1}(current_dataset+1,9)  = "table_performance.mat not found";
            models{current_model,1}(current_dataset+1,10) = "table_performance.mat not found";
            models{current_model,1}(current_dataset+1,11) = "table_performance.mat not found";
            models{current_model,1}(current_dataset+1,12) = "table_performance.mat not found";
            models{current_model,1}(current_dataset+1,13) = "table_performance.mat not found";
            models{current_model,1}(current_dataset+1,14) = "table_performance.mat not found";
            models{current_model,1}(current_dataset+1,15) = "table_performance.mat not found";
            models{current_model,1}(current_dataset+1,16) = "table_performance.mat not found";
            models{current_model,1}(current_dataset+1,17) = "table_performance.mat not found";
            models{current_model,1}(current_dataset+1,18) = "table_performance.mat not found";
            models{current_model,1}(current_dataset+1,19) = "table_performance.mat not found";
            models{current_model,1}(current_dataset+1,20) = "table_performance.mat not found";
        end
    end
end

cd(raw_data);

models(end) = [];

save models_stats_all.mat models
save models_stats_ratio_top1top2.mat ratios


% models_comparison(:,1) =  models{1,1}(:,1);
% models_comparison(:,2) =  models{2,1}(:,7);
% models_comparison(:,3) =  models{3,1}(:,7);
% models_comparison(:,4) =  models{5,1}(:,7);
% models_comparison(:,5) =  models{6,1}(:,7);
% models_comparison(:,6) =  models{2,1}(:,8);
% models_comparison(:,7) =  models{5,1}(:,8);
% models_comparison(:,8) =  models{5,1}(:,8);
% models_comparison(:,9) =  models{6,1}(:,8);

% remove augmented
% mm{1, 1}([3:4,6:7,11:12,14:15,19:20],:) = [];
% mm{2, 1}([3:4,6:7,11:12,14:15,19:20],:) = [];
% mm{5, 1}([3:4,6:7,11:12,14:15,19:20],:) = [];
% mm{6, 1}([3:4,6:7,11:12,14:15,19:20],:) = [];
% mm{7, 1}([3:4,6:7,11:12,14:15,19:20],:) = [];
% mm{8, 1}([3:4,6:7,11:12,14:15,19:20],:) = [];

% cd(whereami);
% csvwrite('model.csv', models{1,1})
% excel = array2table(models{1,1}(2:end,:));
% excel.Properties.VariableNames = {'dataset' 'images' 'correct1' 'correct2' 'wrong1' 'wrong2' 'top1' 'top2'};