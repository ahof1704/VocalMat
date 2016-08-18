function fnCloseSeq(strctSeq)
strctInfo.m_iSeqiVersion = 3;
strctInfo.m_iImageBitDepth = 8;
strctInfo.m_iImageBitDepthReal = 8;
strctInfo.m_iImageSizeBytes = strctSeq.m_iWidth * strctSeq.m_iHeight;
strctInfo.m_iImageFormat = 102;
strctInfo.m_iTrueImageSize = strctSeq.m_iWidth * strctSeq.m_iHeight;

% Seek to start and write header.
fseek(strctSeq.m_hFileID,0,'bof');

fwrite(strctSeq.m_hFileID,uint32(65261),'uint32');
fwrite(strctSeq.m_hFileID,uint16([78,111,114,112,105,120,32,115,101,113,0,0]),'uint16');

% next 8 bytes for version and header size (1024), then 512 for descr
fwrite(strctSeq.m_hFileID,int32(strctInfo.m_iSeqiVersion),'int32');
fwrite(strctSeq.m_hFileID,uint32(1024),'uint32');
fwrite(strctSeq.m_hFileID,zeros(1,512,'uint8'),'uint8');
fwrite(strctSeq.m_hFileID,strctSeq.m_iWidth,'uint32');
fwrite(strctSeq.m_hFileID,strctSeq.m_iHeight,'uint32');
fwrite(strctSeq.m_hFileID,strctInfo.m_iImageBitDepth,'uint32');
fwrite(strctSeq.m_hFileID,strctInfo.m_iImageBitDepthReal,'uint32');
fwrite(strctSeq.m_hFileID,strctInfo.m_iImageSizeBytes,'uint32');
fwrite(strctSeq.m_hFileID,102,'uint32'); % Compressed JPG
fwrite(strctSeq.m_hFileID,strctSeq.m_iNumFrames,'uint32');
fwrite(strctSeq.m_hFileID,0,'uint32');
fwrite(strctSeq.m_hFileID,strctInfo.m_iTrueImageSize,'uint32');
fwrite(strctSeq.m_hFileID,strctSeq.m_fFPS,'float64');
fclose(strctSeq.m_hFileID);
fprintf('Done!\n');
