function [clipFNAbs,clipSMFNAbs]=loadClipFN(fileName,expDirName)
% Loads the clip filename information from the given file.  If it's an
% old-format file, uses expDirName to return the absolute paths.

s=fnLoadAnonymous(fileName);
if ~isa(s,'struct')
  % messed-up clipFN.mat file
  excp=MException('loadClipFN:wrongFormat', ...
                  ['%s doesn''t seem to be in the right format.  ' ...
                   'Maybe it''s in the old format?'], ...
                  fileName);
  throw(excp);
end
% If we get here, we know s is a struct array.
varName=fieldnames(s);
if any(strcmp('clipFNAbs',varName)) && any(strcmp('clipSMFNAbs',varName))
  % new-style clipFN.mat file
  clipFNAbs=s.clipFNAbs;
  clipSMFNAbs=s.clipSMFNAbs;
elseif any(strcmp('clipFN',varName)) && any(strcmp('clipSMFN',varName))
  % old-style clipFN.mat file
  clipFN=s.clipFN;
  nClip=length(clipFN);
  clipFNAbs=cell(nClip,1);
  for i=1:nClip
    clipFNAbs{i}=fullfile(expDirName,clipFN{i});
  end  
  clipSMFN=s.clipSMFN;
  nClipSM=length(clipSMFN);
  clipSMFNAbs=cell(nClip,1);
  for i=1:nClipSM
    clipSMFNAbs{i}=fullfile(expDirName,clipSMFN{i});
  end
else
  % messed-up clipFN.mat file
  excp=MException('loadClipFN:wrongFormat', ...
                  ['%s doesn''t seem to be in the right format.  ' ...
                   'Maybe it''s in the old format?'], ...
                  fileName);
  throw(excp);
end

end
