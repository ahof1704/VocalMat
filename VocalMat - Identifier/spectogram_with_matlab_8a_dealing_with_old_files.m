% close all
clc
clear all
raiz = pwd;
[vfilename,vpathname] = uigetfile({'*.wav'},'Select the sound track');
cd(vpathname);
diary(['Summary_' num2str(horzcat(fix(clock))) '.txt'])
list = dir('*.wav');
% min_db = -220;%-110;%-107; %selec points >min_db
max_interval = 0.003 %if the distance between two successive points in time is >max_interval, it is new vocalization
minimum_size = 15%20%10; %A valid vocalization must present >minimum_size valid points to be considered a vocalization
median_dist = 1500 %600; If the median of the euclidean distance between succesive pair of points in a vocalization is >median_dist, then it is noise.
max_vocal_duration = 0.140 %If a vocalization is onger than max_vocal_duration, than it can be a noise that needs to be removed by denoising process
use_median = 0 %If =1, use the median method to detect the noise.
min_freq_analysis = 45000
tic 
for Name = 1:size(list,1)
vfilename = list(Name).name;
vfilename = vfilename(1:end-4);
vfile = fullfile(vpathname,vfilename);

disp('Cleaning variables: time_vocal freq_vocal intens_vocal output')
clear time_vocal freq_vocal intens_vocal output time_vocal_nogaps freq_vocal_nogaps intens_vocal_nogaps
fprintf('\n');
disp(['Reading audio ' vfilename])
[y1,fs]=audioread([vfile '.wav']);
% jump = 0;%3*5000000;
% y1 = y1(1:ceil(end/2));
nfft = 1024;
nover = (128);
window = hamming(256);
% db_threshold = -115; %original
db_threshold = -110; 
dx = 0.4;
disp('Calculating spectrogram')
% [S,F,T,P] = spectrogram(y1, window, nover, nfft, fs, 'yaxis', 'MinThreshold',db_threshold);
[S,F,T,P] = spectrogram(y1, window, nover, nfft, fs, 'yaxis');

%cutoff frequency
min_freq = find(F>min_freq_analysis);
F = F(min_freq);
S = S(min_freq,:);
P = P(min_freq,:);

figure('Name',vfilename,'NumberTitle','off')
P(P==0)=1;
A = 10*log10(P);
A = A(:,200:end); %Cut off the first 0.1s... usually there is a weird noise in the beggining
T = T(:,200:end);
median_db = median(median(A));
B = imadjust(imcomplement(abs(A)./max(abs(A(:)))));
T_orig = T;
F_orig = F;
% surf(T,F,A,'edgecolor','none')
% axis tight; view(0,90);
% colormap(gray);
xlabel('Time (s)'); ylabel('Freq (Hz)')

% Threshold image - adaptive threshold
BW = imbinarize(B, 'adaptive', 'Sensitivity', 0.200000, 'ForegroundPolarity', 'bright');

% Clear borders
BW = imclearborder(BW);

% Open mask with line
length = 3.000000;
angle = 0.000000;
se = strel('line', length, angle);
BW = imopen(BW, se);

% Create masked image.
maskedImage = B;
maskedImage(~BW) = 0;
B = maskedImage;

disp('Connected components')
cc = bwconncomp(B, 4);
graindata = regionprops(cc,'basic');
min_area = find([graindata.Area]>20) ;
grain = false(size(B));
for k=1:size(min_area,2)
    grain(cc.PixelIdxList{min_area(k)}) = true;
end
% figure, imshow(grain);

disp('Applying highpass filter')
[q,nd] = max(grain);
vocal = find(q==1);
real_freq_aux = [];
for k=1:size(vocal,2)
    aux = find(grain(:,vocal(k))==1);
    real_freq_aux = [real_freq_aux, F_orig(aux(ceil(end/2)))]; %original
end
T = T(vocal);
% nd = nd(vocal);
% F = F(nd);

