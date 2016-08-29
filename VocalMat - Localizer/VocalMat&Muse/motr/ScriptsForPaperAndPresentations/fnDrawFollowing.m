aiLengths = X.follow16_d1.m1m2(:,2)-X.follow16_d1.m1m2(:,1)+1;
[aiLengthSorted,aiSortInd]=sort(aiLengths,'descend');

strctRes = load('D:\Data\Janelia Farm\ResultsFromNewTrunk\cage16\b6_popcage_16_110405_09.58.30.268.mat');
strctMov = fnReadSeqInfo('E:\cage16\b6_popcage_16_110405_09.58.30.268.seq');

iInterval = 1;

iBefore = 10*5;
iAfter = 20;
iSelectedInterval = aiSortInd(iInterval);
iOriginalIntervalLength = aiLengthSorted((iInterval));
aiFrames=(X.follow16_d1.m1m2(iSelectedInterval,1))-iBefore:X.follow16_d1.m1m2(iSelectedInterval,2)+iAfter;

%%
figure(11);
clf;
I=fnReadFrameFromSeq(strctMov, aiFrames(1));
hImage=imshow(I,[]);
hold on;
a2fColors = [255 0 0;
             0 255 0;   
             0 0 255;
             0 255 255]/255;
         fInitialAlpha=0.3;
for k=1:4
      ahEllipses(k) = fnPlotEllipse2(strctRes.astrctTrackers(k).m_afX(aiFrames(1)),...
        strctRes.astrctTrackers(k).m_afY(aiFrames(1)),...
        strctRes.astrctTrackers(k).m_afA(aiFrames(1)),...
        strctRes.astrctTrackers(k).m_afB(aiFrames(1)),...
        strctRes.astrctTrackers(k).m_afTheta(aiFrames(1)), a2fColors(k,:),2, gca);
      ahTrace(k) = patchline(0,0,'edgecolor',a2fColors(k,:),'linewidth',12,'edgealpha',fInitialAlpha,'facecolor','none');
end

hold on;
for k=1:length(aiFrames)
    I=fnReadFrameFromSeq(strctMov, aiFrames(k));
      for j=1:4
    fnDrawEllipseTupleNew2(ahEllipses(j),strctRes.astrctTrackers(j).m_afX(aiFrames(k)),...
                        strctRes.astrctTrackers(j).m_afY(aiFrames(k)),...
                        strctRes.astrctTrackers(j).m_afA(aiFrames(k)),...
                        strctRes.astrctTrackers(j).m_afB(aiFrames(k)),...
                    strctRes.astrctTrackers(j).m_afTheta(aiFrames(k))+pi/2,a2fColors(j,:),2);
                if j>=3 && k >= iBefore && k <= iBefore+iOriginalIntervalLength
                    set(ahTrace(j),'xdata',[strctRes.astrctTrackers(j).m_afX(aiFrames(iBefore:k)) strctRes.astrctTrackers(j).m_afX(aiFrames(k:-1:iBefore))],...
                                'ydata',[strctRes.astrctTrackers(j).m_afY(aiFrames(iBefore:k)) strctRes.astrctTrackers(j).m_afY(aiFrames(k:-1:iBefore))]);
                end
            if j>=3 && k >= iBefore+iOriginalIntervalLength && k <= iBefore+iOriginalIntervalLength+20 
                    set(ahTrace(j),'edgealpha', fInitialAlpha*(1-(k-(iBefore+iOriginalIntervalLength))/20));
                end                
                
                
    end
    set(hImage,'cdata',I);
    drawnow
end

 
iOriginalIntervalLength = 80;

aiFrames=99095:99095+iOriginalIntervalLength+140;
iBefore=10;
set(ahTrace(3:4),'edgealpha',fInitialAlpha,'xdata',0,'ydata',0);
hold on;
for k=1:length(aiFrames)
    I=fnReadFrameFromSeq(strctMov, aiFrames(k));
      for j=1:4
    fnDrawEllipseTupleNew2(ahEllipses(j),strctRes.astrctTrackers(j).m_afX(aiFrames(k)),...
                        strctRes.astrctTrackers(j).m_afY(aiFrames(k)),...
                        strctRes.astrctTrackers(j).m_afA(aiFrames(k)),...
                        strctRes.astrctTrackers(j).m_afB(aiFrames(k)),...
                    strctRes.astrctTrackers(j).m_afTheta(aiFrames(k))+pi/2,a2fColors(j,:),2);
                if j>=3 && k >= iBefore && k <= iBefore+iOriginalIntervalLength
                    set(ahTrace(j),'xdata',[strctRes.astrctTrackers(j).m_afX(aiFrames(iBefore:k)) strctRes.astrctTrackers(j).m_afX(aiFrames(k:-1:iBefore))],...
                                'ydata',[strctRes.astrctTrackers(j).m_afY(aiFrames(iBefore:k)) strctRes.astrctTrackers(j).m_afY(aiFrames(k:-1:iBefore))]);
                end
            if j>=3 && k >= iBefore+iOriginalIntervalLength && k <= iBefore+iOriginalIntervalLength+20 
                    set(ahTrace(j),'edgealpha', fInitialAlpha*(1-(k-(iBefore+iOriginalIntervalLength))/20));
                end                
                
                
    end
    set(hImage,'cdata',I);
    drawnow
end

 %%
 
 
 
iOriginalIntervalLength = 80;

