function [aiSeekPos, afTimestamp, aiSize] = fnFixSeqHeader(strInputFile)
% Warning, this will OVERWRITE the header!
% Assume gray scale images taken at 30 Hz...

%% This scripts fixes the header of a corrupted seq file.
%[strFile,strPath]=uigetfile('*.seq');
%strInputFile = [strPath,strFile];

[aiSeekPos, afTimestamp, aiSize] = fnGetSeekInfoFromCurroptedFile(strInputFile);
hFileID = fopen(strInputFile,'r+');
%%
strctInfo.m_iWidth = aiSize(2);
strctInfo.m_iHeight = aiSize(1);
strctInfo.m_iImageBitDepth = 8;
strctInfo.m_iImageBitDepthReal = 8;
strctInfo.m_iImageSizeBytes = strctInfo.m_iWidth * strctInfo.m_iHeight;
strctInfo.m_iTrueImageSize = strctInfo.m_iWidth * strctInfo.m_iHeight + 8;
strctInfo.m_iSeqiVersion = 3;
strctInfo.m_fFPS = 30; % assume 30 Hz


%%
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
fwrite(hFileID,length(aiSeekPos),'uint32');
fwrite(hFileID,0,'uint32');
fwrite(hFileID,strctInfo.m_iTrueImageSize,'uint32');
fwrite(hFileID,strctInfo.m_fFPS,'float64');
fclose(hFileID);
fprintf('Done!\n');

% Also, generate the corresponding mat file...
[strPath, strFileName, strExt] = fileparts(strInputFile);
if isunix || ismac
    strSeekFilename = [strPath,'/',strFileName,'.mat'];
else
    strSeekFilename = [strPath,'\',strFileName,'.mat'];
end;
strSeqFileName = strInputFile;
save(strSeekFilename,'strSeqFileName','aiSeekPos','afTimestamp');

return;
