function lim=f(lim)

% the input lim should be a vector of length 2, with lim(1) <= lim(2)
% the returned lim keeps at least one of the elements the same, and changes
% the other so that 0 is in the range, maintaining lim(1) <= lim(2)

if (lim(1)<0)
  lim(2)=max(0,lim(2));
end
if (lim(2)>0)
  lim(1)=min(0,lim(1));
end
