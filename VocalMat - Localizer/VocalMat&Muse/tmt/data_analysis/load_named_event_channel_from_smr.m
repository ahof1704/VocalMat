function [ts,T,t0]=...
  load_named_event_channel_from_smr(file_name,channel_name)

% ts is an array of times in seconds, where t==0 means right at the start
%    of the recording.  It's a col vector.
% T is the total duration of the recording, where T==dt*N, where dt is the
%   sampling interval in seconds, and N is the number of samples.  (Note
%   that the time of the first sample is t0, and the time of the last sample
%   is t0+(N-1)*dt).  T is in seconds.
% t0 is the start time of the recording.  

% load the data
fid=fopen(file_name,'r');
if fid<0
  error('Unable to open file %s',file_name);
end
channel_number=channel_name_to_channel_number(fid,channel_name);
if isempty(channel_number)
  fclose(fid);
  error('No channel named %s in file %s',channel_name,file_name);
end
[ts,h]=SONGetChannel(fid,channel_number);
file_header=SONFileHeader(fid);
N=file_header.maxFTime+1;  % number of samples, since first sample
                           % is at time 0 in clock ticks
T=SONTicksToSeconds(fid,N);  % in s
t0=0;  % s
fclose(fid);
