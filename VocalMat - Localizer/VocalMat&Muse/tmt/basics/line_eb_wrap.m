function line_h = line_eb_wrap(x,y,y_eb,y_lim,c,varargin)

% Draws a patch object to represent an error bar with lower limit y_lo,
% upper limit y_hi, in the current axes.  Returns a handle to the patch.
%
% We assume x is a col vectors of length n
% We assume y_eb is n x 2, with y_eb(i,1) <= y_eb(i,2) for all i

line_h_lo=line_wrap(x,y_eb(:,1),y_lim,'color',c,varargin{:});
line_h_hi=line_wrap(x,y_eb(:,2),y_lim,'color',c,varargin{:});
line_h=[line_h_lo;line_h_hi];