function fnCropSEQ(strInputFile, strOutputFile,iJPGQuality, aiCropInterval)
strctInfo = fnReadSeqInfo(strInputFile);

hFileID = fopen(strOutputFile,'wb');
fwrite(hFileID, zeros(1,1024), 'uchar'); % Write empty header
strTmpFile = [tempname,'.jpg'];

for iFrameIter=aiCropInterval
    if mod(iFrameIter,100) == 0
        fprintf('Writing Frame %d\n',iFrameIter);
        drawnow
    end;
    a2iFrame = fnReadFrameFromSeq(strctInfo,iFrameIter);
    imwrite(a2iFrame,strTmpFile,'jpeg','Quality',iJPGQuality);
    hFileIDtmp = fopen(strTmpFile,'rb');
    aiJPGBuffer = fread(hFileIDtmp,inf,'uchar=>uchar');
    fclose(hFileIDtmp);
    
    % First, write image size
    fwrite(hFileID,4+length(aiJPGBuffer),'uint32'); %4 for timestamp info
    fwrite(hFileID,aiJPGBuffer,'uchar'); 
    A=floor(strctInfo.m_afTimestamp(iFrameIter)); 
    B=floor(mod(strctInfo.m_afTimestamp(iFrameIter),1)*1000);
    fwrite(hFileID,   A, 'uint32');
    fwrite(hFileID, B ,'uint16');
    fwrite(hFileID,zeros(1,10,'uint8'),'uint8'); 
end;
% Seek to start and write header.
fseek(hFileID,0,'bof');

fwrite(hFileID,uint32(65261),'uint32');
fwrite(hFileID,uint16([78,111,114,112,105,120,32,115,101,113,0,0]),'uint16');

% next 8 bytes for version and header size (1024), then 512 for descr
fwrite(hFileID,int32(strctInfo.m_iSeqiVersion),'int32');
fwrite(hFileID,uint32(1024),'uint32');
fwrite(hFileID,zeros(1,512,'uint8'),'uint8');
fwrite(hFileID,strctInfo.m_iWidth,'uint32');
fwrite(hFileID,strctInfo.m_iHeight,'uint32');
fwrite(hFileID,strctInfo.m_iImageBitDepth,'uint32');
fwrite(hFileID,strctInfo.m_iImageBitDepthReal,'uint32');
fwrite(hFileID,strctInfo.m_iImageSizeBytes,'uint32');
fwrite(hFileID,102,'uint32'); % Compressed JPG
fwrite(hFileID,length(aiCropInterval),'uint32');
fwrite(hFileID,0,'uint32');
fwrite(hFileID,strctInfo.m_iTrueImageSize,'uint32');
fwrite(hFileID,strctInfo.m_fFPS,'float64');
fclose(hFileID);
fprintf('Done!\n');

