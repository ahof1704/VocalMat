
raiz = pwd;
identifier_path = 'C:\Users\ahf38\Documents\GitHub\VocalMat\VocalMat - Identifier'
[vfilename,vpathname] = uigetfile({'*.wav'},'Select the sound track');
cd(vpathname);
%diary(['Summary_' num2str(horzcat(fix(clock))) '.txt'])
%list = dir('*.WAV');
p = mfilename('fullpath')

% min_db = -220;%-110;%-107; %selec points >min_db
max_interval = 20 %if the distance between two successive points in time is >max_interval, it is new vocalization
minimum_size = 6 %10%20; %A valid vocalization must present >minimum_size valid points to be considered a vocalization
save_spectogram_background = 1
local_median = 1  %use the median method to detect the noise.
pdf_filter = 0
tic
%for Name = 1:size(list,1)
%    vfilename = list(Name).name;
%    vfilename = vfilename(1:end-4);
vfile = fullfile(vpathname,vfilename);
disp('Cleaning variables: time_vocal freq_vocal intens_vocal output')
clear time_vocal freq_vocal intens_vocal output time_vocal_nogaps freq_vocal_nogaps intens_vocal_nogaps
fprintf('\n');
disp(['Reading audio ' vfilename])
%    cd (vpathname)
[y1,fs]=audioread(vfile);
% -- duration: number of one minute segments in the audio file
duration = ceil(size(y1,1)/(60*fs));

% -- pre-allocate known-size variables for faster performance
F_orig      = [];
T_orig      = cell(1, duration);
A_total     = cell(1, duration);
grain_total = cell(1, duration);
								
overlap = 5 %in seconds	   

segm_size = 1 %in minutes
segments = segm_size:segm_size:ceil(size(y1,1)/(60*fs));
if segments(end)<ceil(size(y1,1)/(60*fs))
    segments = [segments, ceil(size(y1,1)/(60*fs))];
end

