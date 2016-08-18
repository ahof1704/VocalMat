function plotBehaviorSummary()
%
load afS;
n = size(afS, 3);
M =max(afS(:));
figure(1),
for i=1:4
    j = 1:4;
    j(i) = [];
    subplot(4,1,i), plot(squeeze(afS(i,j,:))'), axis([1 n 0 M]);
end
