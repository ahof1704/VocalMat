function [aBehaviorResults, classifier]=fnGeneralizeBehavior(aBehaviorExamples, miceInd, F, iTimeScale)
%
Nrounds = 5;
pairsNum = size(miceInd,1);
[x,y] = fnPrepareLearnInput2(aBehaviorExamples, F, iTimeScale);
classifier = gentleBoost(x, y, Nrounds);
x = [];
for p=1:pairsNum
    m = miceInd(p,:);
    r = [4*m(1)-3:4*m(1) 4*m(2)-3:4*m(2) 15*p+2:15*p+16];
    x = [x F(r, :)];
end
[tag, score] = strongGentleClassifier(x, classifier);
tag = reshape(tag, [], pairsNum)';
aBehaviorResults = [];
for p=1:pairsNum
    aBehaviorResults = [aBehaviorResults fnGetBehavior2(tag(p,:), miceInd(p,:), iTimeScale)];
end