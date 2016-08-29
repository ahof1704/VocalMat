function line_h = line_eb(x,y_eb,c,varargin)

% Draws a patch object to represent an error bar with lower limit y_lo,
% upper limit y_hi, in the current axes.  Returns a handle to the patch.
%
% We assume x is a col vectors of length n
% We assume y_eb is n x 2, with y_eb(i,1) <= y_eb(i,2) for all i

line_h=nan(2,1);
line_h(1)=line(x,y_eb(:,1),'color',c,varargin{:});
line_h(2)=line(x,y_eb(:,2),'color',c,varargin{:});
