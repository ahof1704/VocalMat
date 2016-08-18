function [ TDOA max_corr] = fn_TDOA_estimates( dir1, dir2, audio_fname_prefix, fc , mouse, z, Vsound, creat_syl_list,creat_syl_list_manual )
%This function estimates the time of delays for individual sounds
%(vocalizatoins) between four microphones based on xcorrs of signals
%dir1, dir2, audio_fname_prefix, fc , start_point, end_point, corr_thresh,
%plot_pdf, syl_name, voc_data_struct, filtering
%output sturcture =  (1 row x 9 columns) column 1 = mic 1 vs mic2
%
% column 1 = mic 1 vs mic2
% column 2 = mic 1 vs mic3
% column 3 = mic 1 vs mic4
% column 4 = mic 2 vs mic3
% column 5 = mic 2 vs mic4
% column 6 = mic 3 vs mic4
%
% Variables
%
% dir1 = directory where data is located
% dir2 = directory for saving pdf
% fmane_prefix = name of file
% fc = sampling rate (samples/s)
% start_point = starting time for vocalization
% end_point = end time for vocalization
% corr_thresh = sets the min correlation value and only looks at
%   correlations above threshhold
% plot_pdf = generates pdfs of signal, sonogram, and correlations for each
%   signal; string ('y' or 'n')
% syl_name = name of syllable; string; used for saving autoprocess sheet
%   that has spectrograms, voltage signal, and xcorr for all channels

% cd (dir1)
% max_distance_d = 0.8621; %m diagonal
% max_travel_time_d = max_distance_d/Vsound; %s
% max_travel_samples_d = ceil(max_travel_time_d*fc); %samples
% 
% max_distance_s = 0.6096; %m side
% max_travel_time_s = max_distance_s/Vsound; %s
% max_travel_samples_s = ceil(max_travel_time_s*fc); %samples
% 
% start_point = floor(mouse(1,z).start_sample_fine);
% end_point = ceil(mouse(1,z).stop_sample_fine);

cd (dir1)
for i=1:4
    % load in each channel
    fname=[audio_fname_prefix '.ch' num2str(i)];
    x=read_file_chunk(fname,end_point+5,0,'float32');%function from Roian  %end point + 5 is sloppy way to read in data and not very efficient
    switch isnumeric(i)
        case i == 1
            tmp1 = x(start_point:end_point);
        case i == 2
            tmp2 = x(start_point:end_point);
        case i == 3
            tmp3 = x(start_point:end_point);
        case i == 4
            tmp4 = x(start_point:end_point);
    end
    clear x
end
%should include high bandwidth noise detector
%might be better to narrow the width of filtering to target the loaded
%vocalization

low = floor(mouse(1,z).lf_fine);
high = ceil(mouse(1,z).hf_fine);
if low>high
    tmp_frq = low;
    low = high;
    high = tmp_frq;
end

foo12 = rfilter(tmp1,low,high,fc);
clear tmp1
tmp1 = foo12;
clear foo12;
foo12 = rfilter(tmp2,low,high,fc);
clear tmp2
tmp2 = foo12;
clear foo12;
foo12 = rfilter(tmp3,low,high,fc);
clear tmp3
tmp3 = foo12;
clear foo12;
foo12 = rfilter(tmp4,low,high,fc);
clear tmp4
tmp4 = foo12;
clear foo12;

%cross correlation based on tight filtering
xcorr12 = xcorr(tmp1,tmp2,max_travel_samples_s,'coef');
xcorr13 = xcorr(tmp1,tmp3,max_travel_samples_d,'coef');
xcorr14 = xcorr(tmp1,tmp4,max_travel_samples_s,'coef');
xcorr23 = xcorr(tmp2,tmp3,max_travel_samples_s,'coef');
xcorr24 = xcorr(tmp2,tmp4,max_travel_samples_d,'coef');
xcorr34 = xcorr(tmp3,tmp4,max_travel_samples_s,'coef');


