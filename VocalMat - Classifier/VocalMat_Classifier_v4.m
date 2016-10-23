% Aug 31th, 2016: This script intends to classify the vocalization in the
% eleven different categories we currently have described by Grimsley, Jasmine MS, Jessica JM Monaghan, and Jeffrey J. Wenstrup. "Development of social vocalizations in mice." PloS one 6.3 (2011): e17460.

clc
clear all
raiz = pwd;
[vfilename,vpathname] = uigetfile({'*.mat'},'Select the output file');
cd(vpathname);
list = dir('*.mat');

for Name=5%1:size(list,1)
    vfilename = list(Name).name;
    vfilename = vfilename(1:end-4);
    vfile = fullfile(vpathname,vfilename);
    
    clearvars -except list raiz vfile vfilename vpathname
    
    disp(['Reading ' vfilename])
    load(vfile);
    
    %We are gonna get only 10 points (time stamps) to classify the vocalization
    %Grimsley, Jasmine, Marie Gadziola, and Jeff James Wenstrup. "Automated classification of mouse pup isolation syllables: from cluster analysis to an Excel-based “mouse pup syllable classification calculator”." Frontiers in behavioral neuroscience 6 (2013): 89.
    disp('Verify vocalizations for steps')
    stepup_count=0;
    stepdown_count=0;
    harmonic_count=0;
    flat_count=0;
    chevron_count=0;
    revchevron_count=0;
    downfm_count=0;
    upfm_count=0;
    complex_count=0;
    noisy_count=0;
    nonlinear_count = 0;
    short_count = 0;
    
    for k=1:size(time_vocal,2)
            if k==60
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
        vocal_classified{k}.noisy = [];
        vocal_classified{k}.non_linear = [];
        vocal_classified{k}.short =  [];
        
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
                            current_freq = [current_freq; freq_vocal{k}{time_stamp+1}];
                            harmonic_candidate = [];
                        else
                            if size(harmonic_candidate,1)>10 && size(harmonic_candidate,1)/ size(current_freq,1)>0.8 %If the harmonic is big and close to the size of current_freq
                                disp(['Vocalization ' num2str(k) ' had an harmonic in t = ' num2str(start_harmonic) 's']);
                                current_freq = harmonic_candidate;
                                harmonic_candidate = [];
                                vocal_classified{k}.harmonic = [vocal_classified{k}.harmonic; start_harmonic];
                                harmonic_count = harmonic_count +1;
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
                        if size(test_harmonic,1)>3 %too many jumps in frequency... should be noise or noisy vocalization.
                            vocal_classified{k}.noisy = time_vocal{k}(1);
                            noisy_count = noisy_count +1;
                        else
                            current_freq = [current_freq; freq_vocal{k}{time_stamp+1}];
                            if size(harmonic_candidate,1)>10 % at least 5 points to say it was really an harmonic
                                disp(['Vocalization ' num2str(k) ' had an harmonic in t = ' num2str(start_harmonic) 's']);
                                vocal_classified{k}.harmonic = [vocal_classified{k}.harmonic; start_harmonic];
                                harmonic_count = harmonic_count +1;
                            end
                        end
                        
                        harmonic_candidate = [];
                    end
                    
                else
                    aux = freq_vocal{k}{time_stamp+1} - freq_vocal{k}{time_stamp};
                    current_freq = [current_freq; freq_vocal{k}{time_stamp+1}];
                    if (aux>=10000)
%                         current_freq = freq_vocal{k}{time_stamp+1};
                        idx_stepdown_time = time_vocal{k}(time_stamp);
                        disp(['Vocalization ' num2str(k) ' had a step up in t = ' num2str(idx_stepdown_time)]);
                        vocal_classified{k}.step_up = [vocal_classified{k}.step_up; idx_stepdown_time];
                        stepup_count = stepup_count+1;
                    elseif (aux<=(-10000))
