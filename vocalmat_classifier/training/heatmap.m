[vfilename,vpathname] = uigetfile({'*.mat'},'Select table performance file')
cd(vpathname);
vfile = fullfile(vpathname,vfilename)
load(vfile);

dataset_path = '/Users/gustavo/git/ahof_vocalmat/vocalmat_classifier/training/.dataset/testset';

imds                 = imageDatastore([dataset_path], 'IncludeSubfolders', true, 'LabelSource', 'foldernames');
dataset_stats        = countEachLabel(imds);
dataset_stats        = sortrows(dataset_stats, 'Count', 'ascend')
dataset_labels_count = numel(dataset_stats(:, 1))
dataset_images_count = numel(imds.Files(:, 1))
dataset_labels       = table2cell(dataset_stats);

% ------------- FROM PERFORMANCE_COMPARISON
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
% ----------------------------------------

preds = T{:,2:2:4};
preds = string(preds);

labels         = {'chevron','complex','down_fm','flat','mult_steps','noise_dist','rev_chevron','short','step_down','step_up','two_steps','up_fm'};
heatingmap     = zeros(12,12);
heatingmaptop2 = zeros(12,12);

for current_label=1:size(labels, 2)
    this_label          = labels{current_label};
    appears_in          = preds(:,1) == this_label;
    this_label          = preds(appears_in,:);
    
    total_label_count   = size(this_label, 1);
    
    correct             = this_label(:,1) == this_label(:,2);
    
    label_correct       = this_label(correct,:);
    label_wrong         = this_label(~correct,:);
    
    total_label_correct = size(label_correct, 1);
    total_label_wrong   = size(label_wrong, 1);
    
    correct_pred_percentage                 = total_label_correct/total_label_count;
    heatingmap(current_label,current_label) = correct_pred_percentage;
    
    % get top1 wrong predictions statistics
    for lbl=1:size(labels, 2)
        if ~(lbl == current_label)
            testing_label = labels{lbl};
            heatingmap(current_label,lbl) = sum(strcmp(label_wrong(:,2), testing_label))/total_label_count;
        end
    end
    
    
    
    % get top2 wrong predictions statistics
    idx_wrong = preds(:,1) ~= preds(:,2);
    top1wrong = preds(idx_wrong, :);
    top1wrong(:,3) = table2array(Twrong(:,end));

    this_label          = labels{current_label};
    appears_in          = top1wrong(:,1) == this_label;
    this_label          = top1wrong(appears_in,:);
    
    total_label_count   = size(this_label, 1);
    top2labelcount{current_label} = total_label_count;
    
    correct             = this_label(:,1) == this_label(:,3);
    
    label_correct       = this_label(correct,:);
    label_wrong         = this_label(~correct,:);
    
    total_label_correct = size(label_correct, 1);
    total_label_wrong   = size(label_wrong, 1);
    
    correct_pred_percentage                 = total_label_correct/total_label_count;
    heatingmaptop2(current_label,current_label) = correct_pred_percentage;
    
    % get top2 wrong predictions statistics
    for lbl=1:size(labels, 2)
        if ~(lbl == current_label)
            testing_label = labels{lbl};
            heatingmaptop2(current_label,lbl) = sum(strcmp(label_wrong(:,3), testing_label))/total_label_count;
        end
    end
end
