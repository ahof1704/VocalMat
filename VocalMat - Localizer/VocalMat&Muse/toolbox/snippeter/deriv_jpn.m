function [dx,r,theta,phi,xf] = deriv_jpn(x,srate,lowcut,taps,porder,derivf)
%
% nice derivative function, with polynomial edge fitting
% and proper bandwidth contorl
%
%IN: x = time series to get 1st deriv of
%        if x is matrix we get deriv for each row, so data should be in
%        columns
%   srate = sampling rate of x
%   lowcut = lowpass cutoff (Hz) for x (denoising; def = 0.1*srate)
%   taps = filter length; > taps = better filter but more edge polynomial
%   (def=41)
%   porder = order of polynomial for edge filtering (def=5)
%   derivf = deriv filter (def= 7th order central diff)
%
%OUT: dx = derivative of x, per row
%     r,theta,phi: magnitude and angles of deriv if x is dim=2 or 3
%
% AL, janelia, 9/2010
%
% [dx,r,theta,phi] = deriv(x,srate,lowcut,taps,porder,derivf)
%

%defaults
if ~exist('lowcut') || isempty(lowcut);    lowcut = 0.15*srate;   end;
if ~exist('taps') || isempty(taps);        taps = 41;            end;
if ~exist('porder') || isempty(porder);    porder = 5;           end;
if ~exist('derivf') || isempty(derivf);    derivf = [1 -9 45 0 -45 9 -1]/60;  end;

% low pass filter time-series;
% warn if lowcut > 0.2*srate
% if lowcut > 0.2*srate
%     sprintf('warning: low pass cutoff (%d hz) exceeds 0.2*srate (%d), bandwidth of derivative filter is not accurate here!!',lowcut,srate)
% end;

if lowcut <= 0
    lowf = nan;
else lowf = fir1(taps,lowcut/(srate/2),'low');
end;
lowf_h = ceil(taps/2);

% define output
dx = zeros(size(x));
xf = dx;
xdim = size(x,2);
for k = 1:xdim

    if ~isnan(lowf)       
        % first we low-pass our time series to remove power where the
        % derivative filter is poor:
        xf(:,k) = tconv(x(:,k),lowf,1);

        % the edges of our filtered time series will have zero-padding artifacts
        % equal to the the filter half-width. we replace these with the polynomial
        % smoothed time-series with the same bandwidht as lowf, centered on 1-taps
        % and end-taps...
        tpts = (1:taps+1)';
        xbegin = x(tpts,k);
        [xbeginp,S,mu] = polyfit(tpts,xbegin,porder);
        xbeginf = polyval(xbeginp,tpts,[],mu);
        xf(1:lowf_h+1,k) = xbeginf(1:lowf_h+1) - xbeginf(lowf_h+1) + xf(lowf_h+1,k);
        
        tpts2 = [size(x,1)-taps:size(x,1)]';
        xend = x(tpts2,k);
        [xendp,S,mu] = polyfit(tpts2,xend,porder);
        xendf = polyval(xendp,tpts2,[],mu);
        xf(end-lowf_h:end,k) = xendf(end-lowf_h:end) - xendf(lowf_h+1) + xf(end-lowf_h,k);
    else xf = x;
    end;
    
    % now get the derivative
    dx_tmp = tconv(xf(:,k),derivf,1);

    % derivative at edges should be replaced w/ exact polynomial deriv.
    % since it is only a few pts we'll leave it as nan for now...
    % but this should be fixed soon.
    dx_tmp(1:porder) = nan;
    dx_tmp(end-porder:end) = nan;

    dx(:,k) = dx_tmp;
end;

% adjust for dt
dx = dx.*srate;

% get direction and speed...
switch xdim
    case 1
        r = dx;
        phi = 0;
        theta = 0;
    case 2
        [theta,r] = cart2pol(dx(:,1),dx(:,2));
        phi = 0;
    case 3
        [theta,phi,r] = getspherecoords(dx);
    otherwise
        phi = 0;
        theta = 0;
end;

dx = single(dx);
