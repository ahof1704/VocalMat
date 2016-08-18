function strctSeq = fnWriteSeqFrame(strctSeq, a2iFrame)
if strctSeq.m_iNumFrames == 0
    strctSeq.m_iWidth = size(a2iFrame,2);
    strctSeq.m_iHeight = size(a2iFrame,1);
else
    if size(a2iFrame,1) ~= strctSeq.m_iHeight || size(a2iFrame,2) ~= strctSeq.m_iWidth 
        error('Could not write frame because size is different.');
    end;
end;


iTimeStampA = 1000^2*round(strctSeq.m_iNumFrames/1000) ;
iTimeStampB = mod(strctSeq.m_iNumFrames,1000) ;
strctSeq.m_iNumFrames = strctSeq.m_iNumFrames + 1;

imwrite(a2iFrame,strctSeq.m_strTmpFile,'jpeg','Quality',strctSeq.m_iQuality);
hFileIDtmp = fopen(strctSeq.m_strTmpFile,'rb');
aiJPGBuffer = fread(hFileIDtmp,inf,'uchar=>uchar');
fclose(hFileIDtmp);

% First, write image size
fwrite(strctSeq.m_hFileID,4+length(aiJPGBuffer),'uint32'); %4 for timestamp info
fwrite(strctSeq.m_hFileID,aiJPGBuffer,'uchar');
fwrite(strctSeq.m_hFileID,iTimeStampA,'uint32');
fwrite(strctSeq.m_hFileID,iTimeStampB,'uint16');
fwrite(strctSeq.m_hFileID,zeros(1,10,'uint8'),'uint8');

return;
