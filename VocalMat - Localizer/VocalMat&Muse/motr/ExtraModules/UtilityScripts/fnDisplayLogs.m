function fnDisplayLogs()
%
global g_CaptainsLogDir;
%%
D = dir(g_CaptainsLogDir);

for i=1:length(D)
   if isdir(D(i).name) && ~strcmp(D(i).name,'..')
      fnDisplayLog(fullfile(g_CaptainsLogDir, D(i).name));
   end
end

