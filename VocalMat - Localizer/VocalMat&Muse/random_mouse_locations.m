function [r_head,r_tail]=random_mouse_locations(r_corners,mouse_length,n_mice_per_set,n_reps_wanted)

% Generates random mouse locations, where the heads and tails of the fake
% mice are guaranteed to be within the polygon defined by r_corners (2 x
% n_vertices).  The returned random mice are all of length mouse_length.

% Below, a "mouse-set" means a set of n_mice_per_set mice.

% On most iterations, we generate somewhat more candidate mouse-sets than
% think we need to generate to get the number of mouse-sets we still need.
% But if this number is small, we instead generate a fixed
% number, to increase our odds of getting enough good ones.
min_n_reps_to_generate_per_iter=100;

R_min=min(r_corners,[],2);  % the lower-left corner of the bounding box of r_corners
R_max=max(r_corners,[],2);  % the upper-right corner of the bounding box of r_corners

% a "valid" mouse is one for which the head and tail are within the bounding polygon
n_reps_valid=0;  
r_head=zeros(2,n_mice_per_set,0);
r_tail=zeros(2,n_mice_per_set,0);
while n_reps_valid<n_reps_wanted,
  % figure out how many candidate mouse-sets to generate on this iteration
  n_reps_still_wanted=n_reps_wanted-n_reps_valid;
  n_candidates_this=max(min_n_reps_to_generate_per_iter,2*n_reps_still_wanted);
  % generate candidate head positions
  f_rand=rand(2,n_mice_per_set,n_candidates_this);
  r_head_this_candidate=bsxfun(@times,1-f_rand,R_min)+bsxfun(@times,f_rand,R_max);
  % generate candidate tail positions
  theta_rand=2*pi*rand(1,n_mice_per_set,n_candidates_this);
  theta_rand_hat=[cos(theta_rand);sin(theta_rand)];
  r_tail_this_candidate=bsxfun(@plus,r_head_this_candidate,mouse_length*theta_rand_hat);
  %x_tail_this=reshape(r_tail_this(1,:,:),[n_mice n_reps_to_generate_this]);
  %y_tail_this=reshape(r_tail_this(2,:,:),[n_mice n_reps_to_generate_this]);
  is_head_inside_bounding_box = ...
    inpolygon(r_head_this_candidate(1,:,:),r_head_this_candidate(2,:,:), ...
              r_corners(1,:),r_corners(2,:));  % 1 x n_mice x n_candidates_this
  is_tail_inside_bounding_box = ...
    inpolygon(r_tail_this_candidate(1,:,:),r_tail_this_candidate(2,:,:), ...
              r_corners(1,:),r_corners(2,:));  % 1 x n_mice x n_candidates_this
  all_heads_inside_bounding_box=all(is_head_inside_bounding_box,2);  % 1 x 1 x n_candidates_this
  all_tails_inside_bounding_box=all(is_tail_inside_bounding_box,2);  % 1 x 1 x n_candidates_this
  all_mice_inside_bounding_box= ...
    all_heads_inside_bounding_box&all_tails_inside_bounding_box;    % 1 x 1 x n_candidates_this
  n_keepers_this=sum(all_mice_inside_bounding_box,3);
  n_reps_valid=n_reps_valid+n_keepers_this;
  r_head_this=r_head_this_candidate(:,:,all_mice_inside_bounding_box);
  r_tail_this=r_tail_this_candidate(:,:,all_mice_inside_bounding_box);
  r_head=cat(3,r_head,r_head_this);
  r_tail=cat(3,r_tail,r_tail_this);
end

% trim to desired number of reps
r_head=r_head(:,:,1:n_reps_wanted);
r_tail=r_tail(:,:,1:n_reps_wanted);


% % for one pseudo-random rep, draw
% i_example=3;
% r_head_example=r_head(:,:,i_example);
% r_tail_example=r_tail(:,:,i_example);
% 
% fig_h=figure('color','w');
% %set_figure_size_explicit(fig_h,[w_fig h_fig]);
% axes_h=axes('parent',fig_h);
% set(axes_h,'fontsize',7);
% set(axes_h','dataaspectratio',[1 1 1]);
% %set_axes_size_fixed_center_explicit(axes_h,[w_axes h_axes])
% 
% fake_mice_handles=draw_mice_given_head_and_tail(axes_h,r_head_example,r_tail_example,1);
% line('parent',axes_h, ...
%      'xdata',100*r_corners(1,:), ...
%      'ydata',100*r_corners(2,:), ...
%      'marker','.', ...
%      'markersize',6*3, ...
%      'linestyle','none', ...
%      'color','k');
% title(axes_h,'fake mice','interpreter','none','fontsize',7);

end
