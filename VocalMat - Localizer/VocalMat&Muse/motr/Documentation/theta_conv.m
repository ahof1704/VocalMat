figure(1);
clf;

afTheta = [0, pi/2, pi, 3*pi/2];
for k=1:4
    strctTracker.m_fX = 0;
    strctTracker.m_fY = 0;
    strctTracker.m_fA = 20;
    strctTracker.m_fB = 10;
    strctTracker.m_fTheta = afTheta(k);
    subplot(2,2,k);
    hold on;
    fnDrawTracker(gca,strctTracker, 'r', 2,false);
    axis equal
    title(num2str(afTheta(k)/pi*180));
   % axis ij
end
