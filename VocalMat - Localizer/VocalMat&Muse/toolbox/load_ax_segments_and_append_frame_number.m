function mouse=load_ax_segments_and_append_frame_number(file_name,video_pulse_start_ts,associated_video_frame_method)

mouse=load_ax_segments(file_name);
n_segments=length(mouse);

for i = 1:n_segments %maybe setup parallel processing
    start_point_this = mouse(i).start_sample_fine;
    end_point_this = mouse(i).stop_sample_fine;
    %determines frames associated with vocalization
    [ frame_number,frame_number_ts ] = fn_extract_frames2( video_pulse_start_ts, start_point_this, end_point_this );
    %if want closest video frame associated with vocalization start sample
    %set associated video frame to close
    if strcmp(associated_video_frame_method,'close')==1
        [~,smallest_loc] = min(abs(frame_number_ts-start_point_this));
        frame_of_interest = frame_number(smallest_loc);
        %frame_ts_of_interest = frame_number_ts(smallest_loc);
        %if want begining video frame associated with vocalization start sample
        %set associated video frame to close
    elseif  strcmp(associated_video_frame_method,'begin')==1
        frame_of_interest = frame_number(1);
    end
    mouse(i).frame_range = frame_number;
    mouse(i).frame_range_ts = frame_number_ts;
    mouse(i).frame_number = frame_of_interest;
    %clear start_point end_point frame_range
    %clear smallest_value smallest_loc
end

end
