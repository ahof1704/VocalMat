function [x, y]=fnCalcMousePOIxy(strctTracker, iMouseRank, BCparams)
%
% calculate all POI coordinates in the movie for one mouse.
%
% x = zeros(sum(BCparams.MousePOIs{iMouseRank}.aPointsNum), length(strctTracker.m_afX));
x = zeros(1, length(strctTracker.m_afX));
y = x;
%
% if iMouseRank == 1
%     x = mod(1:length(x), 100);
% else
%     x = mod(1:length(x), 100) + 50;
%     x = max(100, x);
% end
% return;
%
j = 1;
for iLeyer=1:length(BCparams.MousePOIs{iMouseRank}.aPointsNum)
    afTheta = BCparams.MousePOIs{iMouseRank}.aTheta(iLeyer) + linspace(0,2*pi,BCparams.MousePOIs{iMouseRank}.aPointsNum(iLeyer)+1);
    for i=1:BCparams.MousePOIs{iMouseRank}.aPointsNum(iLeyer)
        apt2f = BCparams.MousePOIs{iMouseRank}.aNormRadii(iLeyer) * [strctTracker.m_afA * cos(afTheta(i)); strctTracker.m_afB * sin(afTheta(i))];
        Rx = [cos(strctTracker.m_afTheta); sin(strctTracker.m_afTheta)]; 
        Ry = [-sin(strctTracker.m_afTheta); cos(strctTracker.m_afTheta)];
        x(j,:) = strctTracker.m_afX + apt2f(1,:).*Rx(1,:) + apt2f(2,:).*Rx(2,:);
        y(j,:) = strctTracker.m_afY + apt2f(1,:).*Ry(1,:) + apt2f(2,:).*Ry(2,:);
        j = j+ 1;
    end
end

