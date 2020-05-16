% ----------------------------------------------------------------------------------------------
% -- Title       : VocalMat Identifier
% -- Project     : VocalMat - A Tool for Automated Mouse Vocalization Detection and Classification
% ----------------------------------------------------------------------------------------------
% -- File        : vocalmat_identifier.m
% -- Group       : Dietrich Lab - Department of Comparative Medicine @ Yale University
% -- Standard    : <MATLAB 2018a>
% ----------------------------------------------------------------------------------------------
% -- Copyright (c) 2020 Dietrich Lab - Yale University
% ----------------------------------------------------------------------------------------------
% -- Description: The VocalMat Identifier is responsible for identifying possible vocalizations 
% -- in the provided audio file. Candidates for vocalization are further analyzed and regions
% -- identenfied as noise are removed. 
% -- The VocalMat Identifier outputs a MATLAB formatted file (.MAT) that contains information
% -- about identified vocalizations (e.g. frequency, vocalization intensity, timestamp).
% ----------------------------------------------------------------------------------------------

% ----------------------------------------------------------------------------------------------
% -- The code is divided into three main sections: 
% -- (1) setup;
% -- (2) image processing;
% -- (3) post-processing.
% -- Bellow is a small description of each section. Further explanation is provided alongside
% -- the code.
% ----------------------------------------------------------------------------------------------

% -- (1) SETUP ---------------------------------------------------------------------------------
% -- This section is responsible for loading the audio file to be processed and initializing
% -- variables to be used throughout the program.
% -- Search for 'SETUP BEGIN' to jump to this section.
% ----------------------------------------------------------------------------------------------

% -- (2) IMAGE PROCESSING ----------------------------------------------------------------------
% -- The audio file is divided into one minute frames, and each frame is processed independently.
% -- First, the spectrogram and the power spectral density of the current segment is computed. 
% -- Next, several morphological image processing techniques - such as contrast enhancement, 
% -- erosion, and dilation - are applied. 
% -- Search for 'IMAGE PROCESSING BEGIN' to jump to this section.
% ----------------------------------------------------------------------------------------------

% -- (3) POST-PROCESSING -----------------------------------------------------------------------
% -- Go through each possible vocalization (connected component) and analyze its area, size, and
% -- other properties. Components that do not meet certain criteria are considered noise and
% -- thus removed. Finally, generate a MAT file with all vocalizations and their properties.
% -- Search for 'POST-PROCESSING BEGIN' to jump to this section.
% ----------------------------------------------------------------------------------------------

% ----------------------------------------------------------------------------------------------
% -- (1) SETUP BEGIN ---------------------------------------------------------------------------
% ----------------------------------------------------------------------------------------------
raiz = pwd;
disp('[vocalmat]: choose the audio file to be analyzed.');
[vfilename,vpathname] = uigetfile({'*.wav'},'Select the sound track');
cd(vpathname);
p = mfilename('fullpath');

% -- save_spectrogram_background: option to output spectrogram background
save_spectrogram_background = 0;

% -- local_median: option to use the local median method to detect noise
local_median = 1;

if ~save_output_files
    disp('[vocalmat][identifier]: the output files from VocalMat Identifier will not be saved to disk (default behavior).')
    disp('                        to change this, modify ''save_output_files'' from 0 to 1 in vocalmat_identifier.m.');
end

% -- tic: start runtime counter
tic

vfile = fullfile(vpathname, vfilename);
mkdir(vfile(1:end-4))
clear time_vocal freq_vocal intens_vocal time_vocal_nogaps freq_vocal_nogaps intens_vocal_nogaps

% -- y1: sampled data; fs: sample rate
[y1,fs] = audioread(vfile);

% -- duration: number of one minute segments in the audio file
duration = ceil(size(y1,1)/(60*fs));
disp(['[vocalmat]: ' vfilename ' has around ' num2str(duration-1) ' minutes.'])

% -- segm_size: duration of each segment to be processed individually, in minutes
% -- overlap: amount of overlap between segments, in seconds
segm_size = 1;
overlap   = 5;
segments  = segm_size:segm_size:duration;
if segments(end) < duration
    segments = [segments, duration];
