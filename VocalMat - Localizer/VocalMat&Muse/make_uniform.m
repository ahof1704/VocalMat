function [ring_resamp,phase_resamp]=f(ring,n_resamp)

% ring should be nx3, in LAB coordinates
% ring is expected to be a ring, but without an endpoint repeat

n=size(ring,1);
ring_wrap=[ring ; ring(1,:)];  % len == n+1
ds=dist_lab(ring_wrap(1:end-1,:),ring_wrap(2:end,:));  % len == n
s=[0 ; cumsum(ds)];  % len == n+1
phase=s/s(end);  % normalized path length == phase in cycles

% make a uniform color sequence
phase_resamp=linspace(0,1,n_resamp+1)';
ring_resamp=interp1(phase,ring_wrap,phase_resamp,'linear');

% chop off the last bit
phase_resamp=phase_resamp(1:end-1);
ring_resamp=ring_resamp(1:end-1,:);
