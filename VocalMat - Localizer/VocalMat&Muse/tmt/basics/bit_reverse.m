function rev_n=f(n)

% i should be a uint8
% this is probably hecka slow
% if you're using this, you should think about using bitrevorder

rev_n=uint8(0);
for j=1:8
  rev_n=bitset(rev_n,j,bitget(n,9-j));
end
