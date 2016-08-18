function fnShowOptions(cOption, a2fFrame, ind)
%
n = length(cOption.afMaxCorr);
afMaxCorr = cOption.afMaxCorr;
[afMaxCorr, iInd] = sort(afMaxCorr, 'descend');
iTrueInd = find(iInd==cOption.iTrueInd);
fMaxCorrThr = afMaxCorr(1)-0.15;
fMinDistThr = 0.7*cOption.afMinDist(iInd(1));
fMaxAreaStdThr = cOption.afAreaStd(iInd(1))+0.4*cOption.afAreaMean(iInd(1));

afMinDist = cOption.afMinDist(iInd);
afAreaMean = cOption.afAreaMean(iInd);
afAreaStd = cOption.afAreaStd(iInd);
acEllipses = cOption.acEllipses(iInd);
iFrame = cOption.iFrame;

abPass = afMaxCorr > fMaxCorrThr & afMinDist > fMinDistThr & afAreaStd < fMaxAreaStdThr;
s = 0.25;
ps = 0.025*[1 1 -2 -2];
for i=1:n
   subplot('Position',[0.1+(i-1)*s 0.93-s-(ind-1)/3 s s]+~abPass(i)*ps);
   imshow(a2fFrame);
   hold on;
   fnDrawTrackers(acEllipses{i},1);
   if i==iTrueInd
      fnDrawColoredFrame(size(a2fFrame),'g');
   end
   hold off;
   title(sprintf('%2.2f %4.0f %4.0f %4.0f', afMaxCorr(i), afMinDist(i), afAreaStd(i), afAreaMean(i)));
   if i==1, ylabel(num2str(iFrame)); end;
end
