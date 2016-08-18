function [ pulse ] = fn_video_time_ts_chuncks(dir1, audio_fname_prefix, fc, vfc )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
cd (dir1)
filename = [audio_fname_prefix '.ch5'];

precision = 'float32';
precision_bytes=4;
fid = fopen(filename,'r');
fseek(fid,0,1);%goes to end of file
position = ftell(fid); %finds location of end of file
fseek(fid,0,-1); %goes to begining of file

number_of_samples = (position)/precision_bytes; %position gives the length of the file in bytes and given the precision float32, this gives the number of samples in the file
% pulse_loc = [];
devisor = 50;
% while isempty(pulse_loc)==1
fraction_no_samples = floor(number_of_samples/devisor);
%     A = fread(fid, fraction_no_samples, precision);
%     fseek(fid,0,-1);
%     count = 1;
%     tmp = A>1;
%     pulse_loc = find(diff(tmp)==1);
% %     clear fraction_no_samples
%     devisor = devisor-10;
% end

% pulse(count,1) = pulse_loc(1,1);
% lenght_pulse = diff(pulse_loc);
fseek(fid,0,-1);
position = ftell(fid);
start_sample_number = (position)/precision_bytes;
clear tmp A pulse_loc
loops = 0;
while ~feof(fid)
    
    %     if count==1 && lenght_pulse(1)<floor(fc/vfc)
    %         position_pre100pulse = ((pulse(count)+lenght_pulse(1))-100)*precision_bytes;
    %     else
    %         position_pre100pulse = ((pulse(count)+floor(fc/vfc))-100)*precision_bytes;
    %     end
    %     fseek(fid, position_pre100pulse, -1);
    position = ftell(fid);
    start_sample_number = (position)/precision_bytes    
    disp(fraction_no_samples)
    A = fread(fid, fraction_no_samples, precision);
    tmp = A>1;
    pulse_loc = find(diff(tmp));
    if loops == 0
        pulse = pulse_loc;
        loops = loops + 1;
    else
        pulse = cat(1,pulse,pulse_loc);
    end
    disp(1);
    %     pulse_loc = find(diff(tmp),1,'first');
    %     if isempty(pulse_loc)==1
    %         break
    %     end
    %     count = count + 1;
    %     pulse(count,1) = pulse_loc+(position_pre100pulse/precision_bytes);
    %     clear tmp A pulse_loc
    %     position2 = ftell(fid);
    %     if position<(position2+floor(fc/vfc))
    %         break
    %     end
    clear A tmp pulse_loc
end
end

