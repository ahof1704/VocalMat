function [r_head,r_tail]= ...
  r_head_for_segment_from_snippets(r_head_per_snippet, ...
                                   r_tail_per_snippet, ...
                                   i_first_sample_per_snippet, ...
                                   i_last_sample_per_snippet)

  % We want to get a head and tail position for each segment.  To do
  % this, we get the head and tail position for each snippet, but then
  % filter so that we only get one position per time window (there can
  % be several snippets per time window).  We then average the
  % per-snippet position estimates across the filtered snippets.
  % On call, r_head_per_snippet should be 2 x n_mice x n_snippets

  % Collect the first and last audio sample index for each snippet
  i_sample_bounds_per_snippet=[i_first_sample_per_snippet ...
                               i_last_sample_per_snippet ];
                                             
  % For each time window, get the index of one snippet
  [~,i_snippet_one_per_time_window] = ...   
    unique(i_sample_bounds_per_snippet,'rows');

  % filter, keeping one snippet per time-window
  r_head_per_snippet_one_per_time_window= ...
    r_head_per_snippet(:,:,i_snippet_one_per_time_window);
  r_tail_per_snippet_one_per_time_window= ...
    r_tail_per_snippet(:,:,i_snippet_one_per_time_window);

  % take the mean of the filtered snippet position locations
  r_head=mean(r_head_per_snippet_one_per_time_window,3);
  r_tail=mean(r_tail_per_snippet_one_per_time_window,3);
end
