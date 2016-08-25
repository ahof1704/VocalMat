function strctTracker = fnGetTrackerAtFrame(astrctTrackers, iMouseIter, iFrame)
    strctTracker.m_fX = astrctTrackers(iMouseIter).m_afX(iFrame);
    strctTracker.m_fY = astrctTrackers(iMouseIter).m_afY(iFrame);
    strctTracker.m_fA = astrctTrackers(iMouseIter).m_afA(iFrame);
    strctTracker.m_fB = astrctTrackers(iMouseIter).m_afB(iFrame);
    strctTracker.m_fTheta = astrctTrackers(iMouseIter).m_afTheta(iFrame);
    if isfield(astrctTrackers(iMouseIter),'m_astrctClass')
        strctTracker.m_strctClass = astrctTrackers(iMouseIter).m_astrctClass(iFrame);
    end;
return;
