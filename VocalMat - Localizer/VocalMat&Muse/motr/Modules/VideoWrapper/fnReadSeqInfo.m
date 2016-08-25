function strctMovInfo = fnReadSeqInfo(strSeqFileName,forceNoMetadata)
% Credits go for Poitr Dollar for the initial code of reading the SEQ
% files.
% forceNoMetaData, if true, means the resulting strctMovInfo structure says
% that both the per-file and per-frame metadata is of length zero.  This
% may be useful for reading Streampix 5.19+ files when the built-in
% heuristics fail.

% Deal with optional arguments
if ~exist('forceNoMetadata','var') || isempty(forceNoMetadata)
  forceNoMetadata=false;
end 
  
hFileID = fopen(strSeqFileName);
fseek(hFileID,0,'bof');
% first 4 bytes store OxFEED, next 24 store 'Norpix seq  '
if ~(strcmp(sprintf('%X',fread(hFileID,1,'uint32')),'FEED'))
    % Attempt to fix SEQ header.
    fclose(hFileID);
    error('Header is corrupted for file %s!\n', strSeqFileName);
%     strResponse = input('Do you want to fix the file [Y]/[N]? : ','s');
%     bFix = strResponse(1) == 'Y' || strResponse(1) == 'y';
%     if bFix
%         fnFixSeqHeader(strSeqFileName); 
%         hFileID = fopen(strSeqFileName);
%         fseek(hFileID,0,'bof');
%         assert(strcmp(sprintf('%X',fread(hFileID,1,'uint32')),'FEED'));
%     else
%         strctMovInfo = [];
%         return;
%     end;
end;
assert(strcmp(char(fread(hFileID,10,'uint16'))','Norpix seq')); %#ok<FREAD>
fseek(hFileID,4,'cof');
% next 8 bytes for version and header size (1024), then 512 for descr
iVersion=fread(hFileID,1,'int32'); 
assert(fread(hFileID,1,'uint32')==1024);
fseek(hFileID,512,'cof');
% read in more strctMovInfo
iWidth=fread(hFileID,1,'uint32'); 
iHeight=fread(hFileID,1,'uint32'); 
iImageBitDepth=fread(hFileID,1,'uint32'); 
iImageBitDepthReal=fread(hFileID,1,'uint32'); 
iImageSizeBytes=fread(hFileID,1,'uint32'); 
iImageFormatRaw=fread(hFileID,1,'uint32'); 
iNumFrames=fread(hFileID,1,'uint32'); 
fread(hFileID,1,'uint32');  % skip one field
iTrueImageSize=fread(hFileID,1,'uint32');  
  % for uncompressed frames, the number of bytes between image starts
  % ignored for compressed frames
fps = fread(hFileID,1,'float64');

% version 4 of the .seq format separated information about type of image
% in the frames from information about how they're compressed.  Sort that
% out
if iVersion>=4
  iImageFormat=iImageFormatRaw;
    % 100 == monochrome
    % 200 == BGR compressed
  % go look at the the compression format, stored separately
  fseek(hFileID,620,'bof');
  iCompressionFormat=fread(hFileID,1,'uint32');
  % 0 == uncompressed
  % 1 == JPEG compressed
else
  switch iImageFormatRaw
    case 100,
      % monochrome, uncompressed
      iImageFormat=100;  % monochrome
      iCompressionFormat=0;  % uncompressed
    case 102,
      % monochrome, jpeg compression
      iImageFormat=100;  % monochrome
      iCompressionFormat=1;  % jpeg compressed
    case 200,
      % BGR color, uncompressed
      iImageFormat=200;  % BGR color
      iCompressionFormat=0;  % uncompressed
    case 201,
      % BGR color, jpeg compression
      iImageFormat=200;  % BGR color
      iCompressionFormat=1;  % jpeg compressed
    otherwise
      error('Motr:unhandledImageFormat', ...
            'SEQ file is in a format that Motr can''t handle');
  end
end

% determine file and frame metadata size
if forceNoMetadata
  iFrameMetadataSize=0;
  iFileMetadataSize=0;    
else
  if iVersion>=4
    fseek(hFileID,640,'bof');
    iFrameMetadataSize=fread(hFileID,1,'uint32');
    iFileMetadataSize=fread(hFileID,1,'uint32');
    % This is a hack to deal with files produced by Streampix v5.19
    % Streampix 5.16-5.18 included metadata in the .seq file, but this was 
    % removed in 5.19.  And there's no good way to determine what kind of
    % .seq file you're dealing with (all of them say they're version 4).
    % Daniel Wang at Norpix suggested the heuristic below.
    if iFrameMetadataSize>=2^31
      % Probably a 5.19+ file
      %warning('iFrameMetadataSize is %d, which is crazy.  Assuming this is a Streampix 5.19+ .seq file.',iFrameMetadataSize);
      iFrameMetadataSize=0;
      iFileMetadataSize=0;    
    end
  else
    iFrameMetadataSize=0;
    iFileMetadataSize=0;
  end
end

% store strctMovInformation in strctMovInfo struct
strctMovInfo=struct( 'm_strFileName', strSeqFileName,...
                     'm_iWidth',iWidth, ...
                     'm_iHeight',iHeight, ...
                     'm_iImageBitDepth',iImageBitDepth, ...
                     'm_iImageBitDepthReal',iImageBitDepthReal, ...
                     'm_iImageSizeBytes',iImageSizeBytes, ...
                     'm_iImageFormat',iImageFormat, ...
                     'm_iCompressionFormat',iCompressionFormat, ...
                     'm_iNumFrames',iNumFrames, ...
                     'm_iTrueImageSize', iTrueImageSize,...
                     'm_fFPS',fps, ...
                     'm_iSeqiVersion',iVersion, ...
                     'm_iFileMetadataSize',iFileMetadataSize, ...
                     'm_iFrameMetadataSize',iFrameMetadataSize);
fclose(hFileID);

% Automatically generate seeking strctMovInfo if not exist
% [strPath, strFileName] = fileparts(strSeqFileName);
% if isunix || ismac
%     strSeekFilename = [strPath,'/',strFileName,'.mat'];
% else
%     if length(strPath) == 3 && strPath(3) == '\'
%         strSeekFilename = [strPath,strFileName,'.mat'];
%     else
%         strSeekFilename = [strPath,'\',strFileName,'.mat'];
%     end
% end;
[strPath, strBaseName] = fileparts(strSeqFileName);
strSeekFileName=fullfile(strPath,[strBaseName '.mat']);
if exist(strSeekFileName,'file')
%if false
    % load the frame index from the pre-existing file
    strctTmp = load(strSeekFileName);
    strctMovInfo.m_aiSeekPos = strctTmp.aiSeekPos;
    strctMovInfo.m_afTimestamp = strctTmp.afTimestamp;
else
    % generate an index, save it to file
    [aiSeekPos, afTimestamp] = ...
        fnGenerateSeqSeekInfo(strctMovInfo,strctMovInfo.m_iNumFrames);
    strctMovInfo.m_aiSeekPos = aiSeekPos;
    strctMovInfo.m_afTimestamp = afTimestamp;
    save(strSeekFileName,'strSeqFileName','aiSeekPos','afTimestamp');
end

% hack for some .seq files that inexplicably have their FPS value set to inf
if ~isfinite(strctMovInfo.m_fFPS) && all(isfinite(strctMovInfo.m_afTimestamp))
  strctMovInfo.m_fFPS=1/mean(diff(strctMovInfo.m_afTimestamp));
end

return


function [aiSeekPos, afTimestamp] = fnGenerateSeqSeekInfo(strctMovInfo, iNumFrames)
aiFrameOffset = zeros(1, iNumFrames);
  % The offset of each frame within the file.  Note that this is the offset
  % of the 4-byte frame header that gives info about how long the frame
  % is.  For JPEG-compressed files, this is _not_ the offset of the frame 
  % data itself.
afTimestamp = zeros(1, iNumFrames);

hFileID = fopen(strctMovInfo.m_strFileName);
%fseek(hFileID, aiSeekPos(1),'bof');
if iNumFrames > 1000
    fprintf('Generating seek info for %d frames, please wait...\n', iNumFrames);
end;

if ( strctMovInfo.m_iCompressionFormat == 0 && ...
     (strctMovInfo.m_iImageFormat == 100 || strctMovInfo.m_iImageFormat == 200) )
    % uncompressed, and either monochrome or BGR color
    aiFrameOffset = 1024 + strctMovInfo.m_iFileMetadataSize + ...
                (0:iNumFrames)*strctMovInfo.m_iTrueImageSize;
    % Read timestamp info...
    for iIter = 0:iNumFrames-1
        fseek(hFileID,1024+iIter*strctMovInfo.m_iTrueImageSize+strctMovInfo.m_iImageSizeBytes,'bof');
        iA = fread(hFileID,1,'uint32');
        iB = fread(hFileID,1,'uint16');
        afTimestamp(iIter+1) =  double(iA)+ double(iB)/1000;
    end
    aiSeekPos=aiFrameOffset;  % for uncompressed frames, there is no frame header
elseif  ( strctMovInfo.m_iCompressionFormat == 1 && ...
          (strctMovInfo.m_iImageFormat == 100 || strctMovInfo.m_iImageFormat == 200) )
    % jpeg compressed, and either monochrome or BGR color
    aiFrameOffset(1) = 1024 + strctMovInfo.m_iFileMetadataSize;
    iFrameFooterLength = fnJpegSeqFrameFooterSize(strctMovInfo);
    % Compressed seq
    for iIter = 0:iNumFrames-1
        if mod(iIter,10000) == 0
            fprintf('Passed frame %d\n',iIter);
        end;
        fseek(hFileID,aiFrameOffset(iIter+1),'bof');
        iCurrImageSizeBytes = fread(hFileID,1,'uint32')-4;
          % read the frame header, which contains the length of the frame
          % data.  N.B.: On disk, this includes the length of the frame header (4
          % bytes).  The JPEG frame data itself is shorter by 4 bytes, so 
          % we subtract 4.
        if isempty(iCurrImageSizeBytes)
            aiFrameOffset = aiFrameOffset(1:iIter-1);
            afTimestamp = afTimestamp(1:iIter-1);
            aiSeekPos = aiFrameOffset + 4; 
            return;
        end
        fseek(hFileID,iCurrImageSizeBytes,'cof');  % skip the image data
        iA = fread(hFileID,1,'uint32');  % seconds part of frame timestamp
        iB = fread(hFileID,1,'uint16');  % milliseonds part of frame timestamp
        if isempty(iB) || isempty(iA)
            aiFrameOffset = aiFrameOffset(1:iIter-1);
            afTimestamp = afTimestamp(1:iIter-1);
            aiSeekPos = aiFrameOffset + 4; 
            return;
        end
        afTimestamp(iIter+1) =  double(iA)+ double(iB)/1000;
        if iIter ~= iNumFrames-1
            aiFrameOffset(iIter+2) = ...
                aiFrameOffset(iIter+1) + 4 + iCurrImageSizeBytes + ...
                iFrameFooterLength + strctMovInfo.m_iFrameMetadataSize;
        end
    end
        
    aiSeekPos = aiFrameOffset + 4; 
      % We want the index to be the start of the frame data proper,
      % skipping the 4-byte frame header
else
    error('motr:cantReadThisFlavorOfSeq', ...
          sprintf('Unable to read a .seq file with this imageFormat (%d) and this compressionFormat (%d)', ...
                  strctMovInfo.m_iImageFormat,strctMovInfo.m_iCompressionFormat));  %#ok
end
fprintf('Done!\n');
fclose(hFileID);
return;



% function bNewFileType = fnNewSEQFileType(strFileName)
% % The direct method.. try to parse the JPG header.
% % if it fails, it means we jumped too much!
% hFileID = fopen(strFileName);
% fseek(hFileID,1024,'bof');
% iFirstFrameSizeInBytes = fread(hFileID,1,'uint32')-4;
% %fseek(hFileID,iFirstFrameSizeInBytes,'cof');
% %iADummy = fread(hFileID,1,'uint32'); % Read time stamp...
% %iBDummy = fread(hFileID,1,'uint16'); % Read time stamp...
% iNextPositionNewFile = 1028 + iFirstFrameSizeInBytes + 4 + 8;
% try
%     X = parsejpg8(strFileName, iNextPositionNewFile);
%     bNewFileType = true;
% catch
%     bNewFileType = false;
% end
% 
% fclose(hFileID);
% return;



function iFrameFooterSize = fnJpegSeqFrameFooterSize(strctMovInfo)
% Try to empirically determine the size of the frame footer in a JPEG .seq
% file.  Try the two likely options, and see if either hypothesis gets you 
% to a file offset where there's a readable JPEG frame.
strFileName=strctMovInfo.m_strFileName;
iFileMetadataSize=strctMovInfo.m_iFileMetadataSize;
iFrameMetadataSize=strctMovInfo.m_iFrameMetadataSize;
hFileID = fopen(strFileName);
fseek(hFileID,1024+iFileMetadataSize,'bof');
iFirstFrameSizeInBytes = fread(hFileID,1,'uint32')-4;
  % iFirstFrameSizeInBytes is the size of just the JPEG frame data,
  % not including the frame header
fclose(hFileID);
iFrameFooterSize=8;  
  % the frame footer contains an 8-byte timestamp, plus sometimes 8 bytes
  % of reserved storage.  Daniel Wang at Norpix claims that v3 .seg files
  % have no reserved storage, and v4 files have 8 bytes of reserved
  % storage.  But code to determine the frame footer size emprically was
  % already in MouseHouse/Motr before v4 came about.  So a) I'm not sure I
  % beleive Daniel, and b) I don't know whether v1 and v2 .seq have this
  % reserved storage or not.
iNextFrameJpegOffset = ...
    1024 + 4 + iFirstFrameSizeInBytes + iFrameFooterSize + ...
    iFrameMetadataSize + 4;
try
    % parsejpg8() will throw an error if there's no JPEG stream at this offset
    parsejpg8(strFileName, iNextFrameJpegOffset);
    % if we get here, iFrameFooterSize==8 works, so we return
    return;
catch excp
    iFrameFooterSize=16;
    iNextFrameJpegOffset = ...
        1024 + 4 + iFirstFrameSizeInBytes + iFrameFooterSize + ...
        iFrameMetadataSize + 4;
    try
        % parsejpg8() will throw an error if there's no JPEG stream at this offset
        parsejpg8(strFileName, iNextFrameJpegOffset);
        % if we get here, iFrameFooterSize==16 works, so we return
        return;
    catch excpTheSecond
        error('Motr:unableToDetermineJpegSeqFooterSize', ...
              'Unable to determine size of JPEG .seq footer');
    end
end

return