end

% -- pre-allocate known-size variables for faster performance
num_segments = size(segments,2);
F_orig       = [];
T_orig       = cell(1, num_segments);
A_total      = cell(1, num_segments);
grain_total  = cell(1, num_segments);

% ----------------------------------------------------------------------------------------------
% -- (2) IMAGE PROCESSING BEGIN ----------------------------------------------------------------
% ----------------------------------------------------------------------------------------------
disp(['[vocalmat]: audio file split into ' num2str(size(segments,2)) ' segments of up to ' num2str(segm_size) ' minute(s).'])
for minute_frame = 1:num_segments
% -- run through each segment, compute the spectrogram, and process its outputs

    clear A B y2 S F T P q vocal id grain

    if minute_frame == 1
    % -- y2: current minute frame in seconds, cropped from the whole audio file (y1)
    % -- boundary conditions for first minute, last minute, and files smaller than one minute
        try
            y2 = y1(60*(segments(minute_frame)-segm_size)*fs+1:(60*segments(minute_frame)+overlap)*fs);
        catch
            y2 = y1(60*(segments(minute_frame)-segm_size)*fs+1:end);
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

    disp(['[vocalmat][segment (' num2str(minute_frame) ')]: computing the spectrogram.'])
    % -- compute the spectrogram
    % -- nfft: number of points for the Discrete Fourier Transform
    % -- window: windowing function
    % -- nover: number of overlapped samples
    nfft      = 1024;
    window    = hamming(256);
    nover     = (128);
    [S,F,T,P] = spectrogram(y2, window, nover, nfft, fs, 'yaxis');
    
    % -- remove frequencies bellow 45kHz
    min_freq  = find(F>45000);

    F = F(min_freq);
    S = S(min_freq,:);
    P = P(min_freq,:);

    % -- convert power spectral density to dB
    P(P==0)=1;
    A = 10*log10(P);
            if minute_frame == 1
            % -- remove first 0.3s of recording (recordings might have abnormal behaviour in this range)
                A = A(:,600:end);
                T = T(:,600:end);
            end
    
    % -- normalize 'A', subtract the maximum value pixel-wise (imcomplement), and adjust contrast (imadjust)
    B = imadjust(imcomplement(abs(A)./max(abs(A(:)))));
    
    % -- adjust minute frame to remove extra padding
    if segments(minute_frame) == segm_size
        F_orig = F;
        lim_inferior = 1;
        lim_superior = find(T<=60*segments(minute_frame),1,'last');
    elseif minute_frame == size(segments,2)
        T = T+(60*(segments(minute_frame-1))-overlap)*ones(size(T,2),1)';
        lim_inferior = find(T>=(60*(segments(minute_frame-1))),1,'first');
        lim_superior = size(T,2);
    else
        T = T+(60*(segments(minute_frame)-segm_size)-overlap)*ones(size(T,2),1)';
        lim_inferior = find(T>=(60*(segments(minute_frame)-segm_size)),1,'first');
        lim_superior = find(T<=60*segments(minute_frame),1,'last');
    end

    T = T(lim_inferior:lim_superior);
    T_orig{minute_frame} = T;
    
    A = A(:,lim_inferior:lim_superior);
    A_total{minute_frame} = A;

    % -- binarize image using an adaptive threshold
    BW = imbinarize(B, 'adaptive', 'Sensitivity', 0.200000, 'ForegroundPolarity', 'bright');
    
    % -- morphological image operations
    % -- se: structuring element - rectangle structuring element of size 4x2 pixels
    dimensions = [4 2];
    se = strel('rectangle', dimensions);
    BW = imopen(BW, se);
    
    % -- se: structuring element - line of 4 pixels in length at a 90 degree angle
    length = 4.000000;
    angle  = 90.000000;
    se     = strel('line', length, angle);
    BW     = imdilate(BW, se);
    
    % -- apply mask to original image
    maskedImage      = B;
    maskedImage(~BW) = 0;
    B = maskedImage;
    
    disp(['[vocalmat][segment (' num2str(minute_frame) ')]: computing connected components.'])
    % -- calculate connected components using 4-connected neighborhood policy
    cc = bwconncomp(B, 4);

    % -- calculate area of connected components
    % -- if area is lower than 20, remove
    graindata = regionprops(cc,'Area');
    min_area  = find([graindata.Area]>20) ;
    grain     = false(size(B));
    for k=1:size(min_area,2)
        grain(cc.PixelIdxList{min_area(k)}) = true;
    end
    grain2 = grain(:,lim_inferior:lim_superior);
    
    disp(['[vocalmat][segment (' num2str(minute_frame) ')]: refining connected components.'])
    % -- recalculate connected components
    % -- if area is lower than 60, remove
    cc        = bwconncomp(grain2, 4);
    graindata = regionprops(cc,'Area');
    
    clear grain grain2;

    min_area  = find([graindata.Area]>60) ;
    grain     = false(size(A));
 
    for k=1:size(min_area,2)
        grain(cc.PixelIdxList{min_area(k)}) = true;
    end
    
    % -- se: line of the 3 pixels in length at a 0 degree angle
    % -- dilate using structuring element 'se'
    length = 3.000000;
    angle  = 0;
    se     = strel('line', length, angle);
    grain  = imdilate(grain, se);
    grain_total{minute_frame} = grain;
