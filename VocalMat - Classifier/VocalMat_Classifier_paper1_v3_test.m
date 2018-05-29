%Jan 13th, 2017: Give as an option for the user to plot statics per bin if
%this is wanted... it's about time to stop making isolated versions.
%Nov 1st, 2016: Turn identified steps in vocalizations (ex: 2 steps, 3
%steps, etc).
%Oct 26th, 2016: As the hierarchical clustering method also exist in
%Matlab,I will replace R instructions for Matlab instructions.
%Oct 23rd, 2016: First steps to implement a hierarchical clustering method
%using R.
%Oct 22nd, 2016: Set the Classifier to run throughout all the the mat files
%classifying the detected vocalizations and use its output to correct the
%total number of real vocalizations.
% Aug 31th, 2016: This script intends to classify the vocalization in the
% eleven different categories we currently have described by Grimsley, Jasmine MS, Jessica JM Monaghan, and Jeffrey J. Wenstrup. "Development of social vocalizations in mice." PloS one 6.3 (2011): e17460.

%clc
%clear all
raiz = pwd;
% model_noise=load('model_noise.mat');
% model_noise=load('model_noise_randomTree3.mat')
% model_noise = model_noise.model_noise_randomTree3;
% model_class = load('Mdl_categorical_15&30_points_v16.mat')
% model_class_RF = load('Mdl_categorical_RF_Feb13b.mat')
% model_class_RF = model_class_RF.Mdl;
% model_class_DL = load('Mdl_categorical_DL_Feb13b.mat')
% model_class_DL = model_class_DL.netTransfer;
% model_class_DL_RF = load('Mdl_categorical_DL_RF_Feb13b.mat')
% model_class_DL_RF = model_class_DL_RF.Mdl;

% model_class_noise = load('/gpfs/ysm/project/ahf38/Antonio_VocalMat/Reference_CNN_detection/Mdl_categorical_DL_noise.mat');
model_class_noise = load('Mdl_categorical_DL_noise.mat')
model_class_noise = model_class_noise.netTransfer;

[vfilename,vpathname] = uigetfile({'*.mat'},'Select the output file')
cd(vpathname);
list = dir('*output*.mat');
%diary(['Summary_classifier' num2str(horzcat(fix(clock))) '.txt'])

%Setting up
p = mfilename('fullpath')
plot_stats_per_bin=1
save_plot_spectrograms=0 % PLots the spectograms with axes
save_histogram_per_animal=0
save_excel_file=1
save_plot_3d_info=0
axes_dots=1 % Show the dots overlapping the vocalization (segmentation)
size_spectrogram = [227 227]
use_DL = 1
bin_size = 300 %in seconds

% stepup_count_bin_total  = 0;
% stepdown_count_bin_total = 0 ;
% harmonic_count_bin_total  = 0;
% flat_count_bin_total  = 0;
% chevron_count_bin_total  = 0;
% revchevron_count_bin_total  = 0;
% downfm_count_bin_total  = 0;
% upfm_count_bin_total  = 0;
% complex_count_bin_total  = 0;
% noisy_vocal_count_bin_total  = 0;
% nonlinear_count_bin_total  = 0;
% short_count_bin_total  = 0;
% noise_count_bin_total  = 0;
% noise_dist_count_bin_total = 0;
% two_steps_count_bin_total  = 0;
% mult_steps_count_bin_total  = 0;

%for Name=1:size(list,1)
%vfilename = list(Name).name;
%vfilename = vfilename(1:end-4);
vfile = fullfile(vpathname,vfilename)


clearvars -except   noise_count_bin_total two_steps_count_bin_total mult_steps_count_bin_total model_noise plot_stats_per_bin save_plot_spectrograms list...
    raiz vfile vfilename vpathname stepup_count_bin_total stepdown_count_bin_total harmonic_count_bin_total flat_count_bin_total chevron_count_bin_total...
    noise_dist_count_bin_total revchevron_count_bin_total downfm_count_bin_total upfm_count_bin_total complex_count_bin_total noisy_vocal_count_bin_total...
    nonlinear_count_bin_total short_count_bin_total save_histogram_per_animal save_excel_file save_plot_3d_info axes_dots model_class_RF...
    model_class_DL size_spectrogram use_DL model_class_DL_RF bin_size model_class_noise

