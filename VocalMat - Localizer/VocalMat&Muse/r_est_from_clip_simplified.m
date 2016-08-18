function [r_est,rsrp_max,rsrp_grid,a,vel,N_filt,V_filt,V,rsrp_per_pair_grid]= ...
  r_est_from_clip_simplified(v,fs, ...
                             f_lo,f_hi, ...
                             Temp, ...
                             x_grid,y_grid,in_cage, ...
                             R, ...
                             verbosity)

% r_est_from_clip_simplified --- Estimate sound source location from microphone array data
%
%   This is the core function of Muse.  It takes the voltage signals from the
%   microphone array, and outputs an estimated sound source location.
%
%   [r_est,rsrp_max,rsrp_grid,a,vel,N_filt,V_filt,V,rsrp_per_pair_grid]= ...
%       r_est_from_clip_simplified(v,fs, ...
%                                  f_lo,f_hi, ...
%                                  Temp, ...
%                                  x_grid,y_grid,in_cage, ...
%                                  R, ...
%                                  verbosity)
%
%   Inputs:
%       v: An N x K array of microphone signals, N the number of time
%          points, K the number of microphones.
%       fs: The sampling frequency of the audio data, in Hz.
%       f_lo: The lower bound of the frequency band used for analysis, in
%             Hz.  Frequency compenents outside this band are zeroed after
%             the data is intially FFT'ed.
%       f_hi: The upper bound of the frequency band used for analysis, in
%             Hz.
%       Temp: The ambient temperature at which data was taken, in degrees
%             celsius.
%       x_grid: The reduced steered response power (RSRP) is calculated at
%               every point on a grid.  This gives the x-coordinate of each
%               point on the grid.  It is a 2D array.
%       y_grid: A 2D array of the same shape as x_grid, giving the
%               y-coordinate of each point at which RSRP is to be
%               calculated.  The points indicated by x_grid and y_grid are
%               assumed to be in a Cartesian coordinate system.
%       in_cage: A logical array of the same size as x_grid, indicating
%                which grid points are in the interior of the cage.  In
%                theory, the RSRP would only be calculated at these points.
%                In reality, this argument is not used.
%       R: The microphone positions in 3D space, a 3 x K array, in meters,
%          in a standard right-handed Cartesian coordinate system. Positive
%          z coordinates are assumed to be above the plane of the x_grid,
%          y_grid points.
%       verbosity: An integer indicating how much information about
%                  intermediate computations should be output to the
%                  console and/or figures.  A value of 0 indicates no
%                  output, higher values indicate more output.
%
%   Outputs:
%       r_est: A 2 x 1 array giving the estimated position of the sound
%              source.
%       rsrp_max: The value of the RSRP at r_est.  This will have units of
%                 arbs^2, if v is in arbs.
%       rsrp_grid: A 2D array of the same shape as x_grid, giving the RSRP
%                  at every point in the grid.  rsrp_max gives the largest
%                  value in rsrp_grid, and r_est the (x,y) point at which
%                  this value occurs.  This will have units of
%                 arbs^2, if v is in arbs.
%       a: A 1 x K array of values that estimates the gain of each
%          microphone, in same units as v.
%       vel: The speed of sound in air used in the calculation, as computed
%            from Temp.  In m/s.
%       N_filt: The number of frequency values in the passband of the
%               band-pass filter, given f_lo, f_hi, and (implicit) spacing
%               between frequency samples used.
%       V_filt: The FFT of the values in v, after band-pass filtering, in
%               the same units as v.
%       V: The FFT of the values in v, *before* band-pass filtering, in the
%          same units as v.
%       rsrp_per_pair_grid: A 3D array, Nx x Ny x Npairs, where Nx x Ny is
%                           the size of x_grid, and Npairs is the number of
%                           unordered pairs of microphones, not including
%                           self-pairs (K*(K-1)/2).  This contains the RSRP
%                           calculated for each microphone pair.  Summing
%                           rsrp_per_pair_grid across pages yields
%                           rsrp_grid.  This will have units of arbs^2, if
%                           v is in arbs.  The function
%                           mixing_matrix_from_n_mics(K) can be used to
%                           determine which pair corresponds to which
%                           microphones.

% calculate SSE at each grid point                
[rsrp_grid,a,vel,N_filt,V_filt,V,rsrp_per_pair_grid]= ...
  rsrp_grid_from_clip_and_xy_grids(v,fs, ...
                                   f_lo,f_hi, ...
                                   Temp, ...
                                   x_grid,y_grid, ...
                                   R, ...
                                   verbosity);

% find the min-sse point within the cage bounds
%[r_est,sse_min]=argmin_grid(x_grid,y_grid,sse_grid,in_cage);
[r_est,rsrp_max]=argmax_grid(x_grid,y_grid,rsrp_grid);  
  % ignore cage bounds, b/c sometimes they don't help, they hurt

end
