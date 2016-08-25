function F=fnCalcMouseFeatures(iMouseInd, astrctTrackers, BCparams)
%
%
F1 = [];
if BCparams.Features.bMouseFrame
    F1 = fnCalcMouseFrameFeatures(astrctTrackers(iMouseInd), BCparams);
end
bThrLike = isfield(BCparams.Features, 'bThresholdLike') && BCparams.Features.bThresholdLike;
if BCparams.Features.iSelfTimeScale>0 || bThrLike
    F1 = [F1; fnCalcMouseSelfFeatures(astrctTrackers(iMouseInd), 1, BCparams)];
end
i = 1;
if BCparams.Features.bMousePair
    iNumMice = length(astrctTrackers);
    for iOtherMouseInd=1:iNumMice
        if iOtherMouseInd~=iMouseInd
            F2 = [];
            if BCparams.Features.iSelfTimeScale>0 || bThrLike
                F2 = fnCalcMouseSelfFeatures(astrctTrackers(iOtherMouseInd), 2, BCparams);
            end
            F3 = fnCalcMousePairFeatures(astrctTrackers(iMouseInd), astrctTrackers(iOtherMouseInd), BCparams);
            if i==1 && iMouseInd==1
               display(['Features: F1: 1-' num2str(size(F1,1)) ' ; F2: ' num2str(size(F1,1)+1) '-' num2str(size(F1,1)+size(F2,1)) ' ; F3:' num2str(size(F1,1)+size(F2,1)+1) '-' num2str(size(F1,1)+size(F2,1)+size(F3,1))]);
            end
            F(:,:,i,1) = [F1; F2; F3];
            i = i + 1;
        end
    end
else
    F(:,:,i,1) = F1;
end
for i=1:length(BCparams.Features.aTimeScales)
   j = i + 1;
    t = BCparams.Features.aTimeScales(i);
    if t > 0
       F(:,:,:,j) = F(:,:,:,1) - circshift(F(:,:,:,1), [0 t]);
    end
end
% F(:,:,:,j+1) = fnGetPeriods(F(:,:,:,1);

