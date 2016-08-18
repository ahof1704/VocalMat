function [r_argmax,objective_max]= ...
  argmax_grid(x_grid,y_grid,objective,gate_grid)

% Returns the point on the grid where the objective function is maximized.
%   x_grid: m x n, x values at each point on the grid
%   y_grid: m x n, y values at each point on the grid
%   objective: m x n, objective function values at each point on grid
%   gate_grid: m x n, a boolean array that is true for "admissible" grid
%                     points.  If absent or empty, all grid points are
%                     considered admissible
%   
%   r_argmax: 2x1, containing the x and y where the objective function is largest,
%                  considering only the admissible points.
%   objective_max: scalar, value of objective at r_argmax

if nargin<4
  gate_grid=[];
end

objective_cage=objective;
if ~isempty(gate_grid)
  objective_cage(~gate_grid(:))=min(objective(:));
end
[objective_max,i_min]=max(objective_cage(:));
r_argmax=[x_grid(i_min);y_grid(i_min)];

end
