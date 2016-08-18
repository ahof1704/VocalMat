function [h,logpower] = wiener(S)
%
% [h,tpower] = wiener(S)
%  find the wiener entropy of a power spectrum
%
%IN: S  = power spectrum/spectrogram 
%OUT: h = wiener entropy
%     logpower = integrated log power
%
% AL; Caltech,  6/98, 3/00  
%

df = 1/size(S,1);
tpower = df*sum(S);
logpower = exp(df*sum(log(S)));
hnorm = logpower./tpower;
h = exp(hnorm);
