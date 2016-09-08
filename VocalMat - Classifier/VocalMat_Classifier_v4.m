% Aug 31th, 2016: This script intends to classify the vocalization in the
% eleven different categories we currently have described by Grimsley, Jasmine MS, Jessica JM Monaghan, and Jeffrey J. Wenstrup. "Development of social vocalizations in mice." PloS one 6.3 (2011): e17460.

clc
clear all
raiz = pwd;
[vfilename,vpathname] = uigetfile({'*.mat'},'Select the output file');
cd(vpathname);
list = dir('*.wav');

vfilename = vfilename(1:end-4);
vfile = fullfile(vpathname,vfilename);

disp(['Reading ' vfilename])
load(vfile);

%We are gonna get only 10 points (time stamps) to classify the vocalization
%Grimsley, Jasmine, Marie Gadziola, and Jeff James Wenstrup. "Automated classification of mouse pup isolation syllables: from cluster analysis to an Excel-based “mouse pup syllable classification calculator”." Frontiers in behavioral neuroscience 6 (2013): 89.
disp('Verify vocalizations for steps')
for k=1:size(time_vocal,2)
    if k==2
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
                    current_freq(end-size(harmonic_candidate,1)+1:end) = harmonic_candidate;
                    current_freq = [current_freq; freq_vocal{k}{time_stamp+1}];
                    harmonic_candidate = [];
                else %It was an harmonic after all
                    current_freq = [current_freq; freq_vocal{k}{time_stamp+1}];
                    if size(harmonic_candidate,1)>10 % at least 5 points to say it was really an harmonic
                        disp(['Vocalization ' num2str(k) ' had an harmonic in t = ' num2str(start_harmonic) 's']);
                        vocal_classified{k}.harmonic = [vocal_classified{k}.harmonic; start_harmonic];
                    end
                    harmonic_candidate = [];
                end
                
            else
                aux = freq_vocal{k}{time_stamp+1} - freq_vocal{k}{time_stamp};
                current_freq = [current_freq; freq_vocal{k}{time_stamp+1}];
                if (aux>=10000)
                    current_freq = freq_vocal{k}{time_stamp+1};
                    idx_stepdown_time = time_vocal{k}(time_stamp);
                    disp(['Vocalization ' num2str(k) ' had a step up in t = ' num2str(idx_stepdown_time)]);
                    vocal_classified{k}.step_up = [vocal_classified{k}.step_up; idx_stepdown_time];
                elseif (aux<=(-10000))
                    current_freq = freq_vocal{k}{time_stamp+1};
                    idx_stepup_time = time_vocal{k}(time_stamp);
                    disp(['Vocalization ' num2str(k) ' had a step down in t = ' num2str(idx_stepup_time)]);
                    vocal_classified{k}.step_down = [vocal_classified{k}.step_down; idx_stepup_time];
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
    if any(aux(2:end)>=10000) && (size(aux,1)-find(aux(2:end)>=10000)>10)
        disp(['Vocalization ' num2str(k) ' had a step up in t = ' num2str(time_vocal{k}(find(aux(2:end)>5000)+2)) 's']);
        vocal_classified{k}.step_up = [vocal_classified{k}.step_up; time_vocal{k}(find(aux(2:end)>5000)+2)'];
    end
    if any(aux(2:end)<=-10000) && (size(aux,1)-find(aux(2:end)<=-10000)>10)
        disp(['Vocalization ' num2str(k) ' had a step down in t = ' num2str(time_vocal{k}(find(aux(2:end)<-5000)+2)) 's']);
        vocal_classified{k}.step_down = [vocal_classified{k}.step_down; time_vocal{k}(find(aux(2:end)<-5000)+2)'];
%         if size(time_vocal{k}(find(aux(2:end)<-5000)+2),2) > 1
%             size(time_vocal{k}(find(aux(2:end)<-5000)+2),2)
%         end
    end
    
    if (isempty(cell2mat(struct2cell(vocal_classified{k}))) || ~isempty(vocal_classified{k}.harmonic)) %It means there was no step up, down or harmonic
        if max(current_freq)-min(current_freq) <= 6000 % flat
            vocal_classified{k}.flat =  time_vocal{k}(1);
        else
            time_stamps = round(linspace(1,size(current_freq',2),10));
            aux = current_freq;
            aux = aux-circshift(aux ,[1,0]);
            if sum(sign(aux)<0)/size(current_freq,1)>0.7 %Down FM
                vocal_classified{k}.down_fm = time_vocal{k}(1);
            elseif sum(sign(aux)>0)/size(current_freq,1)>0.7 %Up FM
                vocal_classified{k}.up_fm = time_vocal{k}(1);
            else 
                if (max(current_freq)-current_freq(1)> 6000 && max(current_freq)-current_freq(end)> 6000) %Chevron
                    vocal_classified{k}.chevron = time_vocal{k}(1);
                elseif (current_freq(1) - min(current_freq)> 6000 && current_freq(end) - min(current_freq)> 6000)
                    vocal_classified{k}.rev_chevron = time_vocal{k}(1);
                end
            end
        end
        if isempty(cell2mat(struct2cell(vocal_classified{k}))) %If it is still empty, has to be complex
            vocal_classified{k}.complex = time_vocal{k}(1);
        end
    end
    
    
%     if ~isempty(vocal_classified{k}.harmonic) %Had harmonic
%         k
%     end
    
    
end
% disp(['Time to plot all the vocalizations: ' num2str(toc)]);