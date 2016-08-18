function [t,y,chan_names] = load_smr(filename)
%[t, y, chan_names] = load_smr(filename)
%   Loads .smr files, and returns data from wave-form channels,
%   ignoring the rest.
%   -t is in sec and is a col vector (n_samples x 1)
%   -y is a matrix (n_samples x n_signals)
%   -chan_names is optional, and is a cell array with the names of
%    returned channels
% NOTE:
%   (1)This version requires SON library version 2.2 or later.  If it
%      is used with an earlier version, the time may be returned in
%      mega-seconds
%   (2)This m-file assumes the waveforms were collected over the
%      same time-base.

fid=fopen(filename,'r');
if (fid == -1)
  error(['Unable to open ', filename]);
end

channel_list=SONChanList(fid);
n_channels=length(channel_list);
if n_channels<=0
  t=zeros(1,0);  % want to be a row vect
  y=zeros(0,0);
  fclose(fid);
  chan_names = {};
  fclose(fid)
  return;
end

kind_list = cat(1, channel_list.kind);
wave_list = find(kind_list == 1);
n_waves = length(wave_list);
if n_waves<=0
  t=zeros(1,0);  % want to be a row vect
  y=zeros(0,0);
  fclose(fid);
  chan_names = {};
  fclose(fid);
  return;
end

for n = 1:n_waves
  ind = wave_list(n);
  [chan_this, h] = SONGetChannel(fid, ind);
  if n==1
    n_samples = h.npoints;
    y = zeros(n_samples,n_waves);
    [interval, t_start] = SONGetSampleInterval(fid,1);
    t = 1e-6*(t_start + interval*(0:(n_samples-1))');  % us->s
  end
  y(:,n)=double(chan_this)/(2^16/10)*h.scale+h.offset;
  chan_names(n) = {char(h.title)};
end
fclose(fid);

if (n_waves == n_channels)
  disp(sprintf('Found %d wave channels.', n_waves))
else
  disp(sprintf('Found %d wave channels and ignored %d non-wave channels', ...
	       n_waves, n_channels - n_waves))
end

return
