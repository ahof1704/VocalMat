%Jan 19th: Saving the info for the spectogram plot (A) now is optional
%Sept 12th: Inserting the method of removal by local median.
%Sept 6th: Change the code to make it work in batch.
%Aug 29th: For some reason, when I make a big time window (> 60s) to calculate the
%spectogram, the number of detected components is too small (or zero),
%because the objects get too small. I have to make loops to run through all
%the the minutes. Hopefully I won't divide any vocalization in the
%middle...
%Aug 28th: Possible correction in the loop that builds the vocalizations. I
%was calling for graindata(k) instead of graindata(min_area(k)).
%Aug 25th: This version of identifier works with image processing and is
%being developed to be able to identify harmonics in vocalizations.
% close all

clc
clear all
raiz = pwd;
[vfilename,vpathname] = uigetfile({'*.wav'},'Select the sound track');
cd(vpathname);
diary(['Summary_' num2str(horzcat(fix(clock))) '.txt'])
list = dir('*.wav');
p = mfilename('fullpath')

% min_db = -220;%-110;%-107; %selec points >min_db
max_interval = 0.005 %if the distance between two successive points in time is >max_interval, it is new vocalization
minimum_size = 10%20; %A valid vocalization must present >minimum_size valid points to be considered a vocalization
median_dist = 600 %600; If the median of the euclidean distance between succesive pair of points in a vocalization is >median_dist, then it is noise.
max_vocal_duration = 0.140 %If a vocalization is onger than max_vocal_duration, than it can be a noise that needs to be removed by denoising process.
use_median = 1 %If =1, use the median method to detect the noise.
save_spectogram_background = 1
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
    
    grain_total =[];
    T_orig =[];
    % graindata_total = [];
    % cc_total = [];
    A_total = [];
    
    for minute_frame = 1:size(y1,1)/(60*250000) %run through all the minute windows
        disp(['Current minute: ' num2str(minute_frame)])
        %     jump = 0;%3*5000000;
        clear A B y2 S F T P q vocal id F_orig grain
        y2 = y1(60*(minute_frame-1)*250000+1:60*minute_frame*250000); %Window size in seconds
        %         y2 = y1(1:250000); %Analyze first one second.
        %         y2 = y1(0*250000+1:5*250000); %Window size in seconds
        nfft = 1024;
        nover = (128);
        window = hamming(256);
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
            A = A(:,350:end); %Cut off the first 0.18s... usually there is a weird noise in the beggining
            T = T(:,350:end);
        end
        
        median_db = median(median(A));
        B = imadjust(imcomplement(abs(A)./max(abs(A(:)))));
        
        if size(T_orig,2) %Use this information to make time correction later
            prev_T_orig = size(T_orig,2);
        else
            prev_T_orig = 0;
        end
        
        T_orig = [T_orig T+60*(minute_frame-1)*ones(size(T,2),1)']; %Correcting according to the window
        F_orig = F;
        A_total = [A_total A];
        
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
        graindata = regionprops(cc,'all');
        min_area = find([graindata.Area]>20) ;
        grain = false(size(B));
        for k=1:size(min_area,2)
            grain(cc.PixelIdxList{min_area(k)}) = true;
        end
        
        %         se1 = strel('disk', 2, 0);
        %         grain2 = imdilate(grain,se1);
        %         grain2 = imerode(grain2, se);
        % figure, imshow(grain2);
        grain2 = grain;
        
        disp('Recalculating Connected components')
        cc = bwconncomp(grain2, 4);
        
        graindata = regionprops(cc,'all');
        
        clear grain2
        clear grain
        
        min_area = find([graindata.Area]>60) ;
        grain = false(size(B));
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
        
        grain_total = [grain_total grain];
        % dx=2000;
        % figure, imshow((grain))
        % set(gca,'xlim',[0 dx]);
        % pos=get(gca,'position');
        % Newpos=[pos(1) pos(2)-0.1 pos(3) 0.05];
        % xmax=size(grain,2);
        % Stri=['set(gca,''xlim'',get(gcbo,''value'')+[0 ' num2str(dx) '])'];
        % h=uicontrol('style','slider',...
        %     'units','normalized','position',Newpos,...
        %     'callback',Stri,'min',0,'max',xmax-dx,'SliderStep',[0.0001 0.010]);
        %
        %
        % hold on
        % for k=1:size(min_area,2)
        % %     grain(cc.PixelIdxList{min_area(k)}) = true;
        % %     plot(centroids(:,1),centroids(:,2), 'b*')
        %     text(graindata(min_area(k)).Centroid(:,1),graindata(min_area(k)).Centroid(:,2),num2str(min_area(k)),'HorizontalAlignment','left','FontSize',20,'Color','b')
        % end
    end
    
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
    for k=1:size(graindata_2,1)-1
        if k==1
            time_vocal{id} = [];
            time_vocal{id}= unique(graindata_2(k).PixelList(:,1))';
            freq_vocal{id}{1}=[];
            for freq_per_time = 1:size(time_vocal{id},2)
                freq_vocal{id}{freq_per_time} = find(grain(:,time_vocal{id}(freq_per_time))==1); %Storing vector frequency for that vocalization
            end
        else
            if min(graindata_2(k).PixelList(:,1)) - max(time_vocal{id}) > 20 %If the blobs are close enough in X axis (not in time, yet), then they should be part of same vocalization
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
    end
    
    if size(time_vocal,2)>0
        disp(['Removing small vocalizations (< ' num2str(minimum_size) ' points)'])
        for k=1:size(time_vocal,2)
            if  size(time_vocal{k},2) < minimum_size %|| max(freq_vocal{k})-min(freq_vocal{k}) > 45000
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
                    freq_selected = abs(F_orig - freq_vocal{k}{col}(col2));
                    [freq_selected freq_selected] = min(freq_selected);
                    %                 freq_selected = find(freq_vocal{k}{col}(col2)==F_orig);
                    intens_vocal{k} = [intens_vocal{k}; A_total(freq_selected,time_seleted)];
                end
            end
            
            %Use this loop to correct the max_local_freq and min_local_freq
            aux = abs(F_orig-max_local_freq(k));
            [aux aux] = min(aux);
            max_local_freq(k) = F_orig(aux);
            
            aux = abs(F_orig-min_local_freq(k));
            [aux aux] = min(aux);
            min_local_freq(k) = F_orig(aux);
        end
        
        disp('Removing noise by local median')
        for k=1:size(time_vocal,2)
            skip_max_freq = 0;
            %             if k==247
            %                 k
            %             end
            %     median_db = median(median(A(find(F_orig==min(freq_vocal{k})):find(F_orig==max(freq_vocal{k})),find(T_orig==time_vocal{k}(ceil(end/2)))-200 : find(T_orig==time_vocal{k}(ceil(end/2))) + 200))); %Calculating median in the freq range of identified vocalization
            %     median_freq = find(F_orig==median(freq_vocal{k}));
            %         median_freq = abs(F_orig-median(freq_vocal{k}));
            %         [median_freq median_freq] = min(median_freq); %index of closest value
            try
                median_db = median(median(A_total(find(min_local_freq(k)==F_orig)-5:find(max_local_freq(k)==F_orig)+5,find(T_orig==time_vocal{k}(ceil(end/2)))-200 : find(T_orig==time_vocal{k}(ceil(end/2))) + 200))); %Calculating median in the freq range of identified vocalization
            catch
                %             if find(T_orig==time_vocal{k}(ceil(end/2)))-200 <0
                %                 median_db = median(median(A(find(min_local_freq(k)==F_orig)-5:find(max_local_freq(k)==F_orig)+5,1 : find(T_orig==time_vocal{k}(ceil(end/2))) + 200)));
                %             elseif find(T_orig==time_vocal{k}(ceil(end/2))) + 200 > size(A,2)
                %                 if find(min_local_freq(k)==F_orig)-5 < 0
                %                     median_db = median(median(A(1:find(max_local_freq(k)==F_orig)+5,find(T_orig==time_vocal{k}(ceil(end/2)))-200 : end)));
                %                 elseif find(max_local_freq(k)==F_orig)+5 > size(A,1)
                %
                %                 else
                %                     median_db = median(median(A(find(min_local_freq(k)==F_orig)-5:find(max_local_freq(k)==F_orig)+5,find(T_orig==time_vocal{k}(ceil(end/2)))-200 : end)));
                %                 end
                %
                %             elseif find(max_local_freq(k)==F_orig)+5 > size(A,1)
                %                 median_db = median(median(A(find(min_local_freq(k)==F_orig)-5:end,find(T_orig==time_vocal{k}(ceil(end/2)))-200 : find(T_orig==time_vocal{k}(ceil(end/2))) + 200)));
                %             else
                %                 median_db = median(median(A(find(min_local_freq(k)==F_orig),find(T_orig==time_vocal{k}(ceil(end/2)))-200 : find(T_orig==time_vocal{k}(ceil(end/2))) + 200)));
                %             end
                if find(min_local_freq(k)==F_orig)-5 <= 0
                    if find(max_local_freq(k)==F_orig)+5 > size(A_total,1)
                        min_freq=1;
                        max_freq = size(A,1);
                        max_time = find(T_orig==time_vocal{k}(ceil(end/2)))+200;
                        min_time = find(T_orig==time_vocal{k}(ceil(end/2)))-200;
                        if min_time<1
                            min_time=1;
                        end
                        skip_max_freq = 1;
                    else
                        min_freq=1;
                        max_freq = find(max_local_freq(k)==F_orig)+5;
                        max_time = find(T_orig==time_vocal{k}(ceil(end/2)))+200;
                        min_time = find(T_orig==time_vocal{k}(ceil(end/2)))-200;
                        if min_time<1
                            min_time=1;
                        end
                    end
                end
                if find(max_local_freq(k)==F_orig)+5 > size(A_total,1) && skip_max_freq==0
                    max_freq = size(A,1);
                    min_freq = find(min_local_freq(k)==F_orig)-5;
                    max_time = find(T_orig==time_vocal{k}(ceil(end/2)))+200;
                    min_time = find(T_orig==time_vocal{k}(ceil(end/2)))-200;
                     if min_time < 1
                        min_time=1;
                    end
                end
                if find(T_orig==time_vocal{k}(ceil(end/2)))-200 <0
                    min_time=1;
                    max_time = find(T_orig==time_vocal{k}(ceil(end/2)))+200;
                    max_freq = find(max_local_freq(k)==F_orig)+5;
                    if max_freq > size(A_total,1)
                        max_freq = size(A_total,1);
                    end
                    min_freq = find(min_local_freq(k)==F_orig)-5;
                    if min_freq < 1
                        min_freq=1;
                    end
                end
                if find(T_orig==time_vocal{k}(ceil(end/2))) + 200 > size(A_total,2)
                    max_time = size(A_total,2);
                    min_time = find(T_orig==time_vocal{k}(ceil(end/2)))-200;
                    max_freq = find(max_local_freq(k)==F_orig)+5;
                    if max_freq > size(A_total,1)
                        max_freq = size(A_total,1);
                    end
                    min_freq = find(min_local_freq(k)==F_orig)-5;
                    if min_freq < 1
                        min_freq=1;
                    end
                end
                %                 skip_max_freq = 0;
                median_db = median(median(A_total(min_freq:max_freq,min_time:max_time)));
                
            end
            %         if time_vocal{k}(1)> 200
            %             k
            %         end
            temp = sort(intens_vocal{k});
            if median(temp(end-5:end)) < median_db-0.1*median_db %it is a subtraction because the intensity is already negative. So it is increasing the
                %             if median(intens_vocal{k}) < median_db-0.1*median_db
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
        intens_vocal_orig = intens_vocal;
        freq_vocal_orig = freq_vocal;
        time_vocal_orig = time_vocal;
        %         time_vocal = time_vocal_orig;
        %         intens_vocal = intens_vocal_orig;
        %         freq_vocal = freq_vocal_orig;
        
        

        disp('Eliinating points with low intensity (based on STD)')
        freq_vocal_distribution = {};
        intens_vocal_distribution = {};
        for k=1:size(time_vocal,2)
            %            min_intensity = mean(cellfun(@mean, intens_vocal{k}))-sqrt(mean(cellfun(@std, intens_vocal{k})));
            
            %Identify the peak with highest intensity and calculate gaussian around this peak
            [dist_intens,xi,bw]=ksdensity(intens_vocal{k});
            dist_intens = sqrt(dist_intens.^2)/max(abs(dist_intens));
            %            bw
            %            [f,xi,bw]=ksdensity(intens_vocal{k},'width',1.5);
%                         figure,plot(xi,dist_intens)
            [pks,locs]=findpeaks(dist_intens,'MinPeakProminence',0.1);
            
            % evaluate relation to the peaks
            [max_peak1, max_peak1]=max(pks);
            max_peak.intensity = xi(locs(max_peak1)); xi(max_peak1)=[];
            max_peak.peak = max(pks); pks(max_peak1)=[];
            [max_peak1, max_peak1]=max(pks);
            max_peak2.intensity = xi(locs(max_peak1)); xi(max_peak1)=[];
            max_peak2.peak = max(pks); pks(max_peak1)=[];
            sigma = std(intens_vocal{k});
            
                %            f = exp(-(sort(intens_vocal{k})-xi(max(locs))).^2./(2*sigma^2))./(sigma*sqrt(2*pi));
                %            figure(k),plot(sort(intens_vocal{k}),f)
                
                min_intensity = xi(max(locs))- sigma;
                
                    
                
                %            min_intensity = mean(intens_vocal{k})- sigma;
                T_min_max = [time_vocal{k}(1) time_vocal{k}(end)];
                [T_min T_min] = min(abs(T_orig - T_min_max(1)));
                [T_max T_max] = min(abs(T_orig - T_min_max(2)));
                test2 = max(A_total(:,T_min:T_max),[],2);
                test3 = sqrt(test2.^2)/max(abs(test2));
                test3 = 1-test3;
                dist_freq = test3*1/max(test3);
%                             figure, plot(F_orig,dist_freq)
                
                temp={};
                for kk=1:size(freq_vocal{k},2) %organize the intens_vocal in the same way as freq_vocal
                    temp = [ temp intens_vocal{k}(1:size(freq_vocal{1,k}{1,kk},1))];
                    intens_vocal{k}(1:size(freq_vocal{1,k}{1,kk},1)) = [];
                end
                intens_vocal{k} = temp;
                
             if ~isempty(max_peak2.peak) && max_peak.peak / max_peak2.peak < 3
                probability_vector{k} = temp;
                
                for kk=1:size(intens_vocal{k},2)
                    for kkk=1:size(intens_vocal{k}{kk},1)
                        [intens intens] = min(abs(intens_vocal{k}{kk}(kkk)-xi));
                        [freq freq] = min(abs(freq_vocal{k}{kk}(kkk)-F_orig));
                        probability_vector{k}{kk}(kkk) = dist_intens(intens)*dist_freq(freq);
                    end
                end
                
                temp=[];
                for kk=1:size(probability_vector{k},2)
                    for kkk=1:size(probability_vector{k}{kk},1)
                        temp = [temp; probability_vector{k}{kk}(kkk)];
                    end
                end
                probability_vector_dist{k} = temp;
                
                for kk=1:size(intens_vocal{k},2)
                    %               too_low = intens_vocal{k}{kk} < min_intensity;
                    too_low = probability_vector{k}{kk} < 0.25;
                    intens_vocal{k}{kk}(too_low) = [];
                    freq_vocal{k}{kk}(too_low) = [];
                    if isempty(intens_vocal{k}{kk})
                        time_vocal{k}(kk) = -100;
                    end
                end
                freq_vocal{k} = freq_vocal{k}(~cellfun('isempty',freq_vocal{k}));
                intens_vocal{k} = intens_vocal{k}(~cellfun('isempty',intens_vocal{k}));
                time_vocal{k}(time_vocal{k}==-100) = [];
                
            end
            
            %apply attenuation band
            %            T_min_max = [time_vocal{k}(1) time_vocal{k}(end)];
            %            [T_min T_min] = min(abs(T_orig - T_min_max(1)));
            %            [T_max T_max] = min(abs(T_orig - T_min_max(2)));
            %            figure, surf(T_orig(T_min:T_max),F_orig,A_total(:,T_min:T_max),'edgecolor','none')
            %            test2 = max(A_total(:,T_min:T_max),[],2);
            %            test3 = sqrt(test2.^2)/max(abs(test2));
            %            test3 = test3*1/max(test3);
            %
            %            copy_intensity = intens_vocal{k};
            %            for kk=1:size(intens_vocal{k},2)
            %                for kkk=1:size(intens_vocal{k}{kk},1)
            %                 [min_aa min_aa] = min(abs(F_orig-freq_vocal{k}{kk}(kkk)));
            %                 factor = test3(min_aa);
            %                 copy_intensity{kk}(kkk) = factor * copy_intensity{kk}(kkk);
            %                end
            %            end
            
            %create a new vector for distribution
            %            temp = [];
            %            temp1 =[];
            %            for kk=1:size(freq_vocal{k},2)
            %             temp = [temp; freq_vocal{k}{kk}];
            %             temp1 = [temp1; intens_vocal{k}{kk}];
            %            end
            %            freq_vocal_distribution{k} = temp;
            %            intens_vocal_distribution{k} = temp1;
        end
        
        %Plotting histograms to check intensity and frequency distribution
        
        
        % disp('Plotting vocalizations detected')
        % % figure
        % hold on
        % % c = randi([0 256],1,1);
        % for k=1:size(time_vocal,2)
        %    c = [rand() rand() rand()]; %randi([0 256],1,1)
        %    for time_stamp = 1:size(time_vocal{k},2)
        %         scatter(time_vocal{k}(time_stamp)*ones(size(freq_vocal{k}{time_stamp}')),freq_vocal{k}{time_stamp}',[],repmat(c,size(freq_vocal{k}{time_stamp}',2),1))
        %    end
        % end
        
        % dx=0.4;
        % % figure, imshow(flipud(grain))
        % set(gca,'xlim',[0 dx]);
        % set(gca,'ylim',[0 max(F)]);
        % pos=get(gca,'position');
        % Newpos=[pos(1) pos(2)-0.1 pos(3) 0.05];
        % xmax=max(T_orig);
        % Stri=['set(gca,''xlim'',get(gcbo,''value'')+[0 ' num2str(dx) '])'];
        % h=uicontrol('style','slider',...
        %     'units','normalized','position',Newpos,...
        %     'callback',Stri,'min',0,'max',xmax-dx,'SliderStep',[0.0001 0.010]);
        
        
        % disp('Plotting names on spectrogram and organizing table')
        % for i=1:size(time_vocal,2)
        %     text(time_vocal{i}(round(end/2)),freq_vocal{i}{round(end/2)}(round(end/2))+5000,[num2str(i)],'HorizontalAlignment','left','FontSize',20,'Color','r');
        % %     output = [output; i, size(time_vocal{i},2) , min(time_vocal{i}), max(time_vocal{i}), (max(time_vocal{i})-min(time_vocal{i})) , max(freq_vocal{i}), mean(freq_vocal{i}),(max(freq_vocal{i})-min(freq_vocal{i})) , min(freq_vocal{i}), min(intens_vocal{i}), max(intens_vocal{i}), mean(intens_vocal{i})];
        % end
        if save_spectogram_background==1
            save(['output_' vfilename],'T_orig','F_orig','time_vocal','freq_vocal','vfilename','intens_vocal','A_total','-v7.3')
        else
            save(['output_' vfilename],'T_orig','F_orig','time_vocal','freq_vocal','vfilename','intens_vocal')
        end
        warning('off', 'MATLAB:save:sizeTooBigForMATFile')
        disp('Cleaning variables: y y1 S F T P fs q nd vocal id' )
        clear y y1 S F T P fs q nd vocal id
        
        toc
    end
    
    X = [vfilename,' has ',num2str(size(time_vocal,2)),' vocalizations.'];
    disp(X)
    toc
    % set(gca,'xlim',[0 dx]);
    % set(gca,'ylim',[0 max(F)]);
    % % Generate constants for use in uicontrol initialization
    % pos=get(gca,'position');
    % yourcell = 1:size(time_vocal,2);
    % hb = uicontrol('Style', 'listbox','Position',[pos(1)+10 pos(2)+100 100 pos(4)+700],...
    %      'string',yourcell,'Callback',...
    %      ['if get(hb, ''Value'')>0 ',...
    %      ' Stri=[''set(gca,''''xlim'''',[-dx/2 dx/2]+['' num2str(time_vocal{get(hb, ''Value'')}(1)) '' '' num2str(time_vocal{get(hb, ''Value'')}(1)) ''])'']; ',...
    %      ' eval(Stri); ', ...
    %      'end']);
    %  %      ' update_slide(get(hb, ''Value''), time_vocal,xmax, maxF), ',...
    %
    % % This avoids flickering when updating the axis
    % Newpos=[pos(1) pos(2)-0.1 pos(3) 0.05];
    % xmax=max(T_orig);
    % Stri=['set(gca,''xlim'',get(gcbo,''value'')+[0 ' num2str(dx) '])'];
    % h=uicontrol('style','slider',...
    %     'units','normalized','position',Newpos,...
    %     'callback',Stri,'min',0,'max',xmax-dx,'SliderStep',[0.0001 0.010]);
    % % set(gcf,'Renderer','OpenGL')
    % %
    % % % close all
    
    
end
diary('off');