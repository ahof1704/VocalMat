function blob = ...
  tcs_from_voc_indicators_and_ancillary(base_dir_name,...
                                        date_str, ...
                                        letter_str, ...
                                        args, ...
                                        ~)

% unpack args
name_field=fieldnames(args);
for i=1:length(name_field)
  eval(sprintf('%s = args.%s;',name_field{i},name_field{i}));
end

% figure out the experiment dir name
exp_dir_name=sprintf('%s/sys_test_%s',base_dir_name,date_str);
if ~exist(exp_dir_name,'dir')
  exp_dir_name=sprintf('%s/%s',base_dir_name,date_str);
end

% extract the traces for this voc 
n_voc=i_end-i_start+1;
[v,~,fs]= ...
  read_voc_audio_trace(exp_dir_name, ...
                       letter_str, ...
                       i_start-n_voc, ...
                       i_end+n_voc);

% filter                     
V=fft(v);
[N,K]=size(v);
dt=1/fs;
f=fft_base(N,1/(dt*N));
keep=(f_lo<=abs(f))&(abs(f)<f_hi);
N_filt=sum(keep);
V_filt=V;
V_filt(~keep,:)=0;
v_filt=real(ifft(V_filt));
                     
% re-scale so they're audible
fs=fs/16;

% make a timeline
dt=1/fs;
t=dt*(0:(N-1))';
                 
% make name, units
name={'Mic 1','Mic 2','Mic 3','Mic 4'}';
units={'V','V','V','V'}';

% make a file name
base_name=sprintf('%s_%s_%03d', ...
                  date_str,letter_str,i_syl);
tcs_file_name=sprintf('%s.tcs',base_name);
if ~exist(tcs_dir_name,'dir')
  mkdir(tcs_dir_name);
end
tcs_path_name=fullfile(tcs_dir_name,tcs_file_name);

% output
write_tcs_common_timeline(tcs_path_name,name,t,v_filt,units);

% no return values
blob=struct();

end