hold on

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
        time_vocal{id}=[time_vocal{id}, T(k)]; %Storing vector time for that vocalization
        freq_vocal{id} = [freq_vocal{id} , real_freq_aux(k)];
        idx_db_time = find(T_orig == T(k));
        idx_db_freq = find(F_orig == real_freq_aux(k));
        intens_vocal{id} = [intens_vocal{id}, A(idx_db_freq,idx_db_time)]; % idx_db_freq+10 just get in the middle of the vocalization
    end
end

%Remove too small vocalizations (< 5 points)
disp(['Removing small vocalizations (< ' num2str(minimum_size) ' points)'])
for k=1:size(time_vocal,2)
    
%    if  ~isempty(time_vocal{k})
%        if (max(time_vocal{k})-min(time_vocal{k})> 0.08 && max(freq_vocal{k}) - min(freq_vocal{k}) < 2000) % Longer than 0.08s and bandwith shorter than 2khz
%             time_vocal{k}=[];
%             freq_vocal{k}=[];
%             intens_vocal{k}=[];
%        end

%        if max(time_vocal{k})-min(time_vocal{k})> 0.5 %If it is greater than 1s, it is noise for sure
%            time_vocal{k}=[];
%             freq_vocal{k}=[];
%             intens_vocal{k}=[];
%        end
%    end
   
   if  size(time_vocal{k},2) < minimum_size %|| max(freq_vocal{k})-min(freq_vocal{k}) > 45000
%        disp(['Vocalization starting in ' num2str(time_vocal{k}(1)) ' was removed for size criterium'])
       time_vocal{k}=[];
       freq_vocal{k}=[];
       intens_vocal{k}=[];
   end
      
   dist = [];
   for j = 1:size(time_vocal{k},2)-1
       dist = [dist; pdist([time_vocal{k}(j:j+1)' freq_vocal{k}(j:j+1)'],'euclidean')];
   end
%    dist_vocal{k} = median(dist);
   
   if use_median == 1
       if median(dist) > median_dist %in general, when it is a real vocalization, the median is exaclty 244.1406!!
           disp(['eliminating vocal starting in ' num2str(time_vocal{k}(1)) ' for median criterium']);
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

disp(['Number of vocalizations at this point: ' num2str(size(time_vocal,2))])

disp('Removing noise by local median')
for k=1:size(time_vocal,2)
%     median_db = median(median(A(find(F_orig==min(freq_vocal{k})):find(F_orig==max(freq_vocal{k})),find(T_orig==time_vocal{k}(ceil(end/2)))-200 : find(T_orig==time_vocal{k}(ceil(end/2))) + 200))); %Calculating median in the freq range of identified vocalization
%     median_freq = find(F_orig==median(freq_vocal{k}));
    median_freq = abs(F_orig-median(freq_vocal{k}));
    [median_freq median_freq] = min(median_freq); %index of closest value
    try 
        median_db = median(median(A(median_freq-5:median_freq+5,find(T_orig==time_vocal{k}(ceil(end/2)))-200 : find(T_orig==time_vocal{k}(ceil(end/2))) + 200))); %Calculating median in the freq range of identified vocalization
    catch
        if find(T_orig==time_vocal{k}(ceil(end/2)))-200 <0 
            median_db = median(median(A(median_freq-5:median_freq+5,1 : find(T_orig==time_vocal{k}(ceil(end/2))) + 200)));
        elseif find(T_orig==time_vocal{k}(ceil(end/2))) + 200 > size(A,2)
            median_db = median(median(A(median_freq-5:median_freq+5,find(T_orig==time_vocal{k}(ceil(end/2)))-200 : end)));
        elseif median_freq+5 > size(A,1)
            median_db = median(median(A(median_freq-5:end,find(T_orig==time_vocal{k}(ceil(end/2)))-200 : find(T_orig==time_vocal{k}(ceil(end/2))) + 200)));
        else
             median_db = median(median(A(median_freq,find(T_orig==time_vocal{k}(ceil(end/2)))-200 : find(T_orig==time_vocal{k}(ceil(end/2))) + 200)));
        end
    end
    if median(intens_vocal{k}) < median_db-0.1*median_db
        disp(['eliminating vocal starting in ' num2str(time_vocal{k}(1))]);
        time_vocal{k}=[];
        freq_vocal{k}=[];
        intens_vocal{k}=[];
    end
end

