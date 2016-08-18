function astrctTuningEllipses= ...
  fnConvertSegmentationGTToRepositoryFormat(a2strctGTTuningEllipses, ...
                                            iGTTuningFrame)

% Convert one format of segmentation ground-truth data to another.
% a2strctGTTuningEllipses is a iNumMice x iNumFrames struct array with
% the usual ellipse fields.  iGTTuningFrame is a 1 x iNumFrames array
% holding the absolute index of each frame for which ellipses are given
% (one-based).
% On exit, astrctTuningEllipses is a 1 x iNumFrames structure array with
% fields m_bValid, m_iFrame, and m_astrctEllipse, suitable for use with
% the bulk of Repository/MouseHouse code.
% astrctTuningEllipse(i).m_bValid==true for all i.
                                          
[iNumMice,iNumFrames]=size(a2strctGTTuningEllipses);  %#ok
astrctTuningEllipses=struct('m_bValid',cell(1,iNumFrames), ...
                            'm_iFrame',cell(1,iNumFrames), ...
                            'm_astrctEllipse',cell(1,iNumFrames));
for i=1:iNumFrames
  astrctTuningEllipses(i).m_bValid=true;
  astrctTuningEllipses(i).m_iFrame=iGTTuningFrame(i);
  astrctTuningEllipses(i).m_astrctEllipse=a2strctGTTuningEllipses(:,i);
end

end

