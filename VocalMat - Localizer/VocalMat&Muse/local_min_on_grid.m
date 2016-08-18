function is_local_min=local_min_on_grid(J_grid)

% true for all elements that are less than all their 4-neighbors
% false around all the edges

[M,N]=size(J_grid);
diff_ns=diff(J_grid,1,1);  % North-South, M-1 x N
diff_ew=diff(J_grid,1,2);  % East-West, M x N-1

is_local_min_ns=(diff_ns(1:M-2,:)<0)&(diff_ns(2:M-1,:)>0);  % M-2 x N
is_local_min_ew=(diff_ew(:,1:N-2)<0)&(diff_ew(:,2:N-1)>0);  % M x N-2

is_local_min=false(M,N);
is_local_min(2:M-1,2:N-1)= ...
  is_local_min_ns(:,2:N-1)&is_local_min_ew(2:M-1,:);

end
