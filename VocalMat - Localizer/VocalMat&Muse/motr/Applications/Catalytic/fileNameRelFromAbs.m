function fileNameRel=fileNameRelFromAbs(fileNameAbs)

[~,baseName,ext]=fileparts(fileNameAbs);
fileNameRel=[baseName ext];

end
