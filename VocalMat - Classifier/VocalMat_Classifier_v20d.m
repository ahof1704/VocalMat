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
model_noise=load('model_noise_randomTree3.mat')
model_noise = model_noise.model_noise_randomTree3;
% model_class = load('Mdl_categorical_15&30_points_v16.mat')
model_class_RF = load('Mdl_categorical_RF_Feb13b.mat')
model_class_RF = model_class_RF.Mdl;
model_class_DL = load('/gpfs/ysm/project/ahf38/Antonio_VocalMat/Reference_CNN/Mdl_categorical_DL.mat')
% model_class_DL = load('Mdl_categorical_DL_Feb13b.mat')
model_class_DL = model_class_DL.netTransfer;
model_class_DL_RF = load('Mdl_categorical_DL_RF_Feb13b.mat')
model_class_DL_RF = model_class_DL_RF.Mdl;

% [vfilename,vpathname] = uigetfile({'*.mat'},'Select the output file')
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
%flat_count_bin_total  = 0;
%chevron_count_bin_total  = 0;
%revchevron_count_bin_total  = 0;
%downfm_count_bin_total  = 0;
%upfm_count_bin_total  = 0;
%complex_count_bin_total  = 0;
%noisy_vocal_count_bin_total  = 0;
%nonlinear_count_bin_total  = 0;
%short_count_bin_total  = 0;
%noise_count_bin_total  = 0;
%noise_dist_count_bin_total = 0;
%two_steps_count_bin_total  = 0;
%mult_steps_count_bin_total  = 0;

%for Name=1:size(list,1)
%vfilename = list(Name).name;
%vfilename = vfilename(1:end-4);
vfile = fullfile(vpathname,vfilename)


clearvars -except   noise_count_bin_total two_steps_count_bin_total mult_steps_count_bin_total model_noise plot_stats_per_bin save_plot_spectrograms list...
    raiz vfile vfilename vpathname stepup_count_bin_total stepdown_count_bin_total harmonic_count_bin_total flat_count_bin_total chevron_count_bin_total...
    noise_dist_count_bin_total revchevron_count_bin_total downfm_count_bin_total upfm_count_bin_total complex_count_bin_total noisy_vocal_count_bin_total...
    nonlinear_count_bin_total short_count_bin_total save_histogram_per_animal save_excel_file save_plot_3d_info axes_dots model_class_RF...
    model_class_DL size_spectrogram use_DL model_class_DL_RF bin_size

fprintf('\n')
disp(['Reading ' vfilename])
load(vfile);

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
noise_detected_clustering = zeros(length(time_vocal),1);

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
%if ~exist('Infos', 'dir')
%    mkdir('Info')
%end

disp('Running analysis!')

for k=1:size(time_vocal,2)
    vocal_classified{k}.step_up = [];
    vocal_classified{k}.step_down = [];
    vocal_classified{k}.harmonic = [];
    vocal_classified{k}.flat = [];
    vocal_classified{k}.chevron = [];
    vocal_classified{k}.rev_chevron = [];
    vocal_classified{k}.down_fm = [];
    vocal_classified{k}.up_fm = [];
    vocal_classified{k}.complex = [];
    vocal_classified{k}.noisy_vocal = [];
    vocal_classified{k}.non_linear = [];
    vocal_classified{k}.short =  [];
    %     vocal_classified{k}.noise = [];
    vocal_classified{k}.harmonic_size = [];
    vocal_classified{k}.noise_dist = [];
    harmonics = cell(1,size(time_vocal,2));
    
