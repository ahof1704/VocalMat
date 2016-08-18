function output= ...
  r_est_from_segment_indicators_and_trial_overhead(args,options)

% Estimates position for all snippets in the given segment, gets rid of
% outliers, and returns the overall position estimate for the segment.

% call the position estimator on all snippets
r_est_blobs = ...
  r_ests_from_segment_indicators_and_trial_overhead(args,options);
n_snippets=length(r_est_blobs);

% check for emptyness
if n_snippets==0 ,
  if options.verbosity>=1
    n_snippets
    figure_position_estimate_snippetized(args.date_str,args.letter_str,args.i_segment, ...
                                         nan(2,1),nan(2,2),nan(2,0),false(0,1), ...
                                         r_head_from_video,r_tail_from_video, ...
                                         args.R,args.r_corners,args.x_grid,args.y_grid);        
  end
  output=struct();
  output.date_str=args.date_str;
  output.letter_str=args.letter_str;
  output.i_segment=args.i_segment;
  output.localized=false;
  output.r_est=[nan nan]';
  output.Covariance_matrix=[nan nan; nan nan];
  n_mice=size(args.r_head_from_video,3);
  output.p_head=nan(n_mice,1);
  output.P_posterior_head=nan(n_mice,1);
  output.r_head_from_video=nan(2,1);
  output.r_tail_from_video=nan(2,1);
  if options.return_big_things ,
    output.rsrp_grid=nan;
  end
  return  
end

% unpack the return blob
field_names=fieldnames(r_est_blobs);
for i=1:length(field_names)
  eval(sprintf('%s_all_snippets={r_est_blobs.%s}'';',field_names{i},field_names{i}));
end
%clear r_est_blobs;

% transform things from cell arrays what can
if options.return_big_things ,
  rsrp_grid_all_snippets=cell2mat(reshape(rsrp_grid_all_snippets,[1 1 n_snippets]));  %#ok
end
%rsrp_per_pair_grid_all_snippets=cell2mat(reshape(rsrp_per_pair_grid_all_snippets,[1 1 1 n_snippets]));
r_est_all_snippets=cell2mat(reshape(r_est_all_snippets,[1 n_snippets]));  %#ok
r_head_from_video_all_snippets=cell2mat(reshape(r_head_from_video_all_snippets,[1 n_snippets]));  %#ok
r_tail_from_video_all_snippets=cell2mat(reshape(r_tail_from_video_all_snippets,[1 n_snippets]));  %#ok

% Get the video position from the snippets
i_start_all_snippets=cell2mat(i_start_all_snippets);
i_end_all_snippets=cell2mat(i_end_all_snippets);
[r_head_from_video,r_tail_from_video]= ...
  r_head_for_segment_from_snippets(r_head_from_video_all_snippets, ...
                                   r_tail_from_video_all_snippets, ...
                                   i_start_all_snippets, ...
                                   i_end_all_snippets);                                 