disp('Removing empty cells')
time_vocal = time_vocal(~cellfun('isempty',time_vocal));
freq_vocal = freq_vocal(~cellfun('isempty',freq_vocal));
intens_vocal = intens_vocal(~cellfun('isempty',intens_vocal));

disp(['Number of vocalizations at this point: ' num2str(size(time_vocal,2))])

disp(['Removing small vocalizations (< ' num2str(minimum_size) ' points)'])
for k=1:size(time_vocal,2)
    
   if  size(time_vocal{k},2) < minimum_size %|| max(freq_vocal{k})-min(freq_vocal{k}) > 45000
       disp(['Vocalization starting in ' num2str(time_vocal{k}(1)) ' was removed for size criterium'])
       time_vocal{k}=[];
       freq_vocal{k}=[];
       intens_vocal{k}=[];
   end
      
   dist = [];
   for j = 1:size(time_vocal{k},2)-1
       dist = [dist; pdist([time_vocal{k}(j:j+1)' freq_vocal{k}(j:j+1)'],'euclidean')];
   end
%    dist_vocal{k} = median(dist);
   
   if use_median == 1
       if median(dist) > median_dist %in general, when it is a real vocalization, the median is exaclty 244.1406!!
           disp(['eliminating vocal starting in ' num2str(time_vocal{k}(1)) ' for median criterium']);
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

disp(['Number of vocalizations at this point: ' num2str(size(time_vocal,2))])

time_vocal_nogaps{1} = [];
freq_vocal_nogaps{1} = [];
intens_vocal_nogaps{1} = [];

disp('Applying holding time');
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

disp(['Number of vocalizations at this point: ' num2str(size(time_vocal,2))])

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
% disp('Removing outliers')
% for k=1:size(freq_vocal,2) %If there is only one point distant from all the others, it is a outlier
%     for p = 1:size(freq_vocal{k},2)-1
%         if abs(freq_vocal{k}(p+1)- freq_vocal{k}(p)) > 5000 %Detect first jump
%             if p+2 <= size(freq_vocal{k},2)
%                 if abs(freq_vocal{k}(p+2) - freq_vocal{k}(p+1))>5000 %If another jump is detected, then the point (p+1) is an outlier
%                     freq_vocal{k}(p+1) =NaN;
%                     time_vocal{k}(p+1) =NaN;
%                     intens_vocal{k}(p+1) =NaN;
%                 end
%             else
%                 freq_vocal{k}(p+1) =NaN;
%                 time_vocal{k}(p+1) =NaN;
%                 intens_vocal{k}(p+1) =NaN;
%             end
%         end
%     end
%     time_vocal{k}(isnan(time_vocal{k}))=[];
%     freq_vocal{k}(isnan(freq_vocal{k}))=[];
%     intens_vocal{k}(isnan(intens_vocal{k}))=[];
% end

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

% disp('Removing "vocalizations" too big.');
% for k=1:size(time_vocal,2)
%     if  ~isempty(time_vocal{k})
%        if (max(time_vocal{k})-min(time_vocal{k})> 0.08 && max(freq_vocal{k}) - min(freq_vocal{k}) < 2000) % Longer than 0.08s and bandwith shorter than 2khz
%             time_vocal{k}=[];
%             freq_vocal{k}=[];
%             intens_vocal{k}=[];
%        end
% 
%        if max(time_vocal{k})-min(time_vocal{k})> 0.5 %If it is greater than 1s, it is noise for sure
%            time_vocal{k}=[];
%            freq_vocal{k}=[];
%            intens_vocal{k}=[];
%        end
%    end
% end

disp('Removing empty cells')
time_vocal = time_vocal(~cellfun('isempty',time_vocal));
freq_vocal = freq_vocal(~cellfun('isempty',freq_vocal));
intens_vocal = intens_vocal(~cellfun('isempty',intens_vocal));

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

denoiseing = 0;
if denoiseing 
%         close
        disp('Too much noise! Running denoising process')
        disp('Saving and cleaning variables')
        clear time_vocal freq_vocal intens_vocal output
        save('temp') %I have to clean all the varibles now, otherwise I wont have enough memory to make the calculation
        cd(raiz)
        clearvars -except vfile y1 fs vpathname
        
