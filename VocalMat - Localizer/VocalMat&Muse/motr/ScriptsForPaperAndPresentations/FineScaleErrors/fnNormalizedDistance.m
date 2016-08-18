function fDist = fnNormalizedDistance(strctEllipse1,strctEllipse2, strctStandardDeviation)

AbsDiff = abs(strctEllipse1.m_fTheta-strctEllipse2.m_fTheta);
CorrectedDiff = min(AbsDiff, 2*pi-AbsDiff);
T=(CorrectedDiff)^2 * 1/(strctStandardDeviation.m_fTheta)^2;

fDist = sqrt( ....
    (strctEllipse1.m_fX-strctEllipse2.m_fX)^2 * 1/(strctStandardDeviation.m_fX)^2 + ...
    (strctEllipse1.m_fY-strctEllipse2.m_fY)^2 * 1/(strctStandardDeviation.m_fY)^2 + ...
    (strctEllipse1.m_fA-strctEllipse2.m_fA)^2 * 1/(strctStandardDeviation.m_fA)^2 + ...
    (strctEllipse1.m_fB-strctEllipse2.m_fB)^2 * 1/(strctStandardDeviation.m_fB)^2 + ...
    T);

return;




