function [t,x]=load_named_waveform_channel_from_smr(file_name,...
                                                    channel_name)
                                                  
% t is a col vector of timestamps, in seconds
% x is the waveform data, one signal per column

fid=fopen(file_name,'r');
channel_number=channel_name_to_channel_number(fid,channel_name);
[x_raw,h]=SONGetChannel(fid,channel_number);
fclose(fid);
x=double(x_raw)/(2^16/10)*h.scale+h.offset;
n=length(x);
t=1e-6*(h.start+h.sampleinterval*double(0:(n-1))');  % us->s
