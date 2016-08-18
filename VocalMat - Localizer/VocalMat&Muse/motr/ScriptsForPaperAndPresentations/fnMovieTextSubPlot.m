function Mov=fnMovieTextSubPlot(acText, iNumSecFadeIn,Mov,MovieOutputSize,iSubPlot,bFadeOut)
FPS = 30;
f=figure(10);
set(f,'Color',[0 0 0]);
h=tightsubplot(2,2,iSubPlot);
set(h,'Color',[0 0 0]);

if bFadeOut
    afTmp = linspace(1,0,iNumSecFadeIn*FPS);
else
    afTmp = linspace(0,1,iNumSecFadeIn*FPS);
end

for k=afTmp
    %clf;

    hold off;
  %  set(f,'Position',[ 246         106        1188         854]);
 %   h=axes;
    for j=1:size(acText,1)
        text(acText{j,1}, acText{j,2}, acText{j,4},'Color',[k k k],'FontSize',acText{j,3})
    end;
    drawnow

    if ~isempty(Mov)
        M = getframe(gcf);
        a2fOutputFrame = imresize(M.cdata, MovieOutputSize,'bilinear');
        M.cdata = a2fOutputFrame;
        Mov = addframe(Mov,M);
    end
end;
