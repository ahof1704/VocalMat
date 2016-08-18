function [r_argmin,objective_min]= ...
  argmin_grid(x_grid,y_grid,objective,gate_grid)

% Returns the point on the grid where the objective function is minimized.
%   x_grid: m x n, x values at each point on the grid
%   y_grid: m x n, y values at each point on the grid
%   objective: m x n, objective function values at each point on grid
%   gate_grid: m x n, a boolean array that is true for "admissible" grid
%                     points.  If absent or empty, all grid points are
%                     considered admissible
%   
%   r_argmin: 2x1, containing the x and y where the objective function is largest,
%                  considering only the admissible points.
%   objective_min: scalar, value of objective at r_argmin

if nargin<4
  gate_grid=[];
end

objective_cage=objective;
if ~isempty(gate_grid)
  objective_cage(~gate_grid(:))=max(objective(:));
end
[objective_min,i_min]=min(objective_cage(:));
r_argmin=[x_grid(i_min);y_grid(i_min)];

end
