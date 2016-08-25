function [x,y]=fnPrepareLearnInput(aBehaviorExamples, F, iTimeScale)
%
b = aBehaviorExamples(1, :);
s = aBehaviorExamples(2, :);
e = aBehaviorExamples(3, :);
f = aBehaviorExamples(4, :);
n = aBehaviorExamples(7, :);
behaviorOrder = size(aBehaviorExamples, 1) - 6;
examplesNum = size(aBehaviorExamples, 2);
x = []; y = [];
for i=1:examplesNum
    y = [y -ones(1,s(i)-b(i)) ones(1,e(i)-s(i)+1) -ones(1,f(i)-e(i))];
    r = (4*n(i)-3):(4*n(i));
    x = [x F(r, (b(i):f(i))-iTimeScale)];
end