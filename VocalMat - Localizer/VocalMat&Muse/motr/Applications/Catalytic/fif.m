function result=fif(test,resultIfTrue,resultIfFalse)

% A functional form of if.  Useful only if the two possible results are not
% too expensive to compute.

if test ,
  result=resultIfTrue;
else
  result=resultIfFalse;
end

end
