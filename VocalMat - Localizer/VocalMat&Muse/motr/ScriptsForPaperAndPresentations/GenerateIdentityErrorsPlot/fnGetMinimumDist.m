function afMinDist = fnGetMinimumDist(strFile)
strctRes = load(strFile);
N = length(strctRes.astrctTrackers(1).m_afX);
afMinDist = zeros(1,N);
for iFrame=1:N
    a2fD = ones(4,4)*Inf;
    for i=1:4
        for j=i+1:4
            a2fD(i,j) = sqrt(  (strctRes.astrctTrackers(i).m_afX(iFrame) - strctRes.astrctTrackers(j).m_afX(iFrame)).^2+...
                (strctRes.astrctTrackers(i).m_afY(iFrame) - strctRes.astrctTrackers(j).m_afY(iFrame)).^2);
        end
    end
    afMinDist(iFrame) = min(a2fD(:));
end