% %std of xcorr
% std12 = std(xcorr12);
% std13 = std(xcorr13);
% std14 = std(xcorr14);
% std23 = std(xcorr23);
% std24 = std(xcorr24);
% std34 = std(xcorr34);
%
% %find peaks that are 3X standard deviation of xcorr values
% [pks12 pks_loc12] = findpeaks(xcorr12,'minpeakheight',std12*factor);
% [pks13 pks_loc13] = findpeaks(xcorr13,'minpeakheight',std13*factor);
% [pks14 pks_loc14] = findpeaks(xcorr14,'minpeakheight',std14*factor);
% [pks23 pks_loc23] = findpeaks(xcorr23,'minpeakheight',std23*factor);
% [pks24 pks_loc24] = findpeaks(xcorr24,'minpeakheight',std24*factor);
% [pks34 pks_loc34] = findpeaks(xcorr34,'minpeakheight',std34*factor);
%
% TDOA(1,1:6) = NaN;
% max_corr(1,1:6) = NaN;
%
% if ~isempty(pks12)
%     [mpv location_mpv] = max(pks12);
%     max_corr(1,1) = mpv;
%     TDOA(1,1) = (pks_loc12(location_mpv) - max_travel_samples_s)/fc;
% end
%
% if ~isempty(pks13)
%     [mpv location_mpv] = max(pks13);
%     max_corr(1,2) = mpv;
%     TDOA(1,2) = (pks_loc13(location_mpv) - max_travel_samples_d)/fc;
% end
%
% if ~isempty(pks14)
%     [mpv location_mpv] = max(pks14);
%     max_corr(1,3) = mpv;
%     TDOA(1,3) = (pks_loc14(location_mpv) - max_travel_samples_s)/fc;
% end
% if ~isempty(pks23)
%     [mpv location_mpv] = max(pks23);
%     max_corr(1,4) = mpv;
%     TDOA(1,4) = (pks_loc23(location_mpv) - max_travel_samples_s)/fc;
% end
%
% if ~isempty(pks24)
%     [mpv location_mpv] = max(pks24);
%     max_corr(1,5) = mpv;
%     TDOA(1,5) = (pks_loc24(location_mpv) - max_travel_samples_d)/fc;
% end
%
% if ~isempty(pks34)
%     [mpv location_mpv] = max(pks34);
%     max_corr(1,6) = mpv;
%     TDOA(1,6) = (pks_loc34(location_mpv) - max_travel_samples_s)/fc;
% end

for num_compare = 1:6
    switch isnumeric(num_compare)
        case num_compare == 1
            [mpv location_mpv] = max(xcorr12);
            max_corr(1,1) = mpv;
            TDOA(1,1) = (location_mpv - max_travel_samples_s)/fc;
        case num_compare == 2
            [mpv location_mpv] = max(xcorr13);
            max_corr(1,2) = mpv;
            TDOA(1,2) = (location_mpv - max_travel_samples_d)/fc;
        case num_compare == 3
            [mpv location_mpv] = max(xcorr14);
            max_corr(1,3) = mpv;
            TDOA(1,3) = (location_mpv - max_travel_samples_s)/fc;
        case num_compare == 4
            [mpv location_mpv] = max(xcorr23);
            max_corr(1,4) = mpv;
            TDOA(1,4) = (location_mpv - max_travel_samples_s)/fc;
        case num_compare == 5
            [mpv location_mpv] = max(xcorr24);
            max_corr(1,5) = mpv;
            TDOA(1,5) = (location_mpv - max_travel_samples_d)/fc;
        case num_compare == 6
            [mpv location_mpv] = max(xcorr34);
            max_corr(1,6) = mpv;
            TDOA(1,6) = (location_mpv - max_travel_samples_s)/fc;
    end
    clear mpv location_mpv
end

