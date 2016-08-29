function afPredError = fnPredictionError(astrctOptEllipses, astrctPred)

aiAssignment = fnMatchJobToPrevFrame(astrctPred, astrctOptEllipses);
astrctOptEllipses(aiAssignment(1,:)) = astrctOptEllipses(aiAssignment(2,:));

iNumMice = length(astrctPred);
afPredError = zeros(1,iNumMice);
for iMouseIter=1:iNumMice
    dX = astrctOptEllipses(iMouseIter).m_fX - astrctPred(iMouseIter).m_fX;
    dY = astrctOptEllipses(iMouseIter).m_fY - astrctPred(iMouseIter).m_fY;    
    
    dA = astrctOptEllipses(iMouseIter).m_fA - astrctPred(iMouseIter).m_fA;
    dB = astrctOptEllipses(iMouseIter).m_fB - astrctPred(iMouseIter).m_fB;    
    
    dTheta = acos( cos(astrctOptEllipses(iMouseIter).m_fTheta)* cos(astrctPred(iMouseIter).m_fTheta) + ...
                   sin(astrctOptEllipses(iMouseIter).m_fTheta)* sin(astrctPred(iMouseIter).m_fTheta));

    dTheta = min(abs(pi-dTheta),dTheta) / pi * 180;

    dPos = sqrt(dX.^2+dY.^2);
    dSize = sqrt(dA.^2+dB.^2);
% Now, combine 'em all....
    %afPredError(iMouseIter) = ((1-exp(-dPos^2/20^2)) + (1-exp(-dSize^2/10^2)) + (1-exp(-dTheta^2/70^2)))/3;
    afPredError(iMouseIter) = max([1-exp(-dPos^2/20^2),1-exp(-dSize^2/10^2),1-exp(-dTheta^2/70^2)]);
end;

return;

%
figure(12);
clf;
hold on;
fnDrawTrackers(astrctPred)
axis equal
axis ij
fnDrawTrackers(astrctOptEllipses)

% 
% % Error measures.
% figure(11);
% clf;
% subplot(3,1,1);
% X = linspace(0,40);
% plot(X, 1-exp(-X.^2/20^2));
% title('Position');
% 
% 
% subplot(3,1,2);
% X = linspace(0,20);
% plot(X, 1-exp(-X.^2/10^2));
% title('Size');
% 
% subplot(3,1,3);
% X = linspace(0,90);
% plot(X, 1-exp(-X.^2/70^2));
% title('Orienation');
% 
