function [abHeadTailSwap, abNeitherHeadTail, abUnknown] = fnIsHeadTailSwap(astrctTrackersPos_Viterbi,astrctTrackersPos_GT,strctGT,aiCorrectPerm)
%
if isfield(strctGT.astrctGT(iKeyFrameIndex), 'm_abNeitherHeadTail') && ~isempty(strctGT.astrctGT(iKeyFrameIndex).m_abNeitherHeadTail)
   abUnknown = strctGT.m_abNeitherHeadTail;
else
   abUnknown = false(size(aiCorrectPerm));
end
theta1 = [astrctTrackersPos_Viterbi.m_fTheta];
theta1 = theta1(a2iCorrectPerm);
theta0 = [astrctTrackersPos_GT.m_fTheta];
d = mod(theta1 - theta0, 2*pi);
abHeadTailAlign = ~abUnknown & (d<pi/4 | d>7*pi/4);
abHeadTailSwap = ~abUnknown & (d>3*pi/4 & d<5*pi/4);
abNeitherHeadTail = ~abUnknown & ~abNeitherHeadTail & ~abHeadTailAlign;