color_count = 0;
for j = 1:4
    for k = j+1:4
        color_count = color_count + 1;
        switch isnumeric(color_count)
            case color_count == 1
                color = 'r';
                color2 = 'k.';
            case color_count == 2
                color = 'b';
                color2 = 'y.';
            case color_count == 3
                color = 'k';
                color2 = 'y.';
            case color_count == 4
                color = 'c';
                color2 = 'k.';
            case color_count == 5
                color = 'g';
                color2 = 'k.';
            case color_count == 6
                color = 'm';
                color2 = 'k.';
        end
        eval_statement = sprintf('figure; plot(xcorr%d%d,''%s'')',j,k,color);
        eval_statement2 = sprintf('title(''Xcorr %d vs %d''); ylim([-1 1])',j,k);
        %         eval_statement3 = sprintf('hold on; plot(pks_loc%d%d,zeros(size(pks_loc%d%d)),''%s'',''markersize'',%d)',j,k,j,k,color2,14);
        cd (dir2)
        subfolder = sprintf('%s_xcorr',audio_fname_prefix);
        if isdir(subfolder)==0
            mkdir(subfolder)
            cd (subfolder)
        else
            cd (subfolder)
        end
        
        if strcmp(creat_syl_list,'y')==1
            eval_statement4 = sprintf('saveas(gcf,''Xcorr_%s_ch%d%d.jpg'',''jpg''); close(gcf)',mouse(z).syl_name(1:end-4),j,k);
        elseif strcmp(creat_syl_list_manual,'y')==1
            eval_statement4 = sprintf('saveas(gcf,''Xcorr_%s_ch%d%d.jpg'',''jpg''); close(gcf)',mouse(z).syl_name,j,k);
        end
        
        eval(eval_statement)
        eval(eval_statement2)
        %         eval(eval_statement3)
        eval(eval_statement4)
        clear eval_statement* color
    end
end

for j = 1:4
    eval_statement = sprintf('figure; plot(tmp%d,''b'')',j);
    eval_statement2 = sprintf('title(''Voltaqge ch%d'');',j);
    
    cd (dir2)
    subfolder = sprintf('%s_voltage',audio_fname_prefix);
    if isdir(subfolder)==0
        mkdir(subfolder)
        cd (subfolder)
    else
        cd (subfolder)
    end
    
    if strcmp(creat_syl_list,'y')==1
        eval_statement3 = sprintf('saveas(gcf,''Voltage_%s_ch%d.jpg'',''jpg''); close(gcf)',mouse(z).syl_name(1:end-4),j);
    elseif strcmp(creat_syl_list_manual,'y')==1
        eval_statement3 = sprintf('saveas(gcf,''Voltage_%s_ch%d.jpg'',''jpg''); close(gcf)',mouse(z).syl_name,j);
    end
    
    eval(eval_statement)
    eval(eval_statement2)
    eval(eval_statement3)
    clear eval_statement* color
end

for j = 1:4
    eval_statement = sprintf('figure; r_specgram_mouse_mod(tmp%d,%d); h=gca; set(h,''clim'',[-.001 .025]);',j,fc);
    eval_statement2 = sprintf('title(''Spectrogram ch%d'');',j);
    
    cd (dir2)
    subfolder = sprintf('%s_spectrogram',audio_fname_prefix);
    if isdir(subfolder)==0
        mkdir(subfolder)
        cd (subfolder)
    else
        cd (subfolder)
    end
    if strcmp(creat_syl_list,'y')==1
        eval_statement3 = sprintf('saveas(gcf,''Spectrogram_%s_ch%d.jpg'',''jpg''); close(gcf)',mouse(z).syl_name(1:end-4),j);
    elseif strcmp(creat_syl_list_manual,'y')==1
        eval_statement3 = sprintf('saveas(gcf,''Spectrogram_%s_ch%d.jpg'',''jpg''); close(gcf)',mouse(z).syl_name,j);
    end
    
    eval(eval_statement)
    eval(eval_statement2)
    eval(eval_statement3)
    clear eval_statement* color
end

end

