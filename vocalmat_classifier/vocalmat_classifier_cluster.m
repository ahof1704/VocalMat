% ----------------------------------------------------------------------------------------------
% -- Title       : VocalMat Classifier
% -- Project     : VocalMat - Automated Tool for Mice Vocalization Detection and Classification
% ----------------------------------------------------------------------------------------------
% -- File        : vocalmat_classifier.m
% -- Group       : Dietrich Lab - Department of Comparative Medicine @ Yale University
% -- Standard    : <MATLAB 2018a>
% ----------------------------------------------------------------------------------------------
% -- Copyright (c) 2019 Dietrich Lab - Yale University
% ----------------------------------------------------------------------------------------------

size_spectrogram = [227 227];

% -- 0 = off; 1 = on.
use_DL                    = 1;
plot_stats_per_bin        = 1;
save_plot_spectrograms    = 0; % plots the spectograms with axes
axes_dots                 = 1; % show the dots overlapping the vocalization (segmentation)
save_excel_file           = 1;

% -- variable parameter sizes
scatter_step              = 3; % plot every third point overlapping the vocalization (segmentation)
bin_size                  = 300; % in seconds

disp('[vocalmat][classifier]: list of parameters to be used in this analysis (1 = On; 0 = Off):')
disp('|==========================================|');
disp(['| Bin size (in seconds)              : ' num2str(bin_size) ' |']);
disp(['| Save Excel file                    :  ' num2str(save_excel_file) '  |']);
disp(['| Save spectrogram segmentation plot :  ' num2str(save_plot_spectrograms) '  |']);
disp(['| |- Plot axe dots (segmentation)    :  ' num2str(axes_dots) '  |']);
disp(['| |- Scatter plot step size          :  ' num2str(scatter_step) '  |']);
disp('|==========================================|');

raiz = pwd;
model_class_DL = load('Mdl_categorical_DL.mat');
model_class_DL = model_class_DL.netTransfer;

% [vfilename,vpathname] = uigetfile({'*.mat'},'Select the output file')
% disp(['Reading ' vfilename])
vfile = fullfile(vpathname,vfilename); 
% load(vfile);
%cd(vpathname);
%list = dir('*output*.mat');
%diary(['Summary_classifier' num2str(horzcat(fix(clock))) '.txt'])

%Setting up
p = mfilename('fullpath');
fprintf('\n')


%We are gonna get only 10 points (time stamps) to classify the vocalization
%Grimsley, Jasmine, Marie Gadziola, and Jeff James Wenstrup. "Automated classification of mouse pup isolation syllables: from cluster analysis to an Excel-based �mouse pup syllable classification calculator�."
%Frontiers in behavioral neuroscience 6 (2013): 89.
%     disp('Verify vocalizations for steps')
stepup_count=[];
stepdown_count=[];
harmonic_count=[];
flat_count=[];
chevron_count=[];
revchevron_count=[];
downfm_count=[];
upfm_count=[];
complex_count=[];
noisy_vocal_count=[];
nonlinear_count = [];
short_count = [];
noise_count = [];
noise_count_dist = [];
corr_yy2_yy3 = [];
corr_yy2_yy4 = [];
max_prom = [];
max_prom2 = [];
duration = [];

% disp('[vocalmat][classifier]: checking for empty cells')
time_vocal = time_vocal(~cellfun('isempty',time_vocal));
freq_vocal = freq_vocal(~cellfun('isempty',freq_vocal));
intens_vocal = intens_vocal(~cellfun('isempty',intens_vocal));

output=[];
cd(vpathname)
if ~exist(vfilename, 'dir')
    mkdir(vfilename)
end
cd(vfilename)

disp('[vocalmat][classifier]: running analysis!')

