load('D:\Code\Janelia Farm\DataForFigures\DataForHeadTail4');
figure(20);
clf;
imagesc(a2LogfLikelihood(:,1:1000),[-30 0]);
[afMax, aiMAP]=max(a2LogfLikelihood,[],1);
colormap hot;
color bar
set(gcf,'position',[412 781 879 211])
set(gcf,'color',[1 1 1])
hold on;
colorbar
plot(aiPath(1:1000),'m.')


figure(21);
clf;
imagesc(a2LogfLikelihood(:,1:1000),[-30 0]);
[afMax, aiMAP]=max(a2LogfLikelihood,[],1);
colormap hot;
color bar
set(gcf,'position', [  412   781   435   211])
set(gcf,'color',[1 1 1])
hold on;
plot(aiPath(1:1000),'m.')

figure(22);
clf;
imagesc(a2LogfLikelihood(:,1:1000),[-30 0]);
[afMax, aiMAP]=max(a2LogfLikelihood,[],1);
colormap hot;
color bar
set(gcf,'position', [  412   781   435   211])
set(gcf,'color',[1 1 1])
hold on;
plot(aiMAP(1:1000),'m','LineWidth',2)

figure(4);clf;
imagesc(a2fTransitionMatrix);
colormap hot;colorbar