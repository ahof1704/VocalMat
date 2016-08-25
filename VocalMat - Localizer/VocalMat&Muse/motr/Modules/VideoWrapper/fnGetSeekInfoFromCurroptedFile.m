function [aiSeekPos, afTime, aiSize] = fnGetSeekInfoFromCurroptedFile(strFileName)
try
    I = parsejpg8(strFileName, 1028);
    aiSize = size(I);
catch
    assert(false);
end;
strctTmp = dir(strFileName);

iFileSize = strctTmp.bytes;

iMaxFrames = 1e8;

aiSeekPos = zeros(1,iMaxFrames);
afTime = zeros(1,iMaxFrames);
hFileID = fopen(strFileName);
fseek(hFileID, 0,'bof');
aiSeekPos(1) = 1024;
if fnNewSEQFileType(strFileName)
    iOffset = 8;
else
    iOffset = 16;
end
for iIter = 0:iMaxFrames
        if mod(iIter,10000) == 0
            fprintf('Passed frame %d\n',iIter);
        end;
        
        if aiSeekPos(iIter+1)+4 > iFileSize
            break;
        end;
        fseek(hFileID,aiSeekPos(iIter+1),'bof');
        iCurrImageSizeBytes = fread(hFileID,1,'uint32');
        
        if aiSeekPos(iIter+1)+4+iCurrImageSizeBytes+2 > iFileSize
            break;
        end;
            
        fseek(hFileID,iCurrImageSizeBytes-4,'cof');
        A = fread(hFileID,1,'uint32');
        B = fread(hFileID,1,'uint16');
        afTime(iIter+1) =  double(A)+ double(B)/1000;
        aiSeekPos(iIter+2) = aiSeekPos(iIter+1) + iCurrImageSizeBytes + iOffset;
end;
aiSeekPos = aiSeekPos(1:iIter);
afTime = afTime(1:iIter);
aiSeekPos = aiSeekPos + 4; % Skip image size and go directly to the JPG header.

fprintf('Done!\n');
fclose(hFileID);
return;
% Good frames start at: (i.e., JPG header starts at)
%        1028       54724      108533      162204      215860      269365      323041      376698      430494      484141      537913      591698      645274      698967      752774      806425      859967      913645      967338

% 54732

% 
% warning off
% aiOK  = [];
% for k=1:1000000
%     fprintf('%d ',k);
%     try
%         X = parsejpg8(strFileName, k);
%         aiOK =[aiOK,k];
%         fprintf('Worked!\n');
%     catch
%         fprintf('Failed!\n');
%     end
%     
% end



function bNewFileType = fnNewSEQFileType(strFileName)
% The direct method.. try to parse the JPG header.
% if it fails, it means we jumped too much!
hFileID = fopen(strFileName);
fseek(hFileID,1024,'bof');
iFirstFrameSizeInBytes = fread(hFileID,1,'uint32');
fseek(hFileID,iFirstFrameSizeInBytes-4,'cof');
iADummy = fread(hFileID,1,'uint32'); % Read time stamp...
iBDummy = fread(hFileID,1,'uint16'); % Read time stamp...
iNextPositionNewFile = 1028 +iFirstFrameSizeInBytes + 8;
try
    X = parsejpg8(strFileName, iNextPositionNewFile);
    bNewFileType = true;
catch
    bNewFileType = false;
end

fclose(hFileID);
return;