function [a2strctEllipseGT,iFrameGT]= ...
  fnEllipsesGTFromStrctBackground(strctBackground)

astrctTuningEllipses=strctBackground.m_astrctTuningEllipses;
iFrame=[astrctTuningEllipses.m_iFrame];
bValid=[astrctTuningEllipses.m_bValid];

iNumFrames=length(iFrame);
iNumMice=length(astrctTuningEllipses(1).m_astrctEllipse);

iFrameGT=iFrame(bValid);
a2strctEllipseGT=struct('m_fX',cell(iNumMice,iNumFrames), ...
                        'm_fY',cell(iNumMice,iNumFrames), ...
                        'm_fA',cell(iNumMice,iNumFrames), ...
                        'm_fB',cell(iNumMice,iNumFrames), ...
                        'm_fTheta',cell(iNumMice,iNumFrames));
for j=1:iNumFrames
  for i=1:iNumMice
    astrctEllipseThis=astrctTuningEllipses(j).m_astrctEllipse;
    a2strctEllipseGT(i,j)=astrctEllipseThis(i);
  end
end
a2strctEllipseGT=a2strctEllipseGT(:,bValid);

end
