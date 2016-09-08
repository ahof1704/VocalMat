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
    
    check_harmonic = 0;
%     harmonic_freq = {};
    %Is there an harmonic in this vocalization?
%    for time_stamp = 1:size(time_vocal{k},2)
%        if size(freq_vocal{k}{time_stamp},1)>1
%            check_harmonic = 1;
%            harmonic_freq{time_stamp} = freq_vocal{k}{time_stamp};
%        end
%    end
   
   %Verify jump in frequency
   for time_stamp = 1:size(time_vocal{k},2)-1
%        aux = (freq_vocal{k}{time_stamp} - circshift(freq_vocal{k}{time_stamp} ,[1,0]));
%        aux = freq_vocal{k}{time_stamp} - freq_vocal{k}{time_stamp-1};
       
       if size(freq_vocal{k}{time_stamp+1},1)>1 %Probably we have an harmonic
           if (size(freq_vocal{k}{time_stamp},1)>1 && check_harmonic == 0); %Check if they have same size (could be the continuation of harmonic)
%                 aux = freq_vocal{k}{time_stamp+1} - freq_vocal{k}{time_stamp};
               check_harmonic = 1;
               aux = max(freq_vocal{k}{time_stamp+1}) - min(freq_vocal{k}{time_stamp});
           else
               aux = freq_vocal{k}{time_stamp+1} - freq_vocal{k}{time_stamp}*ones(size(freq_vocal{k}{time_stamp+1},1),1);
           end
           
           [maxi,maxi]=max(abs(aux));
           if (sign(aux(maxi))>0 && abs(aux(maxi))>5000)
               idx_stepdown_time = time_vocal{k}(time_stamp);
               disp(['Vocalization ' num2str(k) ' had a step down in t=' num2str(idx_stepdown_time)]);
           elseif (sign(aux(maxi))<0 && abs(aux(maxi))>5000)
               idx_stepup_time = time_vocal{k}(time_stamp);
               disp(['Vocalization ' num2str(k) ' had a step up in t=' num2str(idx_stepup_time)]);
           end
       else %There is nothing similar to harmonic right now... but there was before?
           if (size(freq_vocal{k}{time_stamp},1)>1 && check_harmonic == 1);
               if (max(freq_vocal{k}{time_stamp+1}) - min(freq_vocal{k}{time_stamp}))> (max(freq_vocal{k}{time_stamp}) - min(freq_vocal{k}{time_stamp+1}))
                   
               else
                   
               end
                   
           else
               aux = freq_vocal{k}{time_stamp+1} - freq_vocal{k}{time_stamp};
               if (aux>5000)
                   idx_stepdown_time = time_vocal{k}(time_stamp);
                   disp(['Vocalization ' num2str(k) ' had a step down in t=' num2str(idx_stepdown_time)]);
               elseif (aux<(-5000))
                   idx_stepup_time = time_vocal{k}(time_stamp);
                   disp(['Vocalization ' num2str(k) ' had a step up in t=' num2str(idx_stepup_time)]);
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
   
   
   
   time_stamps = round(linspace(1,size(time_vocal{k},2),10));
   for time_stamp = 1:time_stamps
        if size(freq_vocal{k}{time_stamp},1)>1
            
        else %Apparently there is no harmonic
            temp = (freq_vocal{k}{time_stamp} - circshift(freq_vocal{k}{time_stamp} ,[1,0]));
        end
   end
end
disp(['Time to plot all the vocalizations: ' num2str(toc)]);