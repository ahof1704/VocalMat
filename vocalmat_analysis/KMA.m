function [ALPHA,LAMBDA,options] = KMA(labeled,unlabeled,options)

% Kernel manifold alignment
%
% Usage :    [eigenvectors,eigenvalues] = KMA(Labeled,Unlabeled,NumDomains,options)
%
% Inputs:
%
% - Labeled:    structure with labeled data [1,NumDomains].
%               each cell has X (dim1 x n1) and Y (n1 x 1) fields
%
% - Unlabeled:  structure with unlabeled data [1,NumDomains].
%               each cell has U (dim1 x u1)
%
% - NumDomains: number of domains involved
%
% - options:    .numDomains
%               .kernelt = 'lin','rbf','int','Wan'
%               .sigma (only in rbf case)
%               .nn = nearest neighbors in graph
%               .mu = mu in the mixture geometry/labels (mu = 0 is only geometry)
%
%
% Outputs:
%
% - ALPHA:  eigenvectors for the projection
% - LAMBDA: corresponding eigenvalues
% - nVect : number of projections [ minimum among 500,rank(KAK) and rank(KBK)) ]
% - options: the options vector used in the projector (useful in KMApredict)
%
% (c) devis tuia, Dec 2013 - devis {dot} tuia [at] epfl (dot) ch


if isfield(options,'numDomains') == 0
    options.numDomains = length(labeled);
end

if isfield(options,'kernelt') == 0
    options.kernelt= 'lin';
    disp('Setting linear kernel by default')
end

if strcmp(options.kernelt,'rbf')
    if isfield(options,'sigma') == 0
        disp('estimating sigma from data of domain 1')
        for i = 1:options.numDomains
            options.sigma{1,i} = 1*mean(pdist(labeled{1,i}.X'));
        end
    else size(options.sigma,2) < options.numDomains
        s = options.sigma;
        options.sigma = {};
        for i = 1:options.numDomains
            
            options.sigma{1,i} = s;
        end
        
        
    end
end


if strcmp(options.kernelt,'pga')
    if isfield(options,'sigma') == 0
        disp('estimating sigma from data of domain 1')
        for i = 1:options.numDomains
            options.sigma{1,i} = 15*mean(pdist(labeled{1,i}.X'));
        end
    end    
    
    if isfield(options,'b') == 0
        b = 2;
    end
    
end

if isfield(options.graph,'nn') == 0
    options.nn= 9;
    disp('Setting 9NN by default')
else
    options.nn= options.graph.nn;
end

if isfield(options,'mu') == 0
    options.mu= 0.5;
    disp('Setting mu=0.5 by default')
end


%% Create data matrices
Y = [];
n = 0;
d = 0;


for i = 1:options.numDomains
    eval(sprintf('X%i = [labeled{1,i}.X,unlabeled{1,i}.X];',i));
    
    eval(sprintf('Y%i = [labeled{1,i}.Y];',i));
    eval(sprintf('Y%iU = zeros(size(unlabeled{1,i}.X,2),1);',i));
    eval(sprintf('Y = [Y; Y%i;zeros(size(unlabeled{1,i}.X,2),1)];',i));
    
    eval(sprintf('[d%i n%i] = size(X%i);n = n+n%i;d = d + d%i;',i,i,i,i,i));
    
end





%% Build Laplacians

W = [];

for i = 1:options.numDomains
    eval(sprintf('G%i = buildKNNGraph(X%i'',options.nn,1);',i,i));
    
    eval(sprintf('W = blkdiag(W,G%i);',i));
    
end


W = double(full(W));
clear G*

% Class Graph Laplacian
Ws = repmat(Y,1,length(Y)) == repmat(Y,1,length(Y))'; Ws(Y == 0,:) = 0; Ws(:,Y == 0) = 0; Ws = double(Ws);
Wd = repmat(Y,1,length(Y)) ~= repmat(Y,1,length(Y))'; Wd(Y == 0,:) = 0; Wd(:,Y == 0) = 0; Wd = double(Wd);
Ws = Ws + eye(size(Ws,1));
Wd = Wd + eye(size(Wd,1));


 Sws = sum(sum(Ws));
 Sw = sum(sum(W));
 Ws = Ws/Sws*Sw;
 
 Swd = sum(sum(Wd));
 Wd = Wd/Swd*Sw;
 
 if options.printing == 1
     
     figure(1),
     imagesc(W)
     
     
     figure(2),
     imagesc(Ws)
     
     figure(3),
     imagesc(Wd)
 end

Ds = sum(Ws,2); Ls = diag(Ds) - Ws;%labels 'pull' Laplacian
D = sum(W,2); L = diag(D) - W;%geometry Laplacian

Dd = sum(Wd,2); Ld = diag(Dd) - Wd;%labels 'push' Laplacian

A = ((1-options.mu)*L  + options.mu*(Ls))+options.lambda*eye(size(Ls)); % (n1+n2) x (n1+n2) %  %+lambda*eye(size(Ls))
B = Ld;         % (n1+n2) x (n1+n2) % +lambda*eye(size(Ld));


%% The kernels
switch lower(options.kernelt)
    
    case 'wan'
        
        Z = []; % (d1+d2) x (n1+n2)
        
        for i = 1:options.numDomains
            eval(sprintf('Z = blkdiag(Z,X%i);',i));
        end
        
        KAK = Z*A*Z';
        KBK = Z*B*Z';
        
        
    case 'lin'
        
        K = [];
        
        for i = 1:options.numDomains
            
            eval(sprintf('K%i = [X%i]''*[X%i];',i,i,i));
            eval(sprintf('K = blkdiag(K,K%i);',i));
            
            
        end
        
        KAK = K*A*K;% +lambda*eye(size(Ls));
        KBK = K*B*K;% +lambda*eye(size(B));
        
    case {'rbf','chi2','histlag'}
        
        K = [];
        
        for i = 1:options.numDomains
            
            
            eval(sprintf('K%i = kernelmatrix(''%s'',X%i,X%i,options.sigma);',i,options.kernelt,i,i));
            eval(sprintf('K = blkdiag(K,K%i);',i));
            
            
            
        end
        
       % figure,imagesc(K),title(num2str(options.sigma))

        
        KAK = K*A*K;% +lambda*eye(size(Ls));
        KBK = K*B*K;% +lambda*eye(size(B));
    
    case {'pga'}
        
        K = [];
        
        for i = 1:options.numDomains
            
            
            eval(sprintf('K%i = kernelmatrix(''%s'',X%i,X%i,options.sigma{1,i},options.b);',i,options.kernelt,i,i));
            eval(sprintf('K = blkdiag(K,K%i);',i));
            
            
        end
        
        
        KAK = K*A*K;% +lambda*eye(size(Ls));
        KBK = K*B*K;% +lambda*eye(size(B));
        
        
    case {'int','jen'}
        
                K = [];
        
        for i = 1:options.numDomains
            
            
            eval(sprintf('K%i = kernelmatrix(''%s'',X%i,X%i);',i,options.kernelt,i,i));
            eval(sprintf('K = blkdiag(K,K%i);',i));
            
            
        end
        
        
        KAK = K*A*K;% +lambda*eye(size(Ls));
        KBK = K*B*K;% +lambda*eye(size(B));
        
    otherwise
        disp('unknown kernel type. Exiting')
        return
        
end
        %figure,imagesc(K)
        %return

%% Extract all features
disp('Solve eigenproblem')

[ALPHA LAMBDA] = gen_eig(KAK,KBK,'LM'); % options.projections

if size(ALPHA,2) < options.projections
    options.projections = size(ALPHA,2);
    fprintf(['Reduced the number of projections (by rank of matrix) to' num2str(options.projections) '.\n'])
end


[LAMBDA j] = sort(diag(LAMBDA));
ALPHA = ALPHA(:,j);





%% check if any eigenvector inversion is needed.
disp('Check for vector inversion')

if strcmp(lower(options.kernelt),'wan')
    for i = 1:options.numDomains
        eval(sprintf('n%i = d%i;',i,i));
        eval(sprintf('K%i = X%i;',i,i));
        
    end
end





cls = unique(Y1);

E1     = ALPHA(1:n1,:);
sourceXp = (E1'*K1)';%.*repmat(((1./eValues.^0.5))',length(Xtr1),1);
sourceXp = zscore(sourceXp);

% for i = 1:numel(unique(Y1))
%     m1(i,:) = mean(sourceXp([Y1;Y1U]==cls(i),:));
% end


start = n1;
ending = n1+n2;

for d = 2:options.numDomains
    
    
    E2     = ALPHA(start+1:ending,:);
    
    eval(sprintf('KK = K%i;',d));
    eval(sprintf('TY = Y%i;',d));
    eval(sprintf('TYU = Y%iU;',d));
    
    VECT = ones(size(ALPHA,2),size(E2,1));
    
    for j = 1:size(ALPHA,2)
        
       % fprintf('Dim = %i ',j);
        
        ErrRec = zeros(numel(unique(Y1)),1);
        ErrRecInv = zeros(numel(unique(Y1)),1);
        
        
        VECT_inv = VECT;
        VECT_inv(j,:) = -1;
        
        targetXp = (E2'.*VECT*KK)';
        targetXpInv = (E2'.*VECT_inv*KK)';
        targetXp = zscore(targetXp);
        targetXpInv = zscore(targetXpInv);
        
        %                 figure(100);
        %                 plot(sourceXp(:,1),sourceXp(:,2),'.'),hold on
        %                 plot(targetXp(:,1),targetXp(:,2),'r.'),hold off
        %
        %                 figure(101);
        %                 scatter(sourceXp(:,1),sourceXp(:,2),20,[Y1;Y1U],'f'),hold on
        %                 scatter(targetXp(:,1),targetXp(:,2),20,[Y2;Y2U],'f'),hold off
        %
        %
        %                 figure(102);
        %                 plot(sourceXp(:,1),sourceXp(:,2),'.'),hold on
        %                 plot(targetXpInv(:,1),targetXpInv(:,2),'r.'),hold off
        %                 title(['Flipping dimension' num2str(j)])
        %
        %                 figure(103);
        %                 scatter(sourceXp(:,1),sourceXp(:,2),20,[Y1;Y1U],'f'),hold on
        %                 scatter(targetXpInv(:,1),targetXpInv(:,2),20,[Y2;Y2U],'f'),hold off
        %                 pause
        
        for i = 1:numel(unique(Y1))
            %fprintf('Cl = %i, ',i);
            ErrRec(i) = sum(sqrt((mean(sourceXp([Y1;Y1U]==cls(i),:))-mean(targetXp([TY;TYU]==cls(i),:))).^2));
            ErrRecInv(i) = sum(sqrt((mean(sourceXp([Y1;Y1U]==cls(i),:))-mean(targetXpInv([TY;TYU]==cls(i),:))).^2));
        end
        
        %fprintf('.\n',j);
        
        if mean(ErrRec) > mean(ErrRecInv)
            VECT(j,:) = -1;
        end
        
    end
    
    
    ALPHA(start+1:ending,:) = ALPHA(start+1:ending,:).*(VECT)';
    
    eval(sprintf('start = start + n%i;',d));
    
    if d < options.numDomains
            eval(sprintf('ending = start + n%i;',d+1));
    else
        ending = size(ALPHA,1);
    end
    
end



nVect = min(500,rank(KBK));
options.nVect =  min(nVect,rank(KAK));

fprintf('... done.\n')