fprintf('\n')
disp(['Reading ' vfilename])
load(vfile);

%We are gonna get only 10 points (time stamps) to classify the vocalization
%Grimsley, Jasmine, Marie Gadziola, and Jeff James Wenstrup. "Automated classification of mouse pup isolation syllables: from cluster analysis to an Excel-based �mouse pup syllable classification calculator�."
%Frontiers in behavioral neuroscience 6 (2013): 89.
%     disp('Verify vocalizations for steps')

harmonic_count=[];
% flat_count=[];
% chevron_count=[];
% revchevron_count=[];
% downfm_count=[];
% upfm_count=[];
% complex_count=[];
% noisy_vocal_count=[];
% nonlinear_count = [];
% short_count = [];
% noise_count = [];
% noise_count_dist = [];
% corr_yy2_yy3 = [];
% corr_yy2_yy4 = [];
% max_prom = [];
% max_prom2 = [];
duration = [];
% noise_detected_clustering = zeros(length(time_vocal),1);

disp('Checking for empty cells')
time_vocal = time_vocal(~cellfun('isempty',time_vocal));
freq_vocal = freq_vocal(~cellfun('isempty',freq_vocal));
intens_vocal = intens_vocal(~cellfun('isempty',intens_vocal));

output=[];
cd(vpathname)
if ~exist(vfilename, 'dir')
    mkdir(vfilename)
end
cd(vfilename)
% if ~exist('Infos', 'dir')
%     mkdir('Info')
% end

disp('Running analysis!')

for k=1:size(time_vocal,2)

    harmonics = cell(1,size(time_vocal,2));
%     if k==210
%         k
%     end
    
    %Verify jump in frequency taking as base the closest frequency detected
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
%                     test_harmonic = sort(harmonic_candidate);
%                     test_harmonic = test_harmonic - circshift(test_harmonic ,[1,0]);
%                     test_harmonic = find(test_harmonic>1000);
%                     if size(test_harmonic,1)>1%3 %too many jumps in frequency... should be noise or noisy_vocal vocalization.
%                        
%                     else
                        current_freq = [current_freq; freq_vocal{k}{time_stamp+1}];
                        if size(harmonic_candidate,1)>10 % at least 10 points to say it was really an harmonic
                            harmonic_count = [harmonic_count;k];
                        end
