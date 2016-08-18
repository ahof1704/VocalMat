function [ r p] = fn_TDOA_p_val( dir1, dir2, audio_fname_prefix, fc , mouse, z, Vsound, creat_syl_list,creat_syl_list_manual )
%This function estimates the time of delays for individual sounds
%(vocalizatoins) between four microphones based on xcorrs of signals
%dir1, dir2, audio_fname_prefix, fc , start_point, end_point, corr_thresh,
%plot_pdf, syl_name, voc_data_struct, filtering
%output sturcture =  r and p values
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

start_point = floor(mouse(1,z).start_sample_fine);
end_point = ceil(mouse(1,z).stop_sample_fine);

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

pad_size = zeros(size(tmp1,1)+1,1);
%cross correlation based on tight filtering
% xcorr12 = xcorr(tmp1,tmp2,'coef');
% xcorr13 = xcorr(tmp1,tmp3,'coef');
% xcorr14 = xcorr(tmp1,tmp4,'coef');
% xcorr23 = xcorr(tmp2,tmp3,'coef');
% xcorr24 = xcorr(tmp2,tmp4,'coef');
% xcorr34 = xcorr(tmp3,tmp4,'coef');

TDOA = [mouse(1,z).TDOA];
sample_delays = TDOA*fc;
loc_max = sample_delays+size(tmp1,1);

[r(1,1),p(1,1)] = corr(cat(1,tmp1,pad_size),circshift(cat(1,pad_size,tmp2),loc_max(1))); 
[r(1,2),p(1,2)] = corr(cat(1,tmp1,pad_size),circshift(cat(1,pad_size,tmp3),loc_max(2))); 
[r(1,3),p(1,3)] = corr(cat(1,tmp1,pad_size),circshift(cat(1,pad_size,tmp4),loc_max(3))); 
[r(1,4),p(1,4)] = corr(cat(1,tmp2,pad_size),circshift(cat(1,pad_size,tmp3),loc_max(4)));
[r(1,5),p(1,5)] = corr(cat(1,tmp2,pad_size),circshift(cat(1,pad_size,tmp4),loc_max(5))); 
[r(1,6),p(1,6)] = corr(cat(1,tmp3,pad_size),circshift(cat(1,pad_size,tmp4),loc_max(6))); 

disp(1)

end

