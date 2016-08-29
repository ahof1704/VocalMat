function a2Intervals=fnConvertToIntervals(y, d)
%
iMinLength = 0;
iMinDetached = 10;

y([1 end]) = false;
s = find(y & ~[false y(1:end-1)]);
e = find(y & ~[y(2:end) false]);
if any(s) && any(e)
   bLong = e - s >= iMinLength;
   if any(bLong)
      s = s(bLong);
      e = e(bLong);
      bDetached = s(2:end) - e(1:end-1) > iMinDetached;
      if any(bDetached)
         s = s([true bDetached]);
         e = e([bDetached true]);
      end
   end
end
a2Intervals = [];
for i=1:length(s)
   [md(i), mi(i)] = max(d(s(i):e(i)));
end
j = md > 70;
a2Intervals = [s(j)' mi(j)' e(j)'];
