function error = registration_error(frame_ref,frame_test,border,A,b)

% Calculates the difference between frame_test and frame_ref, after pixel
% coords for frame_test undergo the linear transform r2=A*r1+b.  I.e. it
% calculates the sum over all valid r=(i,j) of
% (frame_ref(r)-frame_test(A*r+b))^2. frame_ref and frame_test must be
% matrices of the same size, A must be a 2x2 matrix, and b must be a 2x1
% column vector.  border specifies that number of pixel around the edges to
% be ignored.  I.e. border==0 means use all pixels.

n_rows=size(frame_ref,1);
n_cols=size(frame_ref,2);
frame_test_reg=register_frame(frame_test,A,b);
valid_points=~isnan(frame_test_reg);
valid_points_sub= ...
  valid_points(border+1:n_rows-border,border+1:n_cols-border);
error_matrix=(frame_test_reg-frame_ref).^2;
error_matrix_sub= ...
  error_matrix(border+1:n_rows-border,border+1:n_cols-border);
error_values=error_matrix_sub(valid_points_sub);  % eliminate the NaNs
error=sum(error_values)/length(error_values);

