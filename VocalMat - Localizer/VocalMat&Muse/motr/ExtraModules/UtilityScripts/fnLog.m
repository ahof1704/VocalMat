function fnLog(text, iLevel, im)
% Add text and possibly an image to the log.

% deal with arguments
if nargin < 2 
   iLevel = 1;
end

% Do the logging.
if fnGetLogMode(iLevel)
  global g_CaptainsLogDir g_logImIndex;
  sLogFile = fullfile(g_CaptainsLogDir, 'logFile.txt');
  fid = fopen(sLogFile, 'a');
  if nargin>=3
     g_logImIndex = g_logImIndex + 1;
     fprintf(fid, '%s\n image im%d\n', text, g_logImIndex);
     sImFile = fullfile(g_CaptainsLogDir, ['im' num2str(g_logImIndex) '.jpg']);
     imwrite(double(im), sImFile, 'jpg');
  else
     fprintf(fid, '%s\n', text);
  end
  fclose(fid);
end
