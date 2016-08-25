%HELP vuvuzela_denoising
%
%Vuvuzela cancellation with spectral subtraction technique. Based on the spectrum of the
%vuvuzela only sound, this denoising technique simply computes an
%antenuation map in the time-frequency domain. Then, the audio signal is
%obtained by computing the inverse STFT. See [1] or [2] for
%more detail about the algorithm.
%
%References:
%
%[1] Steven F. Boll, "Suppression of Acoustic Noise in Speech Using Spectral
%Subtraction", IEEE Transactions on Signal Processing, 27(2),pp 113-120,
%1979
%
%[2] Y. Ephraim and D. Malah, “Speech enhancement using a minimum mean square error 
% short-time spectral amplitude estimator,” IEEE. Transactions in Acoust., Speech, Signal
% Process., vol. 32, no. 6, pp. 1109–1121, Dec. 1984.
%
%Note: The file: Vuvuzela.wav must be located in the folder of this script file.
%One can note that this time-frequency based technique creates a "musical
%noise".
%
%Programmed by V. Choqueuse (contact: vincent.choqueuse@gmail.com)
% clear all

function vocalmat_denoising_big_variables(vfile,y,Fe)

fprintf('--- Denoising process ---\n\n');
tic

fprintf('-> Step 1/11: Loading sound track.wav:');
% [vfilename,vpathname] = uigetfile({'*.wav'},'Select the sound track');
% vfilename = vfilename(1:end-4);
% vfile = fullfile(vpathname,vfilename);
% [y,Fe]=audioread(vfile);
x=y(1000:end,1).';  %remove the beginning of the sample
clear y
Nx=length(x);
fprintf(' OK\n');

%algorithm parameters
apriori_SNR=1;  %select 0 for aposteriori SNR estimation and 1 for apriori (see [2])
alpha=0.05;      %only used if apriori_SNR=1
beta1=0.5;
beta2=1;
lambda=3;

%STFT parameters
NFFT=1024;
% window_length=round(0.031*Fe); 
% window=hamming(window_length);
window_length = 256;
window = hamming(window_length);
% window = window(:);
% overlap=floor(0.45*window_length); %number of windows samples without overlapping
overlap = 128;

%Signal parameters
t_min=0.4;    %interval for learning the noise
t_max=1.00;   %spectrum (in second)

%construct spectrogram 
[S,F,T] = spectrogram(x+i*eps,window,window_length-overlap,NFFT,Fe); %put a short imaginary part to obtain two-sided spectrogram
[Nf,Nw]=size(S);

%----------------------------%
%        noisy spectrum      %
%          extraction        %
%----------------------------%

fprintf('-> Step 2/11: Extract noise spectrum -');
t_index=find(T>=t_min & T<=t_max);
absS_vuvuzela=abs(S(:,t_index)).^2;
vuvuzela_spectrum=mean(absS_vuvuzela,2); %average spectrum of the vuvuzela (assumed to be ergodic))
clear absS_vuvuzela
vuvuzela_specgram=repmat(vuvuzela_spectrum,1,Nw);
fprintf(' OK\n');

%Break the original signal in blocks
temp = [T(1) T(round(size(T,2)/4)) T(round(size(T,2)/2)) T(round(3*size(T,2)/4)) T(end)];
STFT_out = [];

clear x
count=2;
for k = 1:size(temp,2)-1
    %---------------------------%
    %       Estimate SNR        %
    %---------------------------%
    
    count = count+1;
    t_index=find(T>=temp(k) & T<temp(k+1));
    disp(['-> Step ' num2str(count+k-1) '/11 : Estimate SNR -']);
%     absS=abs(S).^2;
    absS = abs(S(:,t_index)).^2;
    SNR_est=max((absS./vuvuzela_specgram(:,t_index))-1,0); % a posteriori SNR
    clear absS
    if apriori_SNR==1
        SNR_est=filter((1-alpha),[1 -alpha],SNR_est);  %a priori SNR: see [2]
    end    
    fprintf(' OK\n');
    toc

    %---------------------------%
    %  Compute attenuation map  %
    %---------------------------%
    disp(['-> Step ' num2str(count+k) '/11: Compute TF attenuation map -']);
    an_lk=max((1-lambda*((1./(SNR_est+1)).^beta1)).^beta2,0);  %an_l_k or anelka, sorry stupid french joke :)
    clear SNR_est
    STFT=an_lk.*S(:,t_index);
    clear an_lk
    fprintf(' OK\n');
    