%         vocalmat_denoising(vfile,y1,fs);
        vocalmat_denoising_big_variables(vfile,y1,fs);
        
        cd(vpathname)
        load('temp')
        clear y1 fs
        vfilename = [vfilename '_no_noise'];
        disp(['Reading audio ' vfilename '.wav'])
        
        [y1,fs]=audioread([vfilename '.wav']); 
        nfft = 1024;
        nover = (128);
        window = hamming(256);
        % db_threshold = -115; %original
%         db_threshold = -115; 
%         dx = 0.4;
        disp('Calculating spectrogram')
%         [S,F,T,P] = spectrogram(y1, window, nover, nfft, fs, 'yaxis', 'MinThreshold',db_threshold);
        [S,F,T,P] = spectrogram(y1, window, nover, nfft, fs, 'yaxis');
        
       %cutoff frequency
        min_freq = find(F>min_freq_analysis);
        F = F(min_freq);
        S = S(min_freq,:);
        P = P(min_freq,:);

        figure('Name',vfilename,'NumberTitle','off')
%         P(P==0)=1;
        A = 10*log10(P);
        C=A;
        C(C==-inf)=[];
%         median_db = median(median(A));
%         B = imadjust(imcomplement(abs(A)./max(abs(A(:)))));
%         B = abs(A)./max(abs(A(:)));
%         B=A;
%         B(B==0)=[];
        median_db_th = median(median(C))-0.1*median(median(C));
        
        T_orig = T;
        F_orig = F;
