function aBehaviorResults=fnGetBehavior2(behaviorTags, ind, iTimeScale)
%
B = behaviorTags;

B(1) = -1;
B(end) = -1;
s = find(B(2:end) - B(1:end-1) == 2) + 1 + iTimeScale;
e = find(B(1:end-1) - B(2:end) == 2) + iTimeScale;
i = find(s(2:end) - e(1:end-1) > 4);
s = s([1 i+1]);
e = e([i end]);
i = find(e - s > 4);
s = s(i);
e = e(i);
b = [1 e(1:end-1)+1];
f = [s(2:end)-1 length(B)];
a = zeros(2, length(s)); % todo
d = zeros(2, length(s)); % todo
aBehaviorResults = [b; s; e; f; a; d; ind'*ones(1,length(s))];
