function ban=r_specgram_mouse_mod(x,fc,varargin)
% function to plot a properly normalized spectrogram of input
%
% form: r_specgram_mouse_mod(x,fc,p);
%
% x is the time series, fc is the sampling rate in Hz
% p is optional, if 1 then print
%
% window length is 2 ms
% noverlap is 0
% nfft=2^12

if size(varargin,2)==1
    p=varargin{1,1};
elseif size(varargin,1)==0
    p=1;
else
    disp('function requires two or three inputs');
end;

% defaults
window=ceil(fc*.002);                               % 2 ms hanning window
noverlap=0;
nfft=2^12;

x=x-mean(x);  % subtract any dc

[b,f,t]=specgram(x,nfft,fc,window,noverlap);
ba=abs(b);
ban=2*(ba./(window/2));                                 % normalizing to amplitude (1)
if p==1
    h=image(t,f,ban);
    set(h,'CDataMapping','scaled'); % (5)
    axis xy;
    colormap('jet');
end;

% notes:
%
% (1)   if there was no windowing (i.e. if the window was a boxcar with amplitude=1 and 
%       length=window, then should divide by window.  however, specgram uses a hanning
%       window.  the area of a hanning window is half that of a boxcar the same length.
%       therefore we divide by window/2.  the reason it's length window, rather than length
%       nfft is that the specgram algorithm uses length window and then zeropads to length 
%       nfft, so dividing by window seems to produce more sensible numbers. [later: or, more
%       specifically--b/c it is zeropadding it doesn't add any amplitude.  i'm pretty sure
%       it's normalizing by the area, which is N in the case of a boxcar of amplitude 1 and 
%       N/2 in the case of a hanning window with min=0 and max=1.

