function line_hs = line_wrap(x,y,y_lim,varargin)

% Adds a line to the current axes, respecting the fact that
% y is circular.  For instance, y might be an angle in degrees, and
% y_lim set to [-180,+180].  We assume that y is continous, and then look
% for places where it crosses either of the y_lim, and then start a new
% line at the other y_lim.  So this function ends up drawing multiple
% lines, the handles of which are returned in line_hs.

% convert x and y to col vectors if they're not already
if ndims(x)==2 && size(x,1)==1
  x=x';
end
if ndims(y)==2 && size(y,1)==1
  y=y';
end

% draw lines
[x_seg,y_seg]=break_at_wrap_points(x,y,y_lim);
n_seg=length(x_seg);
line_hs=zeros(n_seg,1);
for i=1:n_seg
  line_hs(i)=line(x_seg{i},...
                  y_seg{i},...
                  varargin{:});
end