%         surf(T,F,A,'edgecolor','none')
%         axis tight; view(0,90);
%         colormap(gray);
%         xlabel('Time (s)'); ylabel('Freq (Hz)')

        [q,nd] = max(A);
        vocal = find(q>median_db_th); %original
        q = q(vocal);
        T = T(vocal);
        nd = nd(vocal);
        F = F(nd);

        hold on

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
                time_vocal{id}=[time_vocal{id}, T(k)]; %Storing vector time for that vocalization
                freq_vocal{id} = [freq_vocal{id} , F(k)];
                idx_db_time = find(T_orig == T(k));
                idx_db_freq = find(F_orig == F(k));
                intens_vocal{id} = [intens_vocal{id}, A(idx_db_freq,idx_db_time)]; % idx_db_freq+10 just get in the middle of the vocalization
            end
        end

        %Remove too small vocalizations (< 5 points)
        disp(['Removing small vocalizations (< ' num2str(minimum_size) ' points)'])
        for k=1:size(time_vocal,2)

        %    if  ~isempty(time_vocal{k})
        %        if (max(time_vocal{k})-min(time_vocal{k})> 0.08 && max(freq_vocal{k}) - min(freq_vocal{k}) < 2000) % Longer than 0.08s and bandwith shorter than 2khz
        %             time_vocal{k}=[];
        %             freq_vocal{k}=[];
        %             intens_vocal{k}=[];
        %        end

        %        if max(time_vocal{k})-min(time_vocal{k})> 0.5 %If it is greater than 1s, it is noise for sure
        %            time_vocal{k}=[];
        %             freq_vocal{k}=[];
        %             intens_vocal{k}=[];
        %        end
        %    end

           if  size(time_vocal{k},2) < minimum_size %|| max(freq_vocal{k})-min(freq_vocal{k}) > 45000
        %        disp(['Vocalization starting in ' num2str(time_vocal{k}(1)) ' was removed for size criterium'])
               time_vocal{k}=[];
               freq_vocal{k}=[];
               intens_vocal{k}=[];
           end

           dist = [];
           for j = 1:size(time_vocal{k},2)-1
               dist = [dist; pdist([time_vocal{k}(j:j+1)' freq_vocal{k}(j:j+1)'],'euclidean')];
           end
        %    dist_vocal{k} = median(dist);

           if use_median == 1
               if median(dist) > 600 %in general, when it is a real vocalization, the median is exaclty 244.1406!!
                   disp(['eliminating vocal starting in ' num2str(time_vocal{k}(1)) ' for median criterium']);
                   time_vocal{k}=[];
                   freq_vocal{k}=[];
                   intens_vocal{k}=[];
               end
           end
           
           if sum(dist>2000) > size(time_vocal{k},2)/6 % 1/3 of the total points are jumps? This shit is noise!
               disp(['eliminating vocal starting in ' num2str(time_vocal{k}(1)) ' for median criterium']);
               time_vocal{k}=[];
               freq_vocal{k}=[];
               intens_vocal{k}=[];
           end

        end

        disp('Removing empty cells')
        time_vocal = time_vocal(~cellfun('isempty',time_vocal));
        freq_vocal = freq_vocal(~cellfun('isempty',freq_vocal));
        intens_vocal = intens_vocal(~cellfun('isempty',intens_vocal));

        disp(['Number of vocalizations at this point: ' num2str(size(time_vocal,2))])

        disp('Removing noise by local median')
        for k=1:size(time_vocal,2)
        %     median_db = median(median(A(find(F_orig==min(freq_vocal{k})):find(F_orig==max(freq_vocal{k})),find(T_orig==time_vocal{k}(ceil(end/2)))-200 : find(T_orig==time_vocal{k}(ceil(end/2))) + 200))); %Calculating median in the freq range of identified vocalization
        %     median_freq = find(F_orig==median(freq_vocal{k}));
            median_freq = abs(F_orig-median(freq_vocal{k}));
            [median_freq median_freq] = min(median_freq); %index of closest value
            try 
                median_db = median(median(A(median_freq-5:median_freq+5,find(T_orig==time_vocal{k}(ceil(end/2)))-200 : find(T_orig==time_vocal{k}(ceil(end/2))) + 200))); %Calculating median in the freq range of identified vocalization
            catch
                if find(T_orig==time_vocal{k}(ceil(end/2)))-200 <0 
                    median_db = median(median(A(median_freq-5:median_freq+5,1 : find(T_orig==time_vocal{k}(ceil(end/2))) + 200)));
                elseif find(T_orig==time_vocal{k}(ceil(end/2))) + 200 > size(A,2)
                    median_db = median(median(A(median_freq-5:median_freq+5,find(T_orig==time_vocal{k}(ceil(end/2)))-200 : end)));
                elseif median_freq+5 > size(A,1)
                    median_db = median(median(A(median_freq-5:end,find(T_orig==time_vocal{k}(ceil(end/2)))-200 : find(T_orig==time_vocal{k}(ceil(end/2))) + 200)));
                else
                     median_db = median(median(A(median_freq,find(T_orig==time_vocal{k}(ceil(end/2)))-200 : find(T_orig==time_vocal{k}(ceil(end/2))) + 200)));
                end
            end
            if median(intens_vocal{k}) < median_db-0.1*median_db
                disp(['eliminating vocal starting in ' num2str(time_vocal{k}(1))]);
                time_vocal{k}=[];
                freq_vocal{k}=[];
                intens_vocal{k}=[];
            end
        end

        disp('Removing empty cells')
        time_vocal = time_vocal(~cellfun('isempty',time_vocal));
        freq_vocal = freq_vocal(~cellfun('isempty',freq_vocal));
        intens_vocal = intens_vocal(~cellfun('isempty',intens_vocal));

        disp(['Number of vocalizations at this point: ' num2str(size(time_vocal,2))])

        time_vocal_nogaps{1} = [];
        freq_vocal_nogaps{1} = [];
        intens_vocal_nogaps{1} = [];

        disp('Applying holding time');
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

%         disp(['Number of vocalizations at this point: ' num2str(size(time_vocal,2))])

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
        
        disp('Removing empty cells')
        time_vocal = time_vocal(~cellfun('isempty',time_vocal));
        freq_vocal = freq_vocal(~cellfun('isempty',freq_vocal));
        intens_vocal = intens_vocal(~cellfun('isempty',intens_vocal));

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

end

disp('Cleaning variables: y y1 S F T P fs q nd vocal id' ) 
clear y y1 S F T P fs q nd vocal id A B T_orig F_orig BW maskedImage cc graindata min_area grain real_freq_aux
toc

end

diary('off');
