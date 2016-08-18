function [tf_rect_name,i_start,i_end,f_lo,f_hi,r_head_from_video,r_tail_from_video,R,Temp, ...
          dx,x_grid,y_grid,in_cage,r_corners,fs,i_first_tf_rect_in_segment,i_last_tf_rect_in_segment]= ...
  ssl_trial_overhead_cartesian_heckbertian(base_dir_name,data_analysis_dir_name,date_str,letter_str)

% A "trial" in the sense we use it here is a single video along with
% the audio and other associated data.
                   
% In the single-mouse datasets, the microphone positions in the 
% positions_out.mat file are encoded in a strange way, with the x and y
% coordinates swapped, but with x and y being in a traditional Cartesian
% arrangement, with x increasing as you move right and y increasing as you
% go up in the image frame.  We call this convention "old-style coords".

% Once Josh started using Motr, he switched to not swapping x and y.  (And
% with y increasing down, b/c that's what Motr does.)  That would be
% "new-style".

% In any case, the r_head, r_tail, R, and r_corners output by this function
% are all in the same coordinate system, which is a traditional Cartesian
% coordinate system, (y increases going up), with the lower-left corner of the
% lower-left pixel at (0,0) in real units.  To keep the 3D coord system
% right-handed, that means that a microphone above the plane of the floor
% will have a positive z coordinate.

% Note that doing it this way, rather than the way that is arguably more
% natural in Matlab, is consistent with the advise set down in "What are
% the coordinates of a pixel?" by Paul S. Heckbert, and published in one of
% those Graphics Gems books.

% Also worth noting is that x_grid, y_grid, and in_cage are kind of funky.
% in_cage(i,j) tells whether <x_grid(i,j),y_grid(i,j)> is in the cage (i.e.
% on the floor) or not (i.e. on the walls).  So that's normal.  But
% x_grid(i,j) increases as i increases (j doesn't matter), and y_grid(i,j)
% increases as j increases (i doesn't matter), which is unusual.  <x_grid(i,j),y_grid(i,j)>
% is in the same coordinate system as R and r_corners, so that's good.
% Also, x_grid/y_grid/in_cage is not the same size as the video frames,
% partly because it needs to be much finer than the pixel grid, and partly
% because this function doesn't actually know the video frame dimensions.

% construct the experiment dir name
% try this variant first
exp_dir_name=fullfile(base_dir_name,...
                      sprintf('sys_test_%s',date_str));
if ~exist(exp_dir_name,'dir')
  % if that didn't work, try this
  exp_dir_name=fullfile(base_dir_name,date_str);
end
                      
% read the vocalization index file                      
tf_rect_index_file_name= ...
  fullfile(exp_dir_name, ...
           sprintf('%s/Test_%s_1_Mouse.mat', ...
                   data_analysis_dir_name, ...
                   letter_str));
[tf_rect_name,i_start,i_end,f_lo,f_hi,r_head_from_video_pels,r_tail_from_video_pels]= ...
  read_tf_rect_index(tf_rect_index_file_name);
%n_voc=length(i_syl);

% get the meters per pel
meters_per_pel= ...
  load_anonymous(sprintf('%s/meters_2_pixels.mat',exp_dir_name));  % m/pel

% convert the head and tail positions
r_head_from_video=meters_per_pel*r_head_from_video_pels;  % m
r_tail_from_video=meters_per_pel*r_tail_from_video_pels;  % m

% read the cage bounds
corner_file_name= ...
  fullfile(exp_dir_name, ...
           sprintf('Test_%s_1_mark_corners.mat',letter_str));
r_corners=load_corner_file(corner_file_name);  % m

% load the microphone positions
positions_out=load_anonymous(sprintf('%s/positions_out.mat',exp_dir_name));
n_mike=4;
R=zeros(2,n_mike);  % Mike positions in cols (in meters)
R(1,:)=[positions_out.x_m];  % m
R(2,:)=[positions_out.y_m];  % m
R(3,:)=[positions_out.z_m];  % m
clear positions_out;

are_positions_in_old_style_coords=~isempty(strfind(base_dir_name,'ssl_sys_test'));
  % single-mouse data uses old-style coords, multi-mouse data uses Motr
  % coords

if are_positions_in_old_style_coords ,
  R(1:2,:)=flipud(R(1:2,:));  % old-style coords has x and y swapped
  r_corners=flipud(r_corners);
  r_head_from_video=flipud(r_head_from_video);
  r_tail_from_video=flipud(r_tail_from_video);
else
  % new-style, aka Motr-style, coords, so we convert to conventional
  % Cartesian
  video_file_name=fullfile(exp_dir_name, ...
                           sprintf('Test_%s_1.seq',letter_str));
  video_info=fnReadSeqInfo(video_file_name);
  frame_height_in_pels=video_info.m_iHeight;
  y_offset=meters_per_pel*(frame_height_in_pels+1);
  R(2,:)=y_offset-R(2,:);
  r_corners(2,:)=y_offset-r_corners(2,:);
  r_head_from_video(2,:)=y_offset-r_head_from_video(2,:);
  r_tail_from_video(2,:)=y_offset-r_tail_from_video(2,:);
end

% At this point, center of the lower-left pixel of the video frame is at
% meters_per_pixel*(1,1).  Shift everything so that the lower-left corner
% of the lower-left pixel of the video frame is at (0,0).
% If the center of the LL pel is at meters_per_pixel*(1,1), that means the
% LL corner of the LL pel is at 0.5*meters_per_pixel*(1,1), so just
% subtract this amount from x and y to "move" it to (0,0).
r_shift=meters_per_pel/2*ones(2,1);
R=bsxfun(@minus,R,[r_shift;0]);
r_corners=bsxfun(@minus,r_corners,r_shift);
r_head_from_video=bsxfun(@minus,r_head_from_video,r_shift);
r_tail_from_video=bsxfun(@minus,r_tail_from_video,r_shift);

% velocity of sound in air
Temp = load_anonymous(sprintf('%s/temps.mat',exp_dir_name));  % C
Temp=mean(Temp);  % should fix at some point

% set the grid resolution
%dx=0.001*1;  % m
dx=0.001*0.25;  % m, the resolution we really want

% figure grid bounds
x_min=dx*floor(min(R(1,:))/dx);
x_max=dx*ceil(max(R(1,:))/dx);
y_min=dx*floor(min(R(2,:))/dx);
y_max=dx*ceil(max(R(2,:))/dx);

% make some grids and stuff
xl=[x_min x_max];  % m
yl=[y_min y_max];  % m
x_line=(xl(1):dx:xl(2))';
y_line=(yl(1):dx:yl(2))';
n_x=length(x_line);
n_y=length(y_line);
x_grid=repmat(x_line ,[1 n_y]);
y_grid=repmat(y_line',[n_x 1]);

% move the corners out by a certain amount, since the mice are sometimes
% a little bit out of the quadrilateral defined by r_corners
dx_corner=0.00;  % m
r_center=mean(r_corners,2);  % m, 2x1
v_out=bsxfun(@minus,r_corners,r_center);  % m, 2x4
v_out_sign=sign(v_out);
r_corners_nudged=bsxfun(@plus,r_corners,dx_corner*v_out_sign);

% make a mask that indicates when a grid point is within the cage
in_cage=inside_convex_poly(x_grid,y_grid,r_corners_nudged);

% this is useful
fs=450450;  % Hz, sampling rate of the audio data

% sort out which tf_rect goes with which segment
[i_first_tf_rect_in_segment,i_last_tf_rect_in_segment]= ...
  determine_segments(tf_rect_name);

end
