function aOBfeatures = fnCalcOtherBehaviorFeatures(aOBtags, aiOBfeatureNum, abOBelapted, abOBfreq, aiOBtimeScale)
%
iNumPairs = size(aOBtags, 1);
iNumOB = size(aOBtags, 2);
iNumFrames = size(aOBtags,3);
aOBfeatures = zeros(sum(aiOBfeatureNum), iNumFrames, iNumPairs);

for iPair=1:iNumPairs
    for iOB=1:iNumOB
        iFeatureInd = 1;
        if abOBelapted(iOB)
            aOBfeatures(iFeatureInd, :, iPair) = min(fnCalcElapsed(aOBtags(iPair, iOB, :)), aiOBtimeScale(iOB));
        end
        if abOBfreq(iOB)
            aOBfeatures(iFeatureInd, :, iPair) = fnCalcFreq(aOBtags(iPair, iOB, :), aiOBtimeScale(iOB));
        end
        iFeatureInd = iFeatureInd + 1;
    end
end

function elapsed = fnCalcElapsed(y)
%
elapsed = 1:length(y);
elapsed(y==1) = 0;
s = find(elapsed(2:end) > 0 & elapsed(1:end-1)==0) ;
if isempty(s)
    return;
end
s = s + 1;
if elapsed(1)
    s = [1 s];
end
e = find(elapsed(1:end-1) > 0 & elapsed(2:end)==0) ;
if e(end)  < length(y)
    e = [e length(y)];
end
for i=1:length(s)
    elapsed(s(i):e(i)) = elapsed(s(i):e(i)) - elapsed(s(i)) + 1;
end


function freq = fnCalcFreq(y, t)
%
w = ones(1,t)/t;
freq = conv(y, w, 'full');
freq = freq(1:length(y));
freq(1:t) = t * freq(1:t) ./ (1:t);
