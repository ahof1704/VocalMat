clear all

[vfilename1,vpathname] = uigetfile({'*.xlsx'},'Select the file to combine');
disp(vfilename1)
vfile = fullfile(vpathname,vfilename1);
cd (vpathname);
list = dir('*xlsx');
classes = {'chevron';'complex';'flat';'mult_steps';'down_fm';'noise_dist';'short';'step_down';'step_up';'two_steps';'up_fm'};

for k=1:size(list,1)
    clear data txt raw
    [data,txt,raw] = xlsread(list(k).name);
    name{k} = list(k).name(1:end-5);
    duration{k} = data(:,4);
    min_freq_main{k} = data(:,5);
    max_freq_main{k} = data(:,6);
    mean_freq_main{k} = data(:,7);
    min_freq_total{k} = data(:,8);
    max_freq_total{k} = data(:,9);
    mean_freq_total{k} = data(:,10);
    min_intens_total{k} = data(:,11);
    max_intens_total{k} = data(:,12);
    mean_intens_total{k} = data(:,13);
    class_vocal{k} = txt(2:end,14);
    
    %get indexes
    for j = 1:size(classes,1);
        idx = strfind(class_vocal{k}, classes{j});
        idx = find(not(cellfun('isempty', idx)));
        eval([classes{j} '_duration{k} = duration{k}(idx);'])
        eval([classes{j} '_min_freq_main{k} = min_freq_main{k}(idx);'])
        eval([classes{j} '_max_freq_main{k} = max_freq_main{k}(idx);'])
        eval([classes{j} '_mean_freq_main{k} = mean_freq_main{k}(idx);'])
        eval([classes{j} '_min_freq_total{k} = min_freq_total{k}(idx);'])
        eval([classes{j} '_max_freq_total{k} = max_freq_total{k}(idx);'])
        eval([classes{j} '_mean_freq_total{k} = mean_freq_total{k}(idx);'])
        eval([classes{j} '_min_intens_total{k} = min_intens_total{k}(idx);'])
        eval([classes{j} '_max_intens_total{k} = max_intens_total{k}(idx);'])
        eval([classes{j} '_mean_intens_total{k} = mean_intens_total{k}(idx);'])
    end
end


mkdir('VocalMat_Statistics')
% cd('VocalMat_Statistics')

%Duration
for j = 1:size(classes,1);
    eval(['size_table = cellfun(''length'',' classes{j} '_duration);']);
    T = NaN(max(size_table),size(list,1));
    for k=1:size(list,1)
        eval(['T(1:size(' classes{j} '_duration{k},1),k) = ' classes{j} '_duration{k};'])
    end
    T = array2table(T, 'VariableNames', name);
    writetable(T,[vpathname 'VocalMat_Statistics\Duration.xlsx'], 'Sheet', classes{j} );
end
% cd (vpathname);
RemoveSheet123('\VocalMat_Statistics\Duration.xlsx');

%Min_freq
for j = 1:size(classes,1);
    eval(['size_table = cellfun(''length'',' classes{j} '_min_freq_main);']);
    T = NaN(max(size_table),size(list,1));
    for k=1:size(list,1)
        eval(['T(1:size(' classes{j} '_min_freq_main{k},1),k) = ' classes{j} '_duration{k};'])
    end
    T = array2table(T, 'VariableNames', name);
    writetable(T,[vpathname 'VocalMat_Statistics\min_freq_main.xlsx'], 'Sheet', classes{j} )
end
% cd (vpathname);
RemoveSheet123('\VocalMat_Statistics\min_freq_main.xlsx');

%Max_freq
for j = 1:size(classes,1);
    eval(['size_table = cellfun(''length'',' classes{j} '_max_freq_main);']);
    T = NaN(max(size_table),size(list,1));
    for k=1:size(list,1)
        eval(['T(1:size(' classes{j} '_max_freq_main{k},1),k) = ' classes{j} '_max_freq_main{k};'])
    end
    T = array2table(T, 'VariableNames', name);
    writetable(T,[vpathname 'VocalMat_Statistics\max_freq_main.xlsx'], 'Sheet', classes{j} )
end
% cd (vpathname);
RemoveSheet123('\VocalMat_Statistics\max_freq_main.xlsx');