for minute_frame = 1:size(segments,2) %run through all segments
    disp(['Current minute: ' num2str(minute_frame)])
    %     jump = 0;%3*5000000;
    clear A B y2 S F T P q vocal id grain
    
    if minute_frame == 1 %this division only matters for the spectrogram calculation
       try
            y2 = y1(60*(segments(minute_frame)-segm_size)*fs+1:(60*segments(minute_frame)+overlap)*fs); %Window size in seconds
        catch % in case this file is shorter than one minte
            y2 = y1(60*(segments(minute_frame)-segm_size)*fs+1:end); %Window size in seconds
        end
    elseif minute_frame == size(segments,2)
        y2 = y1((60*(segments(minute_frame-1))-overlap)*fs+1:end);
    else
        if (60*segments(minute_frame)+overlap)*fs>size(y1,1)
            y2 = y1((60*(segments(minute_frame)-segm_size)-overlap)*fs+1:end);
        else
            y2 = y1((60*(segments(minute_frame)-segm_size)-overlap)*fs+1:(60*segments(minute_frame)+overlap)*fs);
        end
    end
    
    %         y2 = y1(1:fs); %Analyze first one second.
    %         y2 = y1(0*fs+1:5*fs); %Window size in seconds
    nfft = 1024; %orig: 1024
    nover = (128);
    window = hamming(256); %orig: 256
    %     db_threshold = -200;
    dx = 0.4;
    disp('Calculating spectrogram')
    % [S,F,T,P] = spectrogram(y1, window, nover, nfft, fs, 'yaxis', 'MinThreshold',db_threshold);
    [S,F,T,P] = spectrogram(y2, window, nover, nfft, fs, 'yaxis');
    
    %cutoff frequency
    min_freq = find(F>45000);
    
    F = F(min_freq);
    S = S(min_freq,:);
    P = P(min_freq,:);
    P(P==0)=1;
    A = 10*log10(P);
    if minute_frame==1
        A = A(:,600:end); %Cut off the first 0.3s... usually there is a weird noise in the beggining.
        T = T(:,600:end);
    end
    
    %     median_db = median(median(A));
    B = imadjust(imcomplement(abs(A)./max(abs(A(:)))));
    
    %     if size(T_orig,2) %Use this information to make time correction later
    %         prev_T_orig = size(T_orig,2);
    %     else
    %         prev_T_orig = 0;
    %     end
    if minute_frame == 1
        lim_inferior = 1;
        lim_superior = find(T<=60*minute_frame,1,'last');
        F_orig = F;
    elseif minute_frame == duration
        T = T+(60*(minute_frame-1)-overlap)*ones(size(T,2),1)';
        lim_inferior = find(T>=(60*(minute_frame-1)),1,'first');
        lim_superior = size(T,2); 
    else
        T = T+(60*(minute_frame-1)-overlap)*ones(size(T,2),1)';
        lim_inferior = find(T>=(60*(minute_frame-1)),1,'first');
        lim_superior = find(T<=60*minute_frame,1,'last');   
    end
    T = T(lim_inferior:lim_superior);
	T_orig{minute_frame} = T; %remove the extra 5s											   
    A = A(:,lim_inferior:lim_superior);
    A_total{minute_frame} = A;
    
    % Threshold image - adaptive threshold
    BW = imbinarize(B, 'adaptive', 'Sensitivity', 0.200000, 'ForegroundPolarity', 'bright');
    
    %     BW = imclearborder(BW);
    
    % Open mask with line
    %         length = 3.000000;
    %         angle = 0.000000;
    %         se = strel('line', length, angle);
    %         BW = imopen(BW, se);
    % Open mask with rectangle
    dimensions = [4 2];
    se = strel('rectangle', dimensions);
    BW = imopen(BW, se);
    
    length = 4.000000;
    angle = 90.000000;
    se = strel('line', length, angle);
    BW = imdilate(BW, se);
    
    % Create masked image.
    maskedImage = B;
    maskedImage(~BW) = 0;
    B = maskedImage;
    
    disp('Connected components')
    cc = bwconncomp(B, 4);
    graindata = regionprops(cc,'Area');
    min_area = find([graindata.Area]>20) ;
    grain = false(size(B));
    for k=1:size(min_area,2)
        grain(cc.PixelIdxList{min_area(k)}) = true;
    end
    
    %         se1 = strel('disk', 2, 0);
    %         grain2 = imdilate(grain,se1);
    %         grain2 = imerode(grain2, se);
    % figure, imshow(grain2);
    
    %Apply limits
    grain2 = grain(:,lim_inferior:lim_superior);
    
    disp('Recalculating Connected components')
    cc = bwconncomp(grain2, 4);
    
    graindata = regionprops(cc,'all');
    
    clear grain2
    clear grain
    
    min_area = find([graindata.Area]>60) ;
    grain = false(size(A));
    for k=1:size(min_area,2)
        %             if ~any(graindata(min_area(k)).PixelList(:,2)>size(grain,1)-5) %5 pixels as tolerance
        grain(cc.PixelIdxList{min_area(k)}) = true;
        %             text(graindata(min_area(k)).Centroid(:,1),graindata(min_area(k)).Centroid(:,2),num2str(k),'HorizontalAlignment','left','FontSize',20,'Color','b')
        %             end
    end
    
    length = 3.000000;
    angle = 0;
    se = strel('line', length, angle);
    grain = imdilate(grain, se);
    
    grain_total{minute_frame} = grain;
    
end
T_orig      = cell2mat(T_orig);
A_total     = cell2mat(A_total);
grain_total = cell2mat(grain_total);
grain = grain_total;
cc_2 = bwconncomp(grain, 4);
graindata_2 = regionprops(cc_2,'all');


% figure('Name',vfilename,'NumberTitle','off')
% surf(T_orig,F_orig,A_total,'edgecolor','none')
% axis tight; view(0,90);
% colormap(gray);
% xlabel('Time (s)'); ylabel('Freq (Hz)')

% hold on

time_vocal = [];
id = 1;
cc_count           = size(graindata_2,1)-1; 
centroid_to_id     = cell(cc_count, 1);

