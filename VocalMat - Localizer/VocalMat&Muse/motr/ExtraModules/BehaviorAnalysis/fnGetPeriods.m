function p = fnGetPeriods(x)
%
M = size(x, 1);
N = size(x, 2);
p = zeros(1, N);
s = 50;
f = [ones(1, s)/s zeros(1, s)];
for i=1:M
   x = x - conv(x, f, 'same');
   a = conv(abs(x), f, 'same') + 1;
   y = sign(x);
   y(abs(x) < a) = 0;
   ps = y(1);
   for j=2:N
      p(j) = p(j-1);
      if y(j)*ps == -1
         p(j) = p(j) + 1;
      end
      if y(j) ~= 0
         ps = y(j);
      end
   end
   p(2*s+1:N) = p(2*s+1:N) - p(1:N-2*s);
end
