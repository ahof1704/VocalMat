raw_data     = '/Users/gustavo/git/ahof_vocalmat/vocalmat_classifier/training/.rawdata';
model_name = 'alexnet_pretrained';
dataset_name = '18-october-dirty';

load(fullfile(raw_data, model_name, dataset_name, 'table_performance.mat'));

scores = table2array(T(:,5:16));
sorted_scores = sort(scores,2);
ratio = sorted_scores(:,end)./sorted_scores(:,end-1);

this = histcounts(sorted_scores(:,end), 100);
bar(this)
hold on;
this = histcounts(sorted_scores(:,end-1), 100);
bar(this)
hold on;

Tlabel = table2cell(T(:,2));
Tlabel = categorical (Tlabel);

Tpred  = table2cell(T(:,4));
Tpred  = categorical(Tpred);

failed = Tlabel ~= Tpred;
Twrong = T(failed,:);
correct = Tlabel == Tpred;
Tright = T(correct,:);

figure
sr = table2cell(Tright(:,end-11:end));
sr = cell2mat(sr);
sr = sort(sr,2);
this = histcounts(sr(:,end), 100);
bar(this)
hold on;

sw = table2cell(Twrong(:,end-11:end));
sw = cell2mat(sw);
sw = sort(sw,2);
this = histcounts(sw(:,end), 100);
bar(this)
hold on;


>> ratio(ratio<0.001) = 0.001;
>> sorted_scores(sorted_scores<0.001) = 0.001;
>> ratio = sorted_scores(:,end)./sorted_scores(:,end-1);
>> Trw = ratio(failed);
>> this = histcounts(Trw, 100);
bar(this)
>> this = histcounts(Trw, 1000);
>> bar(this)
>> bar(this)
>> this = histcounts(Trw, 100);
>> bar(this)
>> asd = Trw(Trw<10);
>> open asd