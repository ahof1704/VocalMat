function fnDisplayLog()
%
global g_CaptainsLogDir;

strFile = [g_CaptainsLogDir filesep 'logFile.gs'];
fid = fopen([g_CaptainsLogDir filesep 'logFile.txt'],'r');

tline = fgets(fid);
while ischar(tline)
    if strcmp(tline(2:9),'image im')
       print('-dpsc2','-append',strFile);
    else
       
    end
    tline = fgets(fid);
end

fclose(fid);

