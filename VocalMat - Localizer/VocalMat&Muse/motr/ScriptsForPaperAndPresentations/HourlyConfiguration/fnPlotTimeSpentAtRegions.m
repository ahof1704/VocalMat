function fnPlotTimeSpentAtRegions(a3fTimePerc,acRegionNames)
    a2fTotalTime = squeeze(sum(a3fTimePerc,2));
    fTotalTime = sum(a2fTotalTime(:,1));
     a2fTotalTimeNormalized = a2fTotalTime / fTotalTime;
iNumDwellingPlaces=7;
iNumMice=4;
afSampleTimeHours = 0:0.1/6:120;


figure;
    clf;
    P(1) =100;
    P(2) = 600;
    P(3:4) = [560,420];
    set(gcf,'position',P);
    ahBars=bar(0:7,a2fTotalTimeNormalized);
    set(gca,'xticklabel',acRegionNames);xticklabel_rotate;
    set(ahBars(1),'facecolor','b');
    set(ahBars(2),'facecolor','c');
    set(ahBars(3),'facecolor','r');
    set(ahBars(4),'facecolor','g');
    

a2fMiceColors = [255,0,255;
                      255,0,0;
                      0,0,255;
                      0,255,0;]/255;
    
        a2fMiceColors = [1,0,0;
        0,1,0;
        0,0,1;
        0,1,1];
    
    
    clear a2fRGB
    for iDwellPlace=1:iNumDwellingPlaces+1
        X = squeeze(a3fTimePerc(iDwellPlace,:,:))';
        for iRowIter=1:iNumMice
            for iColor=1:3
                a2fRGB((iDwellPlace-1)*iNumMice+iRowIter,:,iColor) = max(0,min(1,X(iRowIter,:) * a2fMiceColors(iRowIter,iColor)));
            end
        end
    end
    figure(500);clf;hold on;
    imagesc(afSampleTimeHours ,[0:0.25:double(iNumDwellingPlaces)], a2fRGB   )
    set(gca,'xlim',[0 120],'ylim',[-0.1 7.1])
    afTmp=0.8:0.9:7;
     for k=1:length(afTmp)
        plot([0 afSampleTimeHours(end)],[afTmp(k) afTmp(k)],'w--');
    end
    set(gca,'ytick',afTmp-0.4,'yticklabel',[]);
    set(gca,'xtick',0:12:120);
    for j=0:12:120
        plot([j j],[-1 iNumDwellingPlaces],'w');
    end