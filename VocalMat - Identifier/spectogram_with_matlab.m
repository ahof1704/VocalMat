clear all
close all
clc
[y,fs]=audioread('152_Control_1st_stage_OK_OK.WAV'); %returns sampled data, y, and a sample rate for that data, Fs.
N = numel(y);
t = (0:N-1)/Fs;
figure('Original Signal'), plot(t,y) 
xlabel('Time (s)')
ylabel('Amplitude')

segmentLength = round(numel(y)/4.5); % Equivalent to setting segmentLength = [] in the next line
figure(2), spectrogram(y,segmentLength,[],[],fs,'yaxis')


%Finding in a range of time
t1 = find(t(:)>140 & t(:)<142); %in seconds)

y1 = [];
for i=1:size(t1,1)
    y1 = 
    
end












% figure(1)
% sg = 256; % Divide the waveform into 400-sample segments with 300-sample overlap.
% ov = 300;
% plot(t, y)
% grid
% [s,f,t]=spectrogram(y(6000:10000,:),1024,512,fs);
% Nx = length(y); 
% nsc = floor(Nx/4.5); %Divide the signal into sections of length  ${\tt nsc}=\lfloor N_{\tt x}/4.5\rfloor$.
% nov = floor(3*nsc/4); %Window the sections using a Hamming window. Specify 50% overlap between contiguous sections.
% nff = max(256,2^nextpow2(nsc)); %To compute the FFT, use  $\max(256,2^p)$ points, where  $p=\lceil\log_2N_{\tt x}\rceil$.
% 
% spectrogram(y,hamming(nsc),nov,nff,'yaxis');

% spectrogram(y,sg,ov,[],fs,'yaxis')

% [pks,idx] = findpeaks(abs(s(:,10)), 'MinPeakHeight',10);            % Amplitude(s) & Index (Indices) Of Harmonics
% figure(2)
% mesh(t, f, abs(s))
% grid on
% xlabel('Time')
% ylabel('Frequency')