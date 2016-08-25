%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% atb, 2003
% torralba@ai.mit.edu

clear all

% Create data
x = rand(2,1000);
D = sqrt(((x(1,:)-.5).^2 + (x(2,:)-.5).^2));
y = D<.2;
y = 2*y-1; % we need class label = [-1 1]

% Learn classifier
Nrounds = 15;
classifier = gentleBoost(x, y, Nrounds);

% create test data
[x1, x2] = meshgrid(0:0.01:1,0:0.01:1); [n,m] = size(x1);

xt = [x1(:) x2(:)]';

% run classifier
[Cx, Fx] = strongGentleClassifier(xt, classifier);

% show results
FxShow = reshape(Fx, [n m]);
FxShow = FxShow - min(FxShow(:));
figure
image([0 1], [0 1], 255*FxShow/max(FxShow(:)))
colormap(gray(256))
hold on
j = find(y == -1);
plot(x(1,j), x(2,j), 'rx')
j = find(y == 1);
plot(x(1,j), x(2,j), 'go')
title('gentleBoost with stumps')


