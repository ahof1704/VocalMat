function xi = qinterp_jpn(x)
%
%IN: x = time series with some nan values
%
%OUT: xi = time series with constrained cubic spline interpolation 
%          over nan values.
%NOTE: leading and trailing nans are clipped away first
%
% AL, janelia, 1/10
%
% xi = qinterp(x)
%

% supress annoying warning msg about nan vals we are interping over...
warning off

% clip out any leading and trailing nan values 
% because we can't interpolate over these
% remove trailing nan values...
x = x(1:find(~isnan(x),1,'last'));

% remove leading nan values
x = x(end:-1:1);
x = x(1:find(~isnan(x),1,'last'));
x = x(end:-1:1);

% interpolate over any nan values
npts = find(isnan(x));
if ~isempty(npts)
    xi = x;
    xi(npts) = interp1(x,npts,'pchip');
else xi = x;
end;

% restore warning state
warning on

%%% end sub3 %%%