end

% -- convert cell array to conventional array
T_orig      = cell2mat(T_orig);
A_total     = cell2mat(A_total);
grain_total = cell2mat(grain_total);

% -- calculate connected components using 4-connected policy, then calculate Area and PixelList of the region
grain       = grain_total;
cc_2        = bwconncomp(grain, 4);
graindata_2 = regionprops(cc_2,'Area','PixelList');

% ----------------------------------------------------------------------------------------------
% -- (3) POST-PROCESSING BEGIN -----------------------------------------------------------------
% ----------------------------------------------------------------------------------------------
% -- initialize variables
time_vocal         = [];
id                 = 1;
cc_count           = size(graindata_2,1)-1;
centroid_to_id     = cell(cc_count, 1);

for k = 1:cc_count
% -- for each connected component, get vocalization x-coordinates (time_vocal) and save frequency points (freq_vocal, y-coordinates)
    if k == 1
        time_vocal{id}    = [];
        time_vocal{id}    = unique(graindata_2(k).PixelList(:,1))';
        freq_vocal{id}{1} = [];
        for freq_per_time = 1:size(time_vocal{id},2)
            freq_vocal{id}{freq_per_time} = find(grain(:,time_vocal{id}(freq_per_time))==1);
        end
    else
        if min(graindata_2(k).PixelList(:,1)) - max(time_vocal{id}) > max_interval
        % -- if two points are distant enough, identify as a new vocalization
            id = id + 1;
            time_vocal{id}    = [];
            time_vocal{id}    = unique(graindata_2(k).PixelList(:,1))';
            freq_vocal{id}{1} = [];
            for freq_per_time = 1:size(time_vocal{id},2)
                freq_vocal{id}{freq_per_time} = find(grain(:,time_vocal{id}(freq_per_time))==1);
            end
        else
            time_vocal{id}    = unique([time_vocal{id}, graindata_2(k).PixelList(:,1)']);
            freq_vocal{id}{1} = [];
            for freq_per_time = 1:size(time_vocal{id},2)
                freq_vocal{id}{freq_per_time} = find(grain(:,time_vocal{id}(freq_per_time))==1);
            end
        end
    end
    centroid_to_id{k} = [id, k, T_orig(time_vocal{id}(1)), graindata_2(k).Area];
end

centroid_to_id = cell2mat(centroid_to_id);
centroid_orig  = centroid_to_id;
temp           = [];
idx            = unique(centroid_to_id(:,1));
for k=1:size(idx,1)
    aux  = centroid_to_id((centroid_to_id(:,1)==idx(k)),:);
    temp = [temp; [aux(1,[1 3]) sum(aux(:,4))]];
end
centroid_to_id = temp;

if size(time_vocal,2)>0
% -- if there are vocalizations, remove the ones that have less than 6 points
    disp(['[vocalmat]: removing small vocalizations (less than ' num2str(minimum_size) ' points).'])
    for k=1:size(time_vocal,2)
        if  size(time_vocal{k},2) < minimum_size
            time_vocal{k} = [];
            freq_vocal{k} = [];
        end
    end

    % -- do some cleaning, remove empty cells
    time_vocal = time_vocal(~cellfun('isempty',time_vocal));
    freq_vocal = freq_vocal(~cellfun('isempty',freq_vocal));
    
    freq_harmonic = {};
    time_harmonic = {};

    for k=1:size(time_vocal,2)
    % -- for each vocalization, convert x|y-coordinates to frequency-time points
        for col = 1:size(time_vocal{k},2)
            list_vocal_freq    = find(grain(:,time_vocal{k}(col))==1);
            freq               = F_orig(list_vocal_freq);
            freq_vocal{k}{col} = freq;
            time_vocal{k}(col) = T_orig(time_vocal{k}(col));
        end
    end
        
    for k=1:size(time_vocal,2)
    % -- for each vocalization, check in each timestamp if there is a jump in frequency (harmonic)
        max_local_freq(k) = 0;
        min_local_freq(k) = 200000;
        for time_stamp = 1:size(time_vocal{k},2)
            temp = [];
            if any((freq_vocal{k}{time_stamp} - circshift(freq_vocal{k}{time_stamp} ,[1,0])) > 1000)
            % -- if there are a jumps in frequency, get all jumps
                idx_harmonic = find((freq_vocal{k}{time_stamp} - circshift(freq_vocal{k}{time_stamp} ,[1,0])) > 1000);
                for j=1:size(idx_harmonic,1)
                % -- for each jump, get all frequency points for each range
                    if size(idx_harmonic,1)==1
                    % -- if there's only one jump, get both ranges
                        temp = [temp ; median((freq_vocal{k}{time_stamp}(1:idx_harmonic(j)-1)))];
                        temp = [temp ; median((freq_vocal{k}{time_stamp}(idx_harmonic(j):end)))];
                    else
                    % -- else, sweep jumps and get each range
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

                % -- update local maximum and minimum frequencies
                freq_vocal{k}{time_stamp} = temp;
                if max(temp)>max_local_freq(k)
                    max_local_freq(k) = max(temp);
                end
                if min(temp)<min_local_freq(k)
                    min_local_freq(k) = min(temp);
                end
            else
            % -- if there are no jumps in frequency, only update local maximum and minimum frequencies
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
    
    for k=1:size(time_vocal,2)
    % -- for each vocalization, get intensity (dB)
        intens_vocal{k} = [];
        for col = 1:size(time_vocal{k},2)
        % -- for each timestamp in a vocalization, select the frequencies belonging to that vocalization
            time_selected                 = time_vocal{k}(col)==T_orig;
            [~, time_selected] = max(time_selected);
            for col2 = 1:size(freq_vocal{k}{col},1)
            % -- for each selected frequency, get its intensity
                freq_selected      = abs(F_orig - freq_vocal{k}{col}(col2));
                [~, freq_selected] = min(freq_selected);
                intens_vocal{k}    = [intens_vocal{k}; A_total(freq_selected,time_selected)];
            end
        end
        
        % -- update local maximum and minimum frequencies
        aux               = abs(F_orig-max_local_freq(k));
        [~, aux]          = min(aux);
        max_local_freq(k) = F_orig(aux);
        
        aux               = abs(F_orig-min_local_freq(k));
        [~, aux]          = min(aux);
        min_local_freq(k) = F_orig(aux);
    end

    median_stats = [];
    
    if local_median == 1
    % -- remove noise using local median
    disp(['[vocalmat]: removing noise by local median.'])
        for k=1:size(time_vocal,2)
        % -- for each vocalization, save timestamp where vocalization begins, connected component area, number of elements, ...
            aux_median_stats = [];
            skip_max_freq    = 0;
            try
               pos              = ceil(size(time_vocal{k},2)/2);
               median_db        = median(median(A_total(find(min_local_freq(k)==F_orig)-5:find(max_local_freq(k)==F_orig)+5,find(T_orig==time_vocal{k}(pos))-200 : find(T_orig==time_vocal{k}(pos))+200)));
               aux_median_stats = [aux_median_stats, time_vocal{k}(1)];
               aux_median_stats = [aux_median_stats, centroid_to_id(find(centroid_to_id(:,2)==time_vocal{k}(1)),3)];
               aux_median_stats = [aux_median_stats, numel(A_total(find(min_local_freq(k)==F_orig)-5:find(max_local_freq(k)==F_orig)+5,find(T_orig==time_vocal{k}(pos))-200 : find(T_orig==time_vocal{k}(pos))+200))];
            catch
            % -- boundary conditions
                pos = ceil(size(time_vocal{k},2)/2);
                if find(min_local_freq(k)==F_orig)-5 < 1
                % -- check frequency point is not out or range (lower bound)
                    if find(max_local_freq(k)==F_orig)+5 > size(A_total,1)
                        min_freq = 1;
                        max_freq = size(F_orig,1);
                        max_time = find(T_orig==time_vocal{k}(pos))+200;
                        min_time = find(T_orig==time_vocal{k}(pos))-200;
                        if min_time<1
                            min_time=1;
                        end
                    else
                        min_freq = 1;
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
                % -- check frequency point is not out or range (upper bound)
                    max_freq = size(F_orig,1);
                    min_freq = find(min_local_freq(k)==F_orig)-5;
                    max_time = find(T_orig==time_vocal{k}(pos))+200;
                    min_time = find(T_orig==time_vocal{k}(pos))-200;
                    if min_time < 1
                        min_time=1;
                    end
                end
                if find(T_orig==time_vocal{k}(pos))-200 < 1
                % -- check time point is not out or range (lower bound)
                    min_time = 1;
                    max_time = find(T_orig==time_vocal{k}(pos))+200;
                    max_freq = find(max_local_freq(k)==F_orig)+5;
                    if max_freq > size(A_total,1)
                        max_freq = size(A_total,1);
                    end
                    min_freq = find(min_local_freq(k)==F_orig)-5;
                    if min_freq < 1
                        min_freq = 1;
                    end
                end
                if find(T_orig==time_vocal{k}(pos))+200 >= size(A_total,2)
                % -- check time point is not out or range (upper bound)
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
                end
                median_db        = median(median(A_total(min_freq:max_freq,min_time:max_time)));
                aux_median_stats = [aux_median_stats, time_vocal{k}(1)];
                aux_median_stats = [aux_median_stats, centroid_to_id(find(centroid_to_id(:,2)==time_vocal{k}(1)),3)];
                aux_median_stats = [aux_median_stats, numel(A_total(min_freq:max_freq,min_time:max_time))];
                
            end

            temp             = sort(intens_vocal{k});
            aux_median_stats = [aux_median_stats, size(temp,1)];
            aux_median_stats = [aux_median_stats, [median(temp(end-5:end))  median_db]];
            elim_by_median   = 0;
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
        disp(['[vocalmat]: minimal ratio = ' num2str(th_ratio) '.'])
        
        for k=1:size(time_vocal,2)
            if median_stats(k,5) < th_ratio*median_stats(k,6)
                time_vocal{k}=[];
                freq_vocal{k}=[];
                intens_vocal{k}=[];
                median_stats(k,7) = 1;
            end
        end
        
        % -- do some cleaning, remove empty cells
        time_vocal        = time_vocal(~cellfun('isempty',time_vocal));
        freq_vocal        = freq_vocal(~cellfun('isempty',freq_vocal));
        intens_vocal      = intens_vocal(~cellfun('isempty',intens_vocal));
        intens_vocal_orig = intens_vocal;
        freq_vocal_orig   = freq_vocal;
        time_vocal_orig   = time_vocal;
        
    end
    intens_orig = intens_vocal;
    
    for k=1:size(time_vocal,2)
        temp={};
        for kk=1:size(freq_vocal{k},2)
        % -- for each vocalization, order its intensities in the same pattern as its frequencies
            temp = [ temp intens_vocal{k}(1:size(freq_vocal{1,k}{1,kk},1))];
            intens_vocal{k}(1:size(freq_vocal{1,k}{1,kk},1)) = [];
        end
        intens_vocal{k} = temp;
    end

    vfilename  = vfilename(1:end-4);
    if save_output_files == 1
        disp(['[vocalmat]: saving output files.'])
        % -- output identified vocalizations
%         cd(fullfile(root_path, 'audios'))
        
        save(fullfile(vfile(1:end-4), ['output_short_' vfilename]), 'T_orig', 'F_orig', 'time_vocal', 'freq_vocal', 'vfilename', 'intens_vocal', 'median_stats')
        
        if save_spectrogram_background == 1
            save(fullfile(vfile(1:end-4), ['output_' vfilename]), 'T_orig', 'F_orig', 'time_vocal', 'freq_vocal', 'vfilename', 'intens_vocal', 'median_stats', 'A_total', '-v7.3', '-nocompression')
        end
    end
    
    warning('off', 'MATLAB:save:sizeTooBigForMATFile')
    clear y y1 S F T P fs q nd vocal id
    
    toc
end
disp(['[vocalmat]: ' vfilename ' has ' num2str(size(time_vocal,2)) ' vocalizations.'])

function k=LineCurvature2D(Vertices,Lines)
% This function calculates the curvature of a 2D line. It first fits 
% polygons to the points. Then calculates the analytical curvature from
% the polygons;
%
%  k = LineCurvature2D(Vertices,Lines)
% 
% inputs,
%   Vertices : A M x 2 list of line points.
%   (optional)
%   Lines : A N x 2 list of line pieces, by indices of the vertices
%         (if not set assume Lines=[1 2; 2 3 ; ... ; M-1 M])
%
% outputs,
%   k : M x 1 Curvature values
%
% Example, Circle
%  r=sort(rand(15,1))*2*pi;
%  Vertices=[sin(r) cos(r)]*10;
%  Lines=[(1:size(Vertices,1))' (2:size(Vertices,1)+1)']; Lines(end,2)=1;
%  k=LineCurvature2D(Vertices,Lines);
%
%  figure,  hold on;
%  N=LineNormals2D(Vertices,Lines);
%  k=k*100;
%  plot([Vertices(:,1) Vertices(:,1)+k.*N(:,1)]',[Vertices(:,2) Vertices(:,2)+k.*N(:,2)]','g');
%  plot([Vertices(Lines(:,1),1) Vertices(Lines(:,2),1)]',[Vertices(Lines(:,1),2) Vertices(Lines(:,2),2)]','b');
%  plot(sin(0:0.01:2*pi)*10,cos(0:0.01:2*pi)*10,'r.');
%  axis equal;
%
% Example, Hand
%  load('testdata');
%  k=LineCurvature2D(Vertices,Lines);
%
%  figure,  hold on;
%  N=LineNormals2D(Vertices,Lines);
%  k=k*100;
%  plot([Vertices(:,1) Vertices(:,1)+k.*N(:,1)]',[Vertices(:,2) Vertices(:,2)+k.*N(:,2)]','g');
%  plot([Vertices(Lines(:,1),1) Vertices(Lines(:,2),1)]',[Vertices(Lines(:,1),2) Vertices(Lines(:,2),2)]','b');
%  plot(Vertices(:,1),Vertices(:,2),'r.');
%  axis equal;
%
% Function is written by D.Kroon University of Twente (August 2011)

% If no line-indices, assume a x(1) connected with x(2), x(3) with x(4) ...
if(nargin<2)
    Lines=[(1:(size(Vertices,1)-1))' (2:size(Vertices,1))'];
end

% Get left and right neighbor of each points
Na=zeros(size(Vertices,1),1); Nb=zeros(size(Vertices,1),1);
Na(Lines(:,1))=Lines(:,2); Nb(Lines(:,2))=Lines(:,1);

% Check for end of line points, without a left or right neighbor
checkNa=Na==0; checkNb=Nb==0;
Naa=Na; Nbb=Nb;
Naa(checkNa)=find(checkNa); Nbb(checkNb)=find(checkNb);

% If no left neighbor use two right neighbors, and the same for right... 
Na(checkNa)=Nbb(Nbb(checkNa)); Nb(checkNb)=Naa(Naa(checkNb));

% Correct for sampeling differences
Ta=-sqrt(sum((Vertices-Vertices(Na,:)).^2,2));
Tb=sqrt(sum((Vertices-Vertices(Nb,:)).^2,2)); 

% If no left neighbor use two right neighbors, and the same for right... 
Ta(checkNa)=-Ta(checkNa); Tb(checkNb)=-Tb(checkNb);

% Fit a polygons to the vertices 
% x=a(3)*t^2 + a(2)*t + a(1) 
% y=b(3)*t^2 + b(2)*t + b(1) 
% we know the x,y of every vertice and set t=0 for the vertices, and
% t=Ta for left vertices, and t=Tb for right vertices,  
x = [Vertices(Na,1) Vertices(:,1) Vertices(Nb,1)];
y = [Vertices(Na,2) Vertices(:,2) Vertices(Nb,2)];
M = [ones(size(Tb)) -Ta Ta.^2 ones(size(Tb)) zeros(size(Tb)) zeros(size(Tb)) ones(size(Tb)) -Tb Tb.^2];
invM=inverse3(M);
a(:,1)=invM(:,1,1).*x(:,1)+invM(:,2,1).*x(:,2)+invM(:,3,1).*x(:,3);
a(:,2)=invM(:,1,2).*x(:,1)+invM(:,2,2).*x(:,2)+invM(:,3,2).*x(:,3);
a(:,3)=invM(:,1,3).*x(:,1)+invM(:,2,3).*x(:,2)+invM(:,3,3).*x(:,3);
b(:,1)=invM(:,1,1).*y(:,1)+invM(:,2,1).*y(:,2)+invM(:,3,1).*y(:,3);
b(:,2)=invM(:,1,2).*y(:,1)+invM(:,2,2).*y(:,2)+invM(:,3,2).*y(:,3);
b(:,3)=invM(:,1,3).*y(:,1)+invM(:,2,3).*y(:,2)+invM(:,3,3).*y(:,3);

% Calculate the curvature from the fitted polygon
k = 2*(a(:,2).*b(:,3)-a(:,3).*b(:,2)) ./ ((a(:,2).^2+b(:,2).^2).^(3/2));
end

function  Minv = inverse3(M)
% This function does inv(M) , but then for an array of 3x3 matrices
adjM(:,1,1)=  M(:,5).*M(:,9)-M(:,8).*M(:,6);
adjM(:,1,2)=  -(M(:,4).*M(:,9)-M(:,7).*M(:,6));
adjM(:,1,3)=  M(:,4).*M(:,8)-M(:,7).*M(:,5);
adjM(:,2,1)=  -(M(:,2).*M(:,9)-M(:,8).*M(:,3));
adjM(:,2,2)=  M(:,1).*M(:,9)-M(:,7).*M(:,3);
adjM(:,2,3)=  -(M(:,1).*M(:,8)-M(:,7).*M(:,2));
adjM(:,3,1)=  M(:,2).*M(:,6)-M(:,5).*M(:,3);
adjM(:,3,2)=  -(M(:,1).*M(:,6)-M(:,4).*M(:,3));
adjM(:,3,3)=  M(:,1).*M(:,5)-M(:,4).*M(:,2);
detM=M(:,1).*M(:,5).*M(:,9)-M(:,1).*M(:,8).*M(:,6)-M(:,4).*M(:,2).*M(:,9)+M(:,4).*M(:,8).*M(:,3)+M(:,7).*M(:,2).*M(:,6)-M(:,7).*M(:,5).*M(:,3);
Minv=bsxfun(@rdivide,adjM,detM);
end