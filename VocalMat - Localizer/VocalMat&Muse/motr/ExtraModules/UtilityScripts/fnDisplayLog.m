function fnDisplayLog(sLogDir)
%
%%
fprintf('\n');
fprintf('----------------------------------------------------------\n');
fprintf('%s\n', sLogDir);
fprintf('----------------------------------------------------------\n');
fprintf('\n');
fid = fopen(fullfile(sLogDir, 'logFile.txt'),'r');

tline = fgetl(fid);
while ischar(tline)
   %%
    if strcmp(tline(2:9),'image im')
       im = imread(fullfile(sLogDir, [tline(8:end) '.jpg']));
       imshow(im, 'InitialMagnification', 40);
       snapnow;
    else
       fprintf('%s\n', tline);
    end
    tline = fgetl(fid);
end

fclose(fid);

