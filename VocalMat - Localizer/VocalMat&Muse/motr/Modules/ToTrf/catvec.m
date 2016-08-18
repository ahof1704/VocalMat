function z=catvec(x,y)

% concatenary 1D arrays, whether row or col

if size(x,2)>1 || size(y,2)>1 ,
  z=[x y];
else
  z=[x;y];
end

end