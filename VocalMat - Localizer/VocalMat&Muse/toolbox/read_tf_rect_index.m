function [tf_rect_name,i_start,i_end,f_lo,f_hi,r_head_from_video_pels,r_tail_from_video_pels]= ...
  read_tf_rect_index(tf_rect_index_file_name)

% load the index
s=load(tf_rect_index_file_name);
tf_rect_index=s.mouse;
clear s;

% first things first
n_tf_rect=length(tf_rect_index);

% % check that there are no tf_rects with fewer than 12 hot pels
% % these should have been filtered out by Josh
% if sum([tf_rect_index.hot_pix]<12)>0 ,
%   error('A least one tf_rect has fewer than 12 hot pixels.');
% end

% figure out what form the video position data is in
is_x_head_style=false;
are_positions_from_motr=false;
if isfield(tf_rect_index,'pos_data')
  % this is how the older files store the position data (pre April 2013)
  if n_tf_rect>=1
    pos=tf_rect_index(1).pos_data;
    n_mice=length(pos);
    if n_mice>0
      is_x_head_style=isfield(pos(1),'x_head');
    end
  end
else
  % newer files (post April 2013) store the position data in a separate file
  [tf_rect_index_dir_name,tf_rect_index_base_name,tf_rect_index_extension]=fileparts(tf_rect_index_file_name);
  pos_index_file_name=fullfile(tf_rect_index_dir_name,[tf_rect_index_base_name '_Position' tf_rect_index_extension]);
  s=load(pos_index_file_name);
  pos_index=s.mouse_position;
  are_positions_from_motr=true;
  if n_tf_rect>=1
    pos=pos_index(1);
    n_mice=length(pos.pos_data_nose_x);
  else
    n_mice=0;
  end
end

% prep the arrays
tf_rect_name=cell(n_tf_rect,1);
i_start=zeros(n_tf_rect,1);
i_end=zeros(n_tf_rect,1);
f_lo=zeros(n_tf_rect,1);
f_hi=zeros(n_tf_rect,1);
r_head_from_video_pels=zeros(2,n_tf_rect,n_mice);
r_tail_from_video_pels=zeros(2,n_tf_rect,n_mice);

% iterate over the t-f rects
for i=1:n_tf_rect
  % read in the "syllable" name, a.k.a. the t-f rect name
  tf_rect_name{i}=tf_rect_index(i).syl_name;

  % read the start, end index
  i_start(i)=floor(tf_rect_index(i).start_sample_fine);
  i_end(i)=ceil(tf_rect_index(i).stop_sample_fine);

  % read the band where the t-f rect is
  f_lo(i) = tf_rect_index(i).lf_fine;  % Hz
  f_hi(i) = tf_rect_index(i).hf_fine;

  % get head & tail positions, in pels
  if is_x_head_style
    pos=tf_rect_index(i).pos_data;
    for j=1:n_mice
      r_head_from_video_pels(:,i,j)=[pos(j).x_head ...
                          pos(j).y_head]';  % pels
      r_tail_from_video_pels(:,i,j)=[pos(j).x_tail ...
                          pos(j).y_tail]';  % pels
    end
  elseif are_positions_from_motr
    pos=pos_index(i);
    for j=1:n_mice
      r_head_from_video_pels(:,i,j)=[pos.pos_data_nose_x(j) ...
                          pos.pos_data_nose_y(j)]';  % pels
      r_tail_from_video_pels(:,i,j)=[pos.pos_data_tail_x(j) ...
                          pos.pos_data_tail_y(j)]';  % pels
    end    
  else  % positions are in the tf_rect file, and are named {nose/tail}_{x/y}
    pos=tf_rect_index(i).pos_data;
    for j=1:n_mice
      r_head_from_video_pels(:,i,j)=[pos(j).nose_x ...
                          pos(j).nose_y]';  % pels
      r_tail_from_video_pels(:,i,j)=[pos(j).tail_x ...
                          pos(j).tail_y]';  % pels
    end
  end
end

% the positions from motr are not actually the head and tail positions, 
% because of an issue converting the Motr ellipses to head and tail
% locations.  The "head" position is actually the position of a point
% half-way from the center to the head.  Similarly for the tail.  So we'll
% correct them here.
r_center_pels=(r_head_from_video_pels+r_tail_from_video_pels)/2;
dr_head_pels=2*(r_head_from_video_pels-r_center_pels);
r_head_from_video_pels=r_center_pels+dr_head_pels;
r_tail_from_video_pels=r_center_pels-dr_head_pels;




% % filter out the "vocalizations" with a low-freq cutoff less than 30 kHz
% % also, get rid of those with f_lo>f_hi, they look like just noise
% keep=(f_lo>30e3)&(f_lo<f_hi);
% i_syl=i_syl(keep);
% i_start=i_start(keep);
% i_end=i_end(keep);
% f_lo=f_lo(keep);
% f_hi=f_hi(keep);
% r_head_pels=r_head_pels(:,keep,:);
% r_tail_pels=r_tail_pels(:,keep,:);

end
