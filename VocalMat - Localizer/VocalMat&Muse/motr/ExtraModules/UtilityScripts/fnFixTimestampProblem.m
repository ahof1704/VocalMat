% Fix timestamp
strMov = 'D:\Data\Janelia Farm\Movies\SeqFiles\10.04.19.390_MergeTestSeq.seq';
strctTmp = fnReadVideoInfo(strMov);

strMat = [strMov(1:end-4),'.mat'];
load(strMat);
afTimestamp = 0:1/strctTmp.m_fFps: (strctTmp.m_iNumFrames-1)*(1/strctTmp.m_fFps);
save(strMat,'strSeqFileName','aiSeekPos','afTimestamp');


