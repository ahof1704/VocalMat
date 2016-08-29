function [x,y]=fnPrepareLearnInput2(aBehaviorExamples, F, iTimeScale)
%
b = aBehaviorExamples(1, :);
s = aBehaviorExamples(2, :);
e = aBehaviorExamples(3, :);
f = aBehaviorExamples(4, :);
m1 = aBehaviorExamples(9,:);
m2= aBehaviorExamples(10,:);
p = sum(aBehaviorExamples(9:10, :))-1;
examplesNum = size(aBehaviorExamples, 2);
x = []; y = [];
for i=1:examplesNum
    y = [y -ones(1,s(i)-b(i)) ones(1,e(i)-s(i)+1) -ones(1,f(i)-e(i))];
    r = [4*m1(i)-3:4*m1(i) 4*m2(i)-3:4*m2(i) 15*p(i)+2:15*p(i)+16];
    x = [x F(r, (b(i):f(i))-iTimeScale)];
end
