function home_dir_name=get_home_dir_name()

if ispc
  [status,home_dir_name_w_newline]=system('echo %home%');
  home_dir_name=home_dir_name_w_newline(1:end-1);
else
  [status,home_dir_name_w_newline]=system('echo $home');
  home_dir_name=home_dir_name_w_newline(1:end-1);
end  

end
