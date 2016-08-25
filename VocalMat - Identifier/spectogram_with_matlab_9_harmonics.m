%Aug 25th: This version of identifier works with image processing and is
%being developed to be able to identify harmonics in vocalizations.

% close all
clc
clear all
raiz = pwd;
[vfilename,vpathname] = uigetfile({'*.wav'},'Select the sound track');
cd(vpathname);
list = dir('*.wav');
% min_db = -220;%-110;%-107; %selec points >min_db
max_interval = 0.005; %if the distance between two successive points in time is >max_interval, it is new vocalization
minimum_size = 20;%10; %A valid vocalization must present >minimum_size valid points to be considered a vocalization
median_dist = 600; %600; If the median of the euclidean distance between succesive pair of points in a vocalization is >median_dist, then it is noise.
max_vocal_duration = 0.140; %If a vocalization is onger than max_vocal_duration, than it can be a noise that needs to be removed by denoising process
use_median = 1; %If =1, use the median method to detect the noise.
tic 
for Name = 5%:size(list,1)
vfilename = list(Name).name;
vfilename = vfilename(1:end-4);
vfile = fullfile(vpathname,vfilename);

disp('Cleaning variables: time_vocal freq_vocal intens_vocal output')
clear time_vocal freq_vocal intens_vocal output time_vocal_nogaps freq_vocal_nogaps intens_vocal_nogaps
fprintf('\n');
disp(['Reading audio ' vfilename])
[y1,fs]=audioread([vfile '.wav']);
jump = 0;%3*5000000;
y1 = y1((jump+1):(jump+6*250000),:);
nfft = 1024;
nover = (128);
window = hamming(256);
% db_threshold = -115; %original
db_threshold = -200; 
dx = 0.4;
disp('Calculating spectrogram')
% [S,F,T,P] = spectrogram(y1, window, nover, nfft, fs, 'yaxis', 'MinThreshold',db_threshold);
[S,F,T,P] = spectrogram(y1, window, nover, nfft, fs, 'yaxis');

%cutoff frequency
min_freq = find(F>45000);
F = F(min_freq);
S = S(min_freq,:);
P = P(min_freq,:);

% T = size(y1,1)+T;
figure('Name',vfilename,'NumberTitle','off')
% for col = 1:size(P,2)
P(P==0)=1;
A = abs(10*log10(P))./max(abs(10*log10(P(:)))); %Normalizes
% end
% A = abs(P) / max(max(P)); %Normalizes
B = imadjust(imcomplement(A));
T_orig = T;
F_orig = F;
surf(T,F,10*log10(P),'edgecolor','none')
axis tight; view(0,90);
colormap(gray);
xlabel('Time (s)'); ylabel('Freq (Hz)')

% disp('Calc the median of intensity')
% min_db = median(median(10*log10(P)));
% min_db = median(median(B));
% disp(['Intensity threshold: ' num2str(min_db)])

% Threshold image - adaptive threshold
BW = imbinarize(B, 'adaptive', 'Sensitivity', 0.200000, 'ForegroundPolarity', 'bright');

%Threshold image
% BW = B > min_db;

% Open mask with disk
% radius = 1;
% decomposition = 0;
% se = strel('disk', radius, decomposition);
% BW = imopen(BW, se);

% Threshold image - manual threshold
% BW = B > 9.882400e-01; %BEST!
% BW = B > 0.8;

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
graindata = regionprops(cc,'all');
min_area = find([graindata.Area]>20) ;
grain = false(size(B));
for k=1:size(min_area,2)
    grain(cc.PixelIdxList{min_area(k)}) = true;
%     plot(centroids(:,1),centroids(:,2), 'b*')
%     text(graindata(min_area(k)).Centroid(:,1),graindata(min_area(k)).Centroid(:,2),num2str(k),'HorizontalAlignment','left','FontSize',20,'Color','b')
end


% hold on
% for k=1:size(min_area,2)
% %     grain(cc.PixelIdxList{min_area(k)}) = true;
% %     plot(centroids(:,1),centroids(:,2), 'b*')
%     text(graindata(min_area(k)).Centroid(:,1),graindata(min_area(k)).Centroid(:,2),num2str(k),'HorizontalAlignment','left','FontSize',20,'Color','b')
% end

se1 = strel('disk', 2, 0);
grain2 = imdilate(grain,se1);
grain2 = imerode(grain2, se);
% figure, imshow(grain2);

disp('Recalculating Connected components')
cc = bwconncomp(grain2, 4);
graindata = regionprops(cc,'all');
clear grain2

min_area = find([graindata.Area]>20) ;
grain = false(size(B));
for k=1:size(min_area,2)
    grain(cc.PixelIdxList{min_area(k)}) = true;
%     plot(centroids(:,1),centroids(:,2), 'b*')
%     text(graindata(min_area(k)).Centroid(:,1),graindata(min_area(k)).Centroid(:,2),num2str(k),'HorizontalAlignment','left','FontSize',20,'Color','b')
end

