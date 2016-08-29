function [i_extrema,sign_extrema]=f(y,sigma_filter)

% y should be a col vector
extrema_array=extrema(y,sigma_filter);
[i_extrema,dummy,sign_extrema]=find(extrema_array);
