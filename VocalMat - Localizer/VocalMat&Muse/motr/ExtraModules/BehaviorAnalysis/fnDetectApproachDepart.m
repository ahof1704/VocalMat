function astrctBehaviors = fnDetectApproachDepart(astrctBehaviorsIn, strctHeadPos)
%
astrctBehaviors = astrctBehaviorsIn;
for eventInd=1:length(astrctBehaviorsIn)
    aMice = astrctBehaviorsIn(eventInd).m_aMice;
    astrctBehaviors(eventInd).m_aApproach = zeros(size(aMice));
    astrctBehaviors(eventInd).m_aDepart = zeros(size(aMice));
    for i=1:length(aMice)
        aFrames = [max(1, astrctBehaviorsIn(eventInd).m_iStart-30), ...
                                astrctBehaviorsIn(eventInd).m_iStart];
        if fnCalcInstHeadDist(strctHeadPos, [aMice(i), aMice(i)], aFrames) > 24
            astrctBehaviors(eventInd).m_aApproach(i) = 1;
        end
        aFrames = [astrctBehaviorsIn(eventInd).m_iEnd,  ...
                                min(length(strctHeadPos(1).x), astrctBehaviorsIn(eventInd).m_iEnd)];
        if fnCalcInstHeadDist(strctHeadPos, [aMice(i), aMice(i)], aFrames) > 24
            astrctBehaviors(eventInd).m_aDepart(i) = 1;
        end
    end
end