%Mean_freq
for j = 1:size(classes,1);
    eval(['size_table = cellfun(''length'',' classes{j} '_mean_freq_main);']);
    T = NaN(max(size_table),size(list,1));
    for k=1:size(list,1)
        eval(['T(1:size(' classes{j} '_mean_freq_main{k},1),k) = ' classes{j} '_mean_freq_main{k};'])
    end
    T = array2table(T, 'VariableNames', name);
    writetable(T,[vpathname 'VocalMat_Statistics\mean_freq_main.xlsx'], 'Sheet', classes{j} )
end
% cd (vpathname);
RemoveSheet123('\VocalMat_Statistics\mean_freq_main.xlsx');

%min_freq_total
for j = 1:size(classes,1);
    eval(['size_table = cellfun(''length'',' classes{j} '_min_freq_total);']);
    T = NaN(max(size_table),size(list,1));
    for k=1:size(list,1)
        eval(['T(1:size(' classes{j} '_min_freq_total{k},1),k) = ' classes{j} '_min_freq_total{k};'])
    end
    T = array2table(T, 'VariableNames', name);
    writetable(T,[vpathname 'VocalMat_Statistics\min_freq_total.xlsx'], 'Sheet', classes{j} )
end
% cd (vpathname);
RemoveSheet123('\VocalMat_Statistics\min_freq_total.xlsx');

%max_freq_total
for j = 1:size(classes,1);
    eval(['size_table = cellfun(''length'',' classes{j} '_max_freq_total);']);
    T = NaN(max(size_table),size(list,1));
    for k=1:size(list,1)
        eval(['T(1:size(' classes{j} '_max_freq_total{k},1),k) = ' classes{j} '_max_freq_total{k};'])
    end
    T = array2table(T, 'VariableNames', name);
    writetable(T,[vpathname 'VocalMat_Statistics\max_freq_total.xlsx'], 'Sheet', classes{j} )
end
% cd (vpathname);
RemoveSheet123('\VocalMat_Statistics\max_freq_total.xlsx');

%_mean_freq_total
for j = 1:size(classes,1);
    eval(['size_table = cellfun(''length'',' classes{j} '_mean_freq_total);']);
    T = NaN(max(size_table),size(list,1));
    for k=1:size(list,1)
        eval(['T(1:size(' classes{j} '_mean_freq_total{k},1),k) = ' classes{j} '_mean_freq_total{k};'])
    end
    T = array2table(T, 'VariableNames', name);
    writetable(T, [vpathname 'VocalMat_Statistics\mean_freq_total.xlsx'], 'Sheet', classes{j} )
end
% cd (vpathname);
RemoveSheet123('\VocalMat_Statistics\mean_freq_total.xlsx');

%min_intens_total
for j = 1:size(classes,1);
    eval(['size_table = cellfun(''length'',' classes{j} '_min_intens_total);']);
    T = NaN(max(size_table),size(list,1));
    for k=1:size(list,1)
        eval(['T(1:size(' classes{j} '_min_intens_total{k},1),k) = ' classes{j} '_min_intens_total{k};'])
    end
    T = array2table(T, 'VariableNames', name);
    writetable(T, [vpathname 'VocalMat_Statistics\min_intens_total.xlsx'], 'Sheet', classes{j} )
end
% cd (vpathname);
RemoveSheet123('\VocalMat_Statistics\min_intens_total.xlsx');

%_max_intens_total
for j = 1:size(classes,1);
    eval(['size_table = cellfun(''length'',' classes{j} '_max_intens_total);']);
    T = NaN(max(size_table),size(list,1));
    for k=1:size(list,1)
        eval(['T(1:size(' classes{j} '_max_intens_total{k},1),k) = ' classes{j} '_max_intens_total{k};'])
    end
    T = array2table(T, 'VariableNames', name);
    writetable(T,[vpathname 'VocalMat_Statistics\max_intens_total.xlsx'], 'Sheet', classes{j})
end
% cd (vpathname);
RemoveSheet123('\VocalMat_Statistics\max_intens_total.xlsx');

%_mean_intens_total
for j = 1:size(classes,1);
    eval(['size_table = cellfun(''length'',' classes{j} '_mean_intens_total);']);
    T = NaN(max(size_table),size(list,1));
    for k=1:size(list,1)
        eval(['T(1:size(' classes{j} '_mean_intens_total{k},1),k) = ' classes{j} '_mean_intens_total{k};'])
    end
    T = array2table(T, 'VariableNames', name);
    writetable(T, [vpathname 'VocalMat_Statistics\mean_intens_total.xlsx'], 'Sheet', classes{j} )
end
% cd (vpathname);
RemoveSheet123('\VocalMat_Statistics\mean_intens_total.xlsx');