for k=1:size(time_vocal,2)
    
    harmonics = cell(1,size(time_vocal,2));
    
    current_freq = [];
    harmonic_candidate = [];
    skip_current = 0;
    for time_stamp = 1:size(time_vocal{k},2)-1
        
        if size(freq_vocal{k}{time_stamp+1},1)>1 %Probably we have an harmonic
            if (size(freq_vocal{k}{time_stamp},1)>1); %Check if they have same size (could be the continuation of harmonic)
                if time_stamp==1 %If the vocalization starts with an harmonic
                    current_freq = freq_vocal{k}{time_stamp}(1);
                    harmonic_candidate = freq_vocal{k}{time_stamp}(2);
                    if size(harmonic_candidate,1)==1
                        start_harmonic = time_vocal{k}(time_stamp);
                    end
                else
                    aux = freq_vocal{k}{time_stamp+1} - current_freq(end)*ones(size(freq_vocal{k}{time_stamp+1},1),1);
                    [mini,mini]=min(abs(aux));
                    temp = freq_vocal{k}{time_stamp+1};
                    current_freq = [current_freq; temp(mini)]; temp(mini) = [];
                    if size(harmonic_candidate,1)>1
                        if abs(temp - harmonic_candidate(end)) < 10000
                            harmonic_candidate = [harmonic_candidate; temp(1)];
                        else %if it is >10khz then it is already another harmonic
                            if size(harmonic_candidate,1)>10
                                harmonic_count = [harmonic_count;k];
                            end
                            harmonic_candidate = temp;
                        end
                    else
                        harmonic_candidate = [harmonic_candidate; temp(1)];
                    end
                    if size(harmonic_candidate,1)==1
                        start_harmonic = time_vocal{k}(time_stamp);
                    end
                end
            else %Find the closests freq to be the current and classify the other as harmonic candidate
                try
                    aux = freq_vocal{k}{time_stamp+1} - current_freq(end)*ones(size(freq_vocal{k}{time_stamp+1},1),1);
                catch
                    aux = freq_vocal{k}{time_stamp+1} - freq_vocal{k}{time_stamp}*ones(size(freq_vocal{k}{time_stamp+1},1),1);
                end
                
                [mini,mini]=min(abs(aux));
                temp = freq_vocal{k}{time_stamp+1};
                current_freq = [current_freq; temp(mini)]; temp(mini) = [];
                harmonic_candidate = [harmonic_candidate; temp];
                if size(harmonic_candidate,1)==1 || (size(harmonic_candidate,1)>1 && time_stamp==1)
                    start_harmonic = time_vocal{k}(time_stamp);
                end
            end
            
        else %There is nothing similar to harmonic right now... but there was before?
            if (size(freq_vocal{k}{time_stamp},1)>1)
                %                So... Was it an harmonic or not?
                if time_stamp == 1 %If the vocalization starts with something that reminds a vocalization
                    aux = freq_vocal{k}{time_stamp} - freq_vocal{k}{time_stamp+1}*ones(size(freq_vocal{k}{time_stamp},1),1);
                    [mini,mini]=min(abs(aux));
                    temp = freq_vocal{k}{time_stamp};
                    current_freq = [current_freq; temp(mini)]; temp(mini) = [];
                    harmonic_candidate = [harmonic_candidate; temp];
                    if size(harmonic_candidate,1)==1
                        start_harmonic = time_vocal{k}(time_stamp);
                    end
                end
                
                if abs(freq_vocal{k}{time_stamp+1} - harmonic_candidate(end)) < abs(freq_vocal{k}{time_stamp+1} - current_freq(end)) %Continued on the line that we thought was harmonic. So it is not harmonic
                    if size(harmonic_candidate,1)> size(current_freq,1)
                        
                        current_freq = [current_freq; freq_vocal{k}{time_stamp+1}];
                        harmonic_candidate = [];
                    else %current_freq > harmonic_candidate -> So it is a jump, not a harmonic
                        if size(harmonic_candidate,1)>10% && size(harmonic_candidate,1)/ size(current_freq,1)>0.8 %If the harmonic is big and close to the size of current_freq
                            
                            if (time_stamp+2 < size(time_vocal{k},2)) && any(abs(freq_vocal{k}{time_stamp+2} - current_freq(end)) < abs(freq_vocal{k}{time_stamp+2} - harmonic_candidate(end))) %Is there any chance of continuing with the current_freq?
                                harmonic_candidate = [harmonic_candidate; freq_vocal{k}{time_stamp+1}];
                                skip_current = 1;
                                harmonic_count = [harmonic_count;k];
                            else
                                current_freq(end-size(harmonic_candidate,1)+1:end) = harmonic_candidate;
                                current_freq = [current_freq; freq_vocal{k}{time_stamp+1}];
                                harmonic_candidate = [];
                                harmonic_count = [harmonic_count;k];
                            end
                            
                        else %So they just overlapped for a little while, but was actually a step
                            harmonic_candidate = [];
                        end
                    end
                else %It was an harmonic after all
                    current_freq = [current_freq; freq_vocal{k}{time_stamp+1}];
                    if size(harmonic_candidate,1)>10 % at least 10 points to say it was really an harmonic
                        harmonic_count = [harmonic_count;k];
                    end
                    harmonic_candidate = [];
                end
                
            else
                aux = freq_vocal{k}{time_stamp+1} - freq_vocal{k}{time_stamp};
                if skip_current==0
                    current_freq = [current_freq; freq_vocal{k}{time_stamp}];
                end
                skip_current = 0;
                
            end
        end
        
    end
    
    %Extra filtering by removing the points with intensity below 5% of the average
    tabela = [];
    for kk = 1:size(time_vocal{k},2)
        for ll = 1:size(freq_vocal{k}{kk},1)
            tabela = [tabela; time_vocal{k}(kk) freq_vocal{k}{kk}(ll) intens_vocal{k}{kk}(ll)];
        end
    end
    tabela_all_points{k} = tabela;
