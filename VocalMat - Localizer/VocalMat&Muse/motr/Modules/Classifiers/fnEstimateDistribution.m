function [afX, Hpos_smooth, Hneg_smooth, afProbPos] = ...
    fnEstimateDistribution(afProjPos,afProjNeg, iPDFQuantizer, fCutoff, iNumClasses)


afX = linspace(min(afProjNeg),max(afProjPos),iPDFQuantizer);

afHistPos = hist(afProjPos, afX);
afHistNeg = hist(afProjNeg, afX);
Hpos = afHistPos ./ sum(afHistPos);
Hneg = afHistNeg ./ sum(afHistNeg);


% Smooth histograms 
Hpos_smooth = conv2(Hpos, ones(1,5)/5,'same');
Hneg_smooth = conv2(Hneg, ones(1,5)/5,'same');
Hpos_smooth = Hpos_smooth/sum(Hpos_smooth(:));
Hneg_smooth = Hneg_smooth/sum(Hneg_smooth(:));

% figure(10);
% clf;
% plot(afX,Hpos,afX,Hneg,afX,Hpos_smooth,afX,Hneg_smooth);

% Crop anything below 1e-4, since it is just numerical inaccuracies....
Hpos_smooth(Hpos_smooth<fCutoff) = 0;
Hneg_smooth(Hneg_smooth<fCutoff) = 0;
Hpos_smooth = Hpos_smooth/sum(Hpos_smooth(:));
Hneg_smooth = Hneg_smooth/sum(Hneg_smooth(:));
%P(A|x) = P(x|A) * Pr(A) / Pr(x)
%Pr(A) = 1/NumMice
%Pr(x) = Pr(x|A)*Pr(a)+Pr(x|Not A)*Pr(Not A) = Pr(x|A)*1/iNumMice + Pr(x|Not A)* (iNumMice-1)/iNumMice
abHasData = Hpos_smooth ~= 0 | Hneg_smooth ~= 0;
afPrX = (Hpos_smooth(abHasData) * 1/iNumClasses) ./ ...
    ((Hpos_smooth(abHasData) * 1/iNumClasses) + (Hneg_smooth(abHasData) * (iNumClasses-1)/iNumClasses));
afProbPos = interp1( afX(abHasData),afPrX,  afX,'linear','extrap');

return;
 