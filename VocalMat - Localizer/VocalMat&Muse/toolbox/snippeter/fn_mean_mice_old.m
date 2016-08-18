function [ mean_mice ] = fn_mean_mice( TDOA, estimated_delta_t )
%fn_mag_mice
%   function determines the difference between m and TDOA 
%       only uses possible estimated delta t for 6 mic positions based on 
%       calculations from fn_equations function and only uses TDOA that are
%       greater than correlation threshold calcuated in fn_TDOA_estimates
%
%   After calculating differnece between usualble Delta t and TDOA,
%       the absolute value is determined.
%
%   The last step determines the mean of the absolute value of diffence 
%       between usuable delta t and tdoa for each mouse
%
%   OUTPUT (mean_mice) is a matrix with the mean of  mean of the absolute 
%       value of diffence between usuable delta t and tdoa for each mouse.
%       Size of the output matrix = (number_mice, 1)
%
%   Variables:
%
%   TDOA = time delay on arival between pairs of microphones; calculated
%       with fn_TDOA function
%   estimated_delta_t = estimated time of delays based on the positions of
%       the mice between different microphones 
%

for j = 1:size(estimated_delta_t,1)
    count = 0;
    for k = 1:size(estimated_delta_t,2)
        if estimated_delta_t(j,k)~= 0 && isnan(TDOA(1,k))==0
            count = count + 1;
            foo(count,1) = abs(estimated_delta_t(j,k)-TDOA(1,k));
        end
    end
    mean_mice(1,j) = mean(foo);
    clear foo
end

end

