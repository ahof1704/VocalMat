% -- first run performance_comparison.m
% -- expected directory structure:
% -- [raw_data]/[model_name]/[dataset_name]/models_stats_all.mat

whereami     = mfilename('fullpath');
raw_data     = '/Users/gustavo/git/ahof_vocalmat/vocalmat_classifier/training/.rawdata';
load([raw_data '/models_stats_all.mat']);

models_num = size(models,1);

% -- plots model call type accuracy by dataset
for current_model=1:models_num
    % -- get model and dataset info
    model_name     = models{current_model,1}(1,1);
    model_name     = split(model_name, ["/", "\"]);
    model_name     = model_name(end);
    dataset_names  = models{current_model,1}(2:end,1)';
    dataset_labels = models{current_model,1}(1,end-11:end);

    % -- get each call type accuracy
    % -- call type columns are sorted alphabetically
    % -- chevron_accuracy
    % -- complex_accuracy
    % -- down_fm_accuracy
    % -- flat_accuracy
    % -- mult_steps_accuracy
    % -- noise_dist_accuracy
    % -- rev_chevron_accuracy
    % -- short_accuracy
    % -- step_down_accuracy
    % -- step_up_accuracy
    % -- two_steps_accuracy
    % -- up_fm_accuracy

    chevron_accuracy     = models{current_model,1}(2:end,end-11)';
    chevron_accuracy     = cellfun(@str2num, chevron_accuracy, 'UniformOutput', false);

    complex_accuracy     = models{current_model,1}(2:end,end-10)';
    complex_accuracy     = cellfun(@str2num, complex_accuracy, 'UniformOutput', false);

    down_fm_accuracy     = models{current_model,1}(2:end,end-9)';
    down_fm_accuracy     = cellfun(@str2num, down_fm_accuracy, 'UniformOutput', false);

    flat_accuracy        = models{current_model,1}(2:end,end-8)';
    flat_accuracy        = cellfun(@str2num, flat_accuracy, 'UniformOutput', false);

    mult_steps_accuracy  = models{current_model,1}(2:end,end-7)';
    mult_steps_accuracy  = cellfun(@str2num, mult_steps_accuracy, 'UniformOutput', false);

    noise_dist_accuracy  = models{current_model,1}(2:end,end-6)';
    noise_dist_accuracy  = cellfun(@str2num, noise_dist_accuracy, 'UniformOutput', false);

    rev_chevron_accuracy = models{current_model,1}(2:end,end-5)';
    rev_chevron_accuracy = cellfun(@str2num, rev_chevron_accuracy, 'UniformOutput', false);

    short_accuracy       = models{current_model,1}(2:end,end-4)';
    short_accuracy       = cellfun(@str2num, short_accuracy, 'UniformOutput', false);

    step_down_accuracy   = models{current_model,1}(2:end,end-3)';
    step_down_accuracy   = cellfun(@str2num, step_down_accuracy, 'UniformOutput', false);

    step_up_accuracy     = models{current_model,1}(2:end,end-2)';
    step_up_accuracy     = cellfun(@str2num, step_up_accuracy, 'UniformOutput', false);

    two_steps_accuracy   = models{current_model,1}(2:end,end-1)';
    two_steps_accuracy   = cellfun(@str2num, two_steps_accuracy, 'UniformOutput', false);

    up_fm_accuracy       = models{current_model,1}(2:end,end)';
    up_fm_accuracy       = cellfun(@str2num, up_fm_accuracy, 'UniformOutput', false);

    segments = [chevron_accuracy ; complex_accuracy ; down_fm_accuracy ; flat_accuracy ; mult_steps_accuracy ; noise_dist_accuracy ; rev_chevron_accuracy ; short_accuracy ; step_down_accuracy ; step_up_accuracy ; two_steps_accuracy ; up_fm_accuracy];
    segments = cell2mat(segments);

    figure(current_model)
    bar(segments, 'hist')
        set(gca,'fontsize', 18);
        title(['Call Type Accuracy by Dataset; ' char(model_name)]);
        xlabel('call type');
        ylabel('accuracy');
        % yticks([0 0.8 0.9 1 1.5]);
        grid minor;
        axis([0 13 0.00 1.0]);
        set(gca,'XTickLabel', {'chevron', 'complex', 'down fm', 'flat', 'mult steps', 'noise', 'revchevron', 'short', 'step down', 'step up', 'two steps', 'up fm'});
        legend(dataset_names, 'Location', 'Best');
        % legend("18-october", "18-october-augment", "18-october-augment-plus", "18-october-dirty", "18-october-dirty-augment", "18-october-dirty-augment-plus", "18-october-dirty-plus", "18-october-plus", "18-september", "18-september-augment", "18-september-augment-plus", "18-september-plus", 'Location', 'Best');
end

% -- plots distribution probabilty
% -- must choose which one to plot (there are too many)
clearvars -except whereami raw_data  models

model_name = 'alexnet_pretrained';
dataset_name = '18-october-dirty';

% load(fullfile(raw_data, model_name, dataset_name, 'table_performance.mat'));
% 
% scores = table2array(T(:,5:16));
% sorted_scores = sort(scores,2);
% ratio = 1 - sorted_scores(:,end-1)./sorted_scores(:,end);
% histfit(ratio, 10, 'kernel');
% hold on;
% counts = histcounts(ratio, 10);
% bar(counts)