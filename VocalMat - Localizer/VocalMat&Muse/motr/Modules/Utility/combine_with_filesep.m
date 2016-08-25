function path=combine_with_filesep(path_as_array)
  % combine a cell array of dir names into a single path name
  n=length(path_as_array);
  if n>0
    path=path_as_array{1};
    for i=2:n
      path=[path filesep path_as_array{i}];  %#ok
    end
  end
end