%     STFT_out = [STFT_out STFT];
    save(['STFT_out_' num2str(k) '.mat'],'STFT','-v7.3');
    clear STFT
end
clear vuvuzela_specgram
clear S

disp('Loading STFTs');
STFT_out_1 = load ('STFT_out_1.mat'); STFT_out_2 = load ('STFT_out_2.mat'); STFT_out_3 = load ('STFT_out_3.mat'); STFT_out_4 = load ('STFT_out_4.mat');


disp('Concatenating...')
STFT_out_1 = STFT_out_1.STFT; STFT_out_2 = STFT_out_2.STFT; STFT_out_3 = STFT_out_3.STFT; STFT_out_4 = STFT_out_4.STFT;
STFT_out = [STFT_out_1 STFT_out_2 STFT_out_3 STFT_out_4];
clear STFT_out_1
clear STFT_out_2
clear STFT_out_3
clear STFT_out_4

 %--------------------------%
    %   Compute Inverse STFT   %
    %--------------------------%
    fprintf('-> Step 11/11: Compute Inverse STFT:');
    ind=mod((1:window_length)-1,Nf)+1;
%     output_signal=zeros((Nw-1)*overlap+window_length,1);
    output_signal=zeros((size(STFT_out,2)-1)*overlap+window_length,1);

%     for indice=1:Nw %Overlapp add technique
    for indice=1:size(STFT_out,2)
        left_index=((indice-1)*overlap) ;
        index=left_index+[1:window_length];
        temp_ifft=real(ifft(STFT_out(:,indice),NFFT));
        output_signal(index)= output_signal(index)+temp_ifft(ind).*window;
    end
    fprintf(' OK\n');


    %-----------------    Display Figure   ------------------------------------      

    %show temporal signals
    % figure
    % subplot(2,1,1);
%     t_index=find(T>t_min & T<t_max);
    % plot([1:length(x)]/Fe,x);
    % xlabel('Time (s)');
    % ylabel('Amplitude');
    % hold on;
%     noise_interval=floor([T(t_index(1))*Fe:T(t_index(end))*Fe]);
    % plot(noise_interval/Fe,x(noise_interval),'r');
    % hold off;
    % legend('Original signal','Vuvuzela Only');
    % title('Original Sound');
    %show denoised signal
    % subplot(2,1,2);
    % plot([1:length(output_signal)]/Fe,output_signal );
    % xlabel('Time (s)');
    % ylabel('Amplitude');
    % title('Sound without vuvuzela');

    %show spectrogram
    % t_epsilon=0.001;
    % figure
    % S_one_sided=max(S(1:length(F)/2,:),t_epsilon); %keep only the positive frequency
    % pcolor(T,F(1:end/2),10*log10(abs(S_one_sided))); 
    % shading interp;
    % colormap('hot');
    % title('Spectrogram: speech + Vuvuzela');
    % xlabel('Time (s)');
    % ylabel('Frequency (Hz)');

    % figure
    % S_one_sided=max(STFT(1:length(F)/2,:),t_epsilon); %keep only the positive frequency
    % pcolor(T,F(1:end/2),10*log10(abs(S_one_sided))); 
    % shading interp;
    % colormap('hot');
    % title('Spectrogram: speech only');
    % xlabel('Time (s)');
    % ylabel('Frequency (Hz)');


    %-----------------    Listen results   ------------------------------------

    % fprintf('\nPlay 5 seconds of the Original Sound:');
    % audioplayer(x(1:5*Fe),Fe);
    % fprintf(' OK\n');
    % fprintf('Play 5 seconds of the new Sound: ');
    % audioplayer(output_signal(1:5*Fe),Fe);
%     cd(vpathname)
    fprintf('OK\n');
    disp(['Writing ' vfile '_no_noise.wav']);
    audiowrite([vfile '_no_noise.wav'],output_signal,Fe);
    fprintf('OK\n');    
    toc
