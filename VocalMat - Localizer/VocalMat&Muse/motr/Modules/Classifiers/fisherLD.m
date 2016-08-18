function [LDs, Xm ] = fisherLD ( X, y, rank )
%% FISHERLD compute Fisher Linear Discriminants
%% X - data vector, each column is a data point
%% y - labels of each data point. Not necessarily consecutive
%% rank - project the data down to this dimension  to avoid overfitting
%% LDs - Fisher Principal Dimensions
%% Xm - origin used to compute the LDs

%%% Written by M. Weber, 1999 based on Ripley's textbook pages 93 and
%%% following.

%%% Modified by P. Perona, April 2006
%%% Modified by P. Perona, Dec 2006


[D, N] = size(X);  %% Get n. of dimensions and n. of sample points from X

if nargin<3,
    rank = min(D,N-1);
else, %% Check that rank is not larger than the rank of the data
    rank = min([D, N-1, rank]);
end;


%% Count the number of groups from the label vector
%% The labels may be arbitrary numbers and not in order
yS = sort(y); dyS = diff(yS); %% Detect changes in sorted labels vector
g = sum(dyS > 0) + 1; %% Count number of groups

%% Construct ordered labels, one for each group (class) of points
%% 
groupLabels = zeros(g, 1);
groupLabels(1) = yS(1);
groupLabels(2 : g) = yS(find(dyS) + 1);

%% Count how many points per group
Ng = zeros(g, 1);   %% Number of sample points per group
yRelabeled = zeros(size(y)); %% New vector of labels using 1,2,3, ... Ng as labels. More consistent and making following code easier to write

for i = 1 : g,
	idx = find(y == groupLabels(i));
	Ng(i) = length(idx);  %% Calculate the n. of sample points for each group
	yRelabeled(idx) = i * ones(Ng(i), 1);
end


%% Different way to encode the labels. This one has g columns and if data
%% point i is in group j then G(i,j)=1 otherwise it is 0
G = zeros(N, g);

for i = 1 : N,
	G(i, yRelabeled(i)) = 1;
end

%% This is an auxhiliary matrix which will be useful later
%% It is related to the inverse of the matrix N (see class notes)
T = diag(sqrt(N ./ Ng));

% Make X zeromean
Xm = mean(X')'; %% Mean of all the data points
X = X - Xm * ones(1, N); %% Make data zero mean.

% Collect Group means
[U L V] = svd(X',0);

R = rank; %% Why N-1 and not N??
U = U(:, 1:R);
L = L(1:R, 1:R);
V = V(:, 1:R);

%%keyboard

S = sqrt(N) * V * inv(L);
Xrs = (X' * S)';
M = inv(G' * G) * G' * Xrs';

[UU LL VV] = svd(inv(T) * M);
LDs = S * VV;

return

%% My own sanity check


%% The rows of X are the N of sample and the cols are the D dimensions
Xp = X'; 
[Np,Dp]=size(Xp);

%% Calculate matrix containing means
for i=1:g,
   idx = find(yRelabeled == groupLabels(i));
   Xp_m(i,:) = mean(Xp(idx,:));
end;

%% Calculate the position of each point w.r. to its cluster's mean
Xp0 = Xp - G*Xp_m;  %% take the cluster-mean out of each point.
figure(11); clf; plotclusters(Xp0,groupLabels,yRelabeled); title('Xp0');

%% Calculate change of coord S so that Yp0 is whitened version of Xp0
[Up,Lp,Vp] = svd(Xp0,0);
Sp = Vp*inv(Lp);
Yp0 = Xp0*Sp;
figure(12); clf; plotclusters(Yp0,groupLabels,yRelabeled); title('Yp0');

Bp = Sp' * Xp_m' * G' * G * Xp_m * Sp;
[Ub,Lb,Vb] = svd(Bp,0);

FDp = Sp*Vb;
Zp = Xp*FDp(:,1:2);
figure(13); clf; plotclusters(Zp,groupLabels,yRelabeled); 
title('Data plotted on my first 2 LFDs'); axis 'equal';

[UG,LG,VG] = svd(G,0);
FDp2 = S* Up' * UG;

%% Generalized eigenvector problem
Bp2 = M' * G' * G * M;
Wp2 = Xp0' * Xp0;
[FDp3,Dp3] = eigs(Bp2,Wp2,2);
figure(14); clf; plotclusters(Xp*FDp3,groupLabels,yRelabeled);
title('Data plotted on eigs-method LFDs'); axis 'equal';






return

% tests

Xrs * Xrs'

(G * M)' * (G * M)
N * VV * LL .^ 2 * VV'

T * G' * G * T

M
inv(G' * G) * G' * Xrs'
1/N * T.^2 * G' * Xrs'




XRS = X' * S * VV';

(XRS - G * M)' * (XRS - G * M)


%A = S' * X * X' * S;

%(V' * invL)' * (U * L * V



function plotclusters(X,groupLabels,yRelabeled)
mrks = {'r.', 'g.', 'b.', 'c.', 'm.', 'k.'};  %% Colors of the markers
hold on;
for i=1:length(groupLabels), 
   idx = find(yRelabeled == groupLabels(i));
   plot(X(idx,1),X(idx,2),mrks{i});
end;
hold off;
