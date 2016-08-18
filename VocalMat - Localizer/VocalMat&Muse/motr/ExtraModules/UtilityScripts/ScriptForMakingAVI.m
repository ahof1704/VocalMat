strctMovInfo = fnReadVideoInfo('M:\ExpE\b6_pop_cage_13_07.02.10_09.58.25.734.seq');

strAviFileName = 'MovieSnippet1.avi';

aviobj = avifile(strAviFileName,'Compression','None'); % I would advise on replacing None with 'xvid' after installing 
                                                  % http://www.koepi.info/Xvid-1.2.2-07062009.exe
 
iStartFrame = 1000;
iEndFrame = 1050;
aiFrames = iStartFrame:iEndFrame;
aiOutputSize = [480 640  3];

for iFrameIter=1:length(aiFrames)
    a2iFrame = fnReadFramesFromSeq(strctMovInfo,aiFrames(iFrameIter));
    fig=figure(1);
    clf;
    imshow(a2iFrame);
    hold on;
    % draw whatever you want on the frame here.
    
    %
    drawnow
    F = getframe(fig);
    OutputFrame = zeros(aiOutputSize,'uint8');
    for k=1:3
        OutputFrame(:,:,k) = uint8(imresize(double(F.cdata(:,:,k))/255, aiOutputSize(1:2))*255);
    end
    F.cdata = OutputFrame;
    aviobj = addframe(aviobj,F);
end
 aviobj = close(aviobj);
 