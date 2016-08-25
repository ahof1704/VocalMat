function [x_seg,y_normed_seg,y_eb_normed_seg] = ...
  break_at_wrap_points(x,y,y_lim,y_eb)

% this function breaks an angular quantity y wherever it passes the "wrap
% points" in y_lim.  For instance, y might be an angle in radians, and 
% y_lim might equal [-pi +pi].  It returns x_seg and y_normed_seg, both
% cell arrays of "segments".  If y crosses the wrap limits n_break times, 
% then there will be n_break+1 segments, each containing a stretch of
% values where y did not cross the wrap limits.  Any y_normed_seg{i}(j), 
% for all i and j, will be s.t. y_lim(1) <= y_normed_seg{i}(j) <= y_lim(2).
% This is useful is you would like to plot an angular quantity, for
% instance.  The function is smart about interpolating near the break
% points so that the segments end exactly at the y limits, not just near
% them.  If the y_eb argument is provided, this error bar is also wrapped
% appropriately, and y_eb_normed_seg{i}(j,:) is the wrapped error bar for
% y_eb_normed_seg{i}(j).  Note however that the error bar limits can lie
% outside of [y_lim(1),y_lim(2)].  (This is usually a good thing for
% plotting purposes.)
%
% we assume x, y, are col vectors of length n
% we assume y_lim is 2x1, with y_lim(1)<y_lim(2)
% if present, we assume y_eb is n x 2, with 
%  y_eb(i,1) <= y_eb(i,2) for all i

% deal with args
calc_error_bars=(nargin>=4);
if nargin<4 
  calc_error_bars=false;
  y_eb_normed_seg=[];
else
  calc_error_bars=true;
end

% figure out where the breaks are
y_lo=y_lim(1);
y_hi=y_lim(2);
y_span=y_hi-y_lo;
y_shift=y-y_lo;
y_phase=y_shift/y_span;  
  % y_phase takes on integer values at wrap points
y_n_wraps=floor(y_phase);
  % y_n_wraps is the (signed) number of times you pass the wrap point in 
  % going from between y_lo and y_hi to that value of y.
i_break=find(diff(y_n_wraps)~=0);
  % there's a break between i_break(j) and i_break(j)+1, for all j
n_break=length(i_break);
n_seg=n_break+1;  % a "seg" (==segment) is a run between breaks
  % there's also a seg before the first break, and after the last

% calculate the x coordinate of each break
x_break=zeros(n_break,1);
for i=1:n_break
  j=i_break(i);
  x_break(i)=interp1([y_phase(j);y_phase(j+1)],...
                     [x(j);x(j+1)],...
                     max(y_n_wraps(j),y_n_wraps(j+1)));
end

%
% useful quantities for making the segments
%
n_wraps_seg=[y_n_wraps(i_break);y_n_wraps(end)];
  % n_wraps_seg gives the value of y_n_wraps for each seg (y_n_wraps is 
  % constant within a seg)

% calculate the offset of the error bars from y
if calc_error_bars
  dy_eb=y_eb-repmat(y,[1 2]);
end

% calc the version of y restricted to the bounds
y_normed      =y      -y_n_wraps*y_span;  % y_lo <= this < y_hi
if calc_error_bars
  y_eb_normed=repmat(y_normed,[1 2])+dy_eb;
end

% calculate the value of y on either side of each break
y_normed_break_pre =y_span*(1+diff(n_wraps_seg))/2+y_lo;
y_normed_break_post=y_span*(1-diff(n_wraps_seg))/2+y_lo;
if isempty(y_normed_break_pre)
  % this matters downstream
  y_normed_break_pre =zeros(0,1);
  y_normed_break_post=zeros(0,1);  
end

% calculate the offset of the error bars from y at each break
if calc_error_bars
  y_break=interp1(x,y,x_break);
  y_eb_break=interp1(x,y_eb,x_break);
  dy_eb_break=y_eb_break-repmat(y_break,[1 2]);
end

% calculate the error bars on either side of each break
if calc_error_bars
  y_eb_normed_break_pre =repmat(y_normed_break_pre ,[1 2])+dy_eb_break;
  y_eb_normed_break_post=repmat(y_normed_break_post,[1 2])+dy_eb_break;
end

% make the segments
x_seg=cell(n_seg,1);
y_normed_seg=cell(n_seg,1);
for i=1:n_seg
  if i==1 && i==n_seg
    % i.e., if there are no breaks
    x_seg{i}=x;
    y_normed_seg{i}=y_normed;
    if calc_error_bars
      y_eb_normed_seg{i}=y_eb_normed;
    end
  elseif i==1 
    x_seg{i}=[x(1:i_break(1)) ; ...
              x_break(1)];
    y_normed_seg{i}=[y_normed(1:i_break(1)) ; ...
                     y_normed_break_pre(1)];
    if calc_error_bars               
      dy_eb_normed_seg_this=...
        [dy_eb(1:i_break(1),:) ; ...
         dy_eb_break(1,:)    ];
      y_eb_normed_seg{i}=repmat(y_normed_seg{i},[1 2])+...
                         dy_eb_normed_seg_this; 
    end
  elseif i==n_seg
    x_seg{i}=[x_break(end) ; ...
              x(i_break(end)+1:end)];
    y_normed_seg{i}=[y_normed_break_post(end) ; ...
                     y_normed(i_break(end)+1:end)];
    if calc_error_bars               
      dy_eb_normed_seg_this=...
        [dy_eb_break(end,:) ; ...
         dy_eb(i_break(end)+1:end,:) ]; ...
      y_eb_normed_seg{i}=repmat(y_normed_seg{i},[1 2])+...
                         dy_eb_normed_seg_this; 
    end
  else
    x_seg{i}=[x_break(i-1);...
              x(i_break(i-1)+1:i_break(i));...
              x_break(i)];
    y_normed_seg{i}=[y_normed_break_post(i-1); ...
                     y_normed(i_break(i-1)+1:i_break(i)); ...
                     y_normed_break_pre(i)];
    if calc_error_bars               
      dy_eb_normed_seg_this=[dy_eb_break(i-1,:); ...
                             dy_eb(i_break(i-1)+1:i_break(i),:); ...
                             dy_eb_break(i,:)];
      y_eb_normed_seg{i}=repmat(y_normed_seg{i},[1 2])+...
                         dy_eb_normed_seg_this;
    end
  end
end