%                         current_freq = freq_vocal{k}{time_stamp+1};
                        idx_stepup_time = time_vocal{k}(time_stamp);
                        disp(['Vocalization ' num2str(k) ' had a step down in t = ' num2str(idx_stepup_time)]);
                        vocal_classified{k}.step_down = [vocal_classified{k}.step_down; idx_stepup_time];
                        stepdown_count = stepdown_count+1;
                    end
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
            stepup_count = stepup_count+1;
        elseif size(temp2,1)>0 && (size(aux,1)-temp2(end)<10) %Delete the final portion of the vocalization (probabily noise)
            current_freq(temp2+1:end)=[];
        end
        temp2 = find(aux(2:end)<=-10000);
        if any(aux(2:end)<=-10000) && (size(aux,1)-temp2(end)>10)
            disp(['Vocalization ' num2str(k) ' had a step down in t = ' num2str(time_vocal{k}(find(aux(2:end)<-5000)+2)) 's']);
            vocal_classified{k}.step_down = [vocal_classified{k}.step_down; time_vocal{k}(find(aux(2:end)<-5000)+2)'];
            stepdown_count = stepdown_count+1;
        elseif size(temp2,1)>0 && (size(aux,1)-temp2(end)<10) %Delete the final portion of the vocalization (probabily noise)
            current_freq(temp2+1:end)=[];
        end
        
        if (isempty(cell2mat(struct2cell(vocal_classified{k}))) || ~isempty(vocal_classified{k}.harmonic)) %It means there was no step up, down or harmonic
            if max(current_freq)-min(current_freq) <= 6000 % flat
                if time_vocal{k}(end) - time_vocal{k}(1) < 0.0065
                    vocal_classified{k}.short =  time_vocal{k}(1);
                    short_count = short_count+1;
                else
                    vocal_classified{k}.flat =  time_vocal{k}(1);
                    flat_count = flat_count+1;
                end
            else
                time_stamps = round(linspace(1,size(current_freq',2),10));
                aux = current_freq;
                aux = aux-circshift(aux ,[1,0]);
                if sum(sign(aux)<0)/size(current_freq,1)>0.7 %Down FM
                    vocal_classified{k}.down_fm = time_vocal{k}(1);
                    downfm_count = downfm_count+1;
                elseif sum(sign(aux)>0)/size(current_freq,1)>0.7 %Up FM
                    vocal_classified{k}.up_fm = time_vocal{k}(1);
                    upfm_count = upfm_count+1;
                else
                    if (max(current_freq)-current_freq(1)> 6000 && max(current_freq)-current_freq(end)> 6000) %Chevron
                        [max_local max_local] = max(current_freq);
                        aux2 = aux(2:max_local);
                        aux3 = aux(max_local:end);
                        if sum(sign(aux2)>0)/size(current_freq,1)>0.7 && sum(sign(aux3)<0)/size(current_freq,1)>0.7 %The "U" shape is verified
                            vocal_classified{k}.chevron = time_vocal{k}(1);
                            chevron_count = chevron_count+1;
                        end
                    elseif (current_freq(1) - min(current_freq)> 6000 && current_freq(end) - min(current_freq)> 6000)
                        [min_local min_local] = min(current_freq);
                        aux2 = aux(2:min_local);
                        aux3 = aux(min_local:end);
                        if sum(sign(aux2)<0)/size(current_freq,1)>0.7 && sum(sign(aux3)>0)/size(current_freq,1)>0.7 %The inverted "U" shape is verified
                            vocal_classified{k}.rev_chevron = time_vocal{k}(1);
                            revchevron_count = revchevron_count+1;
                        end
                    end
                end
            end
            if isempty(cell2mat(struct2cell(vocal_classified{k}))) %If it is still empty, has to be complex
                vocal_classified{k}.complex = time_vocal{k}(1);
                complex_count = complex_count+1;
            end
        end
        
        
        %     if ~isempty(vocal_classified{k}.harmonic) %Had harmonic
        %         k
        %     end
        
        %Plot how many
        
        
    end
    save(['vocal_classified_' vfilename],'vocal_classified')
    all_class = [stepup_count stepdown_count harmonic_count flat_count chevron_count revchevron_count downfm_count upfm_count complex_count noisy_count nonlinear_count short_count];
    figure('Name',vfilename,'NumberTitle','off')
    bar(all_class);
    Labels = {'stepup_count', 'stepdown_count', 'harmonic_count', 'flat_count', 'chevron_count', 'revchevron_count', 'downfm_count', 'upfm_count', 'complex_count', 'noisy_count', 'nonlinear_count', 'short_count'};
    set(gca, 'XTick', 1:12, 'XTickLabel', Labels);
    
end
% disp(['Time to plot all the vocalizations: ' num2str(toc)]);