% Because of grid sampling, it is possible for the r_ests to be exactly
% equal to one another, and thus for there to be >=3 snippets, but <3
% unique snippets, which will make kur_rce() throw an error.
r_est_all_snippets_unique=unique(r_est_all_snippets','rows')';
n_snippets_unique=size(r_est_all_snippets_unique,2);

% if fewer than 3 unique snippets, kur_rce() will error
if n_snippets_unique<3 ,
  if options.verbosity>=1
    n_snippets
    n_snippets_unique
    figure_position_estimate_snippetized(args.date_str,args.letter_str,args.i_segment, ...
                                         nan(2,1),nan(2,2),r_est_all_snippets,is_outlier, ...
                                         r_head_from_video,r_tail_from_video, ...
                                         args.R,args.r_corners,args.x_grid,args.y_grid);    
  end
  %output=rmfield(args,{'x_grid' 'y_grid' 'in_cage'});
  output=struct();
  output.date_str=args.date_str;
  output.letter_str=args.letter_str;
  output.i_segment=args.i_segment;
  output.localized=false;
  output.r_est=[nan nan]';
  output.Covariance_matrix=[nan nan; nan nan];
  n_mice=size(args.r_head_from_video,3);
  output.p_head=nan(n_mice,1);
  output.P_posterior_head=nan(n_mice,1);
  output.r_head_from_video=nan(2,1);
  output.r_tail_from_video=nan(2,1);
  if options.return_big_things ,
    output.rsrp_grid=nan;
  end
  return
end

% need to do outlier filtering on r_est here
[is_outlier,~,r_est_trans,Covariance_matrix] = kur_rce(r_est_all_snippets',1);
is_outlier=logical(is_outlier);
n_outliers=sum(is_outlier);
n_keepers=n_snippets-n_outliers;
r_est=r_est_trans';  % overall position estimate for the segment
if all(isnan(r_est)) ,
  r_est=nan(2,1);  % at least get the dimensions right
end
if all(isnan(Covariance_matrix(:))) ,
  Covariance_matrix=nan(2,2);  % at least get the dimensions right
end
if n_keepers<3 ,
  if options.verbosity>=1
    n_snippets
    n_snippets_unique
    n_outliers
    n_keepers
    figure_position_estimate_snippetized(args.date_str,args.letter_str,args.i_segment, ...
                                         r_est,Covariance_matrix,r_est_all_snippets,is_outlier, ...
                                         r_head_from_video,r_tail_from_video, ...
                                         args.R,args.r_corners,args.x_grid,args.y_grid);
    
  end
  %output=rmfield(args,{'x_grid' 'y_grid' 'in_cage'});
  output=struct();
  output.date_str=args.date_str;
  output.letter_str=args.letter_str;
  output.i_segment=args.i_segment;
  output.localized=false;
  output.r_est=[nan nan]';
  output.Covariance_matrix=[nan nan; nan nan];
  n_mice=size(args.r_head_from_video,3);
  output.p_head=nan(n_mice,1);
  output.P_posterior_head=nan(n_mice,1);
  output.r_head_from_video=nan(2,1);
  output.r_tail_from_video=nan(2,1);
  if options.return_big_things ,
    output.rsrp_grid=nan;
  end
  return
end

% filter out the outliers
is_keeper=~is_outlier;
%n_keepers=sum(is_keeper);
if options.return_big_things ,
  rsrp_grid_all_keepers=rsrp_grid_all_snippets(:,:,is_keeper);
end
%r_est_all_keepers=r_est_all_snippets(:,is_keeper);
%r_est_all_outliers=r_est_all_snippets(:,is_outlier);

% take the mean of the maps for all the non-outliers
if options.return_big_things ,
  output.rsrp_grid=mean(rsrp_grid_all_keepers,3);  %#ok
end

% calculate the density at the mice, and the posterior
% probabilities
p_head=mvnpdf(r_head_from_video',r_est',Covariance_matrix);  % density
P_posterior_head=p_head/sum(p_head);  % posterior probability

% put stuff in the return blob
%output=rmfield(args,{'x_grid' 'y_grid' 'in_cage'});
output=struct();
output.date_str=args.date_str;
output.letter_str=args.letter_str;
output.i_segment=args.i_segment;
output.localized=true;
output.r_est=r_est;
output.Covariance_matrix=Covariance_matrix;
output.p_head=p_head;
output.P_posterior_head=P_posterior_head;
output.r_head_from_video=r_head_from_video;
output.r_tail_from_video=r_tail_from_video;
if options.return_big_things ,
  output.rsrp_grid=nan;
end

if options.verbosity>=1
  n_snippets
  n_snippets_unique
  n_outliers
  n_keepers
  figure_position_estimate_snippetized(args.date_str,args.letter_str,args.i_segment, ...
                                       r_est,Covariance_matrix,r_est_all_snippets,is_outlier, ...
                                       r_head_from_video,r_tail_from_video, ...
                                       args.R,args.r_corners,args.x_grid,args.y_grid);
end

end
