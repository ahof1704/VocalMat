function [i_first_tf_rect_in_segment,i_last_tf_rect_in_segment]= ...
  determine_segments(tf_rect_names)

% Find the indices of the first and last t-f rect in each segment.

if isempty(tf_rect_names) ,
  i_first_tf_rect_in_segment=zeros(0,1);
  i_last_tf_rect_in_segment=zeros(0,1);
else
  tf_rect_name_first=tf_rect_names{1};
  if length(tf_rect_name_first)~=17 ,
    error('The t-f rect names appear to be in the wrong format.');
  end
  i_segment_for_tf_rect_as_string=cellfun(@(s)s(4:9),tf_rect_names,'UniformOutput',false);
  i_segment_for_tf_rect=str2double(i_segment_for_tf_rect_as_string);

  % i_first_tf_rect_in_segment=find(diff([0;i_segment_for_tf_rect])>0);
  % i_last_tf_rect_in_segment=[i_first_tf_rect_in_segment(2:end)-1 ; ...
  %                            length(i_segment_for_tf_rect)];
  
  % had to change to this to check argeement with Josh's code, which treats
  % segments with zero snippets an un-localizable segments, whereas
  % previously my code didn't treat them as segments at all
  n_segments=max(i_segment_for_tf_rect);
  i_first_tf_rect_in_segment=nan(n_segments,1);
  i_last_tf_rect_in_segment=nan(n_segments,1);
  for i_segment=1:n_segments ,
    is_in_this_segment=(i_segment_for_tf_rect==i_segment);
    i_tf_rects_in_this_segment=find(is_in_this_segment);
    if isempty(i_tf_rects_in_this_segment) ,
      i_first_tf_rect_in_segment(i_segment)=nan;
      i_last_tf_rect_in_segment(i_segment)=nan;
    else
      % should be a contiguous stretch
      if any(abs(diff(i_tf_rects_in_this_segment)-1)>1e-3) ,
        error('Snippets for segment are not a contiguous stretch.')
      end
      % if get here, are a contiguous stretch with at least one element
      i_first_tf_rect_in_segment(i_segment)=i_tf_rects_in_this_segment(1);
      i_last_tf_rect_in_segment(i_segment)=i_tf_rects_in_this_segment(end);
    end
  end
end

end