end

cd(raiz)

if use_DL==1
    if save_plot_spectrograms==1
        fig = figure('Name',vfilename,'NumberTitle','off','Position',[300 200 1167 875]);
    end

    cd(vpathname)
    if ~exist(vfilename, 'dir')
        mkdir(vfilename)
    end
    cd(vfilename)
    
    if (~exist([vfile '\All_axes'],'dir') && save_plot_spectrograms==1)
        mkdir('All_axes')
    end
    
    if ~exist([vfile '\All'],'dir')
        mkdir('All')
    end

    for id_vocal = 1:size(time_vocal,2)
        %         cd(raiz)
        dx = 0.22;
        
        T_min_max = [-dx/2 dx/2]+[time_vocal{id_vocal}(ceil(size(time_vocal{id_vocal},2)/2)) time_vocal{id_vocal}(ceil(size(time_vocal{id_vocal},2)/2))];
        [T_min T_min] = min(abs(T_orig - T_min_max(1)));
        [T_max T_max] = min(abs(T_orig - T_min_max(2)));
        
        if save_plot_spectrograms==1
           if save_plot_spectrograms==1
            clf('reset');
            hold on;
            surf(T_orig(T_min:T_max),F_orig,A_total(:,T_min:T_max),'edgecolor','none');
            axis tight; view(0,90);
            colormap(gray);
            xlabel('Time (s)'); ylabel('Freq (Hz)');
            
            if axes_dots == 1
                for time_stamp = 1:scatter_step:size(time_vocal{id_vocal},2)
                    try
                        scatter(time_vocal{id_vocal}(time_stamp)*ones(size(freq_vocal{id_vocal}{time_stamp}')),freq_vocal{id_vocal}{time_stamp}',[],'b');
                    catch
                        scatter(time_vocal{id_vocal}(time_stamp-1)*ones(size(freq_vocal{id_vocal}{time_stamp-1}')),freq_vocal{id_vocal}{time_stamp}',[],'b');
                    end
                end
            end
            set(gca,'fontsize', 18);
            frame = getframe(fig);
            imwrite(frame.cdata, [vpathname '/' vfilename '/All_axes/' num2str(id_vocal)  '.png'], 'png');
            hold off;
            
            end
        end        
        img = imresize(flipud(mat2gray(A_total(:,T_min:T_max))),size_spectrogram);
        img = cat(3, img, img, img);
        %                 imwrite(img,[vpathname '/' vfilename '/'  name '/' num2str(id_vocal)  '.png'])
        imwrite(img,[vpathname '/' vfilename '/All/' num2str(id_vocal)  '.png'])
        
    end
    
end

close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Rebuild curr_freq
dist_between_points=[];
slopes =[];
all_jumps =[];
higher_jumps=[];
lower_jumps=[];
table_out={};
duration=[];
num_points = 15;
for k=1:size(freq_vocal,2)
    curr_freq = [];
    intens_freq =[];
    for kk=1:size(freq_vocal{k},2)
        if size(freq_vocal{k}{kk},1)>1
            if isempty(curr_freq)
                j=2;
                try
                    while size(freq_vocal{k}{j},1)>1 %find the first element without "harmonic"
                        j=j+1;
                    end
                    [min_idx, min_idx] = min(abs((freq_vocal{k}{j}*ones(size(freq_vocal{k}{kk},1),1)) - freq_vocal{k}{kk}));
                    curr_freq = [curr_freq; freq_vocal{k}{kk}(min_idx)];
                    intens_freq = [intens_freq; intens_vocal{k}{kk}(min_idx)];
                catch
                    curr_freq = [curr_freq; freq_vocal{k}{kk}(1)]; %Just get any element if there is no time stamp with only one
                    intens_freq = [intens_freq; intens_vocal{k}{kk}(1)];
                end
                
            else
                [min_idx, min_idx] = min(abs((curr_freq(end)*ones(size(freq_vocal{k}{kk},1),1)) - freq_vocal{k}{kk}));
                curr_freq = [curr_freq; freq_vocal{k}{kk}(min_idx)];
                intens_freq = [intens_freq; intens_vocal{k}{kk}(min_idx)];
            end
        else
            curr_freq = [curr_freq; freq_vocal{k}{kk}];
            intens_freq = [intens_freq; intens_vocal{k}{kk}];
        end
    end
    curr_freq_total{k} = curr_freq;
end

if use_DL==1
    validationImages = imageDatastore([vpathname '/' vfilename '/All/']);
    [predictedLabels, scores] = classify(model_class_DL,validationImages);
    lista = [validationImages.Files, predictedLabels];
    
    AA2 = cellstr(lista);
    AA = array2table(AA2);
    ttt = model_class_DL.Layers(25).ClassNames;
    ttt2 = cellstr(num2str(2*ones(12,1)));
    s = strcat(ttt,ttt2);
    T2 = array2table(scores,'VariableNames',s');
    
    % AA2 = strsplit(cell2mat(AA2(1,1)),'\');
    for k=1:size(AA2,1)
        AA1 = strsplit(cell2mat(AA2(k,1)),{'/','\'});
        AA3 = str2double(AA1{end}(1:end-4));
        %     AA4 = str2double(AA1{end}(1:end-20));
        AA2(k,3) = num2cell(AA3);
    end
    
    T_classProb = [T2, AA, array2table(cell2mat(AA2(:,3)))];
    T_classProb.Properties.VariableNames{15} = 'NumVocal';
    T_classProb.Properties.VariableNames{14} = 'DL_out';
    T_classProb = sortrows(T_classProb,'NumVocal','ascend');
end

if use_DL==1
%     temp = [T_classProb];
%    writetable(T_classProb,[vfile '\' vfilename '_DL.xlsx'])
    writetable(T_classProb,fullfile(vfile, [vfilename '_DL.xlsx']))
end
save T_classProb T_classProb
% 
chevron_count = sum(strcmp(T_classProb.DL_out,'chevron'));
complex_count = sum(strcmp(T_classProb.DL_out,'complex'));
down_fm_count = sum(strcmp(T_classProb.DL_out,'down_fm'));
flat_count = sum(strcmp(T_classProb.DL_out,'flat'));
mult_steps_count = sum(strcmp(T_classProb.DL_out,'mult_steps'));
noise_count = sum(strcmp(T_classProb.DL_out,'noise_dist'));
rev_chevron_count = sum(strcmp(T_classProb.DL_out,'rev_chevron'));
short_count = sum(strcmp(T_classProb.DL_out,'short'));
step_down_count = sum(strcmp(T_classProb.DL_out,'step_down'));
step_up_count = sum(strcmp(T_classProb.DL_out,'step_up'));
two_steps_count = sum(strcmp(T_classProb.DL_out,'two_steps'));
up_fm_count = sum(strcmp(T_classProb.DL_out,'up_fm'));
noise_dist_count = sum(strcmp(T_classProb.DL_out,'noise_dist'));
harmonic_count = unique(harmonic_count);
noisy_vocal_count = unique(noisy_vocal_count);

disp(['[vocalmat][classifier]: total number of vocalizations: ' num2str(size(time_vocal,2)-noise_dist_count) ' vocalizations (' num2str(noise_dist_count) ' were noise)']);

for j=1:size(model_class_DL.Layers(25,1).ClassNames)
    eval(['disp([''' cell2mat(model_class_DL.Layers(25,1).ClassNames(j)) ': '' num2str('  cell2mat(model_class_DL.Layers(25,1).ClassNames(j)) '_count)])'])
end

% Fixed up to here.
if save_excel_file==1
    %     names2 = model_class_DL_RF.ClassNames;
    names = [{'Names_vocal'};{'Start_time'}; {'End_time'}; {'Inter_vocal_interval'}; {'Inter_real_vocal_interval'}; {'Duration'}; {'min_freq_main'}; {'max_freq_main'};{'mean_freq_main'};{'Bandwidth'};{'min_freq_total'};...
        {'max_freq_total'};{'mean_freq_total'};{'min_intens_total'};{'max_intens_total'}; {'corrected_max_intens_total'};{'Background_intens'};{'mean_intens_total'};{'Class'};{'Harmonic'};{'Noisy'}];
    tabela = zeros(size(T_classProb,1),size(names,1));
    tabela(:,1) = 1:size(T_classProb,1);
    tabela = num2cell(tabela);
    
    if ~isempty(noisy_vocal_count)
        tabela(noisy_vocal_count,21)= {1};
    end
    
    if ~isempty(harmonic_count)
        tabela(harmonic_count,20)= {1};
    end
    
    for i=1:size(time_vocal,2)
        time_start(i) = time_vocal{i}(1);
        time_end(i) = time_vocal{i}(end);
        if i>1
            time_interval(i) = time_start(i)-time_end(i-1);
        else
            time_interval(i) = NaN;
        end
        duration(i) = time_end(i)-time_start(i);
        if ~isempty(curr_freq_total{i}), min_freq_main(i) = min(curr_freq_total{i}); else min_freq_main(i) = NaN; end
        if ~isempty(curr_freq_total{i}), max_freq_main(i) = max(curr_freq_total{i}); else max_freq_main(i) = NaN; end
        mean_freq_main(i) = mean(curr_freq_total{i});
        min_freq_total(i) = min(tabela_all_points{i}(:,2));
        max_freq_total(i) = max(tabela_all_points{i}(:,2));
        mean_freq_total(i) = mean(tabela_all_points{i}(:,2));
        min_intens_total(i) = min(tabela_all_points{i}(:,3));
        max_intens_total(i) = max(tabela_all_points{i}(:,3));
        mean_intens_total(i) = mean(tabela_all_points{i}(:,3));
    end
    
    tabela(:,19) = T_classProb.DL_out;
    
    noise_idx = strcmp(tabela(:,18),'noise_dist');
    time_start_real = time_start; time_start_real(noise_idx) = NaN;
    time_end_real = time_end; time_end_real(noise_idx) = NaN;
    curr_time = NaN;
    for i=1:size(time_start_real,2)
        if ~isnan(time_start_real(i))
            time_interval_real(i) = time_start_real(i) - curr_time;
            curr_time = time_end_real(i);
        else
            time_interval_real(i) = NaN;
        end
    end
    
    median_stats = [ zeros(size(median_stats,1),1) median_stats, zeros(size(median_stats,1),1)];
    for k=1:size(time_start,2)
        median_stats(find(median_stats(:,2)==time_start(k)),end) = 1;
        median_stats(find(median_stats(:,2)==time_start(k)),1) = k;
    end
    
    median_stats(:,7) = median_stats(:,7)/0.9;
    median_stats = median_stats(median_stats(:,1)>0,:);
    
    
    tabela(:,2) = num2cell(time_start');
    tabela(:,3) = num2cell(time_end');
    tabela(:,4) = num2cell(time_interval');
    tabela(:,5) = num2cell(time_interval_real');
    tabela(:,6) = num2cell(duration');
    tabela(:,7) = num2cell(min_freq_main');
    tabela(:,8) = num2cell(max_freq_main');
    tabela(:,9) = num2cell(mean_freq_main');
    tabela(:,10) = num2cell(max_freq_main'-min_freq_main');
    tabela(:,11) = num2cell(min_freq_total');
    tabela(:,12) = num2cell(max_freq_total');
    tabela(:,13) = num2cell(mean_freq_total');
    tabela(:,14) = num2cell(min_intens_total');
    tabela(:,15) = num2cell(max_intens_total');
    corrected_max_intens_total = max_intens_total' - median_stats(:,7);
    tabela(:,16) = num2cell(corrected_max_intens_total);
    tabela(:,17) = num2cell(median_stats(:,7)');
    tabela(:,18) = num2cell(mean_intens_total');
    
    names = transpose(names);
    T = array2table(tabela);
    T.Properties.VariableNames = names;
    %     VM1_out.Properties.VariableNames{1} = 'VM1_out';
    if exist([vfilename '.xlsx'])>0
        delete([vfilename '.xlsx'])
    end
    
%    writetable(T,[vfile '\' vfilename '.xlsx'])
    writetable(T,fullfile(vfile, [vfilename '.xlsx']))
end

% Estimate number of bins given the bin size
aux = ~strcmp(T.Class,'noise_dist');
T_no_noise = T(aux,:);
if size(T_no_noise,1)>0
    num_of_bins = ceil(max(cell2mat(T_no_noise.Start_time))/bin_size);
    edges = 0:bin_size:num_of_bins*bin_size;
    [num_vocals_in_bin] = histcounts(cell2mat(T_no_noise.Start_time),edges);
    
    
    
    disp(['[vocalmat][classifier]: vocalizations per bin (not considering noise):'])
    for k=1:num_of_bins
        disp(['Bin_' num2str(k) '(' num2str(edges(k)) '-' num2str(edges(k+1)) 's): ' num2str(num_vocals_in_bin(k))])
    end
    
    if plot_stats_per_bin ==1
        
        %Show classes per bin
        for j=1:size(model_class_DL.Layers(25, 1).ClassNames  )
            aux = strcmp(T.Class,model_class_DL.Layers(25, 1).ClassNames (j));
            T_class = T(aux,:);
            [num_vocals_in_bin,~] = histcounts(cell2mat(T_class.Start_time),edges);
            disp(['[vocalmat][classifier]: vocalizations per bin for class ' cell2mat(model_class_DL.Layers(25, 1).ClassNames(j)) ' :'])
            for k=1:num_of_bins
                disp(['Bin_' num2str(k) '(' num2str(edges(k)) '-' num2str(edges(k+1)) 's): ' num2str(num_vocals_in_bin(k))])
            end
        end
        
    end
    
else
    disp('[vocalmat][classifier]: no real vocalizations detected in this file.')
end