aiFrames=99315:99315+iOriginalIntervalLength+60;
iBefore=1;
set(ahTrace(3:4),'edgealpha',fInitialAlpha,'xdata',0,'ydata',0);
hold on;
for k=1:length(aiFrames)
    I=fnReadFrameFromSeq(strctMov, aiFrames(k));
      for j=1:4
    fnDrawEllipseTupleNew2(ahEllipses(j),strctRes.astrctTrackers(j).m_afX(aiFrames(k)),...
                        strctRes.astrctTrackers(j).m_afY(aiFrames(k)),...
                        strctRes.astrctTrackers(j).m_afA(aiFrames(k)),...
                        strctRes.astrctTrackers(j).m_afB(aiFrames(k)),...
                    strctRes.astrctTrackers(j).m_afTheta(aiFrames(k))+pi/2,a2fColors(j,:),2);
                if j>=3 && k >= iBefore && k <= iBefore+iOriginalIntervalLength
                    set(ahTrace(j),'xdata',[strctRes.astrctTrackers(j).m_afX(aiFrames(iBefore:k)) strctRes.astrctTrackers(j).m_afX(aiFrames(k:-1:iBefore))],...
                                'ydata',[strctRes.astrctTrackers(j).m_afY(aiFrames(iBefore:k)) strctRes.astrctTrackers(j).m_afY(aiFrames(k:-1:iBefore))]);
                end
            if j>=3 && k >= iBefore+iOriginalIntervalLength && k <= iBefore+iOriginalIntervalLength+20 
                    set(ahTrace(j),'edgealpha', fInitialAlpha*(1-(k-(iBefore+iOriginalIntervalLength))/20));
                end                
                
                
    end
    set(hImage,'cdata',I);
    drawnow
end
 %%
 
 
 
iOriginalIntervalLength = 60;

aiFrames=99455:99455+iOriginalIntervalLength+180;
iBefore=1;
set(ahTrace([1,3]),'edgealpha',fInitialAlpha,'xdata',0,'ydata',0);
hold on;
for k=1:length(aiFrames)
    I=fnReadFrameFromSeq(strctMov, aiFrames(k));
      for j=1:4
    fnDrawEllipseTupleNew2(ahEllipses(j),strctRes.astrctTrackers(j).m_afX(aiFrames(k)),...
                        strctRes.astrctTrackers(j).m_afY(aiFrames(k)),...
                        strctRes.astrctTrackers(j).m_afA(aiFrames(k)),...
                        strctRes.astrctTrackers(j).m_afB(aiFrames(k)),...
                    strctRes.astrctTrackers(j).m_afTheta(aiFrames(k))+pi/2,a2fColors(j,:),2);
                if (j==3 || j == 1) && k >= iBefore && k <= iBefore+iOriginalIntervalLength
                    set(ahTrace(j),'xdata',[strctRes.astrctTrackers(j).m_afX(aiFrames(iBefore:k)) strctRes.astrctTrackers(j).m_afX(aiFrames(k:-1:iBefore))],...
                                'ydata',[strctRes.astrctTrackers(j).m_afY(aiFrames(iBefore:k)) strctRes.astrctTrackers(j).m_afY(aiFrames(k:-1:iBefore))]);
                end
            if (j==3 || j == 1)&& k >= iBefore+iOriginalIntervalLength && k <= iBefore+iOriginalIntervalLength+20 
                    set(ahTrace(j),'edgealpha', fInitialAlpha*(1-(k-(iBefore+iOriginalIntervalLength))/20));
                end                
                
                
    end
    set(hImage,'cdata',I);
    drawnow
end
set(ahTrace(1),'visible','off');
set(ahTrace(1:4),'xdata',0,'ydata',0,'edgealpha',fInitialAlpha);

% Fade to black
aiFrames=99715:99715+100-1;
iBefore = 20;
iOriginalIntervalLength= 100;
for k=1:length(aiFrames)
    I=fnReadFrameFromSeq(strctMov, aiFrames(k));
      for j=1:4
    fnDrawEllipseTupleNew2(ahEllipses(j),strctRes.astrctTrackers(j).m_afX(aiFrames(k)),...
                        strctRes.astrctTrackers(j).m_afY(aiFrames(k)),...
                        strctRes.astrctTrackers(j).m_afA(aiFrames(k)),...
                        strctRes.astrctTrackers(j).m_afB(aiFrames(k)),...
                    strctRes.astrctTrackers(j).m_afTheta(aiFrames(k))+pi/2,a2fColors(j,:)*(1-k/100),2);
                
            if (j==2 || j == 3) && k >= iBefore && k <= iBefore+iOriginalIntervalLength
                    set(ahTrace(j),'xdata',[strctRes.astrctTrackers(j).m_afX(aiFrames(iBefore:k)) strctRes.astrctTrackers(j).m_afX(aiFrames(k:-1:iBefore))],...
                                'ydata',[strctRes.astrctTrackers(j).m_afY(aiFrames(iBefore:k)) strctRes.astrctTrackers(j).m_afY(aiFrames(k:-1:iBefore))],'edgecolor',a2fColors(j,:)*(1-k/100));
                end
            if (j==2 || j == 3)&& k >= iBefore+iOriginalIntervalLength && k <= iBefore+iOriginalIntervalLength+20 
                    set(ahTrace(j),'edgealpha', fInitialAlpha*(1-(k-(iBefore+iOriginalIntervalLength))/20),'edgecolor',a2fColors(j,:)*(1-k/100));
                end                
                   
                
    end
    set(hImage,'cdata',I*(1-k/100));
    drawnow
end
