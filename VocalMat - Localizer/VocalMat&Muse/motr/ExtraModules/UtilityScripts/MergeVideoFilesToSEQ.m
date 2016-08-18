strOutput = 'C:\Users\Shay\Documents\Data\Janelia Farm\Movies\NewSetup\pera_mf_081107_A_lowrez_compressed.seq';
strctSeq = fnOpenSeqForWriting(strOutput,30,80);

for iFileIter=0:4
    strctAVI = fnReadVideoInfo(['C:\Users\Shay\Documents\Data\Janelia Farm\Movies\NewSetup\pera_mf_081107_A_lowrez_compressed_Part.0',num2str(iFileIter),'.avi']);

    for k=1:strctAVI.m_iNumFrames
        fprintf('Writing frame %d,%d\n',iFileIter,k);
        a2iFrame = fnReadFrameFromVideo(strctAVI,k);
        strctSeq = fnWriteSeqFrame(strctSeq, a2iFrame);
    end;
end;
fnCloseSeq(strctSeq);



strctInfo = fnReadVideoInfo(strOutput);