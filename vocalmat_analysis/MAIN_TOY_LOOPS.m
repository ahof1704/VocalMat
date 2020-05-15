function results = MAIN_TOY_LOOPS(N,realz,modif)

% parameters
NF = 100;
mu = 0.5;               %(1-mu)*L  + mu*(Ls)
options.graph.nn = 10;  %KNN graph number of neighbors

%% Loop process
results = [];


for dim = 1:modif.additDim
    
    
    for r = 1:realz
        
        fprintf('Dim replicates: %i, realization %i\n',dim,r);
        
        r1 = []; rT1 = []; r2 = []; rT2 = [];
        rl1 = []; rlT1 = []; rl2 = []; rlT2 = [];
        rW1 = []; rWT1 = []; rW2 = []; rWT2 = [];
        
        %% create data
        
        load ./data/ellipses2D.mat
        
        noise = 0.15; % noise in the multidim data       
        
        %Add the third discriminant dimension
        if modif.X1_3D
            X1 = [X1 linspace(0,1,length(X1))'];
        end
        
        if modif.X2_3D
            X2 = [X2 linspace(0,1,length(X2))'];
        end
        
        
        X1 = repmat(X1,1,dim);%ceil(d/size(X1,2))
        X2 = repmat(X2,1,dim);%ceil(d/size(X2,2)
        
               X1 = X1+rand(size(X1))*noise;
        X2 = X2+rand(size(X2))*noise;
        
        
        
        %50%-50% split for training and testing
        XT1 = X1(1:2:end,:)';
        YT1 = Y1(1:2:end,:);
        T = length(XT1)/2;
        
        Xtemp1 = X1(2:2:end,:);
        Ytemp1 = Y1(2:2:end,:);
        
        XT2 = X2(1:2:end,:)';
        YT2 = Y2(1:2:end,:);
        
        Xtemp2 = X2(2:2:end,:);
        Ytemp2 = Y2(2:2:end,:);
        
        [X1 Y1 U1 Y1U indices] = ppc(Xtemp1,Ytemp1,N,r);
        [X2 Y2 U2 Y2U indices] = ppc(Xtemp2,Ytemp2,N,r);
        
        X1 = X1';
        X2 = X2';
        U1 = U1(1:2:end,:)';
        U2 = U2(1:2:end,:)';
        
        clear *temp*
        
        Y1U = zeros(length(U1),1);
        Y2U = zeros(length(U2),1);
        
        ncl = numel(unique(Y1));
        
        
        %% Distortions (if needed)
        
        if modif.classes
            ii = find(Y2 == 1);
            jj = find(Y2 == 3);
            Y2(ii,1) = 3; Y2(jj,1) = 1;
            
            ii = find(YT2 == 1);
            jj = find(YT2 == 3);
            YT2(ii,1) = 3; YT2(jj,1) = 1;
        end
        
        if modif.mirror
            X1(1,:) = X1(1,:)*-1;
            U1(1,:) = U1(1,:)*-1;
            XT1(1,:) = XT1(1,:)*-1;
        end
        
        if modif.square
            X1(1,:) = X1(1,:).^2;
            U1(1,:) = U1(1,:).^2;
            XT1(1,:) = XT1(1,:).^2;
        end
        
        if modif.lines
            X1(1,:) = linspace(min(X1(1,:)),max(X1(1,:)),length(X1))+rand(1,length(X1))/10;
            X1(2,:) = linspace(min(X1(2,:)),max(X1(2,:)),length(X1))+rand(1,length(X1))/10;
            
            U1(1,:) = linspace(min(U1(1,:)),max(U1(1,:)),length(U1))+rand(1,length(U1))/10;
            U1(2,:) = linspace(min(U1(2,:)),max(U1(2,:)),length(U1))+rand(1,length(U1))/10;
            
            XT1(1,:) = linspace(min(XT1(1,:)),max(XT1(1,:)),length(XT1))+rand(1,length(XT1))/10;
            XT1(2,:) = linspace(min(XT1(2,:)),max(XT1(2,:)),length(XT1))+rand(1,length(XT1))/10;
        end
        
        
        if modif.scales
            factor = modif.scales;
            
            X1(1,:) = X1(1,:).*linspace(1,factor,length(X1));
            X1(2,:) = X1(2,:).*linspace(1,factor,length(X1));
            
            U1(1,:) = U1(1,:).*linspace(1,factor,length(U1));
            U1(2,:) = U1(2,:).*linspace(1,factor,length(U1));
            
            XT1(1,:) = XT1(1,:).*linspace(1,factor,length(XT1));
            XT1(2,:) = XT1(2,:).*linspace(1,factor,length(XT1));
            
        end
        
        Y = [Y1;Y1U;Y2;Y2U];
        YT = [YT1;YT2];
        
        
        [d1 n1] = size(X1);
        [d2 n2] = size(X2);
        
        [temp,u1] = size(U1);
        [temp,u2] = size(U2);
        
        n = n1+n2+u1+u2;
        d = d1+d2;
        
        n1=n1+u1;
        n2=n2+u2;
        
        [dT1 T1] = size(XT1);
        [dT2 T2] = size(XT2);
        
        dT = dT1+dT2;
        
        
        
        %% Wang'11
        disp('  Mapping with Wang11 method ...')
        
        % 1) Data in a block diagonal matrix
        Z = blkdiag([X1,U1],[X2,U2]); % (d1+d2) x (n1+n2)
        
        % 2) graph Laplacians         
        G1 = buildKNNGraph([X1,U1]',options.graph.nn,1);
        G2 = buildKNNGraph([X2,U2]',options.graph.nn,1);
        W = blkdiag(G1,G2);
        W = double(full(W));
        clear G*
        
        % Class Graph Laplacian
        Ws = repmat(Y,1,length(Y)) == repmat(Y,1,length(Y))'; Ws(Y == 0,:) = 0; Ws(:,Y == 0) = 0; Ws = double(Ws);
        Wd = repmat(Y,1,length(Y)) ~= repmat(Y,1,length(Y))'; Wd(Y == 0,:) = 0; Wd(:,Y == 0) = 0; Wd = double(Wd);
        
        
        Sws = sum(sum(Ws));
        Sw = sum(sum(W));
        Ws = Ws/Sws*Sw;

        Swd = sum(sum(Wd));
        Wd = Wd/Swd*Sw;

        Ds = sum(Ws,2); Ls = diag(Ds) - Ws;
        Dd = sum(Wd,2); Ld = diag(Dd) - Wd;
        D = sum(W,2); L = diag(D) - W;
        
        
        % Tune the generalized eigenproblem
        A = ((1-mu)*L  + mu*(Ls)); % (n1+n2) x (n1+n2) %  
        B = Ld;         % (n1+n2) x (n1+n2) % 
        
        % 3) Extract all features
        [V D] = eigs(Z*A*Z',Z*B*Z',d,'SM');
        %[V D] = gen_eig(Z*A*Z',Z*B*Z',d);
        
        
        
        %4) rotate axis if necessary
        E1     = V(1:d1,:);
        E2     = V(d1+1:end,:);
        sourceXpInv = (E1'*X1*-1)';
        sourceXp = (E1'*X1)';
        targetXp = (E2'*X2)';
        
        
        sourceXpInv = zscore(sourceXpInv);
        sourceXp = zscore(sourceXp);
        targetXp = zscore(targetXp);
        
        
        ErrRec = zeros(numel(unique(Y1)),size(V,2));
        ErrRecInv = zeros(numel(unique(Y1)),size(V,2));
        
        m1 = zeros(numel(unique(Y1)),size(V,2));
        m1inv = zeros(numel(unique(Y1)),size(V,2));
        m2 = zeros(numel(unique(Y1)),size(V,2));
        
        cls = unique(Y1);
        
        for j = 1:size(V,2)
            
            for i = 1:numel(unique(Y1))
                
                m1inv(i,j) = mean(sourceXpInv([Y1;Y1U]==cls(i),j));
                m1(i,j) = mean(sourceXp([Y1;Y1U]==cls(i),j));
                m2(i,j) = mean(targetXp([Y2;Y2U]==cls(i),j));
                
                ErrRec(i,j) = sqrt((mean(sourceXp([Y1;Y1U]==cls(i),j))-mean(targetXp([Y2;Y2U]==cls(i),j))).^2);
                ErrRecInv(i,j) = sqrt((mean(sourceXpInv([Y1;Y1U]==cls(i),j))-mean(targetXp([Y2;Y2U]==cls(i),j))).^2);
                
            end
        end
        
        
        mean(ErrRec);
        mean(ErrRecInv);
        
        Sc = max(ErrRec)>max(ErrRecInv);
        V(1:d1,Sc) = V(1:d1,Sc)*-1;
        
        
        
        % 4) Project the data
        for Nf = 1:d

            E1     = V(1:d1,1:Nf);
            E2     = V(d1+1:end,1:Nf);
            X1toF = E1'*X1;
            X2toF = E2'*X2;
            
            XT1toF = E1'*XT1;
            XT2toF = E2'*XT2;
               
            % 5) IMPORTAT: Normalize!!!!
            m1 = mean(X1toF');
            m2 = mean(X2toF');
            s1 = std(X1toF');
            s2 = std(X2toF');
            
            X1toF = zscore(X1toF')';
            X2toF = zscore(X2toF')';
            
            XT1toF = ((XT1toF' - repmat(m1,2*T,1))./ repmat(s1,2*T,1))';
            XT2toF = ((XT2toF' - repmat(m2,2*T,1))./ repmat(s2,2*T,1))';
            
            % 6) PREDICT
            % a) predict train (domain 1) using latent
            Ypred = classify([X1toF]',[X1toF,X2toF]',[Y1;Y2]);
            Reslatent1 = assessment(Y1,Ypred,'class');
            
            % b) predict train (domain 2) using latent
            Ypred = classify([X2toF]',[X1toF,X2toF]',[Y1;Y2]);
            Reslatent2 = assessment(Y2,Ypred,'class');
            
            % c) predict test (domain 1) using latent
            Ypred = classify([XT1toF]',[X1toF,X2toF]',[Y1;Y2]);
            Reslatent1T = assessment(YT1,Ypred,'class');
            
            % d) predict test (domain 2) using latent
            Ypred = classify([XT2toF]',[X1toF,X2toF]',[Y1;Y2]);
            Reslatent2T = assessment(YT2,Ypred,'class');
            
            rW1 = [rW1; Reslatent1.OA];
            rWT1 = [rWT1; Reslatent1T.OA];
            
            rW2 = [rW2; Reslatent2.OA];
            rWT2 = [rWT2; Reslatent2T.OA];
            
        end
        
        results.Wang{r,dim}.X1 = rW1;
        results.Wang{r,dim}.XT1 = rWT1;
        results.Wang{r,dim}.X2 = rW2;
        results.Wang{r,dim}.XT2 = rWT2;
        
        
        %% KEMA - LINEAR KERNEL
        disp('  Mapping with the linear kernel ...')
        
        % 2) Compute linear kernels
        % Linear kernel should give the same results as Wang:
        K1 = [X1,U1]'*[X1,U1];
        K2 = [X2,U2]'*[X2,U2];
        K = blkdiag(K1,K2);
        
        KT1 = [X1,U1]'*XT1;
        KT2 = [X2,U2]'*XT2;
        
        KAK = K*A*K;
        KBK = K*B*K;
        
        
        % 3) Extract all features (now we can extract n dimensions!)
        [ALPHA LAMBDA] = gen_eig(KAK,KBK,'LM');
        
        
        [LAMBDA j] = sort(diag(LAMBDA));
        ALPHA = ALPHA(:,j);
        
    
        %4) rotate axis if necessary
        E1     = ALPHA(1:n1,:);
        E2     = ALPHA(n1+1:end,:);
        sourceXpInv = (E1'*K1*-1)';
        sourceXp = (E1'*K1)';
        targetXp = (E2'*K2)';
        
        
        sourceXpInv = zscore(sourceXpInv);
        sourceXp = zscore(sourceXp);
        targetXp = zscore(targetXp);
        
        
        ErrRec = zeros(numel(unique(Y1)),size(ALPHA,2));
        ErrRecInv = zeros(numel(unique(Y1)),size(ALPHA,2));
        
        m1 = zeros(numel(unique(Y1)),size(ALPHA,2));
        m1inv = zeros(numel(unique(Y1)),size(ALPHA,2));
        m2 = zeros(numel(unique(Y1)),size(ALPHA,2));
        
        cls = unique(Y1);
        
        for j = 1:size(ALPHA,2)
            
            for i = 1:numel(unique(Y1))
                
                m1inv(i,j) = mean(sourceXpInv([Y1;Y1U]==cls(i),j));
                m1(i,j) = mean(sourceXp([Y1;Y1U]==cls(i),j));
                m2(i,j) = mean(targetXp([Y2;Y2U]==cls(i),j));
                
                ErrRec(i,j) = sqrt((mean(sourceXp([Y1;Y1U]==cls(i),j))-mean(targetXp([Y2;Y2U]==cls(i),j))).^2);
                ErrRecInv(i,j) = sqrt((mean(sourceXpInv([Y1;Y1U]==cls(i),j))-mean(targetXp([Y2;Y2U]==cls(i),j))).^2);
                
            end
        end
        
        
        mean(ErrRec);
        mean(ErrRecInv);
        
        Sc = max(ErrRec)>max(ErrRecInv);
        ALPHA(1:n1,Sc) = ALPHA(1:n1,Sc)*-1;
        
        
        % 4) Project the data
        
        
        nVectLin = min(NF,rank(KBK));
        nVectLin =  min(nVectLin,rank(KAK));
        
        for Nf = 1:nVectLin
            
            E1     = ALPHA(1:n1,1:Nf);
            E2     = ALPHA(n1+1:end,1:Nf);
            Phi1toF = E1'*K1;
            Phi2toF = E2'*K2;
            
            Phi1TtoF = E1'*KT1;
            Phi2TtoF = E2'*KT2;
            
            % 5) IMPORTAT: Normalize!!!!
            m1 = mean(Phi1toF');
            m2 = mean(Phi2toF');
            s1 = std(Phi1toF');
            s2 = std(Phi2toF');
            
            Phi1toF = zscore(Phi1toF')';
            Phi2toF = zscore(Phi2toF')';
            
            Phi1TtoF = ((Phi1TtoF' - repmat(m1,2*T,1))./ repmat(s1,2*T,1))';
            Phi2TtoF = ((Phi2TtoF' - repmat(m2,2*T,1))./ repmat(s2,2*T,1))';
            
            
            
            
            % 6) Predict
            Ypred           = classify([Phi1toF(:,1:ncl*N)]',[Phi1toF(:,1:ncl*N),Phi2toF(:,1:ncl*N)]',[Y1;Y2]);
            Reslatent1Kernel = assessment(Y1,Ypred,'class');
            
            Ypred           = classify([Phi1TtoF]',[Phi1toF(:,1:ncl*N),Phi2toF(:,1:ncl*N)]',[Y1;Y2]);
            Reslatent1KernelT = assessment(YT1,Ypred,'class');
            
            Ypred           = classify([Phi2toF(:,1:ncl*N)]',[Phi1toF(:,1:ncl*N),Phi2toF(:,1:ncl*N)]',[Y1;Y2]);
            Reslatent2Kernel = assessment(Y2,Ypred,'class');
            
            Ypred           = classify([Phi2TtoF]',[Phi1toF(:,1:ncl*N),Phi2toF(:,1:ncl*N)]',[Y1;Y2]);
            Reslatent2KernelT = assessment(YT2,Ypred,'class');
            
            
            rl1 = [rl1; Reslatent1Kernel.OA];
            rlT1 = [rlT1; Reslatent1KernelT.OA];
            
            rl2 = [rl2; Reslatent2Kernel.OA];
            rlT2 = [rlT2; Reslatent2KernelT.OA];
            
        end
        
        Phi1TtoF_Lin = Phi1TtoF;
        Phi2TtoF_Lin = Phi2TtoF;
        
        
        results.Lin{r,dim}.X1 = rl1;
        results.Lin{r,dim}.XT1 = rlT1;
        results.Lin{r,dim}.X2 = rl2;
        results.Lin{r,dim}.XT2 = rlT2;
        
        
        %% KEMA - RBF KERNEL
        disp('  Mapping with the RBF kernel ...')
        
        % 2) Compute RBF kernels
        sigma1 =  15*mean(pdist([X1]'));
        K1 = kernelmatrix('rbf',[X1,U1],[X1,U1],sigma1);
        sigma2 =  15*mean(pdist([X2]'));
        K2 = kernelmatrix('rbf',[X2,U2],[X2,U2],sigma2);
        
        K = blkdiag(K1,K2);
        
        KT1 = kernelmatrix('rbf',[X1,U1],XT1,sigma1);
        KT2 = kernelmatrix('rbf',[X2,U2],XT2,sigma2);
        
        
        KAK = K*A*K;
        KBK = K*B*K;
        
        % 3) Extract all features (now we can extract n dimensions!)
        [ALPHA LAMBDA] = gen_eig(KAK,KBK,'LM');
        
        [LAMBDA j] = sort(diag(LAMBDA));
        ALPHA = ALPHA(:,j);
        
    
        
        % 3b) check which projections must be inverted (with the 'mean of projected
        % samples per class' trick) and flip the axis that must be flipped
        E1     = ALPHA(1:n1,:);
        E2     = ALPHA(n1+1:end,:);
        sourceXpInv = (E1'*K1*-1)';
        sourceXp = (E1'*K1)';
        targetXp = (E2'*K2)';
        
        
        sourceXpInv = zscore(sourceXpInv);
        sourceXp = zscore(sourceXp);
        targetXp = zscore(targetXp);
        
        
        ErrRec = zeros(numel(unique(Y1)),size(ALPHA,2));
        ErrRecInv = zeros(numel(unique(Y1)),size(ALPHA,2));
        
        m1 = zeros(numel(unique(Y1)),size(ALPHA,2));
        m1inv = zeros(numel(unique(Y1)),size(ALPHA,2));
        m2 = zeros(numel(unique(Y1)),size(ALPHA,2));
        
        cls = unique(Y1);
        
        for j = 1:size(ALPHA,2)
            
            for i = 1:numel(unique(Y1))
                
                m1inv(i,j) = mean(sourceXpInv([Y1;Y1U]==cls(i),j));
                m1(i,j) = mean(sourceXp([Y1;Y1U]==cls(i),j));
                m2(i,j) = mean(targetXp([Y2;Y2U]==cls(i),j));
                
                ErrRec(i,j) = sqrt((mean(sourceXp([Y1;Y1U]==cls(i),j))-mean(targetXp([Y2;Y2U]==cls(i),j))).^2);
                ErrRecInv(i,j) = sqrt((mean(sourceXpInv([Y1;Y1U]==cls(i),j))-mean(targetXp([Y2;Y2U]==cls(i),j))).^2);
                
            end
        end
        
        
        mean(ErrRec);
        mean(ErrRecInv);
        
        Sc = max(ErrRec)>max(ErrRecInv);
        ALPHA(1:n1,Sc) = ALPHA(1:n1,Sc)*-1;
        
        % 4) Project the data
        nVectRBF = min(NF,rank(KBK));
        nVectRBF =  min(nVectRBF,rank(KAK));
        
        for Nf = 1:nVectRBF
            
            E1     = ALPHA(1:n1,1:Nf);
            E2     = ALPHA(n1+1:end,1:Nf);
            Phi1toF = E1'*K1;
            Phi2toF = E2'*K2;
            
            Phi1TtoF = E1'*KT1;
            Phi2TtoF = E2'*KT2;
            
            % 5) IMPORTAT: Normalize!!!!
            m1 = mean(Phi1toF');
            m2 = mean(Phi2toF');
            s1 = std(Phi1toF');
            s2 = std(Phi2toF');
            
            Phi1toF = zscore(Phi1toF')';
            Phi2toF = zscore(Phi2toF')';
            
            Phi1TtoF = ((Phi1TtoF' - repmat(m1,2*T,1))./ repmat(s1,2*T,1))';
            Phi2TtoF = ((Phi2TtoF' - repmat(m2,2*T,1))./ repmat(s2,2*T,1))';
            
            
            
            
            % 6) Predict
            Ypred           = classify([Phi1toF(:,1:ncl*N)]',[Phi1toF(:,1:ncl*N),Phi2toF(:,1:ncl*N)]',[Y1;Y2]);
            Reslatent1Kernel2 = assessment(Y1,Ypred,'class');
            
            Ypred           = classify([Phi1TtoF]',[Phi1toF(:,1:ncl*N),Phi2toF(:,1:ncl*N)]',[Y1;Y2]);
            Reslatent1Kernel2T = assessment(YT1,Ypred,'class');
            
            Ypred           = classify([Phi2toF(:,1:ncl*N)]',[Phi1toF(:,1:ncl*N),Phi2toF(:,1:ncl*N)]',[Y1;Y2]);
            Reslatent2Kernel2 = assessment(Y2,Ypred,'class');
            
            Ypred           = classify([Phi2TtoF]',[Phi1toF(:,1:ncl*N),Phi2toF(:,1:ncl*N)]',[Y1;Y2]);
            Reslatent2Kernel2T = assessment(YT2,Ypred,'class');
            
            
            r1 = [r1; Reslatent1Kernel2.OA];
            rT1 = [rT1; Reslatent1Kernel2T.OA];
            
            r2 = [r2; Reslatent2Kernel2.OA];
            rT2 = [rT2; Reslatent2Kernel2T.OA];
            
        end
        
        results.RBF{r,dim}.X1 = r1;
        results.RBF{r,dim}.XT1 = rT1;
        results.RBF{r,dim}.X2 = r2;
        results.RBF{r,dim}.XT2 = rT2;
        
        
        
        %% unprojected
        
        %train error
        YpredO11 = classify(X1',X1',Y1);
        ResOrig11 = assessment(Y1,YpredO11,'class');
        r_la11 = ResOrig11.OA;
        
        YpredO22 = classify(X2',X2',Y2);
        ResOrig22 = assessment(Y2,YpredO22,'class');
        r_la22 = ResOrig22.OA;
        
        %test error
        YpredT11 = classify(XT1',X1',Y1);
        ResT11 = assessment(YT1,YpredT11,'class');
        r_un11 = ResT11.OA;
        
        YpredT22 = classify(XT2',X2',Y2);
        ResT22 = assessment(YT2,YpredT22,'class');
        r_un22 = ResT22.OA;
        
        
        results.Upper{r,dim}.X1= r_la11;
        results.Upper{r,dim}.XT1 = r_un11;
        results.Upper{r,dim}.X2 = r_la22;
        results.Upper{r,dim}.XT2 = r_un22;
        
        
    end
    
end


%% Plots

close all
% 


if size(XT1,1) < size(XT2,1)
    XT1 = [XT1; 0.5+zeros(1,length(XT1))];
end

if size(XT2,1) < size(XT1,1)
    XT2 = [XT2; 0.5+zeros(1,length(XT2))];
end

% PLOT 1: original data
if min(size(XT1,1),size(XT2,1)) == 2
    
figure,
subplot(1,2,1)
 scatter(XT1(1,:),XT1(2,:),20,YT1,'f'), hold on, scatter(XT2(1,:),XT2(2,:),20,YT2),colormap(jet)
 title('original data (colors are classes)')
 grid on 
 

subplot(1,2,2)
 plot(XT1(1,:),XT1(2,:),'r.'), hold on, plot(XT2(1,:),XT2(2,:),'.'),colormap(jet)
 %legend('Domain 1','Domain 2')
 grid on
 title('Domains (red = X1, blue= X2)')
    
    
else

figure,
subplot(1,2,1)
 scatter3(XT1(1,:),XT1(2,:),XT1(3,:),20,YT1,'f'), hold on, scatter3(XT2(1,:),XT2(2,:),XT2(3,:),20,YT2),colormap(jet)
 title('original data (colors are classes)')
 grid on 
 axis image
 
subplot(1,2,2)
 plot3(XT1(1,:),XT1(2,:),XT1(3,:),'r.'), hold on, plot3(XT2(1,:),XT2(2,:),XT2(3,:),'.'),colormap(jet)
 %legend('Domain 1','Domain 2')
 grid on
 title('Domains (red = X1, blue= X2)')
 axis image
 
end

% PLOT 2: projected data
figure
% subplot(2,2,1)
%  scatter(XT1toF(1,:),XT1toF(2,:),20,YT1,'f'), hold on, scatter(XT2toF(1,:),XT2toF(2,:),20,YT2),colormap(jet),hold off
%  title('Projected data (Wang)'),grid on
%  axis([-2.5 2.5 -2.5 2.5])
 
subplot(2,2,1)
 scatter(Phi1TtoF_Lin(1,:),Phi1TtoF_Lin(2,:),20,YT1,'f'), hold on, scatter(Phi2TtoF_Lin(1,:),Phi2TtoF_Lin(2,:),20,YT2),colormap(jet),hold off
 title('Projected data (Linear K)'),grid on
 axis([-2.5 2.5 -2.5 2.5])
 
subplot(2,2,2)
 plot(Phi1TtoF_Lin(1,:),Phi1TtoF_Lin(2,:),'r.'), hold on, plot(Phi2TtoF_Lin(1,:),Phi2TtoF_Lin(2,:),'.'),colormap(jet),hold off
 title('Projected data (Linear K, domains)'),grid on
 axis([-2.5 2.5 -2.5 2.5])
 
 subplot(2,2,3)
 scatter(Phi1TtoF(1,:),Phi1TtoF(2,:),20,YT1,'f'), hold on, scatter(Phi2TtoF(1,:),Phi2TtoF(2,:),20,YT2),colormap(jet),hold off
 title('Projected data (RBF)'),grid on
 axis([-2.5 2.5 -2.5 2.5])
 
subplot(2,2,4)
 plot(Phi1TtoF(1,:),Phi1TtoF(2,:),'r.'), hold on, plot(Phi2TtoF(1,:),Phi2TtoF(2,:),'.'),colormap(jet),hold off
 title('Projected data (RBF, domains)'),grid on
 axis([-2.5 2.5 -2.5 2.5])

 % PLOT 3: test error in first domain
figure(300)
semilogy(1:nVectLin,100-rlT1,'x-')
hold on,semilogy(1:nVectRBF,100-rT1,'r-')
semilogy(1:d,100-rWT1,'c-.')
semilogy(1:nVectRBF,repmat(100-r_un11,nVectRBF,1),'k:')
%semilogy(1:nVectRBF,repmat(-1,nVectRBF,1),'go:')
 %semilogy(1:nVectRBF,repmat(-1,nVectRBF,1),'mo:')
legend('KEMA, linear kernel','KEMA, RBF kernel','Wang and Mahadevan, 2011','Training with X1 only','Location','NorthEast')
xlabel('Number of dimensions')
ylabel('Error rate')
title('Test, 1st domain')
grid on
axis([0 nVectRBF 0 100])

% PLOT 3: test error in second domain

figure(301)
semilogy(1:nVectLin,100-rlT2,'x-')
hold on,semilogy(1:nVectRBF,100-rT2,'r-')
semilogy(1:d,100-rWT2,'c-.')
%semilogy(1:nVectRBF,repmat(-1,nVectRBF,1),'ko:')
semilogy(1:nVectRBF,repmat(100-r_un22,nVectRBF,1),'k:')
%plot(1:nVectRBF,repmat(ResOriT2.Kappa,nVectRBF,1),'mo:')
legend('KEMA, linear kernel','KEMA, RBF kernel','Wang and Mahadevan, 2011','Training with X2 only','Location','NorthEast')
xlabel('Number of dimensions')
ylabel('Error rate')
title(['Test, 2nd domain'])
grid on
axis([0 nVectRBF 0 100])

pause