%                     end
                    
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
    

    if ~isempty(current_freq)
        aux = current_freq - circshift(current_freq ,[1,0]);
        
        % eliminate outlier
        clear test_outlier; test_outlier = find(abs(aux(2:end))>=10000);
        clear t1; t1 = test_outlier - circshift(test_outlier ,[1,0]);
        if find(t1(2:end)>0 & t1(2:end)<3)
            if any(t1==1)
                t2 = test_outlier(find(t1(2:end)==1));
                for t3 = 1:size(t2,1)
                    current_freq(t2(t3)+[1 2])=NaN;
                end
                current_freq(test_outlier(find(t1(2:end)==1))+1)=NaN;
            end
            if any(t1==2)
                t2 = test_outlier(find(t1(2:end)==2));
                for t3 = 1:size(t2,1)
                    current_freq(t2(t3)+[1 2])=NaN;
                end
            end
            current_freq(isnan(current_freq))=[];
            aux = current_freq - circshift(current_freq ,[1,0]);
        end

        %         aux = aux(2:end);
        temp2 = find(aux(2:end)>=10000);
        if any(aux(2:end)>=10000) && any(size(aux,1)-temp2>5) %If the jump was at the end, check the size of this final portion to be considered as step
            
            if size(aux,1)-temp2(end)<=5 %not consider jump too close to the end of the vocalization
                temp2(end)=[];
            end
            if temp2(1)<=5 %not consider jump too close to the begin of the vocalization
                temp2(end)=[];
            end
            
        elseif ~isempty(temp2) && size(temp2,1)>0 && (size(aux,1)-temp2(end)<5) %Delete the final portion of the vocalization (probabily noise)
            current_freq(temp2+1:end)=[];
        end
        temp2 = find(aux(2:end)<=-10000);
        if any(aux(2:end)<=-10000) && any(size(aux,1)-temp2>5)
            if size(aux,1)-temp2(end)<=5
                temp2(end)=[];
            end
            if temp2(1)<=5 %not consider jump too close to the begin of the vocalization
                temp2(end)=[];
            end
        elseif ~isempty(temp2) && size(temp2,1)>0 && (size(aux,1)-temp2(end)<5) %Delete the final portion of the vocalization (probabily noise)
            current_freq(temp2+1:end)=[];
        end
        
        current_freq_total{k}=current_freq;
        
    else
        current_freq_total{k}=current_freq;
    end
    
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
    
    cd(vpathname)
    if ~exist(vfilename, 'dir')
        mkdir(vfilename)
    end
    cd(vfilename)
    
    if save_plot_spectrograms==1
        if (~exist('All_axes','dir'))
            mkdir('All_axes')
        else
            rmdir('All_axes', 's')
            mkdir('All_axes')
        end
    end

    if ~exist('All','dir')
        mkdir('All')
    else
        rmdir('All', 's')
        mkdir('All')
    end

    for id_vocal = 1:size(time_vocal,2)
        dx = 0.22;
        T_min_max = [-dx/2 dx/2]+[time_vocal{id_vocal}(ceil(size(time_vocal{id_vocal},2)/2)) time_vocal{id_vocal}(ceil(size(time_vocal{id_vocal},2)/2))];
        [T_min T_min] = min(abs(T_orig - T_min_max(1)));
        [T_max T_max] = min(abs(T_orig - T_min_max(2)));
        
        if save_plot_spectrograms==1
            clf('reset')
            hold on
            surf(T_orig(T_min:T_max),F_orig,A_total(:,T_min:T_max),'edgecolor','none')
            axis tight; view(0,90);
            colormap(gray);
            xlabel('Time (s)'); ylabel('Freq (Hz)')
            
            if axes_dots==1
                for time_stamp = 1:size(time_vocal{id_vocal},2)
                    scatter(time_vocal{id_vocal}(time_stamp)*ones(size(freq_vocal{id_vocal}{time_stamp}')),freq_vocal{id_vocal}{time_stamp}',[],'b')
                end
            end
            saveas(gcf,[vpathname '/' vfilename '/All_axes/' num2str(id_vocal)  '.png'])
            hold off
        end
        img = imresize(flipud(mat2gray(A_total(:,T_min:T_max))),size_spectrogram);
        img = cat(3, img, img, img);
        imwrite(img,[vpathname '/' vfilename '/All/' num2str(id_vocal)  '.png'])
        
    end
    
end

close all

if use_DL==1
    validationImages = imageDatastore([vpathname '/' vfilename '/All/']);
    [predictedLabels, scores] = classify(model_class_noise,validationImages);
    lista = [validationImages.Files, predictedLabels];
    
    AA2 = cellstr(lista);
    AA = array2table(AA2);
    ttt = model_class_noise.Layers(25).ClassNames;
%     ttt2 = cellstr(num2str(2*ones(size(ttt,1),1)));
    s = strcat(ttt);
    T2 = array2table(scores,'VariableNames',s');
    
    % AA2 = strsplit(cell2mat(AA2(1,1)),'\');
    for k=1:size(AA2,1)
        AA1 = strsplit(cell2mat(AA2(k,1)),{'/','\'});
        AA3 = str2double(AA1{end}(1:end-4));
        %     AA4 = str2double(AA1{end}(1:end-20));
        AA2(k,3) = num2cell(AA3);
    end
    
    B = [T2, AA, array2table(cell2mat(AA2(:,3)))];
    B.Properties.VariableNames{5} = 'NumVocal';
    B.Properties.VariableNames{4} = 'DL_out';
    B = sortrows(B,'NumVocal','ascend');
end


% temp = table_total_output(:,[1:2 239:end]);
if use_DL==1
    temp = [B];
    if exist([vfilename '_DL.xlsx'])>0
        delete([vfilename '_DL.xlsx'])
    end
    writetable(temp,[vfilename '_DL.xlsx'])
end

noise_dist_count = sum(strcmp(B.DL_out,'noise'));
harmonic_count = unique(harmonic_count);

disp(['Total number of vocalizations: ' num2str(size(time_vocal,2)-noise_dist_count) ' vocalizations (' num2str(noise_dist_count) ' were noise)']);

if save_excel_file==1
    names = [{'Names_vocal'};{'Start_time'}; {'End_time'}; {'Inter_vocal_interval'}; {'Inter_real_vocal_interval'}; {'Duration'}; {'min_freq_main'}; {'max_freq_main'};{'mean_freq_main'};{'min_freq_total'};...
        {'max_freq_total'};{'mean_freq_total'};{'min_intens_total'};{'max_intens_total'}; {'mean_intens_total'};{'Class'};{'Harmonic'}];
    tabela = zeros(size(B,1),size(names,1));
    tabela(:,1) = 1:size(B,1);
    tabela = num2cell(tabela);
     
    if ~isempty(harmonic_count)
        tabela(harmonic_count,17)= {1};
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
        if ~isempty(current_freq_total{i}), min_freq_main(i) = min(current_freq_total{i}); else min_freq_main(i) = NaN; end
        if ~isempty(current_freq_total{i}), max_freq_main(i) = max(current_freq_total{i}); else max_freq_main(i) = NaN; end
        mean_freq_main(i) = mean(current_freq_total{i});
        min_freq_total(i) = min(tabela_all_points{i}(:,2));
        max_freq_total(i) = max(tabela_all_points{i}(:,2));
        mean_freq_total(i) = mean(tabela_all_points{i}(:,2));
        min_intens_total(i) = min(tabela_all_points{i}(:,3));
        max_intens_total(i) = max(tabela_all_points{i}(:,3));
        mean_intens_total(i) = mean(tabela_all_points{i}(:,3));
    end
    
    tabela(:,16) = B.DL_out;
    
    noise_idx = strcmp(tabela(:,16),'noise');
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
    
    tabela(:,2) = num2cell(time_start');
    tabela(:,3) = num2cell(time_end');
    tabela(:,4) = num2cell(time_interval');
    tabela(:,5) = num2cell(time_interval_real');
    tabela(:,6) = num2cell(duration');
    tabela(:,7) = num2cell(min_freq_main');
    tabela(:,8) = num2cell(max_freq_main');
    tabela(:,9) = num2cell(mean_freq_main');
    tabela(:,10) = num2cell(min_freq_total');
    tabela(:,11) = num2cell(max_freq_total');
    tabela(:,12) = num2cell(mean_freq_total');
    tabela(:,13) = num2cell(min_intens_total');
    tabela(:,14) = num2cell(max_intens_total');
    tabela(:,15) = num2cell(mean_intens_total');
    
    names = transpose(names);
    T = array2table(tabela);
    T.Properties.VariableNames = names;
     if exist([vfilename '.xlsx'])>0
        delete([vfilename '.xlsx'])
    end
    writetable(T,[vfilename '.xlsx'])
end

 % Estimate number of bins given the bin size
    aux = ~strcmp(T.Class,'noise');
    T_no_noise = T(aux,:);
    num_of_bins = ceil(max(cell2mat(T_no_noise.Start_time))/bin_size);
    edges = 0:bin_size:num_of_bins*bin_size;
    [num_vocals_in_bin] = histcounts(cell2mat(T_no_noise.Start_time),edges);
    
    disp(['Vocalizations per bin (not considering noise):'])
    for k=1:num_of_bins
        disp(['Bin_' num2str(k) '(' num2str(edges(k)) '-' num2str(edges(k+1)) 's): ' num2str(num_vocals_in_bin(k))])
    end
    
if plot_stats_per_bin ==1
    
    %Show classes per bin
    for j=1:size(ttt,1)
        aux = strcmp(T.Class,ttt(j));
        T_class = T(aux,:);
        [num_vocals_in_bin,~] = histcounts(cell2mat(T_class.Start_time),edges);
        disp(['Vocalizations per bin for class ' cell2mat(ttt(j)) ' :'])
        for k=1:num_of_bins
            disp(['Bin_' num2str(k) '(' num2str(edges(k)) '-' num2str(edges(k+1)) 's): ' num2str(num_vocals_in_bin(k))])
        end
    end
    
end


