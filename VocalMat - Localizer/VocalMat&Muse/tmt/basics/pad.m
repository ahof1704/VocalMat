function xp=f(x,n_endcap,n_reflect)

% function to pad a signal by reflecting endcap segments about the 
% endpoints.  An endcap is a certain number of samples at the
% begining and end of the signal, which are reflected about the
% endpoint, both horizontally and vertically, to create a padded
% version of the signal.  It's simple, and it works pretty well much
% of the time.  This function actually repeats the basic
% reflection operation n_reflect times.This is used by filt2 and
% filtfilt2, maybe others too. 
%
% x has signals in the cols
% n_reflect is the number of times to reflect the endcap segments
% n_endcap is the number of samples in the endcap segments


if n_reflect==0
  xp=x;
else
  stage=[ 2*repmat(x(1,:),[n_endcap 1])-x((n_endcap+1):-1:2,:) ; ...
          x ; ...
          2*repmat(x(end,:),[n_endcap 1])-x(end-1:-1:end-n_endcap,:) ];        
  xp=pad(stage,n_endcap,n_reflect-1);
end

