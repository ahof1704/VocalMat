function small = fn_find_short_chunks(min_seg_time,dur_mat,i)
    small = find(dur_mat(i,:)<min_seg_time);
end