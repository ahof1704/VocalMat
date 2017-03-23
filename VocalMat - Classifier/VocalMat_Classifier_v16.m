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

clc
clear all
raiz = pwd;
[vfilename,vpathname] = uigetfile({'*.mat'},'Select the output file');
cd(vpathname);
list = dir('*output*.mat');
diary(['Summary_classifier' num2str(horzcat(fix(clock))) '.txt'])

%Setting up
p = mfilename('fullpath')
plot_stats_per_bin=1
save_plot_spectrograms=1
save_histogram_per_animal=1
save_excel_file=1

stepup_count_bin_total  = 0;
stepdown_count_bin_total = 0 ;
harmonic_count_bin_total  = 0;
flat_count_bin_total  = 0;
chevron_count_bin_total  = 0;
revchevron_count_bin_total  = 0;
downfm_count_bin_total  = 0;
upfm_count_bin_total  = 0;
complex_count_bin_total  = 0;
noisy_vocal_count_bin_total  = 0;
nonlinear_count_bin_total  = 0;
short_count_bin_total  = 0;
noise_count_bin_total  = 0;
two_steps_count_bin_total  = 0;
mult_steps_count_bin_total  = 0;

for Name=1:size(list,1)
    vfilename = list(Name).name;
    vfilename = vfilename(1:end-4);
    vfile = fullfile(vpathname,vfilename);
    
    clearvars -except   noise_count_bin_total two_steps_count_bin_total mult_steps_count_bin_total ...
        plot_stats_per_bin save_plot_spectrograms list raiz vfile vfilename vpathname stepup_count_bin_total stepdown_count_bin_total harmonic_count_bin_total flat_count_bin_total chevron_count_bin_total ...
        revchevron_count_bin_total downfm_count_bin_total upfm_count_bin_total complex_count_bin_total noisy_vocal_count_bin_total nonlinear_count_bin_total short_count_bin_total save_histogram_per_animal save_excel_file
    fprintf('\n')
    disp(['Reading ' vfilename])
    load(vfile);
    
    %We are gonna get only 10 points (time stamps) to classify the vocalization
    %Grimsley, Jasmine, Marie Gadziola, and Jeff James Wenstrup. "Automated classification of mouse pup isolation syllables: from cluster analysis to an Excel-based “mouse pup syllable classification calculator”."
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
    
    output=[];
    
    for k=1:size(time_vocal,2)
