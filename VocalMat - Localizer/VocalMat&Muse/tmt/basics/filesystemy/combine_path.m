function path=combine_path(path_as_array)
% combine a cell array of dir names into a single path string

n=length(path_as_array);
if n>0
  path=path_as_array{1};
  for i=2:n
    path=[path pathsep path_as_array{i}];
  end
end
  
end

