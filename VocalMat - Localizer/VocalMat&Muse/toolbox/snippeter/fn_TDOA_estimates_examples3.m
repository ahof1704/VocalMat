function [samples_in_voc] = fn_TDOA_estimates_examples3( dir1, audio_fname_prefix, fc , mouse, z)
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
tic
start_point = floor(mouse(1,z).start_sample_fine)%-(450450/5);
end_point = ceil(mouse(1,z).stop_sample_fine)%+(450450/5);

fc = 450450; %audio sampling rate, Hz

T_extra=0.002;  % s, extra time at either end, to accomodate travel time
                %    differences
dt=1/fc;  % s              
n_extra=ceil(T_extra/dt);

start_point = start_point - n_extra;
end_point = end_point + n_extra;

% samples_in_voc = end_point-start_point;
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


toc
samples_in_voc = size(tmp1,1);
color_count = 0;

for j = 1:4
    eval_statement1 = sprintf('tmp%d = tmp%d*1000;',j,j); %mv
    eval(eval_statement1)
    eval_statement = sprintf('figure; plot(tmp%d,''k'')',j);
    eval(eval_statement)
    clear eval_statement* color
end
nfft =2^12;
b=nfft/2;                                       % create frequencies
f=fc/2;			
fs=[f/b:f/b:f]';
fs = fs/1000;

% [fft1 spl dummy] = rfft(tmp1,450450,40,50000,10^-12,0.00002,415);
fft1 = fft(tmp1,nfft);
fft1a=abs(fft1);
fft1ar = fft1a(1:max(size(fs)));
figure
plot(fs(:,1),fft1ar(:,1),'k','LineWidth',4);
% [fft2 spl dummy] = rfft(tmp2,450450,50,50000,10^-12,0.00002,415);
fft2 = fft(tmp2,nfft);
fft2a=abs(fft2);
fft2ar = fft2a(1:max(size(fs)));
figure
plot(fs(:,1),fft2ar(:,1),'k','LineWidth',4);
% [fft3 spl dummy] = rfft(tmp3,450450,40,50000,10^-12,0.00002,415);
fft3 = fft(tmp3,nfft);
fft3a=abs(fft3);
fft3ar = fft3a(1:max(size(fs)));
figure
plot(fs(:,1),fft3ar(:,1),'k','LineWidth',4);
% [fft4 spl dummy] = rfft(tmp4,450450,40,50000,10^-12,0.00002,415);
fft4 = fft(tmp4,nfft);
fft4a=abs(fft4);
fft4ar = fft4a(1:max(size(fs)));
figure
plot(fs(:,1),fft4ar(:,1),'k','LineWidth',4);
disp(1)

% for i = 1:4
%     clim_val(i,:) = get(ha(i),'clim');
% end
% 
% clim_val_1 = max(clim_val(:,1))+5e-11;
% clim_val_2 = min(clim_val(:,2))-0.12;
% set(ha,'clim',[clim_val_1 clim_val_2])
