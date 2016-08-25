% close all
clc
clear all
raiz = pwd;
[vfilename,vpathname] = uigetfile({'*.wav'},'Select the sound track');
cd(vpathname);
list = dir('*.wav');
% min_db = -220;%-110;%-107; %selec points >min_db
max_interval = 0.005; %if the distance between two successive points in time is >max_interval, it is new vocalization
minimum_size = 5;%10; %A valid vocalization must present >minimum_size valid points to be considered a vocalization
median_dist = 600; %600; If the median of the euclidean distance between succesive pair of points in a vocalization is >median_dist, then it is noise.
max_vocal_duration = 0.140; %If a vocalization is onger than max_vocal_duration, than it can be a noise that needs to be removed by denoising process
use_median = 1; %If =1, use the median method to detect the noise.

for Name = 3%1:size(list,1)
vfilename = list(Name).name;
vfilename = vfilename(1:end-4);
vfile = fullfile(vpathname,vfilename);

disp('Cleaning variables: time_vocal freq_vocal intens_vocal output')
clear time_vocal freq_vocal intens_vocal output time_vocal_nogaps freq_vocal_nogaps intens_vocal_nogaps
fprintf('\n');
disp(['Reading audio ' vfilename])
[y1,fs]=audioread([vfile '.wav']);
y1 = y1(1:12500000,:);
nfft = 1024;
nover = (128);
window = hamming(256);
% db_threshold = -115; %original
db_threshold = -115; 
dx = 0.4;
disp('Calculating spectrogram')
[S,F,T,P] = spectrogram(y1, window, nover, nfft, fs, 'yaxis', 'MinThreshold',db_threshold);
% [S,F,T,P] = spectrogram(y1, window, nover, nfft, fs, 'yaxis');

%cutoff frequency
min_freq = find(F>45000);
F = F(min_freq);
S = S(min_freq,:);
P = P(min_freq,:);

% T = size(y1,1)+T;
figure('Name',vfilename,'NumberTitle','off')
surf(T,F,10*log10(P),'edgecolor','none')
axis tight; view(0,90);
colormap(gray);
xlabel('Time (s)'); ylabel('Freq (Hz)')

disp('Calc the median of intensity')
min_db = median(median(10*log10(P)));
disp(['Intensity threshold: ' num2str(min_db)])

disp('Applying highpass filter')
[q,nd] = max(10*log10(P));
vocal = find(q>=min_db); %original
% vocal = find(q>-105); %works better when we have a high 
q = q(vocal);
T = T(vocal);
nd = nd(vocal);
F = F(nd);

hold on


% disp('Showing segmented points')
% scatter3(T,F,q,'filled')
% hold off
% c = colorbar;
% c.Label.String = 'dB';
% view(2)


%Vocalization Segmentating
%If there a huge diff between a point and the next point in time domain, it
%means that one vocalization ended and another just started.

id = 0;
disp('Postprocessing on the segmented vocalizations')
for k = 1:size(T,2)-2
   
    if T(k+1)-T(k)> max_interval %If >0.002s, it is a new vocalization
        id=id+1;
        time_vocal{id} = [];
        freq_vocal{id} = [];
        intens_vocal{id} = [];
    
    else %if it is not a new vocalization
        if k==1
            id=1;
            time_vocal{id} = [];
            freq_vocal{id} = [];
            intens_vocal{id} = [];
        end
        if abs(F(k+1)-F(k))>2000 % Detected a jump in frequency, but if the jump occurs just once, it could still be a syllable 
            if abs(F(k+2)-F(k+1))>2000 %If another jump is detected, so this is not a syllable
               id=id+1;
               time_vocal{id} = [];
               freq_vocal{id} = [];
               intens_vocal{id} = []; 
            end
        end
        time_vocal{id}=[time_vocal{id}, T(k)]; %Storing vector time for that vocalization
        freq_vocal{id} = [freq_vocal{id} , F(k)]; %Storing vector frequency for that vocalization
        intens_vocal{id} = [intens_vocal{id}, q(k)];
    end
end

%Remove too small vocalizations (< 5 points)
disp(['Removing small vocalizations (< ' num2str(minimum_size) ' points)'])
for k=1:size(time_vocal,2)
%     if ~isempty(time_vocal{k}) && time_vocal{k}(1) > 118.4
%         k
%     end

   if  size(time_vocal{k},2) < minimum_size %|| max(freq_vocal{k})-min(freq_vocal{k}) > 45000
%        disp(['Vocalization starting in ' num2str(time_vocal{k}(1)) ' was removed for size criterium'])
       time_vocal{k}=[];
       freq_vocal{k}=[];
       intens_vocal{k}=[];
   end
   
