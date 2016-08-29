function Mov=fnMovieText(acText, iNumSecFadeIn, iNumSecAppear,iNumSecFadeout,Mov,MovieOutputSize)
FPS = 30;
h=gca;
set(h,'Color',[0 0 0])
   hold off;

for k=linspace(0,1,iNumSecFadeIn*FPS)
     for j=1:size(acText,1)
        text(acText{j,1}, acText{j,2}, acText{j,4},'Color',[k k k],'FontSize',acText{j,3})
    end;
    drawnow

    if ~isempty(Mov)
        M=getframe(gcf);
        a2fOutputFrame = imresize(M.cdata, MovieOutputSize,'bilinear');
        M.cdata = a2fOutputFrame;
        Mov = addframe(Mov,M);
    end
end;
%M=getframe;
%a2fOutputFrame = imresize(M.cdata, MovieOutputSize,'bilinear');
for j=1:size(acText,1)
    text(acText{j,1}, acText{j,2}, acText{j,4},'Color',[1 1 1],'FontSize',acText{j,3})
end;
drawnow
M=getframe(gcf);
a2fOutputFrame = imresize(M.cdata, MovieOutputSize,'bilinear');
M.cdata = a2fOutputFrame;

for k=1:iNumSecAppear*FPS
    if ~isempty(Mov)
        Mov = addframe(Mov,M);
    end
end;
for k=linspace(1,0,iNumSecFadeout*FPS)
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
