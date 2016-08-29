function newFileName=replaceExtension(fileName,newExt)

% newExt can be with or without the dot

if isempty(newExt) || ~isequal(newExt(1),'.')
  newExtWithDot=['.' newExt];
else
  newExtWithDot=newExt;
end

[path,baseName]=fileparts(fileName);
newFileName=fullfile(path,[baseName newExtWithDot]);

end
