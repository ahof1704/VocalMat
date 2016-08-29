function [base,ext] = splitext(name)
% [base,ext] = splitext(name)
% EXT is everything including and following the final . in the input filename.
% BASE is everything before that. If no periods occur or there is a slash anywhere
% after the final period, EXT will be an empty string and BASE is the whole input.

k = strfind(name,'.');
if isempty(k),
  base = name;
  ext = '';
  return;
end

k = k(end);
j = strfind(name,'/');
if ~isempty(j) && j(end) > k,
  base = name;
  ext = '';
  return;
end

base = name(1:k-1);
ext = name(k:end);
