function [tmp1 tmp2 tmp3 tmp4] = fn_read_voc_audio_trace( dir1, audio_fname_prefix, mouse, z)
%This function read in data from 4 audio channels associated with specified
%start and stop samples
%
% Variables
%
% dir1 = directory where data is located
% audio_fname_prefix = experimental filename (i.e., Test_B_1)
% mouse = process data in form of structure
% which vocalization in structure analyze
% fields in mouse data structure
% start_point = starting time for vocalization (mouse.start_sample_fine)
% end_point = stop time for vocalization (mouse.stop_sample_fine)
% low = low freq in vocalization (mouse.lf_fine);
% high = high freq in vocalization (mouse.hf_fine);
%
% OUTPUT
%
% tmp1-4 audio trace in samples

cd (dir1)
fc = 450450; %audio sampling rate 
start_point = floor(mouse(1,z).start_sample_fine);
end_point = ceil(mouse(1,z).stop_sample_fine);

for i=1:4
    % load in each channel
    fname=[audio_fname_prefix '.ch' num2str(i)];
    x=read_file_chunk(fname,end_point+5,0,'float32');%function from Roian  %end point + 5 is sloppy way to read in data and not very efficient
    switch isnumeric(i)
        case i == 1
            tmp1 = x(start_point:end_point);
        case i == 2
            tmp2 = x(start_point:end_point);
        case i == 3
            tmp3 = x(start_point:end_point);
        case i == 4
            tmp4 = x(start_point:end_point);
    end
    clear x
end

%high and low pass filter 
%exclude noise outside of specified range
low = floor(mouse(1,z).lf_fine);
high = ceil(mouse(1,z).hf_fine);
if low>high
    tmp_frq = low;
    low = high;
    high = tmp_frq;
end

foo12 = rfilter(tmp1,low,high,fc);
clear tmp1
tmp1 = foo12;%filtered signal on channel 1
clear foo12;
foo12 = rfilter(tmp2,low,high,fc);
clear tmp2
tmp2 = foo12;%filtered signal on channel 1
clear foo12;
foo12 = rfilter(tmp3,low,high,fc);
clear tmp3
tmp3 = foo12;%filtered signal on channel 1
clear foo12;
foo12 = rfilter(tmp4,low,high,fc);
clear tmp4
tmp4 = foo12;%filtered signal on channel 1
clear foo12;
