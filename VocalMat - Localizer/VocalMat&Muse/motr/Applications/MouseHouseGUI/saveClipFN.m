function saveClipFN(expDirName,clipFNAbs,clipSMFNAbs)
% Stores the clip filename information in exp in the file. 

s=struct('clipFNAbs',{clipFNAbs},'clipSMFNAbs',{clipSMFNAbs});
fileName=fullfile(expDirName,'clipFN.mat');
fnSaveAnonymous(fileName,s);

end
