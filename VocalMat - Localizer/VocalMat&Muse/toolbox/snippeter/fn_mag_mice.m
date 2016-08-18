function [ mag_mice ] = fn_mag_mice( TDOA, estimated_delta_t )
%fn_mag_mice
%   function determines the difference between m and TDOA 
%   only uses possible estimated delta t for 6 mic positions based on calculations 
%   from fn_equations function and only uses TDOA that are greater than
%   correlation threshold calcuated in fn_TDOA_estimates
%
%   After calculating differnece between usualble Delta t and TDOA,
%   the magnatude is calcuted using the matlab
%   function norm
%
%   OUTPUT (mag_mice) is a matrix with the magnitude between estimated
%   delta t and TDOA.  Size of the output matrix = (number_mice, 1)
%
%   Variables:
%
%   TDOA = time delay on arival between pairs of microphones; calculated
%       with fn_TDOA function
%   estimated_delta_t = estimated time of delays based on the positions of
%       the mice between different microphones 
%

for i = 1:size(estimated_delta_t,1)
    count = 0;
    for j = 1:size(estimated_delta_t,2)
        if estimated_delta_t(i,j)~=0 && isnan(TDOA(1,j))==0
            count = count + 1;
            diff_estimated_delta_t_TDOA(1,count)=estimated_delta_t(i,j)-TDOA(1,j);
        end
    end
    mag_mice(i,1) = norm(diff_estimated_delta_t_TDOA);
    clear diff_m_TDOA
end

end

