function [ pulse ] = fn_video_time_ts_chuncks2(dir_name, audio_fname_prefix, fc, vfc )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%cd (dir_name)
%cd C:\Data\tmp_data
filename_local = [audio_fname_prefix '.ch5'];
filename_abs=fullfile(dir_name,filename_local);
% precision = 'float32';

m = memmapfile(filename_abs,         ...
    'Offset', 0,        ...
    'Format', 'single',    ...
    'Writable', false);
step_size = floor(size(m.Data,1)/100);
actual_size = size(m.Data,1);
rounded_size = (floor(size(m.Data,1)/100))*100;
format long g
high = zeros(2,101);
start_vector = zeros(1,101);
for loops = 1:101
%     disp(loops)
    %     disp([sample_start sample_end])
    if loops == 101
        A = m.Data(rounded_size:actual_size);
    else
        sample_start = (loops-1)*step_size+1;
        sample_end = loops*step_size;
        A = m.Data(sample_start:sample_end);
        start_vector(1,loops) = sample_start;
    end
    high(1,loops) = A(1);
    high(2,loops) = A(end);
    tmp = A>1;
    pulse_loc_tmp = find(diff(tmp)==1);
    pulse_loc = pulse_loc_tmp+start_vector(1,loops);
%     if loops == 1
%         pulse_loc = pulse_loc_tmp+start_vector(1,loops);
%     else
%         if high(2,loops-1) > 1 && high(1,loops) > 1
%             pulse_loc = pulse_loc_tmp(2:end)+start_vector(1,loops);
%         else
%             pulse_loc = pulse_loc_tmp+start_vector(1,loops);
%         end
%     end
    if loops == 1
        pulse = pulse_loc;
    else
        pulse = cat(1,pulse,pulse_loc);
    end
    clear A sample_start sample_end tmp pulse_loc_tmp pulse_loc
end

% precision_bytes=4;
% fid = fopen(filename,'r');
% fseek(fid,0,1);%goes to end of file
% number_of_samples = ftell(fid); %finds location of end of file
% fseek(fid,0,-1); %goes to begining of file
% 
% devisor = 1000;
% fraction_no_samples = ceil(number_of_samples/devisor);
% high = zeros(2,devisor+1);
% 
% % loops = 0;
% status = fseek(fid,0,'bof');
% if status==-1
%     disp('************error*************')
%     beep
% end
% % while ~feof(fid)
% for loops = 1:devisor
%     %loops = loops + 1;
%     disp(loops)
%     start_sample_number = ftell(fid)/precision_bytes;
%     %     disp(start_sample_number)
%     %     disp(fraction_no_samples)
%     if loops==devisor
%         A = fread(fid, fraction_no_samples, precision);
%     else
%         %         num_samples_remaining = number_of_samples-(start_sample_number+fraction_no_samples)-1;
%         A = fread(fid, inf, precision);
%     end
%     status = fseek(fid,0,'cof');
%     if status==-1
%         disp('************error*************')
%         beep
%     end
%     %     disp(size(A))
%     high(1,loops) = A(1);
%     high(2,loops) = A(end);
%     %     if loops>1
%     %         disp(high(:,loops-1:loops))
%     %     end
%     tmp = A>1;
%     %     figure
%     %     plot(A)
%     pulse_loc_tmp = find(diff(tmp));
%     if loops == 1
%         pulse_loc = pulse_loc_tmp+start_sample_number;
%     else
%         if high(2,loops-1) > 1 && high(1,loops) > 1
%             pulse_loc = pulse_loc_tmp(2:end)+start_sample_number;
%         else
%             pulse_loc = pulse_loc_tmp+start_sample_number;
%         end
%     end
%     
%     if loops == 1
%         pulse = pulse_loc;
%     else
%         pulse = cat(1,pulse,pulse_loc);
%     end
%     %     plot(pulse)
%     %     disp(1);
%     %     pulse_loc = find(diff(tmp),1,'first');
%     %     if isempty(pulse_loc)==1
%     %         break
%     %     end
%     %     count = count + 1;
%     %     pulse(count,1) = pulse_loc+(position_pre100pulse/precision_bytes);
%     %     clear tmp A pulse_loc
%     %     position2 = ftell(fid);
%     %     if position<(position2+floor(fc/vfc))
%     %         break
%     %     end
%     clear A tmp pulse_loc
% end
% disp(1)
end



