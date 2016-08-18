function trxFileName=trxFileNameFromMotrTrackFileName(motrTrackFileName)

[path,baseName,ext]=fileparts(motrTrackFileName);
% if the baseName ends in '_track', chop that off
if length(baseName)>=6 && isequal(baseName(end-5:end),'_track') ,
  baseNameNew=baseName(1:end-6);
elseif length(baseName)>=7 && isequal(baseName(end-6:end),'_tracks') ,
  baseNameNew=baseName(1:end-7);
else
  baseNameNew=baseName;
end
trxFileName=fullfile(path,[baseNameNew '.trx']);

end