%    if size(time_vocal{k},2) >= minimum_size
%        %Remove first and last elements
%        time_vocal{k}(1:4)=[];
%        time_vocal{k}(end-3:end)=[];
%        freq_vocal{k}(1:4)=[];
%        freq_vocal{k}(end-3:end)=[];
%        intens_vocal{k}(1:4)=[];
%        intens_vocal{k}(end-3:end)=[];
%    end
   
   dist = [];
   for j = 1:size(time_vocal{k},2)-1
       dist = [dist; pdist([time_vocal{k}(j:j+1)' freq_vocal{k}(j:j+1)'],'euclidean')];
   end
   
%     aaa = (time_vocal{k}');
%     bbb = circshift(time_vocal{k}',1);
%    if any((time_vocal{k}')-circshift(time_vocal{k}',1)> 4*max_interval)
%            if ~isempty(time_vocal{k}) && time_vocal{k}(1) > 118.4
%               k
%            end
%        time_vocal{k}=[];
%        freq_vocal{k}=[];
%        intens_vocal{k}=[];
%    end

   
   if use_median == 1
       if median(dist) > median_dist %in general, when it is a real vocalization, the median is exaclty 244.1406!!
%            disp(['Vocalization starting in ' num2str(time_vocal{k}(1)) ' was removed for median criterium'])
           time_vocal{k}=[];
           freq_vocal{k}=[];
           intens_vocal{k}=[];
       end
   end
 
   
end

disp('Removing empty cells')
time_vocal = time_vocal(~cellfun('isempty',time_vocal));
freq_vocal = freq_vocal(~cellfun('isempty',freq_vocal));
intens_vocal = intens_vocal(~cellfun('isempty',intens_vocal));

time_vocal_nogaps{1} = [];
freq_vocal_nogaps{1} = [];
intens_vocal_nogaps{1} = [];

for k=1:size(time_vocal,2)
    %Holding time to avoid gaps
   if k>1
       if (~isempty(time_vocal{k-1}) && ~isempty(time_vocal{k})) && time_vocal{k}(1)-time_vocal{k-1}(end)< 0.015  
           time_vocal_nogaps{k} = [time_vocal{k-1} time_vocal{k}];
           freq_vocal_nogaps{k} = [freq_vocal{k-1} freq_vocal{k}];
           intens_vocal_nogaps{k} = [intens_vocal{k-1} intens_vocal{k}];
           time_vocal{k-1} =[];  time_vocal{k} =[];
           freq_vocal{k-1} = []; freq_vocal{k} = [];
           intens_vocal{k-1} =[];  intens_vocal{k} =[];
       elseif ~isempty(time_vocal_nogaps{k-1}) && time_vocal{k}(1)-time_vocal_nogaps{k-1}(end)< 0.015
           time_vocal_nogaps{k} = [time_vocal_nogaps{k-1} time_vocal{k}];
           freq_vocal_nogaps{k} = [freq_vocal_nogaps{k-1} freq_vocal{k}];
           intens_vocal_nogaps{k} = [intens_vocal_nogaps{k-1} intens_vocal{k}];
           time_vocal_nogaps{k-1} =[];
           freq_vocal_nogaps{k-1} = [];
           intens_vocal_nogaps{k-1} =[];
           time_vocal{k}=[];
           freq_vocal{k}=[];
           intens_vocal{k}=[];
       elseif ~isempty(time_vocal{k-1}) && ~isempty(time_vocal{k})
           time_vocal_nogaps{k} = time_vocal{k-1};
           freq_vocal_nogaps{k} = freq_vocal{k-1};
           intens_vocal_nogaps{k} = intens_vocal{k-1};
           time_vocal{k-1}=[];
           freq_vocal{k-1}=[];
           intens_vocal{k-1}=[];
       else
           time_vocal_nogaps{k} = [];
           freq_vocal_nogaps{k} = [];
           intens_vocal_nogaps{k} = [];
       end
   end
end

disp('Removing empty cells')
time_vocal = time_vocal(~cellfun('isempty',time_vocal));
freq_vocal = freq_vocal(~cellfun('isempty',freq_vocal));
intens_vocal = intens_vocal(~cellfun('isempty',intens_vocal));

if size(time_vocal,2)==0
    time_vocal = time_vocal_nogaps(~cellfun('isempty',time_vocal_nogaps));
    freq_vocal = freq_vocal_nogaps(~cellfun('isempty',freq_vocal_nogaps));
    intens_vocal = intens_vocal_nogaps(~cellfun('isempty',intens_vocal_nogaps));
    clear time_vocal_nogaps freq_vocal_nogaps intens_vocal_nogaps
elseif size(time_vocal,2)==1
    time_vocal_nogaps = [time_vocal_nogaps time_vocal];
    freq_vocal_nogaps = [freq_vocal_nogaps freq_vocal];
    intens_vocal_nogaps = [intens_vocal_nogaps intens_vocal];
    time_vocal = time_vocal_nogaps(~cellfun('isempty',time_vocal_nogaps));
    freq_vocal = freq_vocal_nogaps(~cellfun('isempty',freq_vocal_nogaps));
    intens_vocal = intens_vocal_nogaps(~cellfun('isempty',intens_vocal_nogaps));
    clear time_vocal_nogaps freq_vocal_nogaps intens_vocal_nogaps
end

% Remove outliers
disp('Removing outliers')
for k=1:size(freq_vocal,2) %If there is only one point distant from all the others, it is a outlier
    for p = 1:size(freq_vocal{k},2)-1
        if abs(freq_vocal{k}(p+1)- freq_vocal{k}(p)) > 5000 %Detect first jump
            if p+2 <= size(freq_vocal{k},2)
                if abs(freq_vocal{k}(p+2) - freq_vocal{k}(p+1))>5000 %If another jump is detected, then the point (p+1) is an outlier
                    freq_vocal{k}(p+1) =NaN;
                    time_vocal{k}(p+1) =NaN;
                    intens_vocal{k}(p+1) =NaN;
                end
            else
                freq_vocal{k}(p+1) =NaN;
                time_vocal{k}(p+1) =NaN;
                intens_vocal{k}(p+1) =NaN;
            end
        end
    end
    time_vocal{k}(isnan(time_vocal{k}))=[];
    freq_vocal{k}(isnan(freq_vocal{k}))=[];
    intens_vocal{k}(isnan(intens_vocal{k}))=[];
end

disp(['Vocalizations detected before filtering:' num2str(size(time_vocal,2))])

%Verify if the vocalizations detected are too long. If it is, probably
%there is too much noise and we need to remove noise (>125ms, Based on
%maximum duration measured at Acoustic variability and distinguishability
%among mouse, 2003)
denoiseing=0;
for k=1:size(time_vocal,2)
    if (max(time_vocal{k})-min(time_vocal{k}))>max_vocal_duration %125ms
        denoiseing = 1;
        disp(['Vocalization #' num2str(k) ' is ' num2str(max(time_vocal{k})-min(time_vocal{k})) 's long'])
    end
end

% if denoiseing 
%         close
%         disp('Too much noise! Running denoising process')
%         disp('Saving and cleaning variables')
%         clear time_vocal freq_vocal intens_vocal output
%         save('temp') %I have to clean all the varibles now, otherwise I wont have enough memory to make the calculation
%         cd(raiz)
%         clearvars -except vfile y1 fs vpathname
%         
% %         vocalmat_denoising(vfile,y1,fs);
%         vocalmat_denoising_big_variables(vfile,y1,fs);
%         
%         cd(vpathname)
%         load('temp')
%         clear y1 fs
%         vfilename = [vfilename '_no_noise'];
%         disp(['Reading audio ' vfilename '.wav'])
%         
%         [y1,fs]=audioread([vfilename '.wav']); 
%         nfft = 1024;
%         nover = (128);
%         window = hamming(256);
%         % db_threshold = -115; %original
%         db_threshold = -115; 
%         dx = 0.4;
%         disp('Calculating spectrogram')
%         [S,F,T,P] = spectrogram(y1, window, nover, nfft, fs, 'yaxis', 'MinThreshold',db_threshold);
%         
%         %cutoff frequency
%         min_freq = find(F>45000);
%         F = F(min_freq);
%         S = S(min_freq,:);
%         P = P(min_freq,:);
%         
%         figure('Name',vfilename,'NumberTitle','off')
% %         surf(T,F,10*log10(P),'edgecolor','none')
% %         axis tight; view(0,90);
%         % 
%         colormap(gray);
%         xlabel('Time (s)'); ylabel('Freq (Hz)')
%         
%         disp('Applying highpass filter')
%         [q,nd] = max(10*log10(P));
%         vocal = find(q>-115); %Not filtering out anything after denoising
%         % vocal = find(q>-105); %works better when we have a high 
%         q = q(vocal);
%         T = T(vocal);
%         nd = nd(vocal);
%         F = F(nd);
%         
%         hold on
%         disp('Showing segmented points')
%         scatter3(T,F,q,'filled')
%         hold off
%         c = colorbar;
%         c.Label.String = 'dB';
%         view(2)
%       
%         %Vocalization Segmentating
%         %If there a huge diff between a point and the next point in time domain, it
%         %means that one vocalization ended and another just started.
% 
%         id = 0;
%         disp('Postprocessing on the segmented vocalizations')
%         for k = 1:size(T,2)-1
% 
%             if T(k+1)-T(k)> max_interval %If >0.002s, it is a new vocalization
%                 id=id+1;
%                 time_vocal{id} = [];
%                 freq_vocal{id} = [];
%                 intens_vocal{id} = [];
% 
%             else %if it is not a new vocalization
%                 if k==1
%                     id=1;
%                     time_vocal{id} = [];
%                     freq_vocal{id} = [];
%                     intens_vocal{id} = [];
%                 end
%                 time_vocal{id}=[time_vocal{id}, T(k)]; %Storing vector time for that vocalization
%                 freq_vocal{id} = [freq_vocal{id} , F(k)]; %Storing vector frequency for that vocalization
%                 intens_vocal{id} = [intens_vocal{id}, q(k)];
%             end
%         end
%      %Remove too small vocalizations (< 5 points)
%     disp(['Removing small vocalizations (< ' num2str(minimum_size) ' points)'])
%     for k=1:size(time_vocal,2)
%        if  size(time_vocal{k},2) < minimum_size %|| max(freq_vocal{k})-min(freq_vocal{k}) > 45000
%            time_vocal{k}=[];
%            freq_vocal{k}=[];
%            intens_vocal{k}=[];
%        end
%        dist = [];
%        for j = 1:size(time_vocal{k},2)-1
%            dist = [dist; pdist([time_vocal{k}(j:j+1)' freq_vocal{k}(j:j+1)'],'euclidean')];
%        end
% 
%        if median(dist) > median_dist %in general, when it is a real vocalization, the median is exaclty 244.1406!!
%            time_vocal{k}=[];
%            freq_vocal{k}=[];
%            intens_vocal{k}=[];
%        end
%     end 
%     
%     disp('Removing empty cells')
%     time_vocal = time_vocal(~cellfun('isempty',time_vocal));
%     freq_vocal = freq_vocal(~cellfun('isempty',freq_vocal));
%     intens_vocal = intens_vocal(~cellfun('isempty',intens_vocal));
% end
    

output = [];
%Plot names on spectrogram and organize table
disp('Showing segmented points')
for k=1:size(time_vocal,2)
    scatter3(time_vocal{k},freq_vocal{k},intens_vocal{k},'filled')
end
hold off
c = colorbar;
c.Label.String = 'dB';
view(2)

disp('Plotting names on spectrogram and organizing table')
for i=1:size(time_vocal,2)
    text(time_vocal{i}(round(end/2)),freq_vocal{i}(round(end/2))+5000,[num2str(i)],'HorizontalAlignment','left','FontSize',20,'Color','r');
    output = [output; i, size(time_vocal{i},2) , min(time_vocal{i}), max(time_vocal{i}), (max(time_vocal{i})-min(time_vocal{i})) , max(freq_vocal{i}), mean(freq_vocal{i}),(max(freq_vocal{i})-min(freq_vocal{i})) , min(freq_vocal{i}), min(intens_vocal{i}), max(intens_vocal{i}), mean(intens_vocal{i})];
end

output = array2table(output,'VariableNames', {'ID','Num_points','Start_sec','End_sec','Duration_sec','Max_Freq_Hz','Mean_Freq_Hz','Range_Freq_Hz','Min_Freq_Hz','Min_dB','Max_dB','Mean_dB'});
warning('off','MATLAB:xlswrite:AddSheet');

% xlswrite(vfile,output,filename)
writetable(output,[vpathname '_VocalMat'],'FileType','spreadsheet','Sheet',vfilename)
% vfilename
% size(time_vocal,2)
% size(output,1)
X = [vfilename,' has ',num2str(size(output,1)),' vocalizations.'];
disp(X)
% This avoids flickering when updating the axis
set(gca,'xlim',[0 dx]);
set(gca,'ylim',[0 max(F)]);
% Generate constants for use in uicontrol initialization
pos=get(gca,'position');
Newpos=[pos(1) pos(2)-0.1 pos(3) 0.05];
xmax=max(T);
Stri=['set(gca,''xlim'',get(gcbo,''value'')+[0 ' num2str(dx) '])'];
h=uicontrol('style','slider',...
    'units','normalized','position',Newpos,...
    'callback',Stri,'min',0,'max',xmax-dx,'SliderStep',[0.0001 0.010]);
% set(gcf,'Renderer','OpenGL')

% close all
save(['output_' vfilename],'T','F','q','time_vocal','freq_vocal','intens_vocal','output','vfilename')
warning('off', 'MATLAB:save:sizeTooBigForMATFile')
disp('Cleaning variables: y y1 S F T P fs q nd vocal id' ) 
clear y y1 S F T P fs q nd vocal id

end
