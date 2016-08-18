function compile_feval_analysis_function_executable()

% call the mcc executable so we only use the matlab compiler license for
% long enough to do the compile
%cmd='/home/taylora/bin/mcc -m -N -p images -p signal -p stats -v map_multiple_trials_executable.m';
%system(cmd);

% or not
bin_dir_name='bin';
if ~exist(bin_dir_name,'dir')
  mkdir(bin_dir_name);
end
old_dir=pwd();
cd(bin_dir_name);
mcc -R -singleCompThread -m -N -p images -p signal -p stats -v feval_analysis_function_executable.m
cd(old_dir);

end