dx=2000;
figure, imshow((grain))
set(gca,'xlim',[0 dx]);
pos=get(gca,'position');
Newpos=[pos(1) pos(2)-0.1 pos(3) 0.05];
xmax=size(grain,2);
Stri=['set(gca,''xlim'',get(gcbo,''value'')+[0 ' num2str(dx) '])'];
h=uicontrol('style','slider',...
    'units','normalized','position',Newpos,...
    'callback',Stri,'min',0,'max',xmax-dx,'SliderStep',[0.0001 0.010]);


hold on
% for k=1:size(min_area,2)
% %     grain(cc.PixelIdxList{min_area(k)}) = true;
% %     plot(centroids(:,1),centroids(:,2), 'b*')
%     text(graindata(min_area(k)).Centroid(:,1),graindata(min_area(k)).Centroid(:,2),num2str(k),'HorizontalAlignment','left','FontSize',20,'Color','b')
% end

id = 1;
for k=1:size(min_area,2)-1
    
    if k==1
        time_vocal{id} = [];
        time_vocal{id}= unique(graindata(k).PixelList(:,1))';
        freq_vocal{id}{1}=[];
        for freq_per_time = 1:size(time_vocal{id},2)
            freq_vocal{id}{freq_per_time} = [find(grain(:,time_vocal{id}(freq_per_time))==1)]; %Storing vector frequency for that vocalization
        end
    else    
        if min(graindata(min_area(k)).PixelList(:,1)) - max(time_vocal{id}) > 20 %If the blobs are close enough in X axis (not in time, yet), then they should be part of same vocalization
            id=id+1;
            time_vocal{id} = [];
            time_vocal{id}= unique(graindata(k).PixelList(:,1))';
            freq_vocal{id}{1}=[];
            for freq_per_time = 1:size(time_vocal{id},2)
                freq_vocal{id}{freq_per_time} = [find(grain(:,time_vocal{id}(freq_per_time))==1)]; %Storing vector frequency for that vocalization
            end
