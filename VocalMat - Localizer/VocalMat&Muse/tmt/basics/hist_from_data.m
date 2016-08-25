function [pdx,x_center,dx_bin,x_edge]=f(x_data,x_lo,x_hi,dx_bin_wanted,...
                                        centers_or_edges)

% if centers_or_edges=='centers', then x_center is s.t. 
%   x_center(1)=x_lo, x_center(end)=x_hi
%
% if centers_or_edges=='edges', then x_edge is s.t.
%   x_edge(1)=x_lo, x_edge(end)=x_hi
%
% dx_bin_wanted is adjusted such that the number of bins is an integer, 
%   and adjusted value is returned in dx_bin
%
% in either case, length(x_edges)=length(x_center+1), and 
%   x_center==x_edge(1:end-1)+dx_bin/2;

if nargin<2 || isempty(x_lo)
  x_lo=min(x_data);
end
if nargin<3 || isempty(x_hi)
  x_hi=max(x_data);
end
if nargin<4 || isempty(dx_bin_wanted)
  dx_bin_wanted=(x_hi-x_lo)/20;
end
if nargin<5 || isempty(centers_or_edges)
  center_based=true;
elseif strcmp(centers_or_edges,'centers')
  center_based=true;
elseif strcmp(centers_or_edges,'edges')
  center_based=false;
else
  error('centers_or_edges is not ''centers'' or ''edges''');
end

if center_based
  n_bins=ceil((x_hi-x_lo)/dx_bin_wanted)+1;
  dx_bin=(x_hi-x_lo)/(n_bins-1);
  x_edge=(x_lo-dx_bin/2)+dx_bin*(0:(n_bins+1))';
else
  % edge-based
  n_bins=ceil((x_hi-x_lo)/dx_bin_wanted);
  dx_bin=(x_hi-x_lo)/n_bins;
  x_edge=x_lo+dx_bin*(0:(n_bins+1))';
end
x_center=x_edge(1:end-1)+dx_bin/2;
if any((x_data<x_edge(1))|(x_data>=x_edge(end)))
  warning('There is data outside the bin range!');
end
n_data=length(x_data);
count=(histc(x_data,x_edge))';
count=count(1:end-1);  % chop off last bin, which holds number of data
                       % that _equal_ x_edges(end)
pdx=count/n_data;
