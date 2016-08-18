function showFrame(iFrame, strctMovInfo, astrctTrackers, strctHeadPos, aMiceInd, iChosenInd)
%
if nargin<5
    aMiceInd = 1:length(strctHeadPos);
end
if nargin<6
    iChosenInd = 0;
end
a2iFrame = fnReadFrameFromVideo(strctMovInfo, iFrame);
figure(1); clf;
imshow(a2iFrame,[]);
hAxes = gca;
hold on;
title(['frame ' num2str(iFrame)]);
iChosenMouse = 0;
if iChosenInd>0
    iChosenMouse = aMiceInd(iChosenInd);
end
fnDrawTrackers4(astrctTrackers, iFrame, hAxes, iChosenMouse);
if aMiceInd(1)>0
    X =  astrctTrackers(aMiceInd(1)).m_afX(iFrame);
    Y =  astrctTrackers(aMiceInd(1)).m_afY(iFrame);
    plot(X, Y, 'xg');
end
if size(aMiceInd, 2)>1 && aMiceInd(2)>0
    X =  astrctTrackers(aMiceInd(2)).m_afX(iFrame);
    Y =  astrctTrackers(aMiceInd(2)).m_afY(iFrame);
    plot(X, Y, 'or');
end
if size(aMiceInd, 2)>2 && aMiceInd(3)>0
    X =  astrctTrackers(aMiceInd(3)).m_afX(iFrame);
    Y =  astrctTrackers(aMiceInd(3)).m_afY(iFrame);
    plot(X, Y, 'sy');
end

i = find(aMiceInd>0);
for j=1:length(i)
    iMouseIndex = aMiceInd(i(j));
    X =  astrctTrackers(iMouseIndex).m_afX(iFrame);
    Y =  astrctTrackers(iMouseIndex).m_afY(iFrame);
    plot(X, Y, '+b');
    plot(strctHeadPos(iMouseIndex).x(iFrame), strctHeadPos(iMouseIndex).y(iFrame), '+r');
end
hold off
