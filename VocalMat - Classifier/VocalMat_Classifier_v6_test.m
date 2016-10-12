% Aug 31th, 2016: This script intends to classify the vocalization in the
% eleven different categories we currently have described by Grimsley, Jasmine MS, Jessica JM Monaghan, and Jeffrey J. Wenstrup. "Development of social vocalizations in mice." PloS one 6.3 (2011): e17460.

clc
clear all
raiz = pwd;
[vfilename,vpathname] = uigetfile({'*.mat'},'Select the output file');
cd(vpathname);
list = dir('*output*.mat');

for Name=2%1:size(list,1)
    vfilename = list(Name).name;
    vfilename = vfilename(1:end-4);
    vfile = fullfile(vpathname,vfilename);
    
    clearvars -except list raiz vfile vfilename vpathname
    
    disp(['Reading ' vfilename])
    load(vfile);
    
    %We are gonna get only 10 points (time stamps) to classify the vocalization
    %Grimsley, Jasmine, Marie Gadziola, and Jeff James Wenstrup. "Automated classification of mouse pup isolation syllables: from cluster analysis to an Excel-based “mouse pup syllable classification calculator”." Frontiers in behavioral neuroscience 6 (2013): 89.
    disp('Verify vocalizations for steps')
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
            if k==212
                k
            end
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
                    else
                        aux = freq_vocal{k}{time_stamp+1} - current_freq(end)*ones(size(freq_vocal{k}{time_stamp+1},1),1);
                        [mini,mini]=min(abs(aux));
                        temp = freq_vocal{k}{time_stamp+1};
                        current_freq = [current_freq; temp(mini)]; temp(mini) = [];
                        harmonic_candidate = [harmonic_candidate; temp];
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
                        else
                            if size(harmonic_candidate,1)>10% && size(harmonic_candidate,1)/ size(current_freq,1)>0.8 %If the harmonic is big and close to the size of current_freq
                                disp(['Vocalization ' num2str(k) ' had an harmonic in t = ' num2str(start_harmonic) 's']);
                                vocal_classified{k}.harmonic = [vocal_classified{k}.harmonic; start_harmonic];
                                vocal_classified{k}.harmonic_size = [vocal_classified{k}.harmonic_size; size(harmonic_candidate,1)];
                                current_freq = harmonic_candidate;
                                harmonic_candidate = [];
                                harmonic_count = [harmonic_count;k];
                            else
                                current_freq(end-size(harmonic_candidate,1)+1:end) = harmonic_candidate;
                                current_freq = [current_freq; freq_vocal{k}{time_stamp+1}];
                                harmonic_candidate = [];
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
                            if size(harmonic_candidate,1)>10 % at least 5 points to say it was really an harmonic
                                disp(['Vocalization ' num2str(k) ' had an harmonic in t = ' num2str(start_harmonic) 's']);
                                vocal_classified{k}.harmonic = [vocal_classified{k}.harmonic; start_harmonic];
                                vocal_classified{k}.harmonic_size = [vocal_classified{k}.harmonic_size; size(harmonic_candidate,1)];
                                harmonic_count = [harmonic_count;k];
                            end
                        end
                        
                        harmonic_candidate = [];
                    end
                    
                else
                    aux = freq_vocal{k}{time_stamp+1} - freq_vocal{k}{time_stamp};
                    current_freq = [current_freq; freq_vocal{k}{time_stamp+1}];
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
        temp2 = find(aux(2:end)>=10000);
        if any(aux(2:end)>=10000) && (size(aux,1)-temp2(end)>10)
            disp(['Vocalization ' num2str(k) ' had a step up in t = ' num2str(time_vocal{k}(find(aux(2:end)>5000)+2)) 's']);
            vocal_classified{k}.step_up = [vocal_classified{k}.step_up; time_vocal{k}(find(aux(2:end)>5000)+2)'];
            stepup_count = [stepup_count;k];
        elseif size(temp2,1)>0 && (size(aux,1)-temp2(end)<10) %Delete the final portion of the vocalization (probabily noise)
            current_freq(temp2+1:end)=[];
        end
        temp2 = find(aux(2:end)<=-10000);
        if any(aux(2:end)<=-10000) && (size(aux,1)-temp2(end)>10)
            disp(['Vocalization ' num2str(k) ' had a step down in t = ' num2str(time_vocal{k}(find(aux(2:end)<-5000)+2)) 's']);
            vocal_classified{k}.step_down = [vocal_classified{k}.step_down; time_vocal{k}(find(aux(2:end)<-5000)+2)'];
            stepdown_count = [stepdown_count;k];
        elseif size(temp2,1)>0 && (size(aux,1)-temp2(end)<10) %Delete the final portion of the vocalization (probabily noise)
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
                if sum(sign(aux)<0)/size(current_freq,1)>0.7 %Down FM
                    vocal_classified{k}.down_fm = time_vocal{k}(1);
                    downfm_count = [downfm_count;k];
                elseif sum(sign(aux)>0)/size(current_freq,1)>0.7 %Up FM
                    vocal_classified{k}.up_fm = time_vocal{k}(1);
                    upfm_count = [upfm_count;k];
                else
                    if (max(current_freq)-current_freq(1)> 6000 && max(current_freq)-current_freq(end)> 6000) %Chevron
                        [max_local max_local] = max(current_freq);
                        aux2 = aux(2:max_local);
                        aux3 = aux(max_local:end);
                        if sum(sign(aux2)>0)/size(current_freq,1)>0.7 && sum(sign(aux3)<0)/size(current_freq,1)>0.7 %The "U" shape is verified
                            vocal_classified{k}.chevron = time_vocal{k}(1);
                            chevron_count = [chevron_count;k];
                        end
                    elseif (current_freq(1) - min(current_freq)> 6000 && current_freq(end) - min(current_freq)> 6000)
                        [min_local min_local] = min(current_freq);
                        aux2 = aux(2:min_local);
                        aux3 = aux(min_local:end);
                        if sum(sign(aux2)<0)/size(current_freq,1)>0.7 && sum(sign(aux3)>0)/size(current_freq,1)>0.7 %The inverted "U" shape is verified
                            vocal_classified{k}.rev_chevron = time_vocal{k}(1);
                            revchevron_count = [revchevron_count;k];
                        end
                    end
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
                if sum(sign(aux)<0)/size(current_freq,1)>0.7 %Down FM
                    vocal_classified{k}.down_fm = time_vocal{k}(1);
                    downfm_count = [downfm_count;k];
                elseif sum(sign(aux)>0)/size(current_freq,1)>0.7 %Up FM
                    vocal_classified{k}.up_fm = time_vocal{k}(1);
                    upfm_count = [upfm_count;k];
                else
                    if (max(current_freq)-current_freq(1)> 6000 && max(current_freq)-current_freq(end)> 6000) %Chevron
                        [max_local max_local] = max(current_freq);
                        aux2 = aux(2:max_local);
                        aux3 = aux(max_local:end);
                        if sum(sign(aux2)>0)/size(current_freq,1)>0.7 && sum(sign(aux3)<0)/size(current_freq,1)>0.7 %The "U" shape is verified
                            vocal_classified{k}.chevron = time_vocal{k}(1);
                            chevron_count = [chevron_count;k];
                        end
                    elseif (current_freq(1) - min(current_freq)> 6000 && current_freq(end) - min(current_freq)> 6000)
                        [min_local min_local] = min(current_freq);
                        aux2 = aux(2:min_local);
                        aux3 = aux(min_local:end);
                        if sum(sign(aux2)<0)/size(current_freq,1)>0.7 && sum(sign(aux3)>0)/size(current_freq,1)>0.7 %The inverted "U" shape is verified
                            vocal_classified{k}.rev_chevron = time_vocal{k}(1);
                            revchevron_count = [revchevron_count;k];
                        end
                    end
                end
%             end
            if isempty(cell2mat(struct2cell(vocal_classified{k}))) %If it is still empty, has to be complex
                vocal_classified{k}.complex = time_vocal{k}(1);
                complex_count = [complex_count;k];
            end
        end
        
        %     if ~isempty(vocal_classified{k}.harmonic) %Had harmonic
        %         k
        %     end
        
        %Plot how many
        
        
%         aux4 = transpose(freq_vocal{k});
%         aux3 = [];
%         for tttt = 1:size(aux4,1)
%             aux3 = [aux3; aux4{tttt}];
%         end
%         tamanho = size(aux3,1);
%         aux7 = Entropy(aux3);
%         aux3 = aux3 - circshift(aux3 ,[1,0]);
%         aux3 = abs(aux3);
%         aux3 = [sum(aux3>1000), tamanho];
%         aux6 = current_freq - circshift(current_freq ,[1,0]);
%         aux6 = find(aux5>1000);
%         if isempty(aux6)
%             aux6=0;
%         end
        
        %Extra filtering by removing the points with intensity below 5% of the average
        tabela = [];
%         for jj = 207% 1:size(time_vocal,2)
            for kk = 1:size(time_vocal{k},2)
                for ll = 1:size(freq_vocal{k}{kk},1)
                    tabela = [tabela; time_vocal{k}(kk) freq_vocal{k}{kk}(ll)];
                end
            end
%         end

%         ZZ = VocalMat_heatmap(tabela);
        tabela = [tabela intens_vocal{k}];
        tamanho = size(tabela,1);
        aux3 = tabela(:,2) - circshift(tabela(:,2),[1,0]);
        aux3 = [sum(abs(aux3)>1000), tamanho];
        [f,xi]=ksdensity(tabela(:,2));
        [pks,locs]=findpeaks(f);
        if aux3(1)/aux3(2)>=0.75
            size_fields = size(vocal_classified{k}.step_up,1)+size(vocal_classified{k}.step_down,1)+size(vocal_classified{k}.harmonic,1)+size(vocal_classified{k}.flat,1)+size(vocal_classified{k}.chevron,1)+size(vocal_classified{k}.rev_chevron,1)+size(vocal_classified{k}.down_fm,1)+size(vocal_classified{k}.up_fm,1)+size(vocal_classified{k}.complex,1)+size(vocal_classified{k}.short,1);
            if size(pks,2)>1 && size_fields >= size(pks,2) && size_fields<size(pks,2)+floor(tamanho/30)
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
            tabela = tabela(tabela(:,3)>mean(tabela(:,3))*(1-0.05),:);
            tamanho2 = size(tabela,1);
            aux4 = tabela(:,2) - circshift(tabela(:,2),[1,0]);
            aux4 = [sum(abs(aux4)>1000), tamanho2];
            if aux4(1)/aux4(2)<0.5
                aux5 = 2; %'noisy_vocal vocal';
                if isempty(vocal_classified{k}.noisy_vocal)
                    vocal_classified{k}.noisy_vocal = time_vocal{k}(1);
                    noisy_vocal_count = [noisy_vocal_count;k];
                end
            elseif aux4(1)/aux4(2)>=0.7
                size_fields = size(vocal_classified{k}.step_up,1)+size(vocal_classified{k}.step_down,1)+size(vocal_classified{k}.harmonic,1)+size(vocal_classified{k}.flat,1)+size(vocal_classified{k}.chevron,1)+size(vocal_classified{k}.rev_chevron,1)+size(vocal_classified{k}.down_fm,1)+size(vocal_classified{k}.up_fm,1)+size(vocal_classified{k}.complex,1)+size(vocal_classified{k}.short,1);
                if size(pks,2)>1 && size_fields >= size(pks,2) && size_fields<size(pks,2)+floor(tamanho/30)
                    aux5 = 0; %'noisy_vocal vocal';
                else
                    if ~isempty(vocal_classified{k}.harmonic_size) && max(vocal_classified{k}.harmonic_size)>=15 % && max(vocal_classified{k}.harmonic_size)/size(time_vocal{k},2)>0.5
                        
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
    
    % Identifying how many types of vocal happened in each bin
    stepup_count_bin = [ sum(stepup_count <= bin_1(end)), sum(stepup_count>=bin_2(1) & stepup_count<=bin_2(end)), sum(stepup_count>=bin_3(1) & stepup_count<=bin_3(end)), sum(stepup_count>=bin_4(1) & stepup_count<=bin_4(end))];
    stepdown_count_bin = [ sum(stepdown_count <= bin_1(end)), sum(stepdown_count>=bin_2(1) & stepdown_count<=bin_2(end)), sum(stepdown_count>=bin_3(1) & stepdown_count<=bin_3(end)), sum(stepdown_count>=bin_4(1) & stepdown_count<=bin_4(end))];
    harmonic_count_bin = [ sum(harmonic_count <= bin_1(end)), sum(harmonic_count>=bin_2(1) & harmonic_count<=bin_2(end)), sum(harmonic_count>=bin_3(1) & harmonic_count<=bin_3(end)), sum(harmonic_count>=bin_4(1) & harmonic_count<=bin_4(end))];
    flat_count_bin = [ sum(flat_count <= bin_1(end)), sum(flat_count>=bin_2(1) & flat_count<=bin_2(end)), sum(flat_count>=bin_3(1) & flat_count<=bin_3(end)), sum(flat_count>=bin_4(1) & flat_count<=bin_4(end))];
    chevron_count_bin = [ sum(chevron_count <= bin_1(end)), sum(chevron_count>=bin_2(1) & chevron_count<=bin_2(end)), sum(chevron_count>=bin_3(1) & chevron_count<=bin_3(end)), sum(chevron_count>=bin_4(1) & chevron_count<=bin_4(end))];
    revchevron_count_bin = [ sum(revchevron_count <= bin_1(end)), sum(revchevron_count>=bin_2(1) & revchevron_count<=bin_2(end)), sum(revchevron_count>=bin_3(1) & revchevron_count<=bin_3(end)), sum(revchevron_count>=bin_4(1) & revchevron_count<=bin_4(end))];
    downfm_count_bin = [ sum(downfm_count <= bin_1(end)), sum(downfm_count>=bin_2(1) & downfm_count<=bin_2(end)), sum(downfm_count>=bin_3(1) & downfm_count<=bin_3(end)), sum(downfm_count>=bin_4(1) & downfm_count<=bin_4(end))];
    upfm_count_bin = [ sum(upfm_count <= bin_1(end)), sum(upfm_count>=bin_2(1) & upfm_count<=bin_2(end)), sum(upfm_count>=bin_3(1) & upfm_count<=bin_3(end)), sum(upfm_count>=bin_4(1) & upfm_count<=bin_4(end))];
    complex_count_bin = [ sum(complex_count <= bin_1(end)), sum(complex_count>=bin_2(1) & complex_count<=bin_2(end)), sum(complex_count>=bin_3(1) & complex_count<=bin_3(end)), sum(complex_count>=bin_4(1) & complex_count<=bin_4(end))];
    noisy_vocal_count_bin = [ sum(noisy_vocal_count <= bin_1(end)), sum(noisy_vocal_count>=bin_2(1) & noisy_vocal_count<=bin_2(end)), sum(noisy_vocal_count>=bin_3(1) & noisy_vocal_count<=bin_3(end)), sum(noisy_vocal_count>=bin_4(1) & noisy_vocal_count<=bin_4(end))];
    nonlinear_count_bin = [ sum(nonlinear_count <= bin_1(end)), sum(nonlinear_count>=bin_2(1) & nonlinear_count<=bin_2(end)), sum(nonlinear_count>=bin_3(1) & nonlinear_count<=bin_3(end)), sum(nonlinear_count>=bin_4(1) & nonlinear_count<=bin_4(end))];
    short_count_bin = [ sum(short_count <= bin_1(end)), sum(short_count>=bin_2(1) & short_count<=bin_2(end)), sum(short_count>=bin_3(1) & short_count<=bin_3(end)), sum(short_count>=bin_4(1) & short_count<=bin_4(end))];
    noise_count_bin = [ sum(noise_count <= bin_1(end)), sum(noise_count>=bin_2(1) & noise_count<=bin_2(end)), sum(noise_count>=bin_3(1) & noise_count<=bin_3(end)), sum(noise_count>=bin_4(1) & noise_count<=bin_4(end))];
    
    

    save(['vocal_classified_' vfilename],'vocal_classified')
%     all_class = [size(stepup_count,1) size(stepdown_count,1) size(harmonic_count,1) size(flat_count,1) size(chevron_count,1) size(revchevron_count,1) size(downfm_count,1) size(upfm_count,1) size(complex_count,1) size(noisy_vocal_count,1) size(nonlinear_count,1) size(short_count,1)];
    all_class = [stepup_count_bin; stepdown_count_bin; harmonic_count_bin; flat_count_bin; chevron_count_bin; revchevron_count_bin; downfm_count_bin; upfm_count_bin; complex_count_bin; noisy_vocal_count_bin; nonlinear_count_bin; short_count_bin;noise_count_bin];
    figure('Name',['vocal_classified_' vfilename],'NumberTitle','off')
    bar(all_class,'stacked')
    Labels = {'stepup_count', 'stepdown_count', 'harmonic_count', 'flat_count', 'chevron_count', 'revchevron_count', 'downfm_count', 'upfm_count', 'complex_count', 'noisy_vocal_count', 'nonlinear_count', 'short_count','noise_count'};
%     set(gca, 'XTick', [1:12, 'XTickLabel', Labels);
    set(gca,'TickLabelInterpreter','none','XTick',1:size(all_class,1), 'XTickLabel',Labels','YColor','black');
    legend(gca,'Bin 1','Bin 2','Bin 3','Bin 4');
    
end
% disp(['Time to plot all the vocalizations: ' num2str(toc)]);