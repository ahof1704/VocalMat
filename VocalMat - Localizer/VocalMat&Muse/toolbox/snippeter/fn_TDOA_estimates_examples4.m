function fn_TDOA_estimates_examples4( dir1, audio_fname_prefix, fc , mouse, z)
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
% tic

start_point = floor(mouse(1,z).start_sample_fine);%-(450450/5);
end_point = ceil(mouse(1,z).stop_sample_fine);%+(450450/5);

num_channels = 4;
fc = 450450; %audio sampling rate, Hz
precision_bytes=4;
T_extra=0.03;  % s, extra time at either end, to accomodate travel time differences
dt=1/fc;  % s              
n_extra=ceil(T_extra/dt);

start_point = start_point - n_extra;
end_point = end_point + n_extra;

% %for long stretch
% start_point = 6756751;
% end_point = 6981975;

chunk_size = end_point-start_point;
% samples_in_voc = end_point-start_point;

x = zeros(num_channels,chunk_size);
for i = 1:num_channels
    filename = [audio_fname_prefix '.ch' num2str(i)];
    fid = fopen(filename,'r');
    fseek(fid, start_point*precision_bytes, -1);
    x(i,:) = fread(fid,chunk_size,'float32');
    fclose(fid);
end
tmp1 = x(1,:);
tmp2 = x(2,:);
tmp3 = x(3,:);
tmp4 = x(4,:);
% 
% 
% for i=1:4
%     % load in each channel
%     fname=[audio_fname_prefix '.ch' num2str(i)];
%     x=read_file_chunk(fname,end_point+5,0,'float32');%function from Roian  %end point + 5 is sloppy way to read in data and not very efficient
%     switch isnumeric(i)
%         case i == 1
%             tmp1 = x(start_point:end_point);
%         case i == 2
%             tmp2 = x(start_point:end_point);
%         case i == 3
%             tmp3 = x(start_point:end_point);
%         case i == 4
%             tmp4 = x(start_point:end_point);
%     end
%     clear x
% end
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

% foo12 = rfilter(tmp1,low,high,fc);
% clear tmp1
% tmp1 = foo12;
% clear foo12;
% foo12 = rfilter(tmp2,low,high,fc);
% clear tmp2
% tmp2 = foo12;
% clear foo12;
% foo12 = rfilter(tmp3,low,high,fc);
% clear tmp3
% tmp3 = foo12;
% clear foo12;
% foo12 = rfilter(tmp4,low,high,fc);
% clear tmp4
% tmp4 = foo12;
% clear foo12;


% toc
% for j = 1:4
%     eval_statement1 = sprintf('tmp%d = tmp%d*1000;',j,j); %mv
%     eval(eval_statement1)
%     eval_statement = sprintf('figure; plot(tmp%d,''k'')',j);
%     eval(eval_statement)
%     clear eval_statement* color
% end

for j = 1:4
    eval_statement = sprintf('figure(''position'',[1   1   560*2   420]); r_specgram_mouse_mod_khz(tmp%d,%d);',j,fc);
    eval(eval_statement)
    ha(j) = gca;
    colormap(jet(256))
    cbar_handle = colorbar;
    cytick = get(cbar_handle,'ytick');
    set(cbar_handle,'ytick',[cytick(1) cytick(end)],'FontSize',16)    %'ytick',[]
    xticks = get(gca,'xtick');
    xticks2(1) = xticks(1);
    xticks2(2) = xticks(end);
    set(gca,'ytick',[40 100],'ylim',[40 100],'xtick',xticks2)%'xticklabel',
    clear cytick eval_statement* color cbar_handle    
end

for i = 1:4
    clim_val(i,:) = get(ha(i),'clim');
end
sorted_clim1 = sort(clim_val(:,1));
clim_val_1 = sorted_clim1(4);%+5e-11;
sorted_clim2 = sort(clim_val(:,2));
% clim_val_2 = max(clim_val(:,2))-0.12;
clim_val_2 = sorted_clim2(2);%-0.12;
set(ha,'clim',[clim_val_1 clim_val_2])
