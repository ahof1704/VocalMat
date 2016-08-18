function x=interpolateAwayNans(x,xIsAngular)

if ~exist('xIsAngular','var')
  xIsAngular=false;
end

n=length(x);
if n==0
  return
elseif n==1
  if isnan(x)
    error('x has one element, and it''s NaN, so I don''t know what to do.');
  else
    return
  end
end
% if we get here, length(x)>=2
isNan=isnan(x);
isNanStart=catvec(isNan(1),isNan(2:end)&~isNan(1:end-1));  % of length n
isNanEnd=catvec(~isNan(2:end)&isNan(1:end-1),isNan(end));  % of length n
iJustBeforeNanStarts=find(isNanStart)-1;  
  % indices of elements just before a stretch of nans (first element might
  % be zero, implying that the first element of x is a nan
iJustAfterNanEnds=find(isNanEnd)+1;  
  % indices of elements just after a stretch of nans (last element might be
  % n+1, implying that the last element of x is a nan)
if length(iJustBeforeNanStarts)~=length(iJustAfterNanEnds)
  % This shouldn't ever happen, unless I'm confused.
  error('Internal error.');
end
nNanStretches=length(iJustBeforeNanStarts);
if nNanStretches==0
  % no interpolation needed
  return
end
if any(iJustBeforeNanStarts>=iJustAfterNanEnds)
  % This shouldn't ever happen, unless I'm confused.
  error('Internal error.');
end
%iNanStarts=iJustBeforeNanStarts+1;  % index of first element of each nan stretch
%iNanEnds=iJustAfterNanEnds-1;  % index of last element of each nan stretch

% For each stretch of nan's interpolate the values based on the vals just
% outside the stretch.  If the stretch is at the beginning/end, just set
% the whole stretch to the first/last non-nan element.
for iNanStretch=1:nNanStretches
  iPre=iJustBeforeNanStarts(iNanStretch);
  iPost=iJustAfterNanEnds(iNanStretch);
  if iPre==0
    if iPost==n+1
      % The whole array is nans
      error('All elements of x are NaN, so I don''t know what to do.');
    else
      % This stretch is at the start of the array, and there are non-nan's
      % after it
      xPost=x(iPost);
      x(iPre+1:iPost-1)=xPost;
    end
  elseif iPost==n+1
    % This stretch is at the start of the array, and there are non-nan's
    % before it
    xPre=x(iPre);
    x(iPre+1:iPost-1)=xPre;
  else
    % The common case
    nThisStretch=iPost-iPre-1;
    xPre=x(iPre);
    xPost=x(iPost);
    % Replace the nans in this stretch with interpolated values
    dxRaw=xPost-xPre;
    if xIsAngular ,
      dx=atan2(sin(dxRaw),cos(dxRaw));
    else
      dx=dxRaw;
    end
    x(iPre+1:iPost-1)=dx/(nThisStretch+1)*(1:nThisStretch)+xPre;
  end
end

end
