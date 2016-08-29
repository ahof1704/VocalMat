function fnSubmitJob(strJobargin)
%
%Copyright (c) 2008 Shay Ohayon, California Institute of Technology. 
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)


% at the moment, run the job locally instead of sending it to a remote
% machine...
if bRunLocal
    fnJobAlgorithm(strJobargin);
    drawnow
else
    % Submit to grid
    
    % first, prepare the submit file

%    #!/bin/bash
%    /usr/local/matlab/bin/matlab -nosplash -nojvm -r "cd('/groups/egnor/home/ohayons/Code/JaneliaFarm/1.0.1003/');addpath(genpath(pwd()));fnJobAlgorithm('/groups/egnor/mousetrack/Jobs/17.44.28.562/Jobargin${SGE_TASK_ID}.mat');quit;"

    % then, execute the submitting command
    
    
%    !qsub -t 1-2 -N MouseJob -l matlab=1 -b y -cwd -V '/groups/egnor/home/ohayons/Code/JaneliaFarm/1.0.1003/submitscript'
    
end;

    

%!/usr/local/matlab/bin/matlab -nosplash -nojvm -r "cd('/groups/egnor/home/ohayons/Code/JaneliaFarm/1.0.1003/');addpath(genpath(pwd()));fnJobAlgorithm('/groups/egnor/mousetrack/Jobs/17.44.28.562/Jobargin0001.mat');quit;"
%/groups/egnor/mousetrack/Jobs/17.44.28.562/Jobargin0001.mat
%%!qsub -N MouseJob -j y -b y -cwd -o /dev/null -V 'whereis matlab >~/test.txt'


%
%
