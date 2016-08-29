function path_as_array=split_path(path)
% split a path on pathsep into a cell array of single dir names

i_pathsep=strfind(path,pathsep);
n=length(i_pathsep)+1;
path_as_array=cell(n,1);
if n>0
  if n==1
    path_as_array{1}=path;
  else
    % if here, n>=2
    path_as_array{1}=path(1:i_pathsep(1)-1);
    for i=2:(n-1)
      path_as_array{i}=path(i_pathsep(i-1):i_pathsep(i)-1);
    end
    path_as_array{n}=path(i_pathsep(n-1)+1:end);
  end
end
  
end