%     if k==61
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
                                vocal_classified{k}.harmonic = [vocal_classified{k}.harmonic; start_harmonic];
                                vocal_classified{k}.harmonic_size = [vocal_classified{k}.harmonic_size; size(harmonic_candidate,1)];
                                %                                 harmonics{k} = [harmonics{k}; harmonic_candidate];
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
                    %test_harmonic = sort(harmonic_candidate);
                    %test_harmonic = test_harmonic - circshift(test_harmonic ,[1,0]);
                    %test_harmonic = find(test_harmonic>1000);
                    %if size(test_harmonic,1)>1%3 %too many jumps in frequency... should be noise or noisy_vocal vocalization.
                    %    vocal_classified{k}.noisy_vocal = time_vocal{k}(1);
                    %    noisy_vocal_count = [noisy_vocal_count;k];
                    %else
                        current_freq = [current_freq; freq_vocal{k}{time_stamp+1}];
                        if size(harmonic_candidate,1)>10 % at least 10 points to say it was really an harmonic
                            %                                 disp(['Vocalization ' num2str(k) ' had an harmonic in t = ' num2str(start_harmonic) 's']);
                            %vocal_classified{k}.harmonic = [vocal_classified{k}.harmonic; start_harmonic];
                            %vocal_classified{k}.harmonic_size = [vocal_classified{k}.harmonic_size; size(harmonic_candidate,1)];
                            %                             harmonics{k} = harmonic_candidate;
                            harmonic_count = [harmonic_count;k];
                        end
                    %end
                    
                    harmonic_candidate = [];
                end
                
            else
                aux = freq_vocal{k}{time_stamp+1} - freq_vocal{k}{time_stamp};
                %                     current_freq = [current_freq; freq_vocal{k}{time_stamp+1}]; Testing
                if skip_current==0
                    current_freq = [current_freq; freq_vocal{k}{time_stamp}];
                end
                skip_current = 0;
                %                     if (aux>=10000)
                % %                         current_freq = freq_vocal{k}{time_stamp+1};
                %                         idx_stepdown_time = time_vocal{k}(time_stamp);
                %                         disp(['Vocalization ' num2str(k) ' had a step up in t = ' num2str(idx_stepdown_time)]);
                %                         vocal_classified{k}.step_up = [vocal_classified{k}.step_up; idx_stepdown_time];
                %                         stepup_count = stepup_count+1;
                %                     elseif (aux<=(-10000))
                % %                         current_freq = freq_vocal{k}{time_stamp+1};
                %                         idx_stepup_time = time_vocal{k}(time_stamp);
                %                         disp(['Vocalization ' num2str(k) ' had a step down in t = ' num2str(idx_stepup_time)]);
                %                         vocal_classified{k}.step_down = [vocal_classified{k}.step_down; idx_stepup_time];
                %                         stepdown_count = stepdown_count+1;
                %                     end
            end
        end
        
        %        if any(aux > 5000 || aux <-5000) %It's considered a step only if there is a jump higher than 5kHz
        %            %Stepped up or down?
        %            if aux > 5000
        %                idx_stepdown_time = time_vocal{k}(time_stamp);
        %                disp(['Vocalization ' num2str(k) ' had a step down in t=' num2str(idx_stepdown_time)]);
        %            else
        %                idx_stepup_time = time_vocal{k}(time_stamp);
        %                disp(['Vocalization ' num2str(k) ' had a step up in t=' num2str(idx_stepup_time)']);
        %            end
        %
        %        end
    end
    
    
    
    %    time_stamps = round(linspace(1,size(time_vocal{k},2),10));
    %    for time_stamp = 1:time_stamps
    %         if size(freq_vocal{k}{time_stamp},1)>1
    %
    %         else %Apparently there is no harmonic
    %             temp = (freq_vocal{k}{time_stamp} - circshift(freq_vocal{k}{time_stamp} ,[1,0]));
    %         end
    %    end
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
            %             disp(['Vocalization ' num2str(k) ' had a step up in t = ' num2str(time_vocal{k}(find(aux(2:end)>5000)+2)) 's']);
            if size(aux,1)-temp2(end)<=5 %not consider jump too close to the end of the vocalization
                temp2(end)=[];
            end
            if temp2(1)<=5 %not consider jump too close to the begin of the vocalization
                temp2(end)=[];
            end
            if ~isempty(temp2)
                vocal_classified{k}.step_up = [vocal_classified{k}.step_up; time_vocal{k}(temp2)'];
                stepup_count = [stepup_count;k];
            end
        elseif ~isempty(temp2) && size(temp2,1)>0 && (size(aux,1)-temp2(end)<5) %Delete the final portion of the vocalization (probabily noise)
            current_freq(temp2+1:end)=[];
        end
        temp2 = find(aux(2:end)<=-10000);
        if any(aux(2:end)<=-10000) && any(size(aux,1)-temp2>5)
            %             disp(['Vocalization ' num2str(k) ' had a step down in t = ' num2str(time_vocal{k}(find(aux(2:end)<-5000)+2)) 's']);
            if size(aux,1)-temp2(end)<=5
                temp2(end)=[];
            end
            if temp2(1)<=5 %not consider jump too close to the begin of the vocalization
                temp2(end)=[];
            end
            if ~isempty(temp2)
                vocal_classified{k}.step_down = [vocal_classified{k}.step_down; time_vocal{k}(temp2')'];
                stepdown_count = [stepdown_count;k];
            end
        elseif ~isempty(temp2) && size(temp2,1)>0 && (size(aux,1)-temp2(end)<5) %Delete the final portion of the vocalization (probabily noise)
            current_freq(temp2+1:end)=[];
        end
        
        %Eliminate too short steps.
        for lin = 1:size(vocal_classified{k}.step_up,1)
            for lin2 = 1:size(vocal_classified{k}.step_down,1)
                if abs(vocal_classified{k}.step_up(lin) - vocal_classified{k}.step_down(lin2)) < 0.003 %at least 3ms
                    vocal_classified{k}.step_up(lin) = -100;
                    vocal_classified{k}.step_down(lin2) = -100;
                end
            end
        end
        
        vocal_classified{k}.step_up(vocal_classified{k}.step_up==-100) = []; if size(vocal_classified{k}.step_up,2)<1;  vocal_classified{k}.step_up = []; end
        vocal_classified{k}.step_down(vocal_classified{k}.step_down==-100) = []; if size(vocal_classified{k}.step_down,2)<1;  vocal_classified{k}.step_down = []; end
        
        if (isempty(cell2mat(struct2cell(vocal_classified{k}))) || ~isempty(vocal_classified{k}.harmonic)) && size(time_vocal{k},2)<40 %It means there was no step up, down or harmonic
            if max(current_freq)-min(current_freq) <= 5800 % flat, 5.8kHz because I delete the begin and end points to avoid error of segmentation
                if time_vocal{k}(end) - time_vocal{k}(1) < 0.005
                    vocal_classified{k}.short =  time_vocal{k}(1);
                    short_count = [short_count;k];
                else
                    if (time_vocal{k}(2)-time_vocal{k}(1))*size(current_freq,1)<0.005 %6.5ms
                        %                         if ~isempty(vocal_classified{k}.harmonic) && max(vocal_classified{k}.harmonic_size)<15
                        %                         vocal_classified{k}.noise = time_vocal{k}(1);
                        noise_count = [noise_count;k];
                        %                         end
                    else
                        vocal_classified{k}.flat =  time_vocal{k}(1);
                        flat_count = [flat_count;k];
                    end
                end
            else
                time_stamps = round(linspace(1,size(current_freq',2),10));
                aux = current_freq;
                aux = aux-circshift(aux ,[1,0]);
                if (max(current_freq)-current_freq(1)> 5800 && max(current_freq)-current_freq(end)> 5800) %Chevron
                    [max_local max_local] = max(current_freq);
                    aux2 = aux(2:max_local);
                    aux3 = aux(max_local:end);
                    if sum(sign(aux2)>0)/size(aux2,1)>=0.7 && sum(sign(aux3)<0)/size(aux3,1)>=0.7 && mean(diff(current_freq(2:max_local)))/size(current_freq(2:max_local),1)>3 && mean(diff(current_freq(max_local:end)))/size(current_freq(max_local:end),1)<-3%The "U" shape is verified
                        vocal_classified{k}.chevron = time_vocal{k}(1);
                        chevron_count = [chevron_count;k];
                    end
                elseif (current_freq(1) - min(current_freq)> 5800 && current_freq(end) - min(current_freq)> 5800)
                    [min_local min_local] = min(current_freq);
                    aux2 = aux(2:min_local);
                    aux3 = aux(min_local:end);
                    if sum(sign(aux2)<0)/size(aux2,1)>0.7 && sum(sign(aux3)>0)/size(aux3,1)>0.7 %The inverted "U" shape is verified
                        vocal_classified{k}.rev_chevron = time_vocal{k}(1);
                        revchevron_count = [revchevron_count;k];
                    end
                elseif (abs(current_freq(end) - current_freq(1))> 5800) && sum(sign(aux)<0)/size(current_freq,1)>0.7 %Down FM
                    vocal_classified{k}.down_fm = time_vocal{k}(1);
                    downfm_count = [downfm_count;k];
                elseif (abs(current_freq(end) - current_freq(1))> 5800) && sum(sign(aux)>0)/size(current_freq,1)>0.7 %Up FM
                    vocal_classified{k}.up_fm = time_vocal{k}(1);
                    upfm_count = [upfm_count;k];
                end
            end
            if isempty(cell2mat(struct2cell(vocal_classified{k}))) %If it is still empty, has to be complex
                vocal_classified{k}.complex = time_vocal{k}(1);
                complex_count = [complex_count;k];
            end
        end
        
        if (isempty(cell2mat(struct2cell(vocal_classified{k}))) || ~isempty(vocal_classified{k}.harmonic)) %It means there was no step up, down or harmonic
            if max(current_freq)-min(current_freq) <= 5800 % flat
                if time_vocal{k}(end) - time_vocal{k}(1) < 0.005
                    vocal_classified{k}.short =  time_vocal{k}(1);
                    short_count = [short_count;k];
                else
                    if (time_vocal{k}(2)-time_vocal{k}(1))*size(current_freq,1)<0.005 %6.5ms
                        %                         if ~isempty(vocal_classified{k}.harmonic) && max(vocal_classified{k}.harmonic_size)<15
                        vocal_classified{k}.noise = time_vocal{k}(1);
                        noise_count = [noise_count;k];
                        %                         end
                    else
                        vocal_classified{k}.flat =  time_vocal{k}(1);
                        flat_count = [flat_count;k];
                    end
                end
            else
                time_stamps = round(linspace(1,size(current_freq',2),10));
                aux = current_freq;
                aux = aux-circshift(aux ,[1,0]);
                if (max(current_freq)-current_freq(1)> 5800 && max(current_freq)-current_freq(end)> 5800) %Chevron
                    [max_local max_local] = max(current_freq);
                    aux2 = aux(2:max_local);
                    aux3 = aux(max_local:end);
                    if sum(sign(aux2)>0)/size(aux2,1)>=0.7 && sum(sign(aux3)<0)/size(aux3,1)>=0.7 && mean(diff(current_freq(2:max_local)))/size(current_freq(2:max_local),1)>3 && mean(diff(current_freq(max_local:end)))/size(current_freq(max_local:end),1)<-3%The "U" shape is verified
                        vocal_classified{k}.chevron = time_vocal{k}(1);
                        chevron_count = [chevron_count;k];
                    end
                elseif (current_freq(1) - min(current_freq)> 5800 && current_freq(end) - min(current_freq)> 5800)
                    [min_local min_local] = min(current_freq);
                    aux2 = aux(2:min_local);
                    aux3 = aux(min_local:end);
                    if sum(sign(aux2)<0)/size(aux2,1)>=0.7 && sum(sign(aux3)>0)/size(aux3,1)>=0.7 %The inverted "U" shape is verified
                        vocal_classified{k}.rev_chevron = time_vocal{k}(1);
                        revchevron_count = [revchevron_count;k];
                    end
                elseif (abs(current_freq(end) - current_freq(1))> 5800) && sum(sign(aux)<0)/size(current_freq,1)>0.7 %Down FM
                    vocal_classified{k}.down_fm = time_vocal{k}(1);
                    downfm_count = [downfm_count;k];
                elseif (abs(current_freq(end) - current_freq(1))> 5800) && sum(sign(aux)>0)/size(current_freq,1)>0.7 %Up FM
                    vocal_classified{k}.up_fm = time_vocal{k}(1);
                    upfm_count = [upfm_count;k];
                end
                %             end
                check_if_only_harmonic = struct2cell(vocal_classified{k}); check_if_only_harmonic([3 13])=[];
                if isempty(cell2mat(check_if_only_harmonic))  %If it is still empty, has to be complex
                    vocal_classified{k}.complex = time_vocal{k}(1);
                    complex_count = [complex_count;k];
                end
            end
        end
        current_freq_total{k}=current_freq;
        
        
    else
        vocal_classified{k}.noise_dist = time_vocal{k}(1);
        noise_count_dist = [noise_count_dist;k];
        current_freq_total{k}=current_freq;
    end
    %Extra filtering by removing the points with intensity below 5% of the average
    tabela = [];
    %         for jj = 207% 1:size(time_vocal,2)
    for kk = 1:size(time_vocal{k},2)
        for ll = 1:size(freq_vocal{k}{kk},1)
            tabela = [tabela; time_vocal{k}(kk) freq_vocal{k}{kk}(ll) intens_vocal{k}{kk}(ll)];
        end
    end
    tabela_all_points{k} = tabela;
    %         end
    
    tamanho = size(tabela,1);
    aux3 = tabela(:,2) - circshift(tabela(:,2),[1,0]);
    aux3 = [sum(abs(aux3)>1000), tamanho];
    [f,xi]=ksdensity(tabela(:,2),F_orig,'width',500);
    [pks,locs]=findpeaks(f);
    
    % Noise-opinion #2: Clustering points
    if aux3(1)/aux3(2)>=0.75
        %       If number of clusters  > 2 * size_fields, then is noisy vocal
        check_clustering = [tabela(:,1) tabela(:,2)/(10^4)];
        Y = pdist(check_clustering);
        Z = linkage(Y,'single');
        I = inconsistent(Z,4);
        TT = cluster(Z,'cutoff',2.3,'depth',4); %2.3 is the best! Try also TT = cluster(Z,'cutoff',3.1,'depth',5);
        size_fields = size(vocal_classified{k}.step_up,1)+size(vocal_classified{k}.step_down,1)+size(vocal_classified{k}.harmonic,1)+size(vocal_classified{k}.flat,1)+size(vocal_classified{k}.chevron,1)+size(vocal_classified{k}.rev_chevron,1)+size(vocal_classified{k}.down_fm,1)+size(vocal_classified{k}.up_fm,1)+size(vocal_classified{k}.complex,1)+size(vocal_classified{k}.short,1);
        if size(pks,2)>1 && max(TT)>2*size_fields && size_fields >= size(pks,2) && size_fields<size(pks,2)+floor(tamanho/30) && sum(vocal_classified{k}.harmonic_size)/size(time_vocal{k},2)<0.4
            aux5 = 2; %'noisy_vocal vocal';
            if isempty(vocal_classified{k}.noisy_vocal)
                vocal_classified{k}.noisy_vocal = time_vocal{k}(1);
                noisy_vocal_count = [noisy_vocal_count;k];
            end
        else
            if ~isempty(vocal_classified{k}.harmonic_size) && max(vocal_classified{k}.harmonic_size)>=15% && max(vocal_classified{k}.harmonic_size)/size(time_vocal{k},2)>0.5
                %
            else
                %                     %                     [pks,locs]=findpeaks(yy2);
                %                     %                     % evaluate relation to the peaks
                %                     %                     [max_peak1 max_peak1]=max(pks);
                %                     %                     max_peak.peak = max(pks); pks(max_peak1)=[];
                %                     %                     max_peak2.peak = max(pks);
                %                     try
                %                         if isempty(pks) || (mean(pks)/mean(valleys) <= 2.2 && max(proms)<0.55 ) || (max_below_50k>0.8 && max(proms)<0.55) %I'm setting this constant myself... find dynamic way to get it.
                aux5 = 1; %'Noise';
                %                 vocal_classified{k}.noise = time_vocal{k}(1);
                noise_count = [noise_count;k];
                noise_detected_clustering(k) = 1;
                %                         end
                %
                %                     catch
                %                         if isempty(pks) ||  (max_below_50k>0.8 && max(proms)<0.55)  %I'm setting this constant myself... find dynamic way to get it.
                %                             aux5 = 1; %'Noise';
                %                             vocal_classified{k}.noise = time_vocal{k}(1);
                %                             noise_count = [noise_count;k];
                %                         end
                %                     end
            end
        end
    elseif aux3(1)/aux3(2)<0.75 && aux3(1)/aux3(2)>0.5
        check_clustering = [tabela(:,1) tabela(:,2)/(10^4)];
        Y = pdist(check_clustering);
        Z = linkage(Y,'single');
        I = inconsistent(Z,4);
        TT = cluster(Z,'cutoff',2.3,'depth',4);
        size_fields = size(vocal_classified{k}.step_up,1)+size(vocal_classified{k}.step_down,1)+size(vocal_classified{k}.harmonic,1)+size(vocal_classified{k}.flat,1)+size(vocal_classified{k}.chevron,1)+size(vocal_classified{k}.rev_chevron,1)+size(vocal_classified{k}.down_fm,1)+size(vocal_classified{k}.up_fm,1)+size(vocal_classified{k}.complex,1)+size(vocal_classified{k}.short,1);
        tabela = tabela(tabela(:,3)>mean(tabela(:,3))*(1-0.05),:);
        tamanho2 = size(tabela,1);
        aux4 = tabela(:,2) - circshift(tabela(:,2),[1,0]);
        aux4 = [sum(abs(aux4)>1000), tamanho2];
        if aux4(1)/aux4(2)<0.5
            aux5 = 2; %'noisy_vocal vocal';
            if max(TT)>2*size_fields && sum(vocal_classified{k}.harmonic_size)/size(time_vocal{k},2)<0.4 && isempty(vocal_classified{k}.noisy_vocal)
                vocal_classified{k}.noisy_vocal = time_vocal{k}(1);
                noisy_vocal_count = [noisy_vocal_count;k];
            end
        elseif aux4(1)/aux4(2)>=0.7
            size_fields = size(vocal_classified{k}.step_up,1)+size(vocal_classified{k}.step_down,1)+size(vocal_classified{k}.harmonic,1)+size(vocal_classified{k}.flat,1)+size(vocal_classified{k}.chevron,1)+size(vocal_classified{k}.rev_chevron,1)+size(vocal_classified{k}.down_fm,1)+size(vocal_classified{k}.up_fm,1)+size(vocal_classified{k}.complex,1)+size(vocal_classified{k}.short,1);
            if size(pks,2)>1 && size_fields >= size(pks,2) && size_fields<size(pks,2)+floor(tamanho/30)
                aux5 = 0; %'noisy_vocal vocal';
            else
                if ~isempty(vocal_classified{k}.harmonic_size) && max(vocal_classified{k}.harmonic_size)>=15 % && max(vocal_classified{k}.	)/size(time_vocal{k},2)>0.5
                    %
                else
                    %                         %                         [pks,locs]=findpeaks(yy2);
                    %                         %                         % evaluate relation to the peaks
                    %                         %                         [max_peak1 max_peak1]=max(pks);
                    %                         %                         max_peak.peak = max(pks); pks(max_peak1)=[];
                    %                         %                         max_peak2.peak = max(pks);
                    %
                    %                         if mean(pks)/mean(valleys) <= 2.2 %I'm setting this constant myself... find dynamic way to get it.
                    aux5 = 1; %'Noise';
                    %                     vocal_classified{k}.noise = time_vocal{k}(1);
                    noise_count = [noise_count;k];
                    noise_detected_clustering(k) = 1;
                    %                         end
                end
            end
        else
            if ~isempty(vocal_classified{k}.harmonic_size) && max(vocal_classified{k}.harmonic_size)>=15% && max(vocal_classified{k}.harmonic_size)/size(time_vocal{k},2)>0.5
                
            else
                %                     if mean(pks)/mean(valleys) <= 2.2 %I'm setting this constant myself... find dynamic way to get it.
                aux5 = 1; %'Noise';
                %                 vocal_classified{k}.noise = time_vocal{k}(1);
                noise_count = [noise_count;k];
                noise_detected_clustering(k) = 1;
                %                     end
            end
        end
    else
        aux5 = 0; %'';
    end
    
    %         noise_detected_clustering(k)=
    
    % Noise-opinion #3: Median of distance between points
    distancia = [];
    for ddd=1:size(tabela,1)-1
        distancia = [distancia ; sqrt(sum((tabela(ddd+1,1:2)-tabela(ddd,1:2)).^2))];
    end
    
    median_dist = median(distancia);
    mean_dist = mean(distancia);
    
    T_min_max = [time_vocal{k}(1) time_vocal{k}(end)];
    [T_min T_min] = min(abs(T_orig - T_min_max(1)));
    [T_max T_max] = min(abs(T_orig - T_min_max(2)));
    
    test2 = max(A_total(:,T_min:T_max),[],2);
    test3 = sqrt(test2.^2)/max(abs(test2));
    test3 = 1-test3;
    test3 = test3*1/max(test3);
    if save_plot_3d_info==1
        clf
        subplot(2,2,[1,2]), surf(T_orig(T_min:T_max),F_orig,A_total(:,T_min:T_max),'edgecolor','none'),title(k)
        hold on
    end
    
    if max(test2)==0 %it is missing data in this windown (don't know what it happens, but happened once already...)
        vocal_classified{k}.noise_dist = time_vocal{k}(1);
        noise_count_dist = [noise_count_dist;k];
    else
        yy2 = smooth(F_orig,test3,0.1,'rloess');
        [valleys,locs_valleys]=findpeaks(-yy2,'MinPeakProminence',0.3); valleys = valleys*(-1);
        if save_plot_3d_info
            subplot(2,2,3),findpeaks(yy2,F_orig ,'MinPeakProminence',0.3,'Annotate','extent')
        end
        [pks_orig,locs,~,proms]=findpeaks(yy2,'MinPeakProminence',0.3); %The peak has to present local height of at least 0.3 to be considered a peak
        % evaluate relation to the peaks
        pks = pks_orig;
        [max_peak1 max_peak1]=max(pks);
        max_peak.peak = max(pks); pks(max_peak1)=[];
        max_peak2.peak = max(pks);
        pos_max_below_50k = max(find(F_orig<50e3));
        max_below_50k = max(yy2(1:pos_max_below_50k));
        %         max_prom = max(proms);
        
        if save_plot_3d_info==1
            try
                title(['pk1/pk2= ' num2str(max_peak.peak/ max_peak2.peak) ' ;  mean(pks)/mean(valleys):'  num2str(mean(pks)/mean(valleys)) '; maxprom= ' num2str(max(proms)) '; mediandist= ' num2str(median_dist) '; meandist= ' num2str(mean_dist)])
            catch
                title(['pk1= ' num2str(max_peak.peak) ' ;  mean(pks)/mean(valleys):'  num2str(mean(pks)/mean(valleys)) '; maxprom= ' num2str(max(proms)) '; mediandist= ' num2str(median_dist) '; meandist= ' num2str(mean_dist)])
            end
            ylim([0 1])
            xlim([min(F_orig) max(F_orig)])
            hold off
        end
        
        %         tabela = [tabela intens_vocal{k}];
        
        if save_plot_3d_info==1
            %             yy5 = smooth(F_orig,tabela(:,2),0.1,'rloess');
            subplot(2,2,4), plot(xi,f/max(f)), title(k)
            %             subplot(2,2,4),plot(F_orig,test3/max(test3))
            hold on
        end
        %             subplot(2,2,4),plot(F_orig,yy5,'--g')
        yy3 = (f/max(f)).*yy2;
        yy4 = (f/max(f));
        %             yy5 = smooth(F_orig,tabela(:,2),0.1,'rloess');
        if save_plot_3d_info==1
            subplot(2,2,4),plot(F_orig,yy3,'--r')
            ylim([0 1])
            xlim([min(F_orig) max(F_orig)])
            legend('Vocal dist','Vocal detected * Intensity dist')
        end
        
        [pks_orig2,locs2,~,proms2]=findpeaks(yy3,'MinPeakProminence',0.3); %The peak has to present local height of at least 0.3 to be considered a peak
        % evaluate relation to the peaks
        pks2 = pks_orig2;
        [max_peak12 max_peak12]=max(pks2);
        max_peak2.peak = max(pks2); pks2(max_peak12)=[];
        max_peak22.peak = max(pks2);
        corr23 = corrcoef(yy2,yy3); corr_yy2_yy3(k) = corr23(1,2);
        corr24 = corrcoef(yy2,yy4); corr_yy2_yy4(k) = corr24(1,2);
        %         if isempty(corr23),  corr23_total(k) = NaN; else corr23_total(k) = corr23; end
        %         if isempty(corr24),  corr24_total(k) = NaN; else corr24_total(k) = corr24; end
        if isempty(max(proms2)),  max_prom2(k) = NaN; else max_prom2(k) = max(proms2); end
        if isempty(max(proms)),  max_prom(k) = NaN; else max_prom(k) = max(proms); end
        if isempty(mean_dist), mean_dist_total(k) = NaN; else mean_dist_total(k) = mean_dist; end
        if isempty(median_dist), median_dist_total(k) = NaN; else median_dist_total(k) = median_dist;end
        if isempty(max_below_50k), max_below_50k_total(k) = NaN; else max_below_50k_total(k) = max_below_50k;end
        if isempty(mean(pks)/mean(valleys)), mean_pks_valley(k) = NaN; else mean_pks_valley(k) = mean(pks)/mean(valleys);end
        duration(k) = time_vocal{k}(end)-time_vocal{k}(1);
        Xnew = [max_below_50k_total(k), max_prom(k), max_prom2(k), median_dist_total(k), mean_dist_total(k), mean_pks_valley(k), corr_yy2_yy3(k), corr_yy2_yy4(k), duration(k), noise_detected_clustering(k) ];
        
        %correlation with burst
        %             burst_model = yy2;
        if save_plot_3d_info==1
            try
                title(['pk1/pk2= ' num2str(max_peak2.peak/ max_peak22.peak) '; maxprom= ' num2str(max(proms2)) '; mediandist= ' num2str(median_dist) '; meandist= ' num2str(mean_dist) '; corry2y3= ' num2str(corr23(1,2)) '; corry2y4= ' num2str(corr24(1,2))])
            catch
                title(['pk1= ' num2str(max_peak2.peak)  '; maxprom= ' num2str(max(proms2)) '; mediandist= ' num2str(median_dist) '; meandist= ' num2str(mean_dist) '; corry2y3= ' num2str(corr23(1,2)) '; corry2y4= ' num2str(corr24(1,2)) ])
            end
            ylim([0 1])
            xlim([min(F_orig) max(F_orig)])
            hold off
            
            
            cd(vpathname)
            if ~exist(vfilename, 'dir')
                mkdir(vfilename)
            end
            cd(vfilename)
            if ~exist('Info', 'dir')
                mkdir('Info')
            end
            set (gcf, 'Units', 'normalized', 'Position', [0,0,1,1]);
            saveas(gcf,[vpathname '/' vfilename '/'  'Info' '/' num2str(k)  '.png'])
        end
        
        %         [pks,locs]=findpeaks(f);
        
        % Noise-opinion #1: Intensity vs freq distribution
        
        %         try
        %             if isempty(pks_orig) || (mean(pks)/mean(valleys) <= 2.2 && max(proms)<0.6 ) || (max_below_50k>0.75 && max(proms)<0.6) %I'm setting this constant myself... find dynamic way to get it.
        %                 aux5 = 1; %'Noise';
        %                 vocal_classified{k}.noise = time_vocal{k}(1);
        %                 noise_count_dist = [noise_count_dist;k];
        %             end
        %
        %         catch
        %             if isempty(pks_orig) ||  (max_below_50k>0.75 && max(proms)<0.6)  %I'm setting this constant myself... find dynamic way to get it.
        %                 aux5 = 1; %'Noise';
        %                 vocal_classified{k}.noise = time_vocal{k}(1);
        %                 noise_count_dist = [noise_count_dist;k];
        %             end
        %         end
        %         Xnew = [max_below_50k max_prom median_dist];
        try
            [ynew,ynewci] = predict(model_noise,Xnew);
            if ynew> 0.155 %value gotten from the average+std of all noise detected accross samples (95% of the normal are below 0.15, while 1% of the noise is >0.15)
                aux5 = 1; %'Noise';
                vocal_classified{k}.noise_dist = time_vocal{k}(1);
                noise_count_dist = [noise_count_dist;k];
            end
        catch
            if isempty(max_prom)
                aux5 = 1; %'Noise';
                vocal_classified{k}.noise_dist = time_vocal{k}(1);
                noise_count_dist = [noise_count_dist;k];
            else
                disp('Shit went wrong :( ');
            end
        end
        
        
        aux6 = sort(tabela(:,2));
        aux6 = aux6 - circshift(aux6,[1,0]);
        aux6 = find(aux6(2:end)>1000);
        if isempty(aux6)
            aux6=0;
        end
        
        %         aux6 = [size(aux6,1),size(current_freq,1)];
        %         ZZ = VocalMat_heatmap(tabela);
        %         output = [output; time_vocal{k}(1) aux3 aux4 aux5 size(aux6,1) size(pks,2)];
    end
end


%If I run this clustering only for vocalizations identified as being
%part of the same group, can I get a vocalizations that summarizes the
%whole group?

cd(raiz)

if use_DL==1
    if save_plot_spectrograms==1
        figure('Name',vfilename,'NumberTitle','off')
        %         set (gcf, 'Units', 'normalized', 'Position', [0,0,1,1]);
    end
    
    cd(vpathname)
    if ~exist(vfilename, 'dir')
        mkdir(vfilename)
    end
    cd(vfilename)
    
    if (~exist('All_axes','dir') && save_plot_spectrograms==1)
        mkdir('All_axes')
    end
    
    if ~exist('All','dir')
        mkdir('All')
    end
    
    
    %     categories = [categories; 'two_steps'; 'mult_steps'];
    for id_vocal = 1:size(time_vocal,2)
        %         cd(raiz)
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
            %                     Stri=['set(gca,''xlim'',[-dx/2 dx/2]+[' num2str(time_vocal{id_vocal}(1)) ' '  num2str(time_vocal{id_vocal}(1)) '])'];
            %                     eval(Stri);
            saveas(gcf,[vpathname '/' vfilename '/All_axes/' num2str(id_vocal)  '.png'])
            hold off
        end
        img = imresize(flipud(mat2gray(A_total(:,T_min:T_max))),size_spectrogram);
        img = cat(3, img, img, img);
        %                 imwrite(img,[vpathname '/' vfilename '/'  name '/' num2str(id_vocal)  '.png'])
        imwrite(img,[vpathname '/' vfilename '/All/' num2str(id_vocal)  '.png'])
        
    end
    
end

% save(['vocal_classified_' vfilename],'vocal_classified','vfilename','max_prom2','max_prom','mean_dist_total','max_below_50k_total','mean_pks_valley','median_dist_total','corr_yy2_yy3','corr_yy2_yy4','duration','noise_detected_clustering' )
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
    intens_freq_total{k} = intens_freq;
    
    pos = round(linspace(1,size(curr_freq_total{k},1),num_points)); % get 15 points of frequency
    dist_between_points{k} = time_vocal{k}(pos(2))-time_vocal{k}(pos(1)); %in time perspective
    
    intens_freq_out{k} = intens_freq_total{k}(pos);
    freq_vocal_out{k} = curr_freq_total{k}(pos);
    
    x2 = time_vocal{k}(pos);
    x1 = circshift(x2',1); %get slope between points selected
    y2 = curr_freq_total{k}(pos);
    y1 =  circshift(y2,1);
    pairs = [x2' y2];
    pairs_shift = [circshift(x2',1) circshift(y2,1)];
    euclidean_dist{k} = sqrt((pairs(2:end,1) - pairs_shift(2:end,1)).^2 + (pairs(2:end,2) - pairs_shift(2:end,2)).^2);
    slopes{k} = (y2(2:end) - y1(2:end)) ./ (x2(2:end)' - x1(2:end));
    
    all_jumps{k}=(y2(2:end) - y1(2:end)); %get all jumps in frequency
    
    aux =  circshift(curr_freq_total{k},1); %jumps to higher frequency >8kHz
    aux = curr_freq_total{k}(2:end) - aux(2:end);
    aux_high = find(aux>8e3); aux_low = find(aux<-8e3);
    if size(aux_high,1)>1 && size(aux_low,1)>1
        for l=1:size(aux_high,1)
            for ll=1:size(aux_low,1)
                if aux_high(l)>0 && aux_low(ll)>0 && abs(time_vocal{k}(aux_high(l))-time_vocal{k}(aux_low(ll)))<0.004 %only consider steps greater than 5ms
                    aux_high(l)=-100;
                    aux_low(ll)=-100;
                end
            end
        end
        aux_high(aux_high==-100)=[];
        aux_low(aux_low==-100)=[];
    end
    
    higher_jumps{k} = size(aux_high,1);
    lower_jumps{k} = size(aux_low,1);
    
    for l=1:(num_points-1)
        slopes_label{l} = ['slope' num2str(l)];
        jumps_label{l} = ['jump' num2str(l)];
        euclidean_dist_label{l} = ['euclidean_dist' num2str(l)];
    end
    for l=1:(num_points)
        intens_label{l} = ['intens' num2str(l)];
        freq_label{l} = ['freq' num2str(l)];
        %       intens_label_delta{l} = ['intens_delta' num2str(l)];
    end
    duration(k) = time_vocal{k}(end)-time_vocal{k}(1);
    bandwidth(k) = max(curr_freq_total{k})- min(curr_freq_total{k});
    clear aux1
    aux1 = [k, time_vocal{k}(1), dist_between_points{k}, duration(k), bandwidth(k), slopes{k}',all_jumps{k}', higher_jumps{k}, lower_jumps{k}, intens_freq_out{k}', freq_vocal_out{k}', euclidean_dist{k}']; %putting everything togeteher
    
    %Get the double of points now...
    pos = round(linspace(1,size(curr_freq_total{k},1),2*num_points)); % get 15 points of frequency
    dist_between_points{k} = time_vocal{k}(pos(2))-time_vocal{k}(pos(1)); %in time and frequency perspective
    
    intens_freq_out{k} = intens_freq_total{k}(pos);
    freq_vocal_out{k} = curr_freq_total{k}(pos);
    %    intens_freq_out_delta{k} = mean(intens_freq)-intens_freq_total{k}(pos);
    x2 = time_vocal{k}(pos);
    x1 = circshift(x2',1); %get slope between points selected
    y2 = curr_freq_total{k}(pos);
    y1 =  circshift(y2,1);
    pairs = [x2' y2];
    pairs_shift = [circshift(x2',1) circshift(y2,1)];
    euclidean_dist{k} = sqrt((pairs(2:end,1) - pairs_shift(2:end,1)).^2 + (pairs(2:end,2) - pairs_shift(2:end,2)).^2);
    slopes{k} = (y2(2:end) - y1(2:end)) ./ (pos(2:end)' - x1(2:end));
    
    all_jumps{k}=(y2(2:end) - y1(2:end)); %get all jumps in frequency
    
    aux =  circshift(curr_freq_total{k},1); %jumps to higher frequency >8kHz
    aux = curr_freq_total{k}(2:end) - aux(2:end);
    aux_high = find(aux>8e3); aux_low = find(aux<-8e3);
    if size(aux_high,1)>1 && size(aux_low,1)>1
        for l=1:size(aux_high,1)
            for ll=1:size(aux_low,1)
                if aux_high(l)>0 && aux_low(ll)>0 && abs(time_vocal{k}(aux_high(l))-time_vocal{k}(aux_low(ll)))<0.004 %only consider steps greater than 4ms
                    aux_high(l)=-100;
                    aux_low(ll)=-100;
                end
            end
        end
        aux_high(aux_high==-100)=[];
        aux_low(aux_low==-100)=[];
    end
    
    higher_jumps{k} = size(aux_high,1);
    lower_jumps{k} = size(aux_low,1);
    
    for l=1:(2*num_points-1)
        slopes_label2{l} = ['slope' num2str(l) '_2'];
        jumps_label2{l} = ['jump' num2str(l) '_2'];
        euclidean_dist_label2{l} = ['euclidean_dist' num2str(l) '_2'];
    end
    for l=1:(2*num_points)
        intens_label2{l} = ['intens' num2str(l) '_2'];
        freq_label2{l} = ['freq' num2str(l) '_2'];
    end
    
    table_out(k,:) = [num2cell(aux1), num2cell(dist_between_points{k}), num2cell(slopes{k}'), num2cell(all_jumps{k}'), num2cell(higher_jumps{k}), num2cell(lower_jumps{k}), num2cell(intens_freq_out{k}'), num2cell(freq_vocal_out{k}'), num2cell(euclidean_dist{k}'), ...
        num2cell([max_below_50k_total(k), max_prom(k), max_prom2(k), median_dist_total(k), mean_dist_total(k), mean_pks_valley(k), corr_yy2_yy3(k), corr_yy2_yy4(k)])]; % New classifier results
    
end


% Labelling and saving
names_out = ['name_vocal','start_time','dist_between_points','duration', 'bandwidth', slopes_label , jumps_label, 'higher_jumps', 'lower_jumps', intens_label, freq_label, euclidean_dist_label, 'dist_between_points2', slopes_label2 , jumps_label2, 'higher_jumps2', 'lower_jumps2', intens_label2,freq_label2,euclidean_dist_label2, ...
    'max_below_50k_total', 'max_prom', 'max_prom2', 'median_dist_total', 'mean_dist_total', 'mean_pks_valley', 'corr_yy2_yy3', 'corr_yy2_yy4'];
T = array2table(table_out,'VariableNames',names_out);

table_aux = T;
[ynew_RF,ynewci_RF] = predict(model_class_RF,cell2mat(table2array(table_aux(:,2:end-1))));
table_total_output = [ table_aux(:,1:2) array2table(ynewci_RF,'VariableNames',model_class_RF.ClassNames) array2table(ynew_RF,'VariableNames',{'RF_out'})];

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
    
    B = [T2, AA, array2table(cell2mat(AA2(:,3)))];
    B.Properties.VariableNames{15} = 'NumVocal';
    B.Properties.VariableNames{14} = 'DL_out';
    B = sortrows(B,'NumVocal','ascend');
end


% temp = table_total_output(:,[1:2 239:end]);
if use_DL==1
    temp = [table_total_output, B];
    writetable(temp,[vfilename '_ML&DL.xlsx'])
else
    temp = [table_total_output];
    writetable(temp,[vfilename '_ML.xlsx'])
end

[ynew,ynewci] = predict(model_class_DL_RF,table2array(temp(:,[3:14,16:27])));

ttt = model_class_DL_RF.ClassNames;
ttt2 = cellstr(num2str(3*ones(12,1)));
s = strcat(ttt,ttt2);

T3 = [temp, array2table(ynewci,'VariableNames',s) array2table(B.DL_out,'VariableNames',{'Final_Label'})];
writetable(T3,[vfilename '_ML&DL_comb.xlsx'])


%Separating in groups
% pre_corr_table = [];
% categories = fieldnames(vocal_classified{k});
%
% list_clusters.mult_steps = [];
% list_clusters.two_steps = [];
% list_clusters.noisy_vocal = [];
% for names = 1:size(categories,1)
%     count = 0;
%     name = categories{names};
%     disp(['Building ' name ' list'])
%     eval(['list_clusters.' name '= [];']);
%     for k=1:size(time_vocal,2)
%         if ~isempty(eval(['vocal_classified{k}.' name])) && isempty(vocal_classified{k}.noise_dist)
%             count = count+1;
%             temp_table = [];
%             for col = 1:size(time_vocal{k},2)
%                 for col2 = 1:size(freq_vocal{k}{col},1)
%                     temp_table = [temp_table; time_vocal{k}(col) freq_vocal{k}{col}(col2)];
%                 end
%             end
%
%             eval(['pre_corr_table.' name '{count} = temp_table;']);
%             if strcmp(name, 'complex')
%                 [R_pearson,P_value]=corrcoef(temp_table);
%                 R_pearson = R_pearson(1,2) ;% P_value = P_value(1,2);
%                 eval(['list_clusters.' name '= [list_clusters.' name '; k max(temp_table(:,1))-min(temp_table(:,1)) max(temp_table(:,2))-min(temp_table(:,2)) R_pearson median(temp_table(:,2))];']);
%             else
%                 if strcmp(name, 'step_up') || strcmp(name, 'step_down')
%                     if size(vocal_classified{k}.step_up,1)==1 && size(vocal_classified{k}.step_down,1)==1
%                         list_clusters.two_steps = unique([list_clusters.two_steps ; k]);
%                     elseif size(vocal_classified{k}.step_up,1)+ size(vocal_classified{k}.step_down,1)>1 && isempty(vocal_classified{k}.noisy_vocal) && size(vocal_classified{k}.step_up,1)>0 && size(vocal_classified{k}.step_down,1)>0
%                         list_clusters.mult_steps = unique([list_clusters.mult_steps ; k]);
%                     elseif size(vocal_classified{k}.step_up,1)>0 && size(vocal_classified{k}.step_down,1)>0 && ~isempty(vocal_classified{k}.noisy_vocal) %There is step up, down and it is a noisy vocal -> Noisy Vocal
%                         if abs(size(vocal_classified{k}.step_up,1)-size(vocal_classified{k}.step_down,1)) <= 2
%                             list_clusters.mult_steps = unique([list_clusters.mult_steps ; k]);
%                         else
%                             list_clusters.noisy_vocal = unique([list_clusters.noisy_vocal ; k]);
%                         end
%                     else
%                         eval(['list_clusters.' name '= [list_clusters.' name '; k ];']);
%                     end
%                 else
%                     eval(['list_clusters.' name '= [list_clusters.' name '; k ];']);
%                 end
%             end
%             %         elseif strcmp(name, 'noise') && ~isempty(vocal_classified{k}.noise)
%             %             eval(['list_clusters.' name '= [list_clusters.' name '; k ];']);
%         elseif strcmp(name, 'noise_dist') && ~isempty(vocal_classified{k}.noise_dist)
%             eval(['list_clusters.' name '= [list_clusters.' name '; k ];']);
%         end
%     end
% end


chevron_count = sum(strcmp(T3.Final_Label,'chevron'));
complex_count = sum(strcmp(T3.Final_Label,'complex'));
down_fm_count = sum(strcmp(T3.Final_Label,'down_fm'));
flat_count = sum(strcmp(T3.Final_Label,'flat'));
mult_steps_count = sum(strcmp(T3.Final_Label,'mult_steps'));
noise_count = sum(strcmp(T3.Final_Label,'noise_dist'));
rev_chevron_count = sum(strcmp(T3.Final_Label,'rev_chevron'));
short_count = sum(strcmp(T3.Final_Label,'short'));
step_down_count = sum(strcmp(T3.Final_Label,'step_down'));
step_up_count = sum(strcmp(T3.Final_Label,'step_up'));
two_steps_count = sum(strcmp(T3.Final_Label,'two_steps'));
up_fm_count = sum(strcmp(T3.Final_Label,'up_fm'));
noise_dist_count = sum(strcmp(T3.Final_Label,'noise_dist'));
harmonic_count = unique(harmonic_count);
noisy_vocal_count = unique(noisy_vocal_count);

disp(['Total number of vocalizations: ' num2str(size(time_vocal,2)-noise_dist_count) ' vocalizations (' num2str(noise_dist_count) ' were noise)']);
% disp(['The classifier identified ' num2str(size(noise_count_dist,1)) ' as noise'] );

for j=1:size(model_class_RF.ClassNames)
    eval(['disp([''' cell2mat(model_class_RF.ClassNames(j)) ': '' num2str('  cell2mat(model_class_RF.ClassNames(j)) '_count)])'])
end

% Fixed up to here.
if save_excel_file==1
    %     names2 = model_class_DL_RF.ClassNames;
    names = [{'Names_vocal'};{'Start_time'}; {'End_time'}; {'Inter_vocal_interval'}; {'Inter_real_vocal_interval'}; {'Duration'}; {'min_freq_main'}; {'max_freq_main'};{'mean_freq_main'};{'Bandwidth'};{'min_freq_total'};...
        {'max_freq_total'};{'mean_freq_total'};{'min_intens_total'};{'max_intens_total'}; {'corrected_max_intens_total'};{'Background_intens'};{'mean_intens_total'};{'Class'};{'Harmonic'};{'Noisy'}];
    tabela = zeros(size(T3,1),size(names,1));
    tabela(:,1) = 1:size(T3,1);
    tabela = num2cell(tabela);
    
    %     for i = 1:size(names2,1)
    %             if eval(['~isempty(list_clusters.' names2{i} ')']) && ~strcmp(names2{i},'harmonic_size') && ~strcmp(names2{i},'noisy_vocal') && ~strcmp(names2{i},'harmonic') %&& ~strcmp(names2{i},'noise')
    %             eval(['tabela(list_clusters.' names2{i} '(:,1),16)= names2(i);']);
    %         end
    %     end
    
    %     if ~isempty(list_clusters.noisy_vocal)
    %         tabela(list_clusters.noisy_vocal(:,1),18)= {1};
    %         for i=1:size(tabela(list_clusters.noisy_vocal(:,1)),1)
    %             if cell2mat(tabela(list_clusters.noisy_vocal(i,1),16))==0
    %                 tabela(list_clusters.noisy_vocal(i,1),16) = {'noisy_vocal'};
    %             end
    %         end
    %     end
    
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
    
    tabela(:,19) = T3.Final_Label;
    
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
    
    writetable(T,[vfilename '.xlsx'])
end

% Estimate number of bins given the bin size
aux = ~strcmp(T.Class,'noise_dist');
T_no_noise = T(aux,:);
if size(T_no_noise,1)>0
    num_of_bins = ceil(max(cell2mat(T_no_noise.Start_time))/bin_size);
    edges = 0:bin_size:num_of_bins*bin_size;
    [num_vocals_in_bin] = histcounts(cell2mat(T_no_noise.Start_time),edges);
    
    
    
    disp(['Vocalizations per bin (not considering noise):'])
    for k=1:num_of_bins
        disp(['Bin_' num2str(k) '(' num2str(edges(k)) '-' num2str(edges(k+1)) 's): ' num2str(num_vocals_in_bin(k))])
    end
    
    if plot_stats_per_bin ==1
        
        %Show classes per bin
        for j=1:size(model_class_RF.ClassNames)
            aux = strcmp(T.Class,model_class_RF.ClassNames(j));
            T_class = T(aux,:);
            [num_vocals_in_bin,~] = histcounts(cell2mat(T_class.Start_time),edges);
            disp(['Vocalizations per bin for class ' cell2mat(model_class_RF.ClassNames(j)) ' :'])
            for k=1:num_of_bins
                disp(['Bin_' num2str(k) '(' num2str(edges(k)) '-' num2str(edges(k+1)) 's): ' num2str(num_vocals_in_bin(k))])
            end
        end
        
    end
    
else
    disp('No real vocalizations detected in this file')
end
