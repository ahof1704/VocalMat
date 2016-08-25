function h=proofSheet(trackFN,iClip)

% Function to make a figure showing a 'proof sheet' for a single clip.
% trackFN is the filename of a single track file.  h is the handle to a 
% 8.5 x 11 inch figure containing sample frames and other diagnostic
% information.

% deal with args
if nargin<2
  iClip=[];
end

% load the track file data
[tracker,clipFNAbs]=loadTrackFile(trackFN);
% tracker = 
%
% 1xnTracker struct array with fields:
%     m_afX
%     m_afY
%     m_afA
%     m_afB
%     m_afTheta
%
% Each field holds a 1 x nFrame single-precision array, each describing one
% component of the directed ellipse (a.k.a. direllipse).
%
% clipFNAbs is the clip file name, as an absolute path

% extract metadata, numbers of utility
nTracker=length(tracker);  % hopefully equal to number of mice
clipMetaData=fnReadSeqInfo(clipFNAbs);
nFrame=clipMetaData.m_iNumFrames;
fps=clipMetaData.m_fFPS;  % Hz
fph=60*60*fps;  % frames per hour

% get the basename, for titling
[pathStr,baseName,ext]=fileparts(trackFN);

% get the mouse colors
clr=fnGetMiceColors();

% get time origin
%t0=clipMetaData.m_afTimestamp(1);

% dimensions for figure
wPage=8.5;  % in
hPage=11;  % in
ppi=450;
nRow=5;
nCol=3;
%marginTop=0.5;  % in
wSpace=0.25;  % in
hSpace=0.25;  % in

% calc image axes origin, spacing
wImage=clipMetaData.m_iWidth/ppi;  % in
hImage=clipMetaData.m_iHeight/ppi;  % in
wGrid=wImage*nCol+wSpace*(nCol-1);
hGrid=hImage*nRow+hSpace*(nRow-1);
xGrid=(wPage-wGrid)/2;  % center in x
yGrid=(hPage-hGrid)/2;  % center in y
dxGrid=wImage+wSpace;
dyGrid=hImage+hSpace;

% make the figure
h=figure('color','w');
colormap(gray);
set_figure_size([wPage hPage]);
set(h,'name',[baseName '_proof']);

% position the axes
hFrame=zeros(nRow,nCol);
for iPlot=1:nRow
  for jPlot=1:nCol
    hFrame(iPlot,jPlot)=axes;
    posThis=[xGrid+dxGrid*(jPlot-1) yGrid+dyGrid*(nRow-iPlot) ...
             wImage hImage];  % in
    set_axes_position(posThis);
  end
end

% show one frame per four hours
fphApprox=round(fph);
iFrameAll=(1:fphApprox:nFrame)';
if length(iFrameAll)>12
  iFrameAll=iFrameAll(1:12);
end
%t=zeros(size(iFrameAll));
k=1;
for iPlot=1:nRow-1
  for jPlot=1:nCol
    iFrameThis=iFrameAll(k);
    imThis=fnReadFrameFromSeq(clipMetaData,iFrameThis);
    trackerAltThis=sliceTracker(tracker,iFrameThis);  
      % 5 x nMice, each col a direllipse
    axes(hFrame(iPlot,jPlot));
    imagesc(imThis);
    set(gca,'xtick',[]);
    set(gca,'ytick',[]);
    for j=1:nTracker
      fnDrawDirellipse(trackerAltThis(:,j),...
                       'color',clr(j,:), ...
                       'linewidth',0.5);
    end
    if iPlot==1 && jPlot==2
      if isempty(iClip)
        title(sprintf('%s.seq',baseName),'interpreter','none');
      else
        title(sprintf('Clip %02d: %s.seq',iClip,baseName), ...
              'interpreter','none');
      end
    end
%    t(k)=clipMetaData.m_afTimestamp(iFrameThis)-t0;
%     hmsThis=hmsFromTime(t(k));
%     title(sprintf('Frame %d    Time: %2d:%2d:%6.3f', ...
%                   iFrameThis,hmsThis(1),hmsThis(2),hmsThis(3)));
    k=k+1;
  end
end

%
% calculate traces that help us find tracking failures
%

% time
t=clipMetaData.m_afTimestamp-clipMetaData.m_afTimestamp(1);  % s, 1xnFrame

% position
r=zeros(2,nFrame,nTracker);
for k=1:nTracker
  r(1,:,k)=tracker(k).m_afX;
  r(2,:,k)=tracker(k).m_afY;
end

% heading*length
a=zeros(2,nFrame,nTracker);
for k=1:nTracker
  as=tracker(k).m_afA;
  theta=tracker(k).m_afTheta;
  a(1,:,k)=as.*cos(theta);
  a(2,:,k)=-as.*sin(theta);  % neg sign b/c image coords
end

% half-width
b=zeros(1,nFrame,nTracker);
for k=1:nTracker
  b(:,:,k)=tracker(k).m_afB;
end

% % plot them
% figure;
% axes;
% for k=1:nTracker
%   line(t/3600,r(1,:,k),'color',clr(k,:));
% end
% xlabel('Time (hr)');
% ylabel('x (pixels)');
% 
% % plot them
% figure;
% axes;
% for k=1:nTracker
%   line(t/3600,r(2,:,k),'color',clr(k,:));
% end
% xlabel('Time (hr)');
% ylabel('y (pixels)');
% 
% % plot them
% figure;
% axes;
% for k=1:nTracker
%   line(t/3600,a(1,:,k),'color',clr(k,:));
% end
% xlabel('Time (hr)');
% ylabel('a_x (pixels)');
% 
% % plot them
% figure;
% axes;
% for k=1:nTracker
%   line(t/3600,a(2,:,k),'color',clr(k,:));
% end
% xlabel('Time (hr)');
% ylabel('a_y (pixels)');
% 
% % plot them
% figure;
% axes;
% for k=1:nTracker
%   line(t/3600,a(:,:,k),'color',clr(k,:));
% end
% xlabel('Time (hr)');
% ylabel('b (pixels)');

% calculate finite diffs
dt=diff(t);
dr=diff(r,[],2);
da=diff(a,[],2);
db=diff(b);

% estimate derivatives
drdt=dr./repmat(dt,[2 1 nTracker]);
dadt=da./repmat(dt,[2 1 nTracker]);
dbdt=db./repmat(dt,[1 1 nTracker]);

% calc derivative magnitudes
drdtMag=sqrt(sum(drdt.^2,1));
dadtMag=sqrt(sum(dadt.^2,1));
dbdtMag=abs(dbdt);

% get times of deriv estimtes
tdt=(t(1:end-1)+t(2:end))/2;

% plot deriv mags
axes(hFrame(5,1));
for k=1:nTracker
  line(tdt/3600,drdtMag(:,:,k),'color',clr(k,:));
end
xlim([0 12]);
xlabel('Time (hr)');
ylabel('Velocity magnitude (pixels/s)');

axes(hFrame(5,2));
for k=1:nTracker
  line(tdt/3600,dadtMag(:,:,k),'color',clr(k,:));
end
xlim([0 12]);
xlabel('Time (hr)');
ylabel('da/dt magnitude (pixels/s)');

axes(hFrame(5,3));
for k=1:nTracker
  line(tdt/3600,dbdtMag(:,:,k),'color',clr(k,:));
end
xlim([0 12]);
xlabel('Time (hr)');
ylabel('Half-width velocity magnitude (pixels/s)');

end