%         if k==190
%             k
%         end
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
        vocal_classified{k}.noise = [];
        vocal_classified{k}.harmonic_size = [];
        
        %Verify jump in frequency taking as base the closest frequency detected
        current_freq = [];
        harmonic_candidate = [];
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
                                harmonic_candidate = [harmonic_candidate; temp];
                            else %if it is >10khz then it is already another harmonic
                                if size(harmonic_candidate,1)>10
                                    vocal_classified{k}.harmonic = [vocal_classified{k}.harmonic; start_harmonic];
                                    vocal_classified{k}.harmonic_size = [vocal_classified{k}.harmonic_size; size(harmonic_candidate,1)];
                                    harmonic_count = [harmonic_count;k];
                                end
                                harmonic_candidate = temp;
                            end
                        else
                            harmonic_candidate = [harmonic_candidate; temp];
                        end
                        if size(harmonic_candidate,1)==1
                            start_harmonic = time_vocal{k}(time_stamp);
                        end
                    end
                else %Find the closests freq to be the current and classify the other as harmonic candidate
                    aux = freq_vocal{k}{time_stamp+1} - freq_vocal{k}{time_stamp}*ones(size(freq_vocal{k}{time_stamp+1},1),1);
                    [mini,mini]=min(abs(aux));
                    temp = freq_vocal{k}{time_stamp+1};
                    current_freq = [current_freq; temp(mini)]; temp(mini) = [];
                    harmonic_candidate = [harmonic_candidate; temp];
                    if size(harmonic_candidate,1)==1
                        start_harmonic = time_vocal{k}(time_stamp);
                    end
                end
                
                %            [maxi,maxi]=max(abs(aux));
                %            if (sign(aux(maxi))>0 && abs(aux(maxi))>5000)
                %                idx_stepdown_time = time_vocal{k}(time_stamp);
                %                disp(['Vocalization ' num2str(k) ' had a step down in t=' num2str(idx_stepdown_time)]);
                %            elseif (sign(aux(maxi))<0 && abs(aux(maxi))>5000)
                %                idx_stepup_time = time_vocal{k}(time_stamp);
                %                disp(['Vocalization ' num2str(k) ' had a step up in t=' num2str(idx_stepup_time)]);
                %            end
            else %There is nothing similar to harmonic right now... but there was before?
                if (size(freq_vocal{k}{time_stamp},1)>1);
                    %                So... Was it an harmonic or not?
                    if time_stamp == 1 %If the vocalization starts with something that reminds a vocalziation
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
                            vocal_classified{k}.non_linear = [vocal_classified{k}.harmonic; time_vocal{k}(time_stamp)];
                            nonlinear_count = [nonlinear_count;k];
                            current_freq = [current_freq; freq_vocal{k}{time_stamp+1}];
                            harmonic_candidate = [];
                        else %current_freq > harmonic_candidate -> So it is a jump, not a harmonic
                            if size(harmonic_candidate,1)>10% && size(harmonic_candidate,1)/ size(current_freq,1)>0.8 %If the harmonic is big and close to the size of current_freq
                                %                                 disp(['Vocalization ' num2str(k) ' had an harmonic in t = ' num2str(start_harmonic) 's']);
                                %                                 vocal_classified{k}.harmonic = [vocal_classified{k}.harmonic; start_harmonic];
                                %                                 vocal_classified{k}.harmonic_size = [vocal_classified{k}.harmonic_size; size(harmonic_candidate,1)];
                                %                                 current_freq = harmonic_candidate;
                                current_freq(end-size(harmonic_candidate,1)+1:end) = harmonic_candidate;
                                current_freq = [current_freq; freq_vocal{k}{time_stamp+1}];
                                harmonic_candidate = [];
                                %                                 harmonic_count = [harmonic_count;k];
                                %                             else
                                %                                 current_freq(end-size(harmonic_candidate,1)+1:end) = harmonic_candidate;
                                %                                 current_freq = [current_freq; freq_vocal{k}{time_stamp+1}];
                                %                                 harmonic_candidate = [];
                            end
                        end
                    else %It was an harmonic after all
                        test_harmonic = sort(harmonic_candidate);
                        test_harmonic = test_harmonic - circshift(test_harmonic ,[1,0]);
                        test_harmonic = find(test_harmonic>1000);
                        if size(test_harmonic,1)>1%3 %too many jumps in frequency... should be noise or noisy_vocal vocalization.
                            vocal_classified{k}.noisy_vocal = time_vocal{k}(1);
                            noisy_vocal_count = [noisy_vocal_count;k];
                        else
                            current_freq = [current_freq; freq_vocal{k}{time_stamp+1}];
                            if size(harmonic_candidate,1)>10 % at least 10 points to say it was really an harmonic
                                %                                 disp(['Vocalization ' num2str(k) ' had an harmonic in t = ' num2str(start_harmonic) 's']);
                                vocal_classified{k}.harmonic = [vocal_classified{k}.harmonic; start_harmonic];
                                vocal_classified{k}.harmonic_size = [vocal_classified{k}.harmonic_size; size(harmonic_candidate,1)];
                                harmonic_count = [harmonic_count;k];
                            end
                        end
                        
                        harmonic_candidate = [];
                    end
                    
                else
                    aux = freq_vocal{k}{time_stamp+1} - freq_vocal{k}{time_stamp};
                    %                     current_freq = [current_freq; freq_vocal{k}{time_stamp+1}]; Testing
                    current_freq = [current_freq; freq_vocal{k}{time_stamp}];
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
        elseif size(temp2,1)>0 && (size(aux,1)-temp2(end)<5) %Delete the final portion of the vocalization (probabily noise)
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
        elseif size(temp2,1)>0 && (size(aux,1)-temp2(end)<5) %Delete the final portion of the vocalization (probabily noise)
            current_freq(temp2+1:end)=[];
        end
        
        if (isempty(cell2mat(struct2cell(vocal_classified{k}))) || ~isempty(vocal_classified{k}.harmonic)) && size(time_vocal{k},2)<40 %It means there was no step up, down or harmonic
            if max(current_freq)-min(current_freq) <= 1000 % flat
                if time_vocal{k}(end) - time_vocal{k}(1) < 0.0065
                    vocal_classified{k}.short =  time_vocal{k}(1);
                    short_count = [short_count;k];
                else
                    if (time_vocal{k}(2)-time_vocal{k}(1))*size(current_freq,1)<0.0065 %6.5ms
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
                if (max(current_freq)-current_freq(1)> 6000 && max(current_freq)-current_freq(end)> 6000) %Chevron
                    [max_local max_local] = max(current_freq);
                    aux2 = aux(2:max_local);
                    aux3 = aux(max_local:end);
                    if sum(sign(aux2)>0)/size(aux2,1)>0.7 && sum(sign(aux3)<0)/size(aux3,1)>0.7 %The "U" shape is verified
                        vocal_classified{k}.chevron = time_vocal{k}(1);
                        chevron_count = [chevron_count;k];
                    end
                elseif (current_freq(1) - min(current_freq)> 6000 && current_freq(end) - min(current_freq)> 6000)
                    [min_local min_local] = min(current_freq);
                    aux2 = aux(2:min_local);
                    aux3 = aux(min_local:end);
                    if sum(sign(aux2)<0)/size(aux2,1)>0.7 && sum(sign(aux3)>0)/size(aux3,1)>0.7 %The inverted "U" shape is verified
                        vocal_classified{k}.rev_chevron = time_vocal{k}(1);
                        revchevron_count = [revchevron_count;k];
                    end
                elseif (abs(current_freq(end) - current_freq(1))> 6000) && sum(sign(aux)<0)/size(current_freq,1)>0.7 %Down FM
                    vocal_classified{k}.down_fm = time_vocal{k}(1);
                    downfm_count = [downfm_count;k];
                elseif (abs(current_freq(end) - current_freq(1))> 6000) && sum(sign(aux)>0)/size(current_freq,1)>0.7 %Up FM
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
            %             if max(current_freq)-min(current_freq) <= 1000 % flat
            %                 if time_vocal{k}(end) - time_vocal{k}(1) < 0.0065
            %                     vocal_classified{k}.short =  time_vocal{k}(1);
            %                     short_count = [short_count;k];
            %                 else
            %                     if (time_vocal{k}(2)-time_vocal{k}(1))*size(current_freq,1)<0.0065 %6.5ms
            % %                         if ~isempty(vocal_classified{k}.harmonic) && max(vocal_classified{k}.harmonic_size)<15
            %                             vocal_classified{k}.noise = time_vocal{k}(1);
            %                             noise_count = [noise_count;k];
            % %                         end
            %                     else
            %                         vocal_classified{k}.flat =  time_vocal{k}(1);
            %                         flat_count = [flat_count;k];
            %                     end
            %                 end
            %             else
            time_stamps = round(linspace(1,size(current_freq',2),10));
            aux = current_freq;
            aux = aux-circshift(aux ,[1,0]);
            if (max(current_freq)-current_freq(1)> 6000 && max(current_freq)-current_freq(end)> 6000) %Chevron
                [max_local max_local] = max(current_freq);
                aux2 = aux(2:max_local);
                aux3 = aux(max_local:end);
                if sum(sign(aux2)>0)/size(aux2,1)>=0.7 && sum(sign(aux3)<0)/size(aux3,1)>=0.7 %The "U" shape is verified
                    vocal_classified{k}.chevron = time_vocal{k}(1);
                    chevron_count = [chevron_count;k];
                end
            elseif (current_freq(1) - min(current_freq)> 6000 && current_freq(end) - min(current_freq)> 6000)
                [min_local min_local] = min(current_freq);
                aux2 = aux(2:min_local);
                aux3 = aux(min_local:end);
                if sum(sign(aux2)<0)/size(aux2,1)>=0.7 && sum(sign(aux3)>0)/size(aux3,1)>=0.7 %The inverted "U" shape is verified
                    vocal_classified{k}.rev_chevron = time_vocal{k}(1);
                    revchevron_count = [revchevron_count;k];
                end
            elseif (abs(current_freq(end) - current_freq(1))> 6000) && sum(sign(aux)<0)/size(current_freq,1)>0.7 %Down FM
                vocal_classified{k}.down_fm = time_vocal{k}(1);
                downfm_count = [downfm_count;k];
            elseif (abs(current_freq(end) - current_freq(1))> 6000) && sum(sign(aux)>0)/size(current_freq,1)>0.7 %Up FM
                vocal_classified{k}.up_fm = time_vocal{k}(1);
                upfm_count = [upfm_count;k];
            end
            %             end
            check_if_only_harmonic = struct2cell(vocal_classified{k}); check_if_only_harmonic([3 14])=[];
            if isempty(cell2mat(check_if_only_harmonic))  %If it is still empty, has to be complex
                vocal_classified{k}.complex = time_vocal{k}(1);
                complex_count = [complex_count;k];
            end
        end
        
        
        %Extra filtering by removing the points with intensity below 5% of the average
        tabela = [];
        %         for jj = 207% 1:size(time_vocal,2)
        for kk = 1:size(time_vocal{k},2)
            for ll = 1:size(freq_vocal{k}{kk},1)
                tabela = [tabela; time_vocal{k}(kk) freq_vocal{k}{kk}(ll)];
            end
        end
        %         end
        
        
        tabela = [tabela intens_vocal{k}];
        tamanho = size(tabela,1);
        aux3 = tabela(:,2) - circshift(tabela(:,2),[1,0]);
        aux3 = [sum(abs(aux3)>1000), tamanho];
        [f,xi]=ksdensity(tabela(:,2));
        [pks,locs]=findpeaks(f);
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
                    
                else
                    aux5 = 1; %'Noise';
                    vocal_classified{k}.noise = time_vocal{k}(1);
                    noise_count = [noise_count;k];
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
                        
                    else
                        aux5 = 1; %'Noise';
                        vocal_classified{k}.noise = time_vocal{k}(1);
                        noise_count = [noise_count;k];
                    end
                end
            else
                if ~isempty(vocal_classified{k}.harmonic_size) && max(vocal_classified{k}.harmonic_size)>=15% && max(vocal_classified{k}.harmonic_size)/size(time_vocal{k},2)>0.5
                    
                else
                    aux5 = 1; %'Noise';
                    vocal_classified{k}.noise = time_vocal{k}(1);
                    noise_count = [noise_count;k];
                end
            end
        else
            aux5 = 0; %'';
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
    stepup_count=unique(stepup_count);
    stepdown_count=unique(stepdown_count);
    harmonic_count=unique(harmonic_count);
    flat_count=unique(flat_count);
    chevron_count=unique(chevron_count);
    revchevron_count=unique(revchevron_count);
    downfm_count=unique(downfm_count);
    upfm_count=unique(upfm_count);
    complex_count=unique(complex_count);
    noisy_vocal_count=unique(noisy_vocal_count);
    nonlinear_count = unique(nonlinear_count);
    short_count = unique(short_count);
    noise_count = unique(noise_count);
    
    %Show a list of vocalizations that look like noise
    for ttt =1:size(noise_count,1)
        disp(['Vocalization #' num2str(noise_count(ttt)) ' starting in ' num2str(time_vocal{noise_count(ttt)}(1)) 's seems to be noise'])
    end
    
    %Show a list of vocalizations that look like noise
    for ttt =1:size(noisy_vocal_count,1)
        disp(['Vocalization #' num2str(noisy_vocal_count(ttt)) ' starting in ' num2str(time_vocal{noisy_vocal_count(ttt)}(1)) 's seems to be noisy vocalization'])
    end
    
    disp(['Total number of vocalizations: ' num2str(size(time_vocal,2))]);
    disp(['The classifier identified ' num2str(size(noise_count,1)) ' as noise and ' num2str(size(noisy_vocal_count,1)) ' as noisy vocalization']);
    
    %     if plot_stats_per_bin==1
    %         bin_1 = [];
    %         bin_2 = [];
    %         bin_3 = [];
    %         bin_4 = [];
    %
    %         for k=1:size(time_vocal,2)
    %             if time_vocal{k}(1) < 5*60 %5min
    %                 bin_1 = [bin_1, k];
    %             elseif time_vocal{k}(1) >= 5*60 && time_vocal{k}(1) < 10*60
    %                 bin_2 = [bin_2, k];
    %             elseif time_vocal{k}(1) >= 10*60 && time_vocal{k}(1) < 15*60
    %                 bin_3 = [bin_3, k];
    %             else
    %                 bin_4 = [bin_4, k];
    %             end
    %         end
    %
    %         for i=1:4
    %             eval(['if ~isempty(bin_' num2str(i) ') ', ...
    %                 'bin_' num2str(i) ' = [bin_' num2str(i) '(1); bin_' num2str(i) '(end)];',...
    %                 'else ',...
    %                 'bin_' num2str(i) ' = [0; 0];',...
    %                 'end']);
    %         end
    %     end
    %
    % Identifying how many types of vocal happened in each bin
    %          if plot_data == 1
    %              stepup_count_bin = [ sum(stepup_count <= bin_1(end)), sum(stepup_count>=bin_2(1) & stepup_count<=bin_2(end)), sum(stepup_count>=bin_3(1) & stepup_count<=bin_3(end)), sum(stepup_count>=bin_4(1) & stepup_count<=bin_4(end))];
    %              stepdown_count_bin = [ sum(stepdown_count <= bin_1(end)), sum(stepdown_count>=bin_2(1) & stepdown_count<=bin_2(end)), sum(stepdown_count>=bin_3(1) & stepdown_count<=bin_3(end)), sum(stepdown_count>=bin_4(1) & stepdown_count<=bin_4(end))];
    %              harmonic_count_bin = [ sum(harmonic_count <= bin_1(end)), sum(harmonic_count>=bin_2(1) & harmonic_count<=bin_2(end)), sum(harmonic_count>=bin_3(1) & harmonic_count<=bin_3(end)), sum(harmonic_count>=bin_4(1) & harmonic_count<=bin_4(end))];
    %              flat_count_bin = [ sum(flat_count <= bin_1(end)), sum(flat_count>=bin_2(1) & flat_count<=bin_2(end)), sum(flat_count>=bin_3(1) & flat_count<=bin_3(end)), sum(flat_count>=bin_4(1) & flat_count<=bin_4(end))];
    %              chevron_count_bin = [ sum(chevron_count <= bin_1(end)), sum(chevron_count>=bin_2(1) & chevron_count<=bin_2(end)), sum(chevron_count>=bin_3(1) & chevron_count<=bin_3(end)), sum(chevron_count>=bin_4(1) & chevron_count<=bin_4(end))];
    %              revchevron_count_bin = [ sum(revchevron_count <= bin_1(end)), sum(revchevron_count>=bin_2(1) & revchevron_count<=bin_2(end)), sum(revchevron_count>=bin_3(1) & revchevron_count<=bin_3(end)), sum(revchevron_count>=bin_4(1) & revchevron_count<=bin_4(end))];
    %              downfm_count_bin = [ sum(downfm_count <= bin_1(end)), sum(downfm_count>=bin_2(1) & downfm_count<=bin_2(end)), sum(downfm_count>=bin_3(1) & downfm_count<=bin_3(end)), sum(downfm_count>=bin_4(1) & downfm_count<=bin_4(end))];
    %              upfm_count_bin = [ sum(upfm_count <= bin_1(end)), sum(upfm_count>=bin_2(1) & upfm_count<=bin_2(end)), sum(upfm_count>=bin_3(1) & upfm_count<=bin_3(end)), sum(upfm_count>=bin_4(1) & upfm_count<=bin_4(end))];
    %              complex_count_bin = [ sum(complex_count <= bin_1(end)), sum(complex_count>=bin_2(1) & complex_count<=bin_2(end)), sum(complex_count>=bin_3(1) & complex_count<=bin_3(end)), sum(complex_count>=bin_4(1) & complex_count<=bin_4(end))];
    %              noisy_vocal_count_bin = [ sum(noisy_vocal_count <= bin_1(end)), sum(noisy_vocal_count>=bin_2(1) & noisy_vocal_count<=bin_2(end)), sum(noisy_vocal_count>=bin_3(1) & noisy_vocal_count<=bin_3(end)), sum(noisy_vocal_count>=bin_4(1) & noisy_vocal_count<=bin_4(end))];
    %              nonlinear_count_bin = [ sum(nonlinear_count <= bin_1(end)), sum(nonlinear_count>=bin_2(1) & nonlinear_count<=bin_2(end)), sum(nonlinear_count>=bin_3(1) & nonlinear_count<=bin_3(end)), sum(nonlinear_count>=bin_4(1) & nonlinear_count<=bin_4(end))];
    %              short_count_bin = [ sum(short_count <= bin_1(end)), sum(short_count>=bin_2(1) & short_count<=bin_2(end)), sum(short_count>=bin_3(1) & short_count<=bin_3(end)), sum(short_count>=bin_4(1) & short_count<=bin_4(end))];
    %              noise_count_bin = [ sum(noise_count <= bin_1(end)), sum(noise_count>=bin_2(1) & noise_count<=bin_2(end)), sum(noise_count>=bin_3(1) & noise_count<=bin_3(end)), sum(noise_count>=bin_4(1) & noise_count<=bin_4(end))];
    %          end
    %
    %
    %          save(['vocal_classified_' vfilename],'vocal_classified')
    %     %     all_class = [size(stepup_count,1) size(stepdown_count,1) size(harmonic_count,1) size(flat_count,1) size(chevron_count,1) size(revchevron_count,1) size(downfm_count,1) size(upfm_count,1) size(complex_count,1) size(noisy_vocal_count,1) size(nonlinear_count,1) size(short_count,1)];
    %          if plot_data ==1
    %              all_class = [stepup_count_bin; stepdown_count_bin; harmonic_count_bin; flat_count_bin; chevron_count_bin; revchevron_count_bin; downfm_count_bin; upfm_count_bin; complex_count_bin; noisy_vocal_count_bin; nonlinear_count_bin; short_count_bin;noise_count_bin];
    %              figure('Name',['vocal_classified_' vfilename],'NumberTitle','off')
    %              bar(all_class,'stacked')
    %              Labels = {'stepup_count', 'stepdown_count', 'harmonic_count', 'flat_count', 'chevron_count', 'revchevron_count', 'downfm_count', 'upfm_count', 'complex_count', 'noisy_vocal_count', 'nonlinear_count', 'short_count','noise_count'};
    %          %     set(gca, 'XTick', [1:12, 'XTickLabel', Labels);
    %              set(gca,'TickLabelInterpreter','none','XTick',1:size(all_class,1), 'XTickLabel',Labels','YColor','black');
    %              legend(gca,'Bin 1','Bin 2','Bin 3','Bin 4');
    %          end
    % set (gcf, 'Units', 'normalized', 'Position', [0,0,1,1]);
    % saveas(gcf,[vpathname '/' vfilename   '.png'])
    
    %%
    %%%%%%%%%%%% At this point start the clustering method%%%%%%%%%%%%%%
    %Start organizing a struct where each element brings the time vs frequency vs intensity table
    %     pre_corr_table = [];
    %     for k=1:size(time_vocal,2)
    %         temp_table = [];
    %         for col = 1:size(time_vocal{k},2)
    %             for col2 = 1:size(freq_vocal{k}{col},1)
    %                 temp_table = [temp_table; time_vocal{k}(col) freq_vocal{k}{col}(col2)];
    %             end
    %         end
    %         pre_corr_table{k} = temp_table;
    %     end
    
    %If I run this clustering only for vocalizations identified as being
    %part of the same group, can I get a vocalizations that summarizes the
    %whole group?
    pre_corr_table = [];
    categories = fieldnames(vocal_classified{k});
    
    list_clusters.mult_steps = [];
    list_clusters.two_steps = [];
    list_clusters.noisy_vocal = [];
    for names = 1:size(categories,1)
        count = 0;
        name = categories{names};
        disp(['Building ' name ' list'])
        eval(['list_clusters.' name '= [];']);
        for k=1:size(time_vocal,2)
            if ~isempty(eval(['vocal_classified{k}.' name])) && isempty(vocal_classified{k}.noise)
                count = count+1;
                temp_table = [];
                for col = 1:size(time_vocal{k},2)
                    for col2 = 1:size(freq_vocal{k}{col},1)
                        temp_table = [temp_table; time_vocal{k}(col) freq_vocal{k}{col}(col2)];
                    end
                end
                
                eval(['pre_corr_table.' name '{count} = temp_table;']);
                if strcmp(name, 'complex')
                    [R_pearson,P_value]=corrcoef(temp_table);
                    R_pearson = R_pearson(1,2) ;% P_value = P_value(1,2);
                    eval(['list_clusters.' name '= [list_clusters.' name '; k max(temp_table(:,1))-min(temp_table(:,1)) max(temp_table(:,2))-min(temp_table(:,2)) R_pearson median(temp_table(:,2))];']);
                else
                    if strcmp(name, 'step_up') || strcmp(name, 'step_down')
                        if size(vocal_classified{k}.step_up,1)==1 && size(vocal_classified{k}.step_down,1)==1
                            list_clusters.two_steps = unique([list_clusters.two_steps ; k]);
                        elseif size(vocal_classified{k}.step_up,1)+ size(vocal_classified{k}.step_down,1)>1 && isempty(vocal_classified{k}.noisy_vocal)
                            list_clusters.mult_steps = unique([list_clusters.mult_steps ; k]);
                        elseif size(vocal_classified{k}.step_up,1)>0 && size(vocal_classified{k}.step_down,1)>0 && ~isempty(vocal_classified{k}.noisy_vocal) %There is step up, down and it is a noisy vocal -> Noisy Vocal
                            list_clusters.noisy_vocal = unique([list_clusters.noisy_vocal ; k]);
                        else
                            eval(['list_clusters.' name '= [list_clusters.' name '; k ];']);
                        end
                    else
                        eval(['list_clusters.' name '= [list_clusters.' name '; k ];']);
                    end
                end
            elseif strcmp(name, 'noise') && ~isempty(vocal_classified{k}.noise)
                eval(['list_clusters.' name '= [list_clusters.' name '; k ];']);
            end
        end
    end
    
    if plot_stats_per_bin ==1
        bin_1 = [];
        bin_2 = [];
        bin_3 = [];
        bin_4 = [];
        
        for k=1:size(time_vocal,2)
            if time_vocal{k}(1) < 5*60 %5min
                bin_1 = [bin_1, k];
            elseif time_vocal{k}(1) >= 5*60 && time_vocal{k}(1) < 10*60
                bin_2 = [bin_2, k];
            elseif time_vocal{k}(1) >= 10*60 && time_vocal{k}(1) < 15*60
                bin_3 = [bin_3, k];
            else
                bin_4 = [bin_4, k];
            end
        end
        
        for i=1:4
            eval(['if ~isempty(bin_' num2str(i) ') ', ...
                'bin_' num2str(i) ' = [bin_' num2str(i) '(1); bin_' num2str(i) '(end)];',...
                'else ',...
                'bin_' num2str(i) ' = [0; 0];',...
                'end']);
        end
        %
        stepup_count_bin  = [ sum(list_clusters.step_up <= bin_1(end)), sum(list_clusters.step_up >=bin_2(1) & list_clusters.step_up <=bin_2(end)), sum(list_clusters.step_up >=bin_3(1) & list_clusters.step_up <=bin_3(end)), sum(list_clusters.step_up >=bin_4(1) & list_clusters.step_up <=bin_4(end))];
        stepdown_count_bin = [ sum(stepdown_count <= bin_1(end)), sum(stepdown_count>=bin_2(1) & stepdown_count<=bin_2(end)), sum(stepdown_count>=bin_3(1) & stepdown_count<=bin_3(end)), sum(stepdown_count>=bin_4(1) & stepdown_count<=bin_4(end))];
        harmonic_count_bin  = [ sum(list_clusters.harmonic <= bin_1(end)), sum(list_clusters.harmonic >=bin_2(1) & list_clusters.harmonic <=bin_2(end)), sum(list_clusters.harmonic >=bin_3(1) & list_clusters.harmonic <=bin_3(end)), sum(list_clusters.harmonic >=bin_4(1) & list_clusters.harmonic <=bin_4(end))];
        flat_count_bin  = [ sum(list_clusters.flat <= bin_1(end)), sum(list_clusters.flat >=bin_2(1) & list_clusters.flat <=bin_2(end)), sum(list_clusters.flat >=bin_3(1) & list_clusters.flat <=bin_3(end)), sum(list_clusters.flat >=bin_4(1) & list_clusters.flat <=bin_4(end))];
        chevron_count_bin  = [ sum(list_clusters.chevron <= bin_1(end)), sum(list_clusters.chevron >=bin_2(1) & list_clusters.chevron <=bin_2(end)), sum(list_clusters.chevron >=bin_3(1) & list_clusters.chevron <=bin_3(end)), sum(list_clusters.chevron >=bin_4(1) & list_clusters.chevron <=bin_4(end))];
        revchevron_count_bin  = [ sum(list_clusters.rev_chevron <= bin_1(end)), sum(list_clusters.rev_chevron >=bin_2(1) & list_clusters.rev_chevron <=bin_2(end)), sum(list_clusters.rev_chevron >=bin_3(1) & list_clusters.rev_chevron <=bin_3(end)), sum(list_clusters.rev_chevron >=bin_4(1) & list_clusters.rev_chevron <=bin_4(end))];
        downfm_count_bin  = [ sum(list_clusters.down_fm <= bin_1(end)), sum(list_clusters.down_fm >=bin_2(1) & list_clusters.down_fm <=bin_2(end)), sum(list_clusters.down_fm >=bin_3(1) & list_clusters.down_fm <=bin_3(end)), sum(list_clusters.down_fm >=bin_4(1) & list_clusters.down_fm <=bin_4(end))];
        upfm_count_bin  = [ sum(list_clusters.up_fm <= bin_1(end)), sum(list_clusters.up_fm >=bin_2(1) & list_clusters.up_fm <=bin_2(end)), sum(list_clusters.up_fm >=bin_3(1) & list_clusters.up_fm <=bin_3(end)), sum(list_clusters.up_fm >=bin_4(1) & list_clusters.up_fm <=bin_4(end))];
        complex_count_bin  = [ sum(list_clusters.complex(:,1) <= bin_1(end)), sum(list_clusters.complex(:,1) >=bin_2(1) & list_clusters.complex(:,1) <=bin_2(end)), sum(list_clusters.complex(:,1) >=bin_3(1) & list_clusters.complex(:,1) <=bin_3(end)), sum(list_clusters.complex(:,1) >=bin_4(1) & list_clusters.complex(:,1) <=bin_4(end))];
        noisy_vocal_count_bin  = [ sum(list_clusters.noisy_vocal <= bin_1(end)), sum(list_clusters.noisy_vocal >=bin_2(1) & list_clusters.noisy_vocal <=bin_2(end)), sum(list_clusters.noisy_vocal >=bin_3(1) & list_clusters.noisy_vocal <=bin_3(end)), sum(list_clusters.noisy_vocal >=bin_4(1) & list_clusters.noisy_vocal <=bin_4(end))];
        nonlinear_count_bin  = [ sum(list_clusters.non_linear <= bin_1(end)), sum(list_clusters.non_linear >=bin_2(1) & list_clusters.non_linear <=bin_2(end)), sum(list_clusters.non_linear >=bin_3(1) & list_clusters.non_linear <=bin_3(end)), sum(list_clusters.non_linear >=bin_4(1) & list_clusters.non_linear <=bin_4(end))];
        short_count_bin  = [ sum(list_clusters.short <= bin_1(end)), sum(list_clusters.short >=bin_2(1) & list_clusters.short <=bin_2(end)), sum(list_clusters.short >=bin_3(1) & list_clusters.short <=bin_3(end)), sum(list_clusters.short >=bin_4(1) & list_clusters.short <=bin_4(end))];
        noise_count_bin  = [ sum(list_clusters.noise <= bin_1(end)), sum(list_clusters.noise >=bin_2(1) & list_clusters.noise <=bin_2(end)), sum(list_clusters.noise >=bin_3(1) & list_clusters.noise <=bin_3(end)), sum(list_clusters.noise >=bin_4(1) & list_clusters.noise <=bin_4(end))];
        two_steps_count_bin  = [ sum(list_clusters.two_steps <= bin_1(end)), sum(list_clusters.two_steps >=bin_2(1) & list_clusters.two_steps <=bin_2(end)), sum(list_clusters.two_steps >=bin_3(1) & list_clusters.two_steps <=bin_3(end)), sum(list_clusters.two_steps >=bin_4(1) & list_clusters.two_steps <=bin_4(end))];
        mult_steps_count_bin  = [ sum(list_clusters.mult_steps <= bin_1(end)), sum(list_clusters.mult_steps >=bin_2(1) & list_clusters.mult_steps <=bin_2(end)), sum(list_clusters.mult_steps >=bin_3(1) & list_clusters.mult_steps <=bin_3(end)), sum(list_clusters.mult_steps >=bin_4(1) & list_clusters.mult_steps <=bin_4(end))];
        %
        %         all_class = [stepup_count_bin; stepdown_count_bin; harmonic_count_bin; flat_count_bin; chevron_count_bin; revchevron_count_bin; downfm_count_bin; upfm_count_bin; complex_count_bin; noisy_vocal_count_bin; nonlinear_count_bin; short_count_bin; noise_count_bin; mult_steps_count_bin; two_steps_count_bin];
        %         figure('Name',['vocal_classified_' vfilename],'NumberTitle','off')
        %         bar(all_class,'stacked')
        %         Labels = {'stepup_count', 'stepdown_count', 'harmonic_count', 'flat_count', 'chevron_count', 'revchevron_count', 'downfm_count', 'upfm_count', 'complex_count', 'noisy_vocal_count', 'nonlinear_count', 'short_count','noise_count','mult_steps_count_bin','two_steps_count_bin'};
        %         %     set(gca, 'XTick', [1:12, 'XTickLabel', Labels);
        %         set(gca,'TickLabelInterpreter','none','XTick',1:size(all_class,1), 'XTickLabel',Labels','YColor','black');
        %         legend(gca,'Bin 1','Bin 2','Bin 3','Bin 4');
        
    end
    
    %Get correlation table for this vocalizations
    cd(raiz)
    %     save_plot_vocalizations(vfilename,vpathname)
    if save_plot_spectrograms==1
        figure('Name',vfilename,'NumberTitle','off')
        set (gcf, 'Units', 'normalized', 'Position', [0,0,1,1]);
        categories = [categories; 'two_steps'; 'mult_steps'];
        for names = 1:size(categories,1)
            cd(raiz)
            name = categories{names};
            disp(['Saving plots for ' name])
            if isfield(list_clusters, name) && ~strcmp(name, 'complex') && ~strcmp(name, 'harmonic_size')
                %             eval(['corr_table = similarity_VocalMat(vpathname,vfilename,pre_corr_table.' name ');']);
                %                 corr_table = [vpathname,'SimilarityBatch_',vfilename,'.csv'];
                %                 corr_table = strrep(corr_table,'\','/');
                
                %Cluster syllables
                %delete('clusters.txt')
                %[status,result]=system(['R --slave --args' ' ' char(34) corr_table char(34) ' < clusterUSV_pub.r']);
                %system(['R --slave --args' ' ' char(34) corr_table char(34) ' ' 'wavs "0.80" "5" < getClusterCenterUSV_pub.r']);
                %clustered = dlmread('clusters.txt');
                
                cd(vpathname)
                mkdir(vfilename)
                cd(vfilename)
                mkdir(name)
                
                
                %                 for ww1 = 1:size(clustered,1)
                for ww = 1:eval(['size(list_clusters.' name ',1)'])
                    c = [rand() rand() rand()];
                    %                     if (clustered(ww1,ww)) > 0
                    id_vocal = eval(['list_clusters.' name '(ww)']);
                    dx = 0.4;
                    clf('reset')
                    hold on
                    
                    T_min_max = [-dx/2 dx/2]+[time_vocal{id_vocal}(1) time_vocal{id_vocal}(1)];
                    [T_min T_min] = min(abs(T_orig - T_min_max(1)));
                    [T_max T_max] = min(abs(T_orig - T_min_max(2)));
                    
                    surf(T_orig(T_min:T_max),F_orig,A_total(:,T_min:T_max),'edgecolor','none')
                    axis tight; view(0,90);
                    colormap(gray);
                    xlabel('Time (s)'); ylabel('Freq (Hz)')
                    
                    for time_stamp = 1:size(time_vocal{id_vocal},2)
                        scatter(time_vocal{id_vocal}(time_stamp)*ones(size(freq_vocal{id_vocal}{time_stamp}')),freq_vocal{id_vocal}{time_stamp}',[],repmat(c,size(freq_vocal{id_vocal}{time_stamp}',2),1))
                    end
                    Stri=['set(gca,''xlim'',[-dx/2 dx/2]+[' num2str(time_vocal{id_vocal}(1)) ' '  num2str(time_vocal{id_vocal}(1)) '])'];
                    eval(Stri);
                    set(gca,'ylim',[0 max(F_orig)]);
                    x_pos = time_vocal{id_vocal}(ceil(end/2));
                    y_pos = freq_vocal{id_vocal}{ceil(end/2)}(ceil(end/2))+5000;
                    text(x_pos,y_pos,num2str(id_vocal),'HorizontalAlignment','left','FontSize',20,'Color','r');
                    saveas(gcf,[vpathname '/' vfilename '/'  name '/' num2str(id_vocal)  '.png'])
                    %                     end
                    hold off
                    
                end
                %                 end
                
            elseif isfield(list_clusters, name) && strcmp(name, 'complex') && ~isempty(list_clusters.complex)
                if size(list_clusters.complex,1) > 1
                    eval(['corr_table = similarity_VocalMat(vpathname,vfilename,pre_corr_table.' name ');']);
                    corr_test = list_clusters.complex(:,2:end);
                    corr_test(:,2) = corr_test(:,2)/(10^3);
                    corr_test(:,4) = corr_test(:,4)/(10^3);
                    Y = pdist(corr_test);
                    Z = linkage(Y,'single');
                    TT = cluster(Z,'cutoff',1.4,'depth',3); %TT = cluster(Z,'cutoff',2.3,'depth',4); Use this one for a test.
                    
                    cd(vpathname)
                    mkdir(vfilename)
                    cd(vfilename)
                    mkdir(name)
                    %
                    for cluster_number = 1:max(TT)
                        cd([vpathname vfilename '/' name])
                        mkdir(['Cluster_' num2str(cluster_number)]);
                        cd(['Cluster_' num2str(cluster_number)])
                        disp(['Cluster_' num2str(cluster_number)])
                        cluster_list = find(TT==cluster_number);
                        for ww = 1:size(cluster_list,1)
                            c = [rand() rand() rand()];
                            %                     if (clustered(ww1,ww)) > 0
                            id_vocal = list_clusters.complex(cluster_list(ww));
                            dx = 0.4;
                            clf('reset')
                            hold on
                            
                            T_min_max = [-dx/2 dx/2]+[time_vocal{id_vocal}(1) time_vocal{id_vocal}(1)];
                            [T_min T_min] = min(abs(T_orig - T_min_max(1)));
                            [T_max T_max] = min(abs(T_orig - T_min_max(2)));
                            surf(T_orig(T_min:T_max),F_orig,A_total(:,T_min:T_max),'edgecolor','none')
                            axis tight; view(0,90);
                            colormap(gray);
                            xlabel('Time (s)'); ylabel('Freq (Hz)')
                            
                            for time_stamp = 1:size(time_vocal{id_vocal},2)
                                scatter(time_vocal{id_vocal}(time_stamp)*ones(size(freq_vocal{id_vocal}{time_stamp}')),freq_vocal{id_vocal}{time_stamp}',[],repmat(c,size(freq_vocal{id_vocal}{time_stamp}',2),1))
                            end
                            Stri=['set(gca,''xlim'',[-dx/2 dx/2]+[' num2str(time_vocal{id_vocal}(1)) ' '  num2str(time_vocal{id_vocal}(1)) '])'];
                            eval(Stri);
                            set(gca,'ylim',[0 max(F_orig)]);
                            x_pos = time_vocal{id_vocal}(ceil(end/2));
                            y_pos = freq_vocal{id_vocal}{ceil(end/2)}(ceil(end/2))+5000;
                            text(x_pos,y_pos,num2str(id_vocal),'HorizontalAlignment','left','FontSize',20,'Color','r');
                            saveas(gcf,[vpathname '/' vfilename '/'  name '/' 'Cluster_' num2str(cluster_number) '/' num2str(id_vocal)  '.png'])
                            %                     end
                            hold off
                        end
                    end
                    
                else
                    cd(vpathname)
                    mkdir(vfilename)
                    cd(vfilename)
                    mkdir(name)
                    c = [rand() rand() rand()];
                    id_vocal = list_clusters.complex(1,1);
                    dx = 0.4;
                    clf('reset')
                    hold on
                    
                    T_min_max = [-dx/2 dx/2]+[time_vocal{id_vocal}(1) time_vocal{id_vocal}(1)];
                    [T_min T_min] = min(abs(T_orig - T_min_max(1)));
                    [T_max T_max] = min(abs(T_orig - T_min_max(2)));
                    surf(T_orig(T_min:T_max),F_orig,A_total(:,T_min:T_max),'edgecolor','none')
                    axis tight; view(0,90);
                    colormap(gray);
                    xlabel('Time (s)'); ylabel('Freq (Hz)')
                    
                    for time_stamp = 1:size(time_vocal{id_vocal},2)
                        scatter(time_vocal{id_vocal}(time_stamp)*ones(size(freq_vocal{id_vocal}{time_stamp}')),freq_vocal{id_vocal}{time_stamp}',[],repmat(c,size(freq_vocal{id_vocal}{time_stamp}',2),1))
                    end
                    Stri=['set(gca,''xlim'',[-dx/2 dx/2]+[' num2str(time_vocal{id_vocal}(1)) ' '  num2str(time_vocal{id_vocal}(1)) '])'];
                    eval(Stri);
                    set(gca,'ylim',[0 max(F_orig)]);
                    x_pos = time_vocal{id_vocal}(ceil(end/2));
                    y_pos = freq_vocal{id_vocal}{ceil(end/2)}(ceil(end/2))+5000;
                    text(x_pos,y_pos,num2str(id_vocal),'HorizontalAlignment','left','FontSize',20,'Color','r');
                    saveas(gcf,[vpathname '/' vfilename '/'  name '/'  num2str(id_vocal)  '.png'])
                end
                
            elseif isfield(list_clusters, name) && strcmp(name, 'noise')
                cd(vpathname)
                mkdir(vfilename)
                cd(vfilename)
                mkdir(name)
                
                %                 for ww1 = 1:size(clustered,1)
                for ww = 1:eval(['size(list_clusters.' name ',1)'])
                    c = [rand() rand() rand()];
                    %                     if (clustered(ww1,ww)) > 0
                    id_vocal = eval(['list_clusters.' name '(ww)']);
                    dx = 0.4;
                    clf('reset')
                    hold on
                    
                    T_min_max = [-dx/2 dx/2]+[time_vocal{id_vocal}(1) time_vocal{id_vocal}(1)];
                    [T_min, T_min] = min(abs(T_orig - T_min_max(1)));
                    [T_max, T_max] = min(abs(T_orig - T_min_max(2)));
                    surf(T_orig(T_min:T_max),F_orig,A_total(:,T_min:T_max),'edgecolor','none')
                    axis tight; view(0,90);
                    colormap(gray);
                    xlabel('Time (s)'); ylabel('Freq (Hz)')
                    
                    for time_stamp = 1:size(time_vocal{id_vocal},2)
                        scatter(time_vocal{id_vocal}(time_stamp)*ones(size(freq_vocal{id_vocal}{time_stamp}')),freq_vocal{id_vocal}{time_stamp}',[],repmat(c,size(freq_vocal{id_vocal}{time_stamp}',2),1))
                    end
                    Stri=['set(gca,''xlim'',[-dx/2 dx/2]+[' num2str(time_vocal{id_vocal}(1)) ' '  num2str(time_vocal{id_vocal}(1)) '])'];
                    eval(Stri);
                    set(gca,'ylim',[0 max(F_orig)]);
                    x_pos = time_vocal{id_vocal}(ceil(end/2));
                    y_pos = freq_vocal{id_vocal}{ceil(end/2)}(ceil(end/2))+5000;
                    text(x_pos,y_pos,num2str(id_vocal),'HorizontalAlignment','left','FontSize',20,'Color','r');
                    saveas(gcf,[vpathname '/' vfilename  '.png'])
                    %                     end
                    hold off
                end
                %                 end
            end
        end
    else
        cd(vpathname)
        mkdir(vfilename)
        cd(vfilename)
    end
    save(['vocal_classified_' vfilename],'vocal_classified','list_clusters','vfilename')
    close all
    %Generate .wav files for cohesive and split clusters
    %     system(['R --slave --args' ' ' char(34) corr_table char(34) ' ' 'wavs "0.80" "5" < getClusterCenterUSV_pub.r']);
    
    if plot_stats_per_bin == 1
        stepup_count_bin_total  = stepup_count_bin_total + stepup_count_bin;
        stepdown_count_bin_total = stepdown_count_bin_total +  stepdown_count_bin ;
        harmonic_count_bin_total  = harmonic_count_bin_total+ harmonic_count_bin;
        flat_count_bin_total  = flat_count_bin_total + flat_count_bin;
        chevron_count_bin_total  = chevron_count_bin_total + chevron_count_bin;
        revchevron_count_bin_total  = revchevron_count_bin_total + revchevron_count_bin;
        downfm_count_bin_total  = downfm_count_bin_total + downfm_count_bin;
        upfm_count_bin_total  = upfm_count_bin_total + upfm_count_bin;
        complex_count_bin_total  = complex_count_bin_total + complex_count_bin;
        noisy_vocal_count_bin_total  = noisy_vocal_count_bin_total + noisy_vocal_count_bin;
        nonlinear_count_bin_total  = nonlinear_count_bin_total + nonlinear_count_bin;
        short_count_bin_total  = short_count_bin_total + short_count_bin;
        noise_count_bin_total  = noise_count_bin_total + noise_count_bin;
        two_steps_count_bin_total  = two_steps_count_bin_total + two_steps_count_bin;
        mult_steps_count_bin_total  = mult_steps_count_bin_total + mult_steps_count_bin;
        
        disp(' ')
        disp('Number of vocalizations of each class per bin:')
        disp('Step up:')
        disp(['Bin1: ' num2str(stepup_count_bin(1)) ', Bin2: ' num2str(stepup_count_bin(2)) ', Bin3: ' num2str(stepup_count_bin(3)) ', Bin4: ' num2str(stepup_count_bin(4))]);
        disp('Step down:')
        disp(['Bin1: ' num2str(stepdown_count_bin(1)) ', Bin2: ' num2str(stepdown_count_bin(2)) ', Bin3: ' num2str(stepdown_count_bin(3)) ', Bin4: ' num2str(stepdown_count_bin(4))]);
        disp('Harmonics:')
        disp(['Bin1: ' num2str(harmonic_count_bin(1)) ', Bin2: ' num2str(harmonic_count_bin(2)) ', Bin3: ' num2str(harmonic_count_bin(3)) ', Bin4: ' num2str(harmonic_count_bin(4))]);
        disp('Flat:')
        disp(['Bin1: ' num2str(flat_count_bin(1)) ', Bin2: ' num2str(flat_count_bin(2)) ', Bin3: ' num2str(flat_count_bin(3)) ', Bin4: ' num2str(flat_count_bin(4))]);
        disp('Chevron:')
        disp(['Bin1: ' num2str(chevron_count_bin(1)) ', Bin2: ' num2str(chevron_count_bin(2)) ', Bin3: ' num2str(chevron_count_bin(3)) ', Bin4: ' num2str(chevron_count_bin(4))]);
        disp('Rev Chevron:')
        disp(['Bin1: ' num2str(revchevron_count_bin(1)) ', Bin2: ' num2str(revchevron_count_bin(2)) ', Bin3: ' num2str(revchevron_count_bin(3)) ', Bin4: ' num2str(revchevron_count_bin(4))]);
        disp('Down FM:')
        disp(['Bin1: ' num2str(downfm_count_bin(1)) ', Bin2: ' num2str(downfm_count_bin(2)) ', Bin3: ' num2str(downfm_count_bin(3)) ', Bin4: ' num2str(downfm_count_bin(4))]);
        disp('Up FM:')
        disp(['Bin1: ' num2str(upfm_count_bin(1)) ', Bin2: ' num2str(upfm_count_bin(2)) ', Bin3: ' num2str(upfm_count_bin(3)) ', Bin4: ' num2str(upfm_count_bin(4))]);
        disp('Complex:')
        disp(['Bin1: ' num2str(complex_count_bin(1)) ', Bin2: ' num2str(complex_count_bin(2)) ', Bin3: ' num2str(complex_count_bin(3)) ', Bin4: ' num2str(complex_count_bin(4))]);
        disp('Noisy Vocal:')
        disp(['Bin1: ' num2str(noisy_vocal_count_bin(1)) ', Bin2: ' num2str(noisy_vocal_count_bin(2)) ', Bin3: ' num2str(noisy_vocal_count_bin(3)) ', Bin4: ' num2str(noisy_vocal_count_bin(4))]);
        disp('Non Linear:')
        disp(['Bin1: ' num2str(nonlinear_count_bin(1)) ', Bin2: ' num2str(nonlinear_count_bin(2)) ', Bin3: ' num2str(nonlinear_count_bin(3)) ', Bin4: ' num2str(nonlinear_count_bin(4))]);
        disp('Short:')
        disp(['Bin1: ' num2str(short_count_bin(1)) ', Bin2: ' num2str(short_count_bin(2)) ', Bin3: ' num2str(short_count_bin(3)) ', Bin4: ' num2str(short_count_bin(4))]);
        disp('Noise:')
        disp(['Bin1: ' num2str(noise_count_bin(1)) ', Bin2: ' num2str(noise_count_bin(2)) ', Bin3: ' num2str(noise_count_bin(3)) ', Bin4: ' num2str(noise_count_bin(4))]);
        disp('Two steps:')
        disp(['Bin1: ' num2str(two_steps_count_bin(1)) ', Bin2: ' num2str(two_steps_count_bin(2)) ', Bin3: ' num2str(two_steps_count_bin(3)) ', Bin4: ' num2str(two_steps_count_bin(4))]);
        disp('Mult steps:')
        disp(['Bin1: ' num2str(mult_steps_count_bin(1)) ', Bin2: ' num2str(mult_steps_count_bin(2)) ', Bin3: ' num2str(mult_steps_count_bin(3)) ', Bin4: ' num2str(mult_steps_count_bin(4))]);
        
        if save_histogram_per_animal==1
            all_class = [stepup_count_bin; stepdown_count_bin; harmonic_count_bin; flat_count_bin; chevron_count_bin; revchevron_count_bin; downfm_count_bin; upfm_count_bin; complex_count_bin; noisy_vocal_count_bin; nonlinear_count_bin; short_count_bin; noise_count_bin; mult_steps_count_bin; two_steps_count_bin];
            figure('Name',['vocal_classified_' vfilename],'NumberTitle','off')
            bar(all_class,'stacked')
            Labels = {'step_up ', 'step_down ', 'harmonic ', 'flat ', 'chevron ', 'rev_chevron ', 'down_fm ', 'up_fm ', 'complex ', 'noisy_vocal ', 'non_linear ', 'short ','noise ','mult_steps','two_steps'};
            set(gca,'TickLabelInterpreter','none','XTick',1:size(all_class,1), 'XTickLabel',Labels','YColor','black');
            legend(gca,'Bin 1','Bin 2','Bin 3','Bin 4');
            set (gcf, 'Units', 'normalized', 'Position', [0,0,1,1]);
            saveas(gcf,[vpathname  vfilename '\' vfilename '.jpg'])
            close
        end
    end
    
    if save_excel_file==1
        names = fieldnames(list_clusters);
        names = [{'Names_vocal'}; names];
        tabela = zeros(size(vocal_classified,2),size(names,1));
        tabela(:,1) = 1:size(vocal_classified,2);
        
        for i = 2:size(names,1)
            if eval(['~isempty(list_clusters.' names{i} ')'])
                eval(['tabela(list_clusters.' names{i} '(:,1),i)=1;']);
            end
        end
        
        names = transpose(names);
        T = array2table(tabela);
        T.Properties.VariableNames = names;
        
        writetable(T,[vfilename '.xlsx'])
        
        names2 = fieldnames(vocal_classified{1});
        names2 = [{'Names_vocal'}; names2];
        tabela2 = zeros(size(vocal_classified,2),size(names2,1));
        tabela2(:,1) = 1:size(vocal_classified,2);
        for i=1:size(vocal_classified,2)
            for j = 2:size(names2,1)-1
                if eval(['~isempty(vocal_classified{i}.' names2{j} ')'])
                    tabela2(i,j)=1;
                end
            end
        end
        
        names2 = transpose(names2);
        T2 = array2table(tabela2);
        T2.Properties.VariableNames = names2;
        
        writetable(T2,[vfilename '.xlsx'],'Sheet',2)
    end
    
    %Move all the pics to 'All' folder
    if save_plot_spectrograms==1
        mkdir('All')
        p = pwd;
        cd(raiz)
        lista = rdir([p, '\**\*.png']);
        cd(p)
        p = strcat(p, '\All');
        
        for i=1:size(lista,1)
            copyfile(lista(i).name,p)
        end
    end
end

if plot_stats_per_bin ==1
    total = stepup_count_bin_total + stepdown_count_bin_total + harmonic_count_bin_total  + flat_count_bin_total + chevron_count_bin_total + revchevron_count_bin_total  + downfm_count_bin_total + upfm_count_bin_total + complex_count_bin_total  + noisy_vocal_count_bin_total + nonlinear_count_bin_total + short_count_bin_total + noise_count_bin_total + two_steps_count_bin_total + mult_steps_count_bin_total ;
    
    all_class = [stepup_count_bin_total; stepdown_count_bin_total; harmonic_count_bin_total; flat_count_bin_total; chevron_count_bin_total; revchevron_count_bin_total; downfm_count_bin_total; upfm_count_bin_total; complex_count_bin_total; noisy_vocal_count_bin_total; nonlinear_count_bin_total; short_count_bin_total; noise_count_bin_total; mult_steps_count_bin_total; two_steps_count_bin_total];
    figure('Name',['vocal_classified_' vfilename],'NumberTitle','off')
    bar(all_class,'stacked')
    Labels = {'step_up ', 'step_down ', 'harmonic ', 'flat ', 'chevron ', 'rev_chevron ', 'down_fm ', 'up_fm ', 'complex ', 'noisy_vocal ', 'non_linear ', 'short ','noise ','mult_steps','two_steps'};
    set(gca,'TickLabelInterpreter','none','XTick',1:size(all_class,1), 'XTickLabel',Labels','YColor','black');
    legend(gca,'Bin 1','Bin 2','Bin 3','Bin 4');
    set (gcf, 'Units', 'normalized', 'Position', [0,0,1,1]);
    experiment_name = strsplit(vpathname,{'\','/'});
    experiment_name = experiment_name(end-2);
    saveas(gcf,[vpathname  experiment_name{1} '.jpg'])
    
    disp(' ')
    disp('Number of vocalizations of each class per bin for all experiments:')
    disp('Step up:')
    disp(['Bin1: ' num2str(stepup_count_bin_total(1)) ', Bin2: ' num2str(stepup_count_bin_total(2)) ', Bin3: ' num2str(stepup_count_bin_total(3)) ', Bin4: ' num2str(stepup_count_bin_total(4))]);
    disp('Step down:')
    disp(['Bin1: ' num2str(stepdown_count_bin_total(1)) ', Bin2: ' num2str(stepdown_count_bin_total(2)) ', Bin3: ' num2str(stepdown_count_bin_total(3)) ', Bin4: ' num2str(stepdown_count_bin_total(4))]);
    disp('Harmonics:')
    disp(['Bin1: ' num2str(harmonic_count_bin_total(1)) ', Bin2: ' num2str(harmonic_count_bin_total(2)) ', Bin3: ' num2str(harmonic_count_bin_total(3)) ', Bin4: ' num2str(harmonic_count_bin_total(4))]);
    disp('Flat:')
    disp(['Bin1: ' num2str(flat_count_bin_total(1)) ', Bin2: ' num2str(flat_count_bin_total(2)) ', Bin3: ' num2str(flat_count_bin_total(3)) ', Bin4: ' num2str(flat_count_bin_total(4))]);
    disp('Chevron:')
    disp(['Bin1: ' num2str(chevron_count_bin_total(1)) ', Bin2: ' num2str(chevron_count_bin_total(2)) ', Bin3: ' num2str(chevron_count_bin_total(3)) ', Bin4: ' num2str(chevron_count_bin_total(4))]);
    disp('Rev Chevron:')
    disp(['Bin1: ' num2str(revchevron_count_bin_total(1)) ', Bin2: ' num2str(revchevron_count_bin_total(2)) ', Bin3: ' num2str(revchevron_count_bin_total(3)) ', Bin4: ' num2str(revchevron_count_bin_total(4))]);
    disp('Down FM:')
    disp(['Bin1: ' num2str(downfm_count_bin_total(1)) ', Bin2: ' num2str(downfm_count_bin_total(2)) ', Bin3: ' num2str(downfm_count_bin_total(3)) ', Bin4: ' num2str(downfm_count_bin_total(4))]);
    disp('Up FM:')
    disp(['Bin1: ' num2str(upfm_count_bin_total(1)) ', Bin2: ' num2str(upfm_count_bin_total(2)) ', Bin3: ' num2str(upfm_count_bin_total(3)) ', Bin4: ' num2str(upfm_count_bin_total(4))]);
    disp('Complex:')
    disp(['Bin1: ' num2str(complex_count_bin_total(1)) ', Bin2: ' num2str(complex_count_bin_total(2)) ', Bin3: ' num2str(complex_count_bin_total(3)) ', Bin4: ' num2str(complex_count_bin_total(4))]);
    disp('Noisy Vocal:')
    disp(['Bin1: ' num2str(noisy_vocal_count_bin_total(1)) ', Bin2: ' num2str(noisy_vocal_count_bin_total(2)) ', Bin3: ' num2str(noisy_vocal_count_bin_total(3)) ', Bin4: ' num2str(noisy_vocal_count_bin_total(4))]);
    disp('Non Linear:')
    disp(['Bin1: ' num2str(nonlinear_count_bin_total(1)) ', Bin2: ' num2str(nonlinear_count_bin_total(2)) ', Bin3: ' num2str(nonlinear_count_bin_total(3)) ', Bin4: ' num2str(nonlinear_count_bin_total(4))]);
    disp('Short:')
    disp(['Bin1: ' num2str(short_count_bin_total(1)) ', Bin2: ' num2str(short_count_bin_total(2)) ', Bin3: ' num2str(short_count_bin_total(3)) ', Bin4: ' num2str(short_count_bin_total(4))]);
    disp('Noise:')
    disp(['Bin1: ' num2str(noise_count_bin_total(1)) ', Bin2: ' num2str(noise_count_bin_total(2)) ', Bin3: ' num2str(noise_count_bin_total(3)) ', Bin4: ' num2str(noise_count_bin_total(4))]);
    disp('Two steps:')
    disp(['Bin1: ' num2str(two_steps_count_bin_total(1)) ', Bin2: ' num2str(two_steps_count_bin_total(2)) ', Bin3: ' num2str(two_steps_count_bin_total(3)) ', Bin4: ' num2str(two_steps_count_bin_total(4))]);
    disp('Mult steps:')
    disp(['Bin1: ' num2str(mult_steps_count_bin_total(1)) ', Bin2: ' num2str(mult_steps_count_bin_total(2)) ', Bin3: ' num2str(mult_steps_count_bin_total(3)) ', Bin4: ' num2str(mult_steps_count_bin_total(4))]);
    
    
    all_class2 = all_class/sum(total);
    figure('Name',['vocal_classified_' vfilename '(%)'],'NumberTitle','off')
    bar(all_class2,'stacked')
    Labels = {'step_up ', 'step_down ', 'harmonic ', 'flat ', 'chevron ', 'rev_chevron ', 'down_fm ', 'up_fm ', 'complex ', 'noisy_vocal ', 'non_linear ', 'short ','noise ','mult_steps','two_steps'};
    set(gca,'TickLabelInterpreter','none','XTick',1:size(all_class,1), 'XTickLabel',Labels','YColor','black');
    legend(gca,'Bin 1','Bin 2','Bin 3','Bin 4');
    set (gcf, 'Units', 'normalized', 'Position', [0,0,1,1]);
    % disp(['Time to plot all the vocalizations: ' num2str(toc)]);
    saveas(gcf,[vpathname  experiment_name{1} '_%_' '.jpg'])
end

diary('off');