%             
        else %if it is not a new vocalization
            time_vocal{id}= unique([time_vocal{id}, graindata(k).PixelList(:,1)']); %Storing vector time for that vocalization
            freq_vocal{id}{1}=[];
            for freq_per_time = 1:size(time_vocal{id},2)
                freq_vocal{id}{freq_per_time} = find(grain(:,time_vocal{id}(freq_per_time))==1); %Storing vector frequency for that vocalization
            end
        end
    end
end


disp(['Removing small vocalizations (< ' num2str(minimum_size) ' points)'])
for k=1:size(time_vocal,2)
   if  size(time_vocal{k},2) < minimum_size %|| max(freq_vocal{k})-min(freq_vocal{k}) > 45000
       time_vocal{k}=[];
       freq_vocal{k}=[];
   end
end

disp('Removing empty cells')
time_vocal = time_vocal(~cellfun('isempty',time_vocal));
freq_vocal = freq_vocal(~cellfun('isempty',freq_vocal));

hold on
% for k=1:size(time_vocal,2)
%     color = [rand() rand() rand()];
%     for j=1:size(time_vocal{k},2)
%         for l=1:size(freq_vocal{k}{j},1)
%             scatter(time_vocal{k}(j),freq_vocal{k}{j}(l),15,color)
%         end
%     end
% end

% disp('Applying highpass filter')

% [q,nd] = max(grain);
% vocal = find(q==1); 
% % vocal = find(q>-105); %works better when we have a high 
% q = q(vocal);
% T = T(vocal);
% nd = nd(vocal);
% F = F(nd);

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

% id = 0;
% disp('Postprocessing on the segmented vocalizations')
% for k = 1:size(T,2)-2
%    
%     if T(k+1)-T(k)> max_interval %If >0.002s, it is a new vocalization
%         id=id+1;
%         time_vocal{id} = [];
%         freq_vocal{id} = [];
%         intens_vocal{id} = [];
%     
%     else %if it is not a new vocalization
%         if k==1
%             id=1;
%             time_vocal{id} = [];
%             freq_vocal{id} = [];
%             intens_vocal{id} = [];
%         end
%         if abs(F(k+1)-F(k))>2000 % Detected a jump in frequency, but if the jump occurs just once, it could still be a syllable 
%             if abs(F(k+2)-F(k+1))>2000 %If another jump is detected, so this is not a syllable
%                id=id+1;
%                time_vocal{id} = [];
%                freq_vocal{id} = [];
%                intens_vocal{id} = []; 
%             end
%         end
%         time_vocal{id}=[time_vocal{id}, T(k)]; %Storing vector time for that vocalization
%         freq_vocal{id} = [freq_vocal{id} , F(k)]; %Storing vector frequency for that vocalization
%         intens_vocal{id} = [intens_vocal{id}, q(k)];
%     end
% end

%Remove too small vocalizations (< 5 points)
% disp(['Removing small vocalizations (< ' num2str(minimum_size) ' points)'])
% for k=1:size(time_vocal,2)
% 
%    if  size(time_vocal{k},2) < minimum_size %|| max(freq_vocal{k})-min(freq_vocal{k}) > 45000
% %        disp(['Vocalization starting in ' num2str(time_vocal{k}(1)) ' was removed for size criterium'])
%        time_vocal{k}=[];
%        freq_vocal{k}=[];
%        intens_vocal{k}=[];
%    end
%       
%    dist = [];
%    for j = 1:size(time_vocal{k},2)-1
%        dist = [dist; pdist([time_vocal{k}(j:j+1)' freq_vocal{k}(j:j+1)'],'euclidean')];
%    end
%    dist_vocal{k} = median(dist);
%    
%    if use_median == 1
%        if median(dist) > median_dist %in general, when it is a real vocalization, the median is exaclty 244.1406!!
% %            disp(['Vocalization starting in ' num2str(time_vocal{k}(1)) ' was removed for median criterium'])
%            time_vocal{k}=[];
%            freq_vocal{k}=[];
%            intens_vocal{k}=[];
%        end
%    end
%  
%    
% end
% 
% disp('Removing empty cells')
% time_vocal = time_vocal(~cellfun('isempty',time_vocal));
% freq_vocal = freq_vocal(~cellfun('isempty',freq_vocal));
% intens_vocal = intens_vocal(~cellfun('isempty',intens_vocal));
% 
% time_vocal_nogaps{1} = [];
% freq_vocal_nogaps{1} = [];
% intens_vocal_nogaps{1} = [];

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
freq_harmonic = {};
time_harmonic = {};
%Plot names on spectrogram and organize table
disp('Showing segmented points')
ref = 1;
% mask = false(size(T_orig,2),size(F_orig,1));
mask = false(size(B));
for k=1:size(time_vocal,2)
    
        %Detecting harmonics
        for col = 1:size(time_vocal{k},2)
%             freq_harmonic{k}(col) = NaN;
%             time_harmonic{k}(col) = NaN;
            grain_cc = find(T_orig==time_vocal{k}(col));
            list_vocal_freq = find(grain(:,grain_cc)==1);
            freq = F_orig(list_vocal_freq);
%             plot(time_vocal{k}(col),freq','r*')
            mask(list_vocal_freq,grain_cc) = true;
            
%             if size(list_vocal_freq,1)>1
%                     if any(freq - circshift(freq,1)>5000) %There is something that looks like an harmonic
%                          freq_jump = freq_vocal{k}(col-ref)-freq  ; %find who jumped in relation to the last ones
%                          [maimum, idx] = max(freq_jump); 
% %                          freq_jump = freq_jump(freq_jump>0);
%                          freq_harmonic{k} = [freq_harmonic{k} freq(idx)];
%                          time_harmonic{k} = [time_harmonic{k} time_vocal{k}(col)];
%                          ref = ref +1;
%                     else
%                         freq_harmonic{k} = [freq_harmonic{k} NaN];
%                         time_harmonic{k} = [time_harmonic{k} NaN];
%                         ref=0;
%                     end
%             end
        end
        scatter3(time_vocal{k},freq_vocal{k},intens_vocal{k},'filled')
end
clear grain
mask = flipud(mask);
figure,imshow(mask)

cc = bwconncomp(mask, 4);
graindata = regionprops(cc,'all');

hold on
for k=1:size(min_area,2)
    text(graindata(min_area(k)).Centroid(:,1),graindata(min_area(k)).Centroid(:,2),num2str(k),'HorizontalAlignment','left','FontSize',20,'Color','b')
    time_vocal{k}
end

dx=2000;
% figure, imshow(flipud(grain))
set(gca,'xlim',[0 dx]);
pos=get(gca,'position');
Newpos=[pos(1) pos(2)-0.1 pos(3) 0.05];
xmax=size(mask,2);
Stri=['set(gca,''xlim'',get(gcbo,''value'')+[0 ' num2str(dx) '])'];
h=uicontrol('style','slider',...
    'units','normalized','position',Newpos,...
    'callback',Stri,'min',0,'max',xmax-dx,'SliderStep',[0.0001 0.010]);

hold off
c = colorbar;
c.Label.String = 'dB';
view(2)

disp('Plotting names on spectrogram and organizing table')
for i=1:size(time_vocal,2)
%     text(time_vocal{i}(round(end/2)),freq_vocal{i}(round(end/2))+5000,[num2str(i)],'HorizontalAlignment','left','FontSize',20,'Color','r');
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
set(gca,'xlim',[0 dx]);
set(gca,'ylim',[0 max(F)]);
% Generate constants for use in uicontrol initialization
pos=get(gca,'position');
yourcell = 1:size(time_vocal,2);
hb = uicontrol('Style', 'listbox','Position',[pos(1)+10 pos(2)+100 100 pos(4)+700],...
     'string',yourcell,'Callback',... 
     ['if get(hb, ''Value'')>0 ',...
     ' Stri=[''set(gca,''''xlim'''',[-dx/2 dx/2]+['' num2str(time_vocal{get(hb, ''Value'')}(1)) '' '' num2str(time_vocal{get(hb, ''Value'')}(1)) ''])'']; ',...
     ' eval(Stri); ', ...
     'end']);
 %      ' update_slide(get(hb, ''Value''), time_vocal,xmax, maxF), ',...

% This avoids flickering when updating the axis
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
toc

end
