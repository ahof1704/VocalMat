function astrctIntervals = fnMergeIntervals(astrctIntervals,iDistance)

iStartK = 1;
while 1
    bMerged = false;
    
    for k=iStartK:length(astrctIntervals)-1
        if astrctIntervals(k+1).m_iStart-astrctIntervals(k).m_iEnd  < iDistance 
            
            astrctIntervals(k).m_iEnd = astrctIntervals(k+1).m_iEnd;
            astrctIntervals(k).m_iLength = astrctIntervals(k).m_iEnd-astrctIntervals(k).m_iStart+1;
            astrctIntervals(k+1) = [];
            iStartK = k;
            bMerged = true;
            break;
        end;
    end;
    
    if ~bMerged
        break;
    end;
end;

return;
