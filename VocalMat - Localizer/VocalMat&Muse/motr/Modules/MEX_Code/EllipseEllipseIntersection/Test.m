addpath('D:\Code\Janelia Farm\CurrentVersion\MEX\x64');
addpath('D:\Code\Janelia Farm\CurrentVersion\Core');
for ii=1:1000
    fprintf('%d\n',ii);
strctTmp=load(['D:\Data\Janelia Farm\NewResults\10.04.19.390\JobOut',num2str(ii),'.mat']);

X = cat(1,strctTmp.astrctTrackersJob.m_afX);
Y = cat(1,strctTmp.astrctTrackersJob.m_afY);
A = cat(1,strctTmp.astrctTrackersJob.m_afA);
B = cat(1,strctTmp.astrctTrackersJob.m_afB);
Theta = cat(1,strctTmp.astrctTrackersJob.m_afTheta);

iFrame = 1:647805;


a3bIntersections2=fnEllipseEllipseIntersectionMex(X(:,iFrame),Y(:,iFrame),...
    A(:,iFrame),B(:,iFrame),Theta(:,iFrame));
end;

a3bIntersections2=fnEllipseEllipseIntersectionMex(X,Y,A,B,Theta);

iNumFrames = size(X,2);
iNumMice = size(X,1);
a3bIntersect = zeros(iNumMice,iNumMice,iNumFrames);
for iFrameIter=1:iNumFrames
    for i=1:iNumMice
        for j=i+1:iNumMice
            a3bIntersect(i,j,iFrameIter) = fnEllipseEllipseIntersection(...
                X(i,iFrameIter),...
                Y(i,iFrameIter),...
                A(i,iFrameIter),...
                B(i,iFrameIter),...
                Theta(i,iFrameIter),...
                X(j,iFrameIter),...
                Y(j,iFrameIter),...
                A(j,iFrameIter),...
                B(j,iFrameIter),...
                Theta(j,iFrameIter));
             a3bIntersect(j,i,iFrameIter) = a3bIntersect(i,j,iFrameIter);
        end;
    end;
end;

sum( abs(double(a3bIntersect(:)) - double(a3bIntersections2(:))))