for k=1:cc_count
    if k==1
        time_vocal{id} = [];
        time_vocal{id}= unique(graindata_2(k).PixelList(:,1))';
        freq_vocal{id}{1}=[];
        for freq_per_time = 1:size(time_vocal{id},2)
            freq_vocal{id}{freq_per_time} = find(grain(:,time_vocal{id}(freq_per_time))==1); %Storing vector frequency for that vocalization
        end
    else
        if min(graindata_2(k).PixelList(:,1)) - max(time_vocal{id}) > max_interval %Equivalent to 10ms. If the blobs are close enough in X axis (not in time, yet), then they should be part of same vocalization
            id=id+1;
            time_vocal{id} = [];
            time_vocal{id}= unique(graindata_2(k).PixelList(:,1))';
            freq_vocal{id}{1}=[];
            for freq_per_time = 1:size(time_vocal{id},2)
                freq_vocal{id}{freq_per_time} = find(grain(:,time_vocal{id}(freq_per_time))==1); %Storing vector frequency for that vocalization
            end
        else %if it is not a new vocalization (harmonics also fall into this case)
            time_vocal{id}= unique([time_vocal{id}, graindata_2(k).PixelList(:,1)']); %Storing vector time for that vocalization
            freq_vocal{id}{1}=[];
            for freq_per_time = 1:size(time_vocal{id},2)
                freq_vocal{id}{freq_per_time} = find(grain(:,time_vocal{id}(freq_per_time))==1); %Storing vector frequency for that vocalization
            end
        end
    end
    centroid_to_id{k} = [id, k, T_orig(time_vocal{id}(1)), graindata_2(k).Area];
end

centroid_to_id = cell2mat(centroid_to_id);
centroid_orig  = centroid_to_id;
temp = [];
idx = unique(centroid_to_id(:,1));
for k=1:size(idx,1)
    aux = centroid_to_id((centroid_to_id(:,1)==idx(k)),:);
    temp = [temp; [aux(1,[1 3]) sum(aux(:,4))]];
end
centroid_to_id = temp;

if size(time_vocal,2)>0
    disp(['Removing small vocalizations (< ' num2str(minimum_size) ' points)'])
    for k=1:size(time_vocal,2)
        if  size(time_vocal{k},2) < minimum_size 
            disp(['eliminating vocal starting in ' num2str(T_orig(time_vocal{k}(1)))]);
            time_vocal{k}=[];
            freq_vocal{k}=[];
        end
    end
    
    disp('Removing empty cells')
    time_vocal = time_vocal(~cellfun('isempty',time_vocal));
    freq_vocal = freq_vocal(~cellfun('isempty',freq_vocal));
    
    output = [];
    freq_harmonic = {};
    time_harmonic = {};
    
    % mask = false(size(B));
    for k=1:size(time_vocal,2)
        %Detecting harmonics
        for col = 1:size(time_vocal{k},2)
            list_vocal_freq = find(grain(:,time_vocal{k}(col))==1);
            freq = F_orig(list_vocal_freq);
            %         mask(list_vocal_freq,time_vocal{k}(col)) = true;
            freq_vocal{k}{col} = freq;
            time_vocal{k}(col) = T_orig(time_vocal{k}(col));
        end
    end
    
    % clear grain
    
    disp('Smoothing the lines')
    
    for k=1:size(time_vocal,2)
        max_local_freq(k) = 0;
        min_local_freq(k) = 200000;
        for time_stamp = 1:size(time_vocal{k},2)
            %         if k == 23 && time_stamp==27
            %             k
            %         end
            temp = [];
            if  any((freq_vocal{k}{time_stamp} - circshift(freq_vocal{k}{time_stamp} ,[1,0])) > 1000)        %Verify if there is a jump in frequency
                idx_harmonic = find((freq_vocal{k}{time_stamp} - circshift(freq_vocal{k}{time_stamp} ,[1,0])) > 1000); % index of the first frequency stamp after the jump
                for j=1:size(idx_harmonic,1)
                    if size(idx_harmonic,1)==1 % There is no harmonic
                        temp = [temp ; median((freq_vocal{k}{time_stamp}(1:idx_harmonic(j)-1)))];
                        temp = [temp ; median((freq_vocal{k}{time_stamp}(idx_harmonic(j):end)))];
                    else
                        if j==1
                            temp = [temp ; median((freq_vocal{k}{time_stamp}(1:idx_harmonic(j)-1)))];
                        else
                            try
                                temp = [temp ; median((freq_vocal{k}{time_stamp}(idx_harmonic(j-1):idx_harmonic(j)-1)))];
                            catch
                                temp = [temp ; median((freq_vocal{k}{time_stamp}(idx_harmonic(j-1):end)))];
                            end
                        end
                    end
                end
                freq_vocal{k}{time_stamp} = temp;
                if max(temp)>max_local_freq(k)
                    max_local_freq(k) = max(temp);
                end
                if min(temp)<min_local_freq(k)
                    min_local_freq(k) = min(temp);
                end
            else %If there is no harmonic
                if max((freq_vocal{k}{time_stamp}))>max_local_freq(k)
                    max_local_freq(k) = max((freq_vocal{k}{time_stamp}));
                end
                if min((freq_vocal{k}{time_stamp}))<min_local_freq(k)
                    min_local_freq(k) = min(min((freq_vocal{k}{time_stamp})));
                end
                freq_vocal{k}{time_stamp} = median((freq_vocal{k}{time_stamp}));
            end
        end
    end
    
    %Getting intensity for the points we selected as being part of the vocalizations
    for k=1:size(time_vocal,2)
        intens_vocal{k}=[];
        for col = 1:size(time_vocal{k},2)
            time_seleted = find(time_vocal{k}(col)==T_orig);
            for col2 = 1:size(freq_vocal{k}{col},1)
                 freq_selected      = abs(F_orig - freq_vocal{k}{col}(col2));
                [~, freq_selected] = min(freq_selected);
                %                 freq_selected = find(freq_vocal{k}{col}(col2)==F_orig);
                intens_vocal{k} = [intens_vocal{k}; A_total(freq_selected,time_seleted)];
            end
        end
        
        %Use this loop to correct the max_local_freq and min_local_freq
        aux               = abs(F_orig-max_local_freq(k));
        [~, aux]          = min(aux);
        max_local_freq(k) = F_orig(aux);
        
        aux               = abs(F_orig-min_local_freq(k));
        [~, aux]          = min(aux);
        min_local_freq(k) = F_orig(aux);
    end
    
    median_stats = [];
	
    
    if local_median == 1
        disp('Removing noise by local median')
        for k=1:size(time_vocal,2)
            aux_median_stats = [];
            skip_max_freq = 0;
            
            try
                pos = ceil(size(time_vocal{k},2)/2);
                median_db = median(median(A_total(find(min_local_freq(k)==F_orig)-5:find(max_local_freq(k)==F_orig)+5,find(T_orig==time_vocal{k}(pos))-200 : find(T_orig==time_vocal{k}(pos)) + 200))); %Calculating median in the freq range of identified vocalization
                aux_median_stats = [aux_median_stats, time_vocal{k}(1)];
                aux_median_stats = [aux_median_stats, centroid_to_id(find(centroid_to_id(:,2)==time_vocal{k}(1)),3)];
                aux_median_stats = [aux_median_stats, numel(size(A_total(find(min_local_freq(k)==F_orig)-5:find(max_local_freq(k)==F_orig)+5,find(T_orig==time_vocal{k}(pos))-200 : find(T_orig==time_vocal{k}(pos)) + 200)))];
            catch
                
                pos = ceil(size(time_vocal{k},2)/2);
                if find(min_local_freq(k)==F_orig)-5 < 1
                    if find(max_local_freq(k)==F_orig)+5 > size(A_total,1)
                        min_freq=1;
                        max_freq = size(A,1);
                        max_time = find(T_orig==time_vocal{k}(pos))+200;
                        min_time = find(T_orig==time_vocal{k}(pos))-200;
                        if min_time<1
                            min_time=1;
                        end
                    else
                        min_freq=1;
                        max_freq = find(max_local_freq(k)==F_orig)+5;
                        max_time = find(T_orig==time_vocal{k}(pos))+200;
                        min_time = find(T_orig==time_vocal{k}(pos))-200;
                        if min_time<1
                            min_time=1;
                        end
                    end
                    skip_max_freq = 1;
                end
                if find(max_local_freq(k)==F_orig)+5 >= size(A_total,1) && skip_max_freq==0
                    max_freq = size(A,1);
                    min_freq = find(min_local_freq(k)==F_orig)-5;
                    max_time = find(T_orig==time_vocal{k}(pos))+200;
                    min_time = find(T_orig==time_vocal{k}(pos))-200;
                    if min_time < 1
                        min_time=1;
                    end
                end
                if find(T_orig==time_vocal{k}(pos))-200 < 1
                    min_time=1;
                    max_time = find(T_orig==time_vocal{k}(pos))+200;
                    max_freq = find(max_local_freq(k)==F_orig)+5;
                    if max_freq > size(A_total,1)
                        max_freq = size(A_total,1);
                    end
                    min_freq = find(min_local_freq(k)==F_orig)-5;
                    if min_freq < 1
                        min_freq=1;
                    end
                end
                if find(T_orig==time_vocal{k}(pos)) + 200 >= size(A_total,2)
                    max_time = size(A_total,2);
                    min_time = find(T_orig==time_vocal{k}(pos))-200;
                    max_freq = find(max_local_freq(k)==F_orig)+5;
                    if max_freq > size(A_total,1)
                        max_freq = size(A_total,1);
                    end
                    min_freq = find(min_local_freq(k)==F_orig)-5;
                    if min_freq < 1
                        min_freq=1;
                    end
                end                %                 skip_max_freq = 0;
                median_db = median(median(A_total(min_freq:max_freq,min_time:max_time)));
                aux_median_stats = [aux_median_stats, time_vocal{k}(1)];
                aux_median_stats = [aux_median_stats, centroid_to_id(find(centroid_to_id(:,2)==time_vocal{k}(1)),3)];
                aux_median_stats = [aux_median_stats, prod(size(A_total(min_freq:max_freq,min_time:max_time)))];
                
            end
            
            temp = sort(intens_vocal{k});
            aux_median_stats = [aux_median_stats, size(temp,1)];
            aux_median_stats = [aux_median_stats, [median(temp(end-5:end))  median_db]];
            elim_by_median = 0;
            aux_median_stats = [aux_median_stats, elim_by_median];
            median_stats(k,:) = aux_median_stats;
        end
        
        ratio = median_stats(:,5)./median_stats(:,6);
        [y,t]=ecdf(ratio);
        aux = round(linspace(1,size(t,1),35)); % Downsample to 50 points only
        t = t(aux);
        y = y(aux);
        K=LineCurvature2D([t,y]);
        K = K*10^-3;
        [maxx maxx] = max(K);
        th_ratio = t(maxx);

	if th_ratio<0.9
		th_ratio=0.92;
	end
        disp(['Minimal Ratio = ' num2str(th_ratio)])
        
        for k=1:size(time_vocal,2)
            if median_stats(k,5) < th_ratio*median_stats(k,6) %-0.1*median_db %it is a subtraction because the intensity is already negative. So it is increasing the
                disp(['eliminating vocal starting in ' num2str(time_vocal{k}(1))]);
                time_vocal{k}=[];
                freq_vocal{k}=[];
                intens_vocal{k}=[];
                median_stats(k,7) = 1;
            end
        end
        
        disp('Removing empty cells')
        time_vocal = time_vocal(~cellfun('isempty',time_vocal));
        freq_vocal = freq_vocal(~cellfun('isempty',freq_vocal));
        intens_vocal = intens_vocal(~cellfun('isempty',intens_vocal));
        intens_vocal_orig = intens_vocal;
        freq_vocal_orig = freq_vocal;
        time_vocal_orig = time_vocal;
        
    end
    intens_orig = intens_vocal;
    
    for k=1:size(time_vocal,2)
        temp={};
        for kk=1:size(freq_vocal{k},2) %organize the intens_vocal in the same way as freq_vocal
            temp = [ temp intens_vocal{k}(1:size(freq_vocal{1,k}{1,kk},1))];
            intens_vocal{k}(1:size(freq_vocal{1,k}{1,kk},1)) = [];
        end
        intens_vocal{k} = temp;
    end
    

    %Plotting histograms to check intensity and frequency distribution
    
    cd(vpathname)
    vfilename = vfilename(1:end-4);
    
    save(['output_shorter_' vfilename],'T_orig','F_orig','time_vocal','freq_vocal','vfilename','intens_vocal','median_stats')
    
    if save_spectogram_background==1
        tic
        save(['output_' vfilename],'T_orig','F_orig','time_vocal','freq_vocal','vfilename','intens_vocal','median_stats','A_total','-v7.3','-nocompression')
        toc
    else
        save(['output_' vfilename],'T_orig','F_orig','time_vocal','freq_vocal','vfilename','intens_vocal','median_stats')
    end
    
    warning('off', 'MATLAB:save:sizeTooBigForMATFile')
    disp('Cleaning variables: y y1 S F T P fs q nd vocal id' )
    clear y y1 S F T P fs q nd vocal id
    
    toc
end

X = [vfilename,' has ',num2str(size(time_vocal,2)),' vocalizations.'];
disp(X)
toc

