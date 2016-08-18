function dist=fnCalcInstHeadDist(strctHeadPos, aMiceInd, aFrames)
%
j = aMiceInd(1);
k = aMiceInd(2);
dist = sqrt((strctHeadPos(j).x(aFrames(1))-strctHeadPos(k).x(aFrames(2))).^2 + ...
                           (strctHeadPos(j).y(aFrames(1))-strctHeadPos(k).y(aFrames(2))).^2);
