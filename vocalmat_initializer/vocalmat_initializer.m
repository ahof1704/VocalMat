disp('[vocalmat]: choose the audio file(s) to be analyzed.');
[vfilenames,vpathname] = uigetfile({'*.wav'},'Select the sound track(s)','MultiSelect','on');
if ~iscell(vfilenames)
    vfilenames = {vfilenames};
end
