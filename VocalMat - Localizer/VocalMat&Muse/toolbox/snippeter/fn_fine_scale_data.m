function [ lf_fine, hf_fine, start_sample_fine, stop_sample_fine] = fn_fine_scale_data( dir1, audio_fname_prefix, fc , mouse, z, Vsound )
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

cd (dir1)

scrsz = get(0,'ScreenSize');

start_point_o = mouse(1,z).start_sample;
end_point_o = mouse(1,z).stop_sample;
buffer_size = ceil((end_point_o-start_point_o)*0.7);
start_point = start_point_o - buffer_size;
end_point = end_point_o + buffer_size;
for i=1:5
    % load in each channel
    fname=[audio_fname_prefix '.ch' num2str(i)];
    x=read_file_chunk(fname,end_point+5,0,'float32');
    switch isnumeric(i)
        case i == 1
            tmp1 = x(start_point:end_point);
            tmp_o = x(start_point_o:end_point_o);
        case i == 2
            tmp2 = x(start_point:end_point);
        case i == 3
            tmp3 = x(start_point:end_point);
        case i == 4
            tmp4 = x(start_point:end_point);     
    end
    clear x
    
end

[details(1:4).x]=deal([]);
correct_string='n';
while strcmp(correct_string,'y')==0
    handle1 = figure('Position', [(scrsz(1)*100) (scrsz(2)*100) (scrsz(3)-(scrsz(3)/10)) (scrsz(4)-(scrsz(4)/5))]);
    subplot (4,2,2)
    r_specgram_mouse_mod(tmp1,fc);
    set(gca,'ylim',[25000 90000])
    subplot (4,2,4)
    r_specgram_mouse_mod(tmp2,fc);
    set(gca,'ylim',[25000 90000])
    subplot (4,2,6)
    r_specgram_mouse_mod(tmp3,fc);
    set(gca,'ylim',[25000 90000])
    subplot (4,2,8)
    r_specgram_mouse_mod(tmp4,fc);
    set(gca,'ylim',[25000 90000])    
    subplot (4,2,1)
    r_specgram_mouse_mod(tmp_o,fc);
    set(gca,'ylim',[25000 90000])
    
    
    for i=1:4
        switch isnumeric(i)
            case i == 1
                position_label = 'highest frequency in';
            case i == 2
                position_label = 'lowest frequency in';
            case i == 3
                position_label = 'start of';
            case i == 4
                position_label = 'end of';
        end
        label = sprintf('measure %s vocalization',position_label);
        clc
        disp(label);
        [details(i).x,details(i).y]=get_pos;
    end;
    
    for g = 2:2:8
        subplot(4,2,g)
        hold on
        plot([details(3).x details(3).x details(4).x details(4).x details(3).x],[details(1).y details(2).y details(2).y details(1).y details(1).y],'r')
    end
    repeat_question = 'y';
    while strcmp(repeat_question,'y')==1
        clc
        correct = input('Are positions correct? (1 = yes; 0 = no)');
        if correct == 1
            correct_string = 'y';
            close (handle1)
            break
        elseif correct == 0
            clear details
            clc
            close (handle1)
            break
        else            
            disp(sprintf('%g is not an option',correct))
            pause(2)
        end
    end    
end

hf_fine = ceil(details(1).y);
lf_fine = floor(details(2).y);
start_sample_fine = (start_point + floor(details(3).x*fc));
stop_sample_fine = (start_point + ceil(details(4).x*fc));

% %visual check of fine scale points

% fname=[audio_fname_prefix '.ch' num2str(1)];
% x=read_file_chunk(fname,end_point+5,0,'float32');
% tmp5 = x(start_sample_fine:stop_sample_fine);
% foo12 = rfilter(tmp5,lf_fine,hf_fine,fc);
% clear tmp5
% tmp5 = foo12;
% figure 
% r_specgram_mouse_mod(tmp5,fc);
% disp(1)

%--------------------------------------------------------------------------
% sub-function to get position from an image
%--------------------------------------------------------------------------
function [x,y]=get_pos

cur_pos=ginput(1);
x=cur_pos(1,1);
y=cur_pos(1,2);

