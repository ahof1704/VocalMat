function path_as_array=split_on_filesep(path)
  % split a path on filesep into a cell array of single dir names
  
  % check for empty input
  if isempty(path)
    path_as_array=cell(0,1);
    return;
  end
  
  % trim a trailing fileseparator
  if path(end)==filesep
    path=path(1:end-1);
  end
  
  i_pathsep=strfind(path,filesep);
  n=length(i_pathsep)+1;
  path_as_array=cell(n,1);
  if n>0
    if n==1
      path_as_array{1}=path;
    else
      % if here, n>=2
      path_as_array{1}=path(1:i_pathsep(1)-1);
      for i=2:(n-1)
        path_as_array{i}=path(i_pathsep(i-1)+1:i_pathsep(i)-1);
      end
      path_as_array{n}=path(i_pathsep(n-1)+1:end);
    end
  end
end
