clear 
clc
close all

cd A:\Neunuebel\ssl_vocal_structure\08212012\Data_analysis
load Test_B_1_Mouse.mat
this_mouse = mouse(134);
clear mouse
audio_fname_prefix = 'Test_B_1';

start_point = this_mouse.start_sample_fine-10000;
end_point = this_mouse.stop_sample_fine+17000;
cd ..
cd demux
for ch_num = 1:4
    filename = sprintf('%s.ch%d',audio_fname_prefix,ch_num);
    % precision = 'float32';
    
    m = memmapfile(filename,         ...
        'Offset', 0,        ...
        'Format', 'single',    ...
        'Writable', false);
    switch isnumeric(ch_num)
        case ch_num == 1
            ach1 = m.Data(start_point:end_point);
        case ch_num == 2
            ach2 = m.Data(start_point:end_point);
        case ch_num == 3
            ach3 = m.Data(start_point:end_point);
        case ch_num == 4
            ach4 = m.Data(start_point:end_point);
    end
    clear filename m
end
%%
fc = 450450;

low = this_mouse.lf_fine;
high = this_mouse.hf_fine;
if low>high
    tmp_frq = low;
    low = high;
    high = tmp_frq;
end

foo12 = rfilter(ach1,low,high,fc);
clear ach1
ach1 = foo12;
clear foo12;
foo12 = rfilter(ach2,low,high,fc);
clear ach2
ach2 = foo12;
clear foo12;
foo12 = rfilter(ach3,low,high,fc);
clear ach3
ach3 = foo12;
clear foo12;
foo12 = rfilter(ach4,low,high,fc);
clear ach4
ach4 = foo12;
clear foo12;


xcorr12 = xcorr(ach1,ach2,'coef');
xcorr13 = xcorr(ach1,ach3,'coef');
xcorr14 = xcorr(ach1,ach4,'coef');
xcorr23 = xcorr(ach2,ach3,'coef');
xcorr24 = xcorr(ach2,ach4,'coef');
xcorr34 = xcorr(ach3,ach4,'coef');

xcorr12abs = xcorr(abs(ach1),abs(ach2),'coef');
xcorr13abs = xcorr(abs(ach1),abs(ach3),'coef');
xcorr14abs = xcorr(abs(ach1),abs(ach4),'coef');
xcorr23abs = xcorr(abs(ach2),abs(ach3),'coef');
xcorr24abs = xcorr(abs(ach2),abs(ach4),'coef');
xcorr34abs = xcorr(abs(ach3),abs(ach4),'coef');

hf=figure('color','w','Position',[69 104 980 1000]);
subplot(6,2,1)
plot(abs(ach1),'k')
subplot(6,2,3)
plot(abs(ach2),'k')
subplot(6,2,5)
plot(abs(ach3),'k')
subplot(6,2,7)
plot(abs(ach4),'k')
subplot(6,2,2)
plot(xcorr12abs,'b')
subplot(6,2,4)
plot(xcorr13abs,'b')
subplot(6,2,6)
plot(xcorr14abs,'b')
subplot(6,2,8)
plot(xcorr23abs,'b')
subplot(6,2,10)
plot(xcorr24abs,'b')
subplot(6,2,12)
plot(xcorr34abs,'b')
subplot(6,2,1); title('Full wave rectifier ch1')
subplot(6,2,2); title('xcorr ch1 vs ch2')
subplot(6,2,3); title('Full wave rectifier ch2')
subplot(6,2,4); title('xcorr ch1 vs ch3')
subplot(6,2,5); title('Full wave rectifier ch3')
subplot(6,2,6); title('xcorr ch1 vs ch4')
subplot(6,2,7); title('Full wave rectifier ch4')
subplot(6,2,8); title('xcorr ch2 vs ch3')
subplot(6,2,10); title('xcorr ch2 vs ch4')
subplot(6,2,12); title('xcorr ch3 vs ch4')

hf=figure('color','w','Position',[69 104 980 1000]);
subplot(6,2,1)
plot(ach1,'k')
subplot(6,2,3)
plot(ach2,'k')
subplot(6,2,5)
plot(ach3,'k')
subplot(6,2,7)
plot(ach4,'k')
subplot(6,2,2)
plot(xcorr12,'b')
subplot(6,2,4)
plot(xcorr13,'b')
subplot(6,2,6)
plot(xcorr14,'b')
subplot(6,2,8)
plot(xcorr23,'b')
subplot(6,2,10)
plot(xcorr24,'b')
subplot(6,2,12)
plot(xcorr34,'b')
subplot(6,2,1); title('Ch1')
subplot(6,2,2); title('xcorr ch1 vs ch2')
subplot(6,2,3); title('Ch2')
subplot(6,2,4); title('xcorr ch1 vs ch3')
subplot(6,2,5); title('Ch3')
subplot(6,2,6); title('xcorr ch1 vs ch4')
subplot(6,2,7); title('Ch4')
subplot(6,2,8); title('xcorr ch2 vs ch3')
subplot(6,2,10); title('xcorr ch2 vs ch4')
subplot(6,2,12); title('xcorr ch3 vs ch4')


disp(1)





% subplot(4,2,1)
% plot(ach1,'r')
% subplot(4,2,3)
% plot(ach2,'b')
% title('Voltage trace ch1')
% subplot(4,2,1)
% title('Voltage trace ch2')
% subplot(4,2,2)
% plot(xcorr12,'k')
% subplot(4,2,5)
% plot(abs(ach1),'r')
% subplot(4,2,7)
% plot(abs(ach2),'b')
% subplot(4,2,6)
% plot(xcorr12abs,'k')
disp(12)

% subplot(4,2,5)
% ban1 = r_specgram_mouse_mod(ach1,fc); 
% h=gca; 
% set(h,'clim',[-.001 .025]);
% title('Spectrogram ch1')
% subplot(4,2,7)
% ban2 = r_specgram_mouse_mod(ach2,fc); 
% h=gca; 
% set(h,'clim',[-.001 .025]);
% title('Spectrogram ch2')
% 
% xcorrspec12 = xcorr2(ban1,ban2);
% subplot(4,2,6)
% imagesc(xcorrspec12)
% subplot(4,2,8)
% plot(sum(xcorrspec12,1))