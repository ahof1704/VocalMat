% ppc: data splitting with a per-class criterion
%
% [Xtr Ytr Xts Yts indices] = ppc(X,Y,ppc)
%
% This function splits the data in X according to the labels in Y and
% returns train and test data, along with the indices in the original data
% vector.
%
% Inputs:       - X: data vector
%               - Y: labels vector
%               - ppc: rule for splitting
%                       o if ppc < 1, it is a percentage per class
%                       o otherwise, # of points per class
%               - randstate: random numbers generator
%
% Outputs:      - Xtr, Xts: data vectors in training and test
%               - Ytr, Yts: label vectors in training and test
%               - indices: indices in the original vectors X and Y.
%
% Devis Tuia and Jordi Mu?oz, 2010

function [Xtr Ytr Xts Yts indices pos] = ppc(X,Y,ppc, randstate)

if nargin < 4
    randstate = 0;
end

s = rand('state');
rand('state',randstate);

flip = 0;
classes = unique(Y(:,1));

if size(Y,1) < size(Y,2)
    flip = 1;
end

if flip
    Y = Y';
    X = X';
end

Xtr = [];
Ytr = [];
Xts = [];
Yts = [];
pos = [];

indices = zeros(size(Y,1),1);

if ppc >= 1
    
    for i = 1:size(classes,1)
        
        ii = find(Y(:,1) == classes(i));
        c = randperm(size(ii,1))';

               
        ppcb = ppc;
        
        
        if size(ii,1) <= ppc
            ppcb = size(ii,1) - ceil(size(ii,1)/5);
            fprintf('Taking 80%% of the %i available pixels for class %i\n',size(ii,1),classes(i));
%         disp(['Class ' num2str(classes(i)) ' is discarded'])
        end
        
        
        indices(ii(c(1:ppcb))) = 1;
        indices(ii(c(ppcb+1:end))) = 2;
        
        Xtr = [Xtr;X(ii(c(1:ppcb)),:)];
        Ytr = [Ytr;Y(ii(c(1:ppcb)),:)];
        
        
        Xts = [Xts;X(ii(c(ppcb+1:end)),:)];
        Yts = [Yts;Y(ii(c(ppcb+1:end)),:)];
        
        pos = [pos; ii(c)];
        

        
    end
    
    
    
    
else
    for i = 1:numel(classes);
        
        ii = find(Y == classes(i));
        ppc2 = max(fix(ppc*size(ii,1)),5);%fix a minimal number of pixels
        c = randperm(size(ii,1))';
        
        
        indices(ii(c(1:ppc2))) = 1;
        indices(ii(c(ppc2+1:end))) = 2;
        
        
        Xtr = [Xtr;X(ii(c(1:ppc2)),:)];
        Ytr = [Ytr;Y(ii(c(1:ppc2)),:)];
        
        
        Xts = [Xts;X(ii(c(ppc2+1:end)),:)];
        Yts = [Yts;Y(ii(c(ppc2+1:end)),:)];
        
         pos = [pos; ii(c)];
        
    end
    
end

if flip
    Xtr = Xtr';
    Xts = Xts';
    Ytr = Ytr';
    Yts = Yts';
    
end

rand('state',s);
