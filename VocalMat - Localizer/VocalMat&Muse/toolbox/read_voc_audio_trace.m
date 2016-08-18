function [v,t,fs] = ...
  read_voc_audio_trace( exp_dir_name, letter_str, ...
                        i_start,i_end)

% i_start and i_end are matlab-style indices                      
                      
path_name=sprintf('%s/demux', exp_dir_name);
base_name=sprintf('Test_%s_1',letter_str);           

% get the filter ready
fs = 450450; %audio sampling rate, Hz

T_extra=0.000;  % s, extra time at either end, to accomodate travel time
                %    differences
dt=1/fs;  % s              
n_extra=ceil(T_extra/dt);
i_start = i_start-n_extra;
i_end = i_end+n_extra;

n_t=i_end-i_start+1;
n_signals=4;
v=zeros(n_t,n_signals);
for i=1:n_signals
    % load in each channel
    fname=fullfile(path_name,[base_name '.ch' num2str(i)]);
    v(:,i)=read_file_chunk(fname,n_t,i_start-1,'float32');
end

% make a time line
t=dt*(0:(n_t-1))';  % s

end
