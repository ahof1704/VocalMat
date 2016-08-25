
acDist{1} = load('D:\Data\Janelia Farm\ResultsFromNewTrunk\cage19_dist.mat');
acDist{2} = load('D:\Data\Janelia Farm\ResultsFromNewTrunk\cage20_dist.mat');

abValid1 = acDist{1}.a2fDistance < 1000;
abValid2 = acDist{2}.a2fDistance < 1000;
a2iMinMouseDist = [1,2,3;
 1,4,5;
 2,4,6;
 3,5,6];

for k=1:4
afDistOfOneToOthers(k,:) = min(acDist{2}.a2fDistance(:,a2iMinMouseDist(2,:)),[],2);
end


%%

figure(20);
clf;hold on;
% Draw Days (dark, light)
for iDayIter=0:4
    % Dark Period
    x = iDayIter * 24 * 60;
    y = 0;
    h = 1;
    w = 12 * 60;
    rectangle('Position',[x,y,w,h],'facecolor',[0.3 0.3 0.3]);
    % Dark Period
    x = iDayIter * 24 * 60 + 12*60;
    y = 0;
    h = 1;
    w = 12 * 60;
    rectangle('Position',[x,y,w,h],'facecolor',[0.9 0.9 0.9]);
    
end

set(gca,'ytick',[]);
set(gca,'xtick',[0:12:145]*60);
set(gca,'xticklabel',{'0',   '12'  , '24'  , '36'   ,'48' , '60'   ,'72' ,'84'  ,'96'  ,'108'  ,'120'  ,'132','140'});
set(gca,'xlim',[0 120]*60);	
xlabel('Hours');
%%

figure(11);
clf;
plot(afDistOfOneToOthers)

sum(afDistOfOneToOthers>5)
sum(afDistOfOneToOthers<5)

afHist=hist(,linspace(0,1000,1000));
figure;
plot(log10(afHist))

afHist1 = hist(acDist{1}.a2fDistance(abValid1),linspace(0,800,1000));
afHist2 = hist(acDist{2}.a2fDistance(abValid2),linspace(0,800,1000));

figure(11);
clf;
plot(log10(afHist1));
hold on;
plot(log10(afHist2),'r');


aiInd = find(a2fDistance(:,1)>1000);
a2fDistance(aiInd(1),1)
figure;
plot(a2fDistance(:,1))

1e2 * sum(a2fDistance < 7) / size(a2fDistance,1)
1e2 * sum(a2fDistance > 7) / size(a2fDistance,1)
