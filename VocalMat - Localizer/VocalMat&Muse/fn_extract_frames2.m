function [ frame_number,frame_number_ts ] = fn_extract_frames2( video_pulse_start_ts, start_point, end_point )
%fn_extract_frames 
%   based on the start and end points in the vocalization, which were
%   generated from muscat, finds video frames associated with vocalization
%   might be more accurate to use the start and stop times from fcontours in
%   muscat
%
% Output: 
%
%   frame_range
%   frame_range(1) is the first frame and frame(2) is last frame
%
% Variables: 
%
%   video_pulse_start_ts = timestamps of video frames genereated by
%   fn_video_pulse_start_ts
%   start_point is the start time in samples of the vocalization
%   end_point is the end time in samplse of the vocalization

frames_s = find(video_pulse_start_ts<start_point);
frames_e = find(video_pulse_start_ts>end_point, 1);

if isempty(frames_s)==1 || isempty(frames_e)==1
    frame_number = NaN;
    frame_number_ts = NaN;
%     frame_range(2) = NaN;
else
    %modified on 10/31/12 by jpn
    %         frame_range(1) = frames_s(end)+1;
    %     frame_range(2) = frames_e(1)-1;
    
        frame_number = frames_s(end):1:frames_e(1);        
        frame_number_ts = video_pulse_start_ts(frame_number)';                
end
end

