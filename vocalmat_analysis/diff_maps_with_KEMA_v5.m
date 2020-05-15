clear all; close all
all_correlations=[];
dist_centroids_all=[];
% addpath(genpath('../'))
work_dir = 'Z:\test'; cd(work_dir)
list = dir;
isdir = [list.isdir].';
list_dir = list(isdir,:); list_dir(1:2)=[];
% list = dir('Control_2nd*');list2 = dir('Agrp_2nd*');
% list3 = dir('Agrp_1st*'); list4 = dir('Agrp_2nd*'); 
% list2 = dir('AJ_AJ*'); list3 = dir('AJ_B6*');
% list = [list; list2;list3;list4];
% list = [list;list2];%;list3;list4];%;list5;list6];
list = list_dir;
show_plots = 1;

confusion_matrix_OA_1 = NaN(size(list,1),size(list,1));
confusion_matrix_OA_2 = NaN(size(list,1),size(list,1));
confusion_matrix_kappa_1 = NaN(size(list,1),size(list,1));
confusion_matrix_kappa_2 = NaN(size(list,1),size(list,1));
confusion_matrix_kappa = NaN(size(list,1),size(list,1));
confusion_matrix_rho = NaN(size(list,1),size(list,1));
chevron_corr = NaN(size(list,1),size(list,1));
complex_corr = NaN(size(list,1),size(list,1));
down_fm_corr = NaN(size(list,1),size(list,1));
flat_corr = NaN(size(list,1),size(list,1));
mult_steps_corr = NaN(size(list,1),size(list,1));
rev_chevron_corr = NaN(size(list,1),size(list,1));
short_corr = NaN(size(list,1),size(list,1));
step_down_corr = NaN(size(list,1),size(list,1));
step_up_corr = NaN(size(list,1),size(list,1));
two_steps_corr = NaN(size(list,1),size(list,1));
up_fm_corr = NaN(size(list,1),size(list,1));

for list_idx = 1:size(list,1)
    name = list(list_idx).name; %name = name(20:end-4);
    %     X1 = load([work_dir '\maps_1_Agrp_2nd_' name '.mat']); X1 = X1.maps_1;
    %     Y1 =load([work_dir '\Agrp_2nd_' name '.mat']); eval(['Y1 = Y1.vocalizations_Agrp_2nd_' name '(:,end);']);
    
    for list2_idx=list_idx+1:size(list,1)
%     for list2_idx=1:size(list2,1)
        try
            %         try
            name2 = list(list2_idx).name; %name2 = name2(20:end-4);
            % X1 = load('Z:\Dietrich_Server\Gabriela\Backup\idisco_90mins_isolation\AJ\maps_1_ajmom_ajpups.mat'); X1 = X1.maps_1;
            % Y1 = load('Z:\Dietrich_Server\Gabriela\Backup\idisco_90mins_isolation\AJ\ajmom_ajpups.mat'); Y1=Y1.vocalizations_aj_aj(:,end);
            % X1 = load('Z:\Dietrich_Server\Gabriela\Backup\3. Cross_foster\AJ-crossfoster\maps_1_b6mom_b6pups.mat'); X1 = X1.maps_1;
            % Y1 = load('Z:\Dietrich_Server\Gabriela\Backup\3. Cross_foster\AJ-crossfoster\b6mom_b6pups.mat'); Y1=Y1.vocalizations_b6_b6(:,end);
            
            % X1 = load('Z:\Dietrich_Server\MZimmer\with_diffusion_maps\Agrp_trpv1_1st\maps_1_vocalizations_Agrp_trpv1_1st_all.mat'); X1 = X1.maps_1;
            % Y1 = load('Z:\Dietrich_Server\MZimmer\with_diffusion_maps\Agrp_trpv1_1st\vocalizations_Agrp_trpv1_1st_all.mat'); Y1=Y1.vocalizations_Agrp_trpv1_1st_all(:,end);
            % X1 = load('Z:\Dietrich_Server\MZimmer\with_diffusion_maps\Control_2nd\maps_1_vocalizations_control_2nd_all.mat'); X1 = X1.maps_1;
            % Y1 = load('Z:\Dietrich_Server\MZimmer\with_diffusion_maps\Control_2nd\vocalizations_control_2nd_all.mat'); Y1=Y1.vocalizations_Control_2nd_all(:,end);
            
            % X2 = load('Z:\Dietrich_Server\Gabriela\Backup\idisco_90mins_isolation\B6\maps_1_b6mom_b6pups.mat'); X2 = X2.maps_1;
            % Y2 = load('Z:\Dietrich_Server\Gabriela\Backup\idisco_90mins_isolation\B6\b6mom_b6pups.mat'); Y2=Y2.vocalizations_b6_b6(:,end);
            % X2 = load('Z:\Dietrich_Server\Gabriela\Backup\3. Cross_foster\AJ-crossfoster\maps_1_ajmom_ajpups.mat'); X2 = X2.maps_1;
            % Y2 = load('Z:\Dietrich_Server\Gabriela\Backup\3. Cross_foster\AJ-crossfoster\ajmom_ajpups.mat'); Y2=Y2.vocalizations_aj_aj(:,end);
            % X2 = load('Z:\Dietrich_Server\MZimmer\with_diffusion_maps\Control_2nd\maps_1_vocalizations_control_2nd_all.mat'); X2 = X2.maps_1;
            % Y2 = load('Z:\Dietrich_Server\MZimmer\with_diffusion_maps\Control_2nd\vocalizations_control_2nd_all.mat'); Y2=Y2.vocalizations_Control_2nd_all(:,end);
            % X2 = load('Z:\Dietrich_Server\MZimmer\with_diffusion_maps\Agrp_2nd\maps_1_vocalizations_Agrp_2nd_all.mat'); X2 = X2.maps_1;
            % Y2 = load('Z:\Dietrich_Server\MZimmer\with_diffusion_maps\Agrp_2nd\vocalizations_Agrp_2nd_all.mat'); Y2=Y2.vocalizations_Agrp_2nd_all(:,end);
            %         X2 = load('Z:\Dietrich_Server\MZimmer\with_diffusion_maps\Agrp_trpv1_1st\maps_1_vocalizations_Agrp_trpv1_1st_all.mat'); X2 = X2.maps_1;
            %         Y2 = load('Z:\Dietrich_Server\MZimmer\with_diffusion_maps\Agrp_trpv1_1st\vocalizations_Agrp_trpv1_1st_all.mat'); Y2=Y2.vocalizations_Agrp_trpv1_1st_all(:,end);
            %         X1 = load([work_dir '\maps_1_Control_2nd_' name '.mat']); X1 = X1.maps_1; X1_orig=X1';
            %         Y1 =load([work_dir '\Control_2nd_' name '.mat']); eval(['Y1 = Y1.vocalizations_Control_2nd_' name '(:,end);']); Y1_orig = Y1;
            %         X2 = load([work_dir '\maps_1_Control_2nd_' name2 '.mat']); X2 = X2.maps_1; X2_orig = X2';
            %         Y2 = load([work_dir '\Control_2nd_' name2 '.mat']); eval(['Y2 = Y2.vocalizations_Control_2nd_' name2 '(:,end);']);Y2_orig = Y2;
            disp([name ' vs ' name2])
            data = load([work_dir '\' name '\map_' name]); eval(['X1 = data.map_' name ';']); X1 = double(X1); X1_orig=X1'; 
            eval(['Y1 = data.label_' name ';']); Y1 = double(Y1); Y1_orig = Y1;
%             try
%                 Y1 =load([work_dir '\' name]); eval(['Y1 = Y1.label' name(1:end-4) '(:,end);']); Y1_orig = Y1;
%             catch
%                 Y1 =load([work_dir '\' name]); eval(['Y1 = Y1.' name(1:end-4) '(:,end);']); Y1_orig = Y1;
%             end
            data2 = load([work_dir '\' name2 '\map_' name2]); eval(['X2 = data2.map_' name2 ';']); X2 = double(X2); X2_orig=X2'; 
            eval(['Y2 = data2.label_' name2 ';']); Y2 = double(Y2); Y2_orig = Y2;
%             try
%                 Y2 = load([work_dir '\' name2]); eval(['Y2 = Y2.vocalizations_' name2(1:end-4) '(:,end);']);Y2_orig = Y2;
%             catch
%                 Y2 = load([work_dir '\' name2]); eval(['Y2 = Y2.' name2(1:end-4) '(:,end);']);Y2_orig = Y2;
%             end
%             
            %Remove the ones with low samples complex and mult
            X1_group = name;
            X2_group = name2;
            %         path_to_save = 'Z:\Dietrich_Server\MZimmer\with_diffusion_maps\';
            path_to_save = [work_dir '\Combined\'];
            if ~exist([path_to_save X1_group '_' X2_group])
                mkdir([path_to_save X1_group '_' X2_group])
                path_to_save = [path_to_save X1_group '_' X2_group '\'];
            else
                mkdir([path_to_save X1_group '_' X2_group])
                path_to_save = [path_to_save X1_group '_' X2_group '\'];
            end
            %             path_to_save
            % uniqueY1=unique(Y1);
            % uniqueY2=unique(Y2);
            N = 10;%min(size(Y1,1),size(Y2,1));
            y1=[];y2=[];x1=[];x2=[];
            clear indy1 indy2
            for i=1:11
                indy1=find(Y1==i);indy2=find(Y2==i);
                minn=min(size(indy1,1),size(indy2,1));
                if minn>=2*N %because will be 50% for training
                    y1=[y1;Y1(indy1(1:minn))];y2=[y2;Y2(indy2(1:minn))];x1=[x1;X1(indy1(1:minn),:)];x2=[x2;X2(indy2(1:minn),:)];
                end
            end
            X1=x1;X2=x2;Y1=y1;Y2=y2;
            for dim=3
                
                % aux = Y1==2 | Y1==5 | Y1==7; Y1=Y1(~aux);X1=X1(~aux,:);
                % aux = Y2==2 | Y2==5 | Y2==7; Y2=Y2(~aux);X2=X2(~aux,:);
                % minsize=min(size(X1,1),size(X2,1));
                % X1 = X1(round(linspace(1, size(X1,1),minsize)),:);Y1 = Y1(round(linspace(1, size(Y1,1),minsize)),:);
                % X2 = X2(round(linspace(1, size(X2,1),minsize)),:);Y2 = Y2(round(linspace(1, size(Y2,1),minsize)),:);
                wang=1;
                linear_k=0;
                rbf_k=0;
                use_3d = 1;
                r=1;
                % N = 0.1;%min(size(Y1,1),size(Y2,1));
                NF = 20;
                mu = 0.5;               %(1-mu)*L  + mu*(Ls)
                options.graph.nn = 10;  %KNN graph number of neighbors
                r1 = []; rT1 = []; r2 = []; rT2 = [];
                rl1 = []; rlT1 = []; rl2 = []; rlT2 = [];
                rW1 = []; rWT1 = []; rW2 = []; rWT2 = [];
                
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
%                 disp('Mapping with Wang11 method...')
                
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
                
                
                if wang==1
                    % 4) Project the data
                    for Nf = 1:d
                        
                        E1     = V(1:d1,1:Nf);
                        E2     = V(d1+1:end,1:Nf);
                        X1toF = E1'*X1;
                        X2toF = E2'*X2;
                        
                        XT1toF = E1'*XT1;
                        XT2toF = E2'*XT2;
                        
                        X1origtoF = E1'*X1_orig;
                        X2origtoF = E2'*X2_orig;
                        
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
                        
                        %             if Nf==3 %safe results for the 3rd
                        Reslatent2T_Wang{Nf} = Reslatent2T;
                        Reslatent1T_Wang{Nf} = Reslatent1T;
                        
                        Phi1TtoF_Wang_all{Nf} = XT1toF;
                        Phi2TtoF_Wang_all{Nf} = XT2toF;
                        
                        Phi1TtoF_Wang_orig{Nf} = X1origtoF;
                        Phi2TtoF_Wang_orig{Nf} = X2origtoF;
                        %             end
                        
                    end
                    
                    Phi1TtoF_Wang = XT1toF;
                    Phi2TtoF_Wang = XT2toF;
                    
                    
                    
                    
                    results.Wang{r,dim}.X1 = rW1;
                    results.Wang{r,dim}.XT1 = rWT1;
                    results.Wang{r,dim}.X2 = rW2;
                    results.Wang{r,dim}.XT2 = rWT2;
                    
                    
                    
                end
                
                %% KEMA - LINEAR KERNEL
                if linear_k==1
                    disp('  Mapping with the linear kernel ...')
                    
                    % 2) Compute linear kernels
                    % Linear kernel should give the same results as Wang:
                    disp('Compute linear kernels')
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
                    disp('Rotate axis')
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
                    
                    disp('Projecting the data')
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
                    
                end
                
                if rbf_k==1
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
                if show_plots ==1
                    figure('units','normalized','outerposition',[0 0 1 1]),
                    subplot(1,2,1)
                    scatter(XT1(1,:),XT1(2,:),20,YT1,'f'), hold on, scatter(XT2(1,:),XT2(2,:),20,YT2),colormap(jet)
                    title('original data (colors are classes)')
                    grid on
                    
                    
                    subplot(1,2,2)
                    plot(XT1(1,:),XT1(2,:),'r.'), hold on, plot(XT2(1,:),XT2(2,:),'.'),colormap(jet)
                    %legend('Domain 1','Domain 2')
                    grid on
                    title(['Domains (red = ' X1_group ', blue= ' X2_group ')'])
                end
                
                
            else
                
                idxs = {};
                scts = {};
                centroid=[];dist_X1=[];
                for i=1:11
                    %     idxs{i} = T.DL_out == i;
                    idxs{i} = Y1_orig(:,1)==i;
                    scts{i,1} = X1_orig(1,idxs{i});
                    scts{i,2} = X1_orig(2,idxs{i});
                    scts{i,3} = X1_orig(3,idxs{i});
                    centroid(i,:) = [mean(scts{i,1}), mean(scts{i,2}) mean(scts{i,3})];
                end
                
                for i=1:11
                    dist_X1(i,:) =  vecnorm(centroid - centroid(i,:), 2, 2);
                end
                
                for i=1:11
                    %     idxs{i} = T.DL_out == i;
                    idxs{i} = YT1(:,1)==i;
                    scts{i,1} = XT1(1,idxs{i});
                    scts{i,2} = XT1(2,idxs{i});
                    scts{i,3} = XT1(3,idxs{i});
                    centroid(i,:) = [mean(scts{i,1}), mean(scts{i,2}) mean(scts{i,3})];
                end
                if show_plots ==1
                    figure('units','normalized','outerposition',[0 0 1 1]),
                    subplot(1,2,1)
                    %     scatter3(XT1(1,:),XT1(2,:),XT1(3,:),20,YT1,'f'), hold on, scatter3(XT2(1,:),XT2(2,:),XT2(3,:),20,YT2),colormap(jet)
                    hold on
                    chevron     = scatter3(scts{1,1},  scts{1,2},  scts{1,3},  20, 'r', 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                    %     chevron_centroid = scatter3(mean(scts{1,1}),  mean(scts{1,2}), mean(scts{1,3}),  300, 'r', 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.8);
                    complex     = scatter3(scts{2,1},  scts{2,2},  scts{2,3},  20, [0.65 0.65 0.65], 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                    %     complex_centroid = scatter3(mean(scts{2,1}),  mean(scts{2,2}), mean(scts{2,3}),  300, [0.65 0.65 0.65], 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.8);
                    down_fm     = scatter3(scts{3,1},  scts{3,2},  scts{3,3},  20, 'b', 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                    %     down_fm_centroid = scatter3(mean(scts{3,1}),  mean(scts{3,2}), mean(scts{3,3}),  300, 'b', 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.8);
                    flat        = scatter3(scts{4,1},  scts{4,2},  scts{4,3},  20, 'y', 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                    %     flat_centroid = scatter3(mean(scts{4,1}),  mean(scts{4,2}), mean(scts{4,3}),  300, 'y', 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.8);
                    mult_steps  = scatter3(scts{5,1},  scts{5,2},  scts{5,3},  20, 'm', 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                    %     mult_steps_centroid = scatter3(mean(scts{5,1}),  mean(scts{5,2}), mean(scts{5,3}),  300, 'm', 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.8);
                    %     noise_dist  = scatter3(axh,scts{6,1},  scts{6,2},  scts{6,3},  20, 'c', 'filled');
                    rev_chevron = scatter3(scts{6,1},  scts{6,2},  scts{6,3},  20, 'k', 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3,'MarkerFaceAlpha',.3);
                    %     rev_chevron_centroid = scatter3(mean(scts{6,1}),  mean(scts{6,2}), mean(scts{6,3}),  300, 'k', 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.8);
                    shorts      = scatter3(scts{7,1},  scts{7,2},  scts{7,3},  20, [0.49 0.18 0.56], 'filled','MarkerEdgeAlpha',.5,'MarkerFaceAlpha',.3);
                    %     shorts_centroid = scatter3(mean(scts{7,1}),  mean(scts{7,2}), mean(scts{7,3}),  300, [0.49 0.18 0.56], 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.8);
                    step_down   = scatter3(scts{8,1},  scts{8,2},  scts{8,3},  20, [0.333333333333333 1 0.666666666666667], 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                    %     step_down_centroid = scatter3(mean(scts{8,1}),  mean(scts{8,2}), mean(scts{8,3}),  300, [0.333333333333333 1 0.666666666666667], 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.8);
                    step_up     = scatter3(scts{9,1}, scts{9,2}, scts{9,3}, 20, [1 0.666666666666667 0], 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                    %     step_up_centroid = scatter3(mean(scts{9,1}),  mean(scts{9,2}), mean(scts{9,3}),  300, [1 0.666666666666667 0], 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.8);
                    two_steps   = scatter3(scts{10,1}, scts{10,2}, scts{10,3}, 20, [0.47 0.67 0.19], 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                    %     two_steps_centroid = scatter3(mean(scts{10,1}),  mean(scts{10,2}), mean(scts{10,3}),  300, [0.47 0.67 0.19], 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.8);
                    up_fm       = scatter3(scts{11,1}, scts{11,2}, scts{11,3}, 20, [0 0.666666666666667 1], 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                    %     up_fm_centroid = scatter3(mean(scts{11,1}),  mean(scts{11,2}), mean(scts{11,3}),  300, [0 0.666666666666667 1], 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.8);
                    %             title(X1_group,'Interpreter','none')
                    title('Classes')
                    grid on
                    axis image
                    set(gca,'fontsize', 15);
                    view(-50, 10);
                    box on
                end
                
                %     figure('units','normalized','outerposition',[0 0 1 1]),
                idxs = {};
                scts = {};
                centroid=[];dist_X2=[];
                for i=1:11
                    %     idxs{i} = T.DL_out == i;
                    idxs{i} = Y2_orig(:,1)==i;
                    scts{i,1} = X2_orig(1,idxs{i});
                    scts{i,2} = X2_orig(2,idxs{i});
                    scts{i,3} = X2_orig(3,idxs{i});
                    centroid(i,:) = [mean(scts{i,1}), mean(scts{i,2}) mean(scts{i,3})];
                end
                
                for i=1:11
                    dist_X2(i,:) =  vecnorm(centroid - centroid(i,:), 2, 2); %General Vector Norm between centroids
                end
                
                %                     [rho,pval]=corrcoef(dist_X1,dist_X2);
                [rho,pval] = corrcoef(dist_X1,dist_X2,'rows','complete');
                
                for i=1:11
                    %     idxs{i} = T.DL_out == i;
                    idxs{i} = YT2(:,1)==i;
                    scts{i,1} = XT2(1,idxs{i});
                    scts{i,2} = XT2(2,idxs{i});
                    scts{i,3} = XT2(3,idxs{i});
                    centroid(i,:) = [mean(scts{i,1}), mean(scts{i,2}) mean(scts{i,3})];
                end
                
                if show_plots ==1
                    %     scatter3(XT1(1,:),XT1(2,:),XT1(3,:),20,YT1,'f'), hold on, scatter3(XT2(1,:),XT2(2,:),XT2(3,:),20,YT2),colormap(jet)
                    hold on
                    chevron     = scatter3(scts{1,1},  scts{1,2},  scts{1,3},  20, 'r', 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                    complex     = scatter3(scts{2,1},  scts{2,2},  scts{2,3},  20, [0.65 0.65 0.65], 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                    down_fm     = scatter3(scts{3,1},  scts{3,2},  scts{3,3},  20, 'b', 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                    flat        = scatter3(scts{4,1},  scts{4,2},  scts{4,3},  20, 'y', 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                    mult_steps  = scatter3(scts{5,1},  scts{5,2},  scts{5,3},  20, 'm', 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                    %     noise_dist  = scatter3(axh,scts{6,1},  scts{6,2},  scts{6,3},  20, 'c', 'filled');
                    rev_chevron = scatter3(scts{6,1},  scts{6,2},  scts{6,3},  20, 'k', 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3,'MarkerFaceAlpha',.3);
                    shorts      = scatter3(scts{7,1},  scts{7,2},  scts{7,3},  20, [0.49 0.18 0.56], 'filled','MarkerEdgeAlpha',.5,'MarkerFaceAlpha',.3);
                    step_down   = scatter3(scts{8,1},  scts{8,2},  scts{8,3},  20, [0.333333333333333 1 0.666666666666667], 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                    step_up     = scatter3(scts{9,1}, scts{9,2}, scts{9,3}, 20, [1 0.666666666666667 0], 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                    two_steps   = scatter3(scts{10,1}, scts{10,2}, scts{10,3}, 20, [0.47 0.67 0.19], 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                    up_fm       = scatter3(scts{11,1}, scts{11,2}, scts{11,3}, 20, [0 0.666666666666667 1], 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                    legend([chevron, complex, down_fm, flat, mult_steps, rev_chevron, shorts, step_down, step_up, two_steps, up_fm], {'chevron','complex','down_fm','flat','mult_steps','rev_chevron','short','step_down','step_up','two_steps','up_fm'}, 'interpreter', 'none', 'FontSize', 15,'Location','northeast');
                    %     axis([-2.5 2.5 -2.5 2.5])
                    %     view(-50, 10);
                    %             title(X2_group,'Interpreter','none')
                    grid on
                    axis image
                    set(gca,'fontsize', 20);
                    view(-50, 10);
                    box on
                    %     saveas(gcf,[path_to_save 'orig_data_' X1_group '_' X2_group '.fig'])
                    
                    subplot(1,2,2)
                    scatter3(XT1(1,:),XT1(2,:),XT1(3,:), 20,'r','filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3), hold on, scatter3(XT2(1,:),XT2(2,:),XT2(3,:),20,'b','filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3),colormap(jet)
                    %legend('Domain 1','Domain 2')
                    grid on
                    box on
                    title(['Domains'])% (red = ' X1_group ', blue= ' X2_group ')'])
                    axis image
                    %     axis([-2.5 2.5 -2.5 2.5])
                    legend({X1_group, X2_group}, 'interpreter', 'none','Location','northeast')
                    view(-50, 10);
                    set(gca,'fontsize', 20);
                    saveas(gcf,[path_to_save 'orig&domains_' X1_group '_' X2_group '.fig'])
                end
            end
            
            % PLOT 2: projected data
            % figure('units','normalized','outerposition',[0 0 1 1])
            % % subplot(2,2,1)
            % %  scatter(XT1toF(1,:),XT1toF(2,:),20,YT1,'f'), hold on, scatter(XT2toF(1,:),XT2toF(2,:),20,YT2),colormap(jet),hold off
            % %  title('Projected data (Wang)'),grid on
            % %  axis([-2.5 2.5 -2.5 2.5])
            %
            % subplot(2,2,1)
            % scatter(Phi1TtoF_Lin(1,:),Phi1TtoF_Lin(2,:),20,YT1,'f'), hold on, scatter(Phi2TtoF_Lin(1,:),Phi2TtoF_Lin(2,:),20,YT2),colormap(jet),hold off
            % title('Projected data (Linear K)'),grid on
            % axis([-2.5 2.5 -2.5 2.5])
            %
            % subplot(2,2,2)
            % plot(Phi1TtoF_Lin(1,:),Phi1TtoF_Lin(2,:),'r.'), hold on, plot(Phi2TtoF_Lin(1,:),Phi2TtoF_Lin(2,:),'.'),colormap(jet),hold off
            % title('Projected data (Linear K, domains)'),grid on
            % axis([-2.5 2.5 -2.5 2.5])
            %
            % subplot(2,2,3)
            % scatter(Phi1TtoF(1,:),Phi1TtoF(2,:),20,YT1,'f'), hold on, scatter(Phi2TtoF(1,:),Phi2TtoF(2,:),20,YT2),colormap(jet),hold off
            % title('Projected data (RBF)'),grid on
            % axis([-2.5 2.5 -2.5 2.5])
            %
            % subplot(2,2,4)
            % plot(Phi1TtoF(1,:),Phi1TtoF(2,:),'r.'), hold on, plot(Phi2TtoF(1,:),Phi2TtoF(2,:),'.'),colormap(jet),hold off
            % title('Projected data (RBF, domains)'),grid on
            % axis([-2.5 2.5 -2.5 2.5])
            
            
            % PLOT 3: test error in first domain
            if show_plots==1
                figure('units','normalized','outerposition',[0 0 1 1])
                if linear_k==1
                    semilogy(1:nVectLin,100-rlT1,'x-')
                end
                if rbf_k==1
                    hold on,semilogy(1:nVectRBF,100-rT1,'r-')
                    semilogy(1:nVectRBF,repmat(100-r_un11,nVectRBF,1),'k:')
                end
                if wang==1
                    semilogy(1:d,100-rWT1,'c-.','LineWidth',2)
                end
                %semilogy(1:nVectRBF,repmat(-1,nVectRBF,1),'go:')
                %semilogy(1:nVectRBF,repmat(-1,nVectRBF,1),'mo:')
                legend('KEMA, linear kernel','KEMA, RBF kernel','Wang and Mahadevan, 2011','Training with X1 only','Location','NorthEast')
                xlabel('Number of dimensions')
                ylabel('Error rate')
                title('Test, 1st domain')
                grid on
                % axis([0 nVectRBF 0 100])
                set(gca,'fontsize', 15);
                saveas(gcf,[path_to_save 'error_rate_1st_domain_' X1_group '_' X2_group '.fig'])
                
                % PLOT 3: test error in second domain
                figure('units','normalized','outerposition',[0 0 1 1])
                if linear_k==1
                    semilogy(1:nVectLin,100-rlT2,'x-')
                end
                if rbf_k==1
                    hold on,semilogy(1:nVectRBF,100-rT2,'r-')
                    semilogy(1:nVectRBF,repmat(100-r_un22,nVectRBF,1),'k:')
                end
                if wang==1
                    semilogy(1:d,100-rWT2,'c-.','LineWidth',2)
                end
                %semilogy(1:nVectRBF,repmat(-1,nVectRBF,1),'ko:')
                %plot(1:nVectRBF,repmat(ResOriT2.Kappa,nVectRBF,1),'mo:')
                if linear_k==1
                    legend('KEMA, linear kernel','KEMA, RBF kernel','Wang and Mahadevan, 2011','Training with X2 only','Location','NorthEast')
                else
                    legend('Wang and Mahadevan, 2011','Location','NorthEast')
                end
                xlabel('Number of dimensions')
                ylabel('Error rate')
                title(['Test, 2nd domain - ' X1_group ' vs ' X2_group],'Interpreter','none')
                grid on
                % axis([0 nVectRBF 0 100])
                set(gca,'fontsize', 15);
                saveas(gcf,[path_to_save 'error_rate_2nd_domain_' X1_group '_' X2_group '.fig'])
            end
            
            %Redo everything in 3D
            if linear_k==1
                figure('units','normalized','outerposition',[0 0 1 1])
                subplot(2,2,1)
                idxs = {};
                scts = {};
                for i=1:11
                    %     idxs{i} = T.DL_out == i;
                    idxs{i} = YT1(:,1)==i;
                    scts{i,1} = Phi1TtoF_Lin(1,idxs{i});
                    scts{i,2} = Phi1TtoF_Lin(2,idxs{i});
                    scts{i,3} = Phi1TtoF_Lin(3,idxs{i});
                end
                % scatter3(Phi1TtoF_Lin(1,:),Phi1TtoF_Lin(2,:),Phi1TtoF_Lin(3,:),20,YT1,'f'), hold on, scatter3(Phi2TtoF_Lin(1,:),Phi2TtoF_Lin(2,:),Phi2TtoF_Lin(3,:),20,YT2),colormap(jet),hold off
                hold on
                chevron     = scatter3(scts{1,1},  scts{1,2},  scts{1,3},  20, 'r', 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                complex     = scatter3(scts{2,1},  scts{2,2},  scts{2,3},  20, [0.65 0.65 0.65], 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                down_fm     = scatter3(scts{3,1},  scts{3,2},  scts{3,3},  20, 'b', 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                flat        = scatter3(scts{4,1},  scts{4,2},  scts{4,3},  20, 'y', 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                mult_steps  = scatter3(scts{5,1},  scts{5,2},  scts{5,3},  20, 'm', 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                %     noise_dist  = scatter3(axh,scts{6,1},  scts{6,2},  scts{6,3},  20, 'c', 'filled');
                rev_chevron = scatter3(scts{6,1},  scts{6,2},  scts{6,3},  20, 'k', 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3,'MarkerFaceAlpha',.3);
                shorts      = scatter3(scts{7,1},  scts{7,2},  scts{7,3},  20, [0.49 0.18 0.56], 'filled','MarkerEdgeAlpha',.5,'MarkerFaceAlpha',.3);
                step_down   = scatter3(scts{8,1},  scts{8,2},  scts{8,3},  20, [0.333333333333333 1 0.666666666666667], 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                step_up     = scatter3(scts{9,1}, scts{9,2}, scts{9,3}, 20, [1 0.666666666666667 0], 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                two_steps   = scatter3(scts{10,1}, scts{10,2}, scts{10,3}, 20, [0.47 0.67 0.19], 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                up_fm       = scatter3(scts{11,1}, scts{11,2}, scts{11,3}, 20, [0 0.666666666666667 1], 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                % title('Projected data (Linear K)'),grid on
                
                idxs = {};
                scts = {};
                for i=1:11
                    %     idxs{i} = T.DL_out == i;
                    idxs{i} = YT2(:,1)==i;
                    scts{i,1} = Phi2TtoF_Lin(1,idxs{i});
                    scts{i,2} = Phi2TtoF_Lin(2,idxs{i});
                    scts{i,3} = Phi2TtoF_Lin(3,idxs{i});
                end
                % scatter3(Phi1TtoF_Lin(1,:),Phi1TtoF_Lin(2,:),Phi1TtoF_Lin(3,:),20,YT1,'f'), hold on, scatter3(Phi2TtoF_Lin(1,:),Phi2TtoF_Lin(2,:),Phi2TtoF_Lin(3,:),20,YT2),colormap(jet),hold off
                hold on
                chevron     = scatter3(scts{1,1},  scts{1,2},  scts{1,3},  20, 'r', 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                complex     = scatter3(scts{2,1},  scts{2,2},  scts{2,3},  20, [0.65 0.65 0.65], 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                down_fm     = scatter3(scts{3,1},  scts{3,2},  scts{3,3},  20, 'b', 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                flat        = scatter3(scts{4,1},  scts{4,2},  scts{4,3},  20, 'y', 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                mult_steps  = scatter3(scts{5,1},  scts{5,2},  scts{5,3},  20, 'm', 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                %     noise_dist  = scatter3(axh,scts{6,1},  scts{6,2},  scts{6,3},  20, 'c', 'filled');
                rev_chevron = scatter3(scts{6,1},  scts{6,2},  scts{6,3},  20, 'k', 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3,'MarkerFaceAlpha',.3);
                shorts      = scatter3(scts{7,1},  scts{7,2},  scts{7,3},  20, [0.49 0.18 0.56], 'filled','MarkerEdgeAlpha',.5,'MarkerFaceAlpha',.3);
                step_down   = scatter3(scts{8,1},  scts{8,2},  scts{8,3},  20, [0.333333333333333 1 0.666666666666667], 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                step_up     = scatter3(scts{9,1}, scts{9,2}, scts{9,3}, 20, [1 0.666666666666667 0], 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                two_steps   = scatter3(scts{10,1}, scts{10,2}, scts{10,3}, 20, [0.47 0.67 0.19], 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                up_fm       = scatter3(scts{11,1}, scts{11,2}, scts{11,3}, 20, [0 0.666666666666667 1], 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                title('Projected data (Linear K)'),grid on
                axis([-2.5 2.5 -2.5 2.5])
                set(gca,'fontsize', 15);
                view(-50, 10);
                % saveas(gcf,[path_to_save 'projected_linear_' X1_group '_' X2_group '.fig'])
                % axis([-2.5 2.5 -2.5 2.5])
                % view(-50, 10);
                
                subplot(2,2,2)
                plot3(Phi1TtoF_Lin(1,:),Phi1TtoF_Lin(2,:),Phi1TtoF_Lin(3,:),'r.'), hold on, plot3(Phi2TtoF_Lin(1,:),Phi2TtoF_Lin(2,:),Phi2TtoF_Lin(3,:),'b.'),colormap(jet),hold off
                title('Projected data (Linear K, domains)'),grid on
                axis([-2.5 2.5 -2.5 2.5])
                set(gca,'fontsize', 15);
                view(-50, 10);
            end
            % saveas(gcf,[path_to_save 'projected_linear_domain_' X1_group '_' X2_group '.fig'])
            
            if rbf_k==1
                subplot(2,2,3)
                % scatter3(Phi1TtoF(1,:),Phi1TtoF(2,:),Phi1TtoF(3,:),20,YT1,'f'), hold on, scatter3(Phi2TtoF(1,:),Phi2TtoF(2,:),Phi2TtoF(3,:),20,YT2),colormap(jet),hold off
                title('Projected data (RBF)'),grid on
                % axis([-2.5 2.5 -2.5 2.5])
                % view(-50, 10);
                idxs = {};
                scts = {};
                for i=1:11
                    %     idxs{i} = T.DL_out == i;
                    idxs{i} = YT1(:,1)==i;
                    scts{i,1} = Phi1TtoF(1,idxs{i});
                    scts{i,2} = Phi1TtoF(2,idxs{i});
                    scts{i,3} = Phi1TtoF(3,idxs{i});
                end
                
                hold on
                chevron     = scatter3(scts{1,1},  scts{1,2},  scts{1,3},  20, 'r', 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                complex     = scatter3(scts{2,1},  scts{2,2},  scts{2,3},  20, [0.65 0.65 0.65], 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                down_fm     = scatter3(scts{3,1},  scts{3,2},  scts{3,3},  20, 'b', 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                flat        = scatter3(scts{4,1},  scts{4,2},  scts{4,3},  20, 'y', 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                mult_steps  = scatter3(scts{5,1},  scts{5,2},  scts{5,3},  20, 'm', 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                %     noise_dist  = scatter3(axh,scts{6,1},  scts{6,2},  scts{6,3},  20, 'c', 'filled');
                rev_chevron = scatter3(scts{6,1},  scts{6,2},  scts{6,3},  20, 'k', 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3,'MarkerFaceAlpha',.3);
                shorts      = scatter3(scts{7,1},  scts{7,2},  scts{7,3},  20, [0.49 0.18 0.56], 'filled','MarkerEdgeAlpha',.5,'MarkerFaceAlpha',.3);
                step_down   = scatter3(scts{8,1},  scts{8,2},  scts{8,3},  20, [0.333333333333333 1 0.666666666666667], 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                step_up     = scatter3(scts{9,1}, scts{9,2}, scts{9,3}, 20, [1 0.666666666666667 0], 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                two_steps   = scatter3(scts{10,1}, scts{10,2}, scts{10,3}, 20, [0.47 0.67 0.19], 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                up_fm       = scatter3(scts{11,1}, scts{11,2}, scts{11,3}, 20, [0 0.666666666666667 1], 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                axis([-2.5 2.5 -2.5 2.5])
                set(gca,'fontsize', 15);
                view(-50, 10);
                
                idxs = {};
                scts = {};
                for i=1:11
                    %     idxs{i} = T.DL_out == i;
                    idxs{i} = YT2(:,1)==i;
                    scts{i,1} = Phi2TtoF(1,idxs{i});
                    scts{i,2} = Phi2TtoF(2,idxs{i});
                    scts{i,3} = Phi2TtoF(3,idxs{i});
                end
                hold on
                chevron     = scatter3(scts{1,1},  scts{1,2},  scts{1,3},  20, 'r', 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                complex     = scatter3(scts{2,1},  scts{2,2},  scts{2,3},  20, [0.65 0.65 0.65], 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                down_fm     = scatter3(scts{3,1},  scts{3,2},  scts{3,3},  20, 'b', 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                flat        = scatter3(scts{4,1},  scts{4,2},  scts{4,3},  20, 'y', 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                mult_steps  = scatter3(scts{5,1},  scts{5,2},  scts{5,3},  20, 'm', 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                %     noise_dist  = scatter3(axh,scts{6,1},  scts{6,2},  scts{6,3},  20, 'c', 'filled');
                rev_chevron = scatter3(scts{6,1},  scts{6,2},  scts{6,3},  20, 'k', 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3,'MarkerFaceAlpha',.3);
                shorts      = scatter3(scts{7,1},  scts{7,2},  scts{7,3},  20, [0.49 0.18 0.56], 'filled','MarkerEdgeAlpha',.5,'MarkerFaceAlpha',.3);
                step_down   = scatter3(scts{8,1},  scts{8,2},  scts{8,3},  20, [0.333333333333333 1 0.666666666666667], 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                step_up     = scatter3(scts{9,1}, scts{9,2}, scts{9,3}, 20, [1 0.666666666666667 0], 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                two_steps   = scatter3(scts{10,1}, scts{10,2}, scts{10,3}, 20, [0.47 0.67 0.19], 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                up_fm       = scatter3(scts{11,1}, scts{11,2}, scts{11,3}, 20, [0 0.666666666666667 1], 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                legend([chevron, complex, down_fm, flat, mult_steps, rev_chevron, shorts, step_down, step_up, two_steps, up_fm], {'chevron','complex','down_fm','flat','mult_steps','rev_chevron','short','step_down','step_up','two_steps','up_fm'}, 'interpreter', 'none', 'FontSize', 15);
                % title('Projected data (Linear K)'),grid on
                % axis([-2.5 2.5 -2.5 2.5])
                % view(-50, 10);
                % saveas(gcf,[path_to_save 'projected_rbf_' X1_group '_' X2_group '.fig'])
                
                subplot(2,2,4)
                plot3(Phi1TtoF(1,:),Phi1TtoF(2,:),Phi1TtoF(3,:),'r.'), hold on, plot3(Phi2TtoF(1,:),Phi2TtoF(2,:),Phi2TtoF(3,:),'b.'),colormap(jet),hold off
                title('Projected data (RBF, domains)'),grid on
                legend({X1_group, X2_group}, 'interpreter', 'none','Location','northeast')
                set(gca,'fontsize', 15);
                axis([-2.5 2.5 -2.5 2.5])
                view(-50, 10);
                saveas(gcf,[path_to_save 'projected_rbf_domains_' X1_group '_' X2_group '.fig'])
            end
            
            %Wang plots
            if wang==1 && show_plots ==1
                figure('units','normalized','outerposition',[0 0 1 1])
                subplot(1,2,1)
                idxs = {};
                scts = {};
                for i=1:11
                    %     idxs{i} = T.DL_out == i;
                    idxs{i} = YT1(:,1)==i;
                    scts{i,1} = Phi1TtoF_Wang(1,idxs{i});
                    scts{i,2} = Phi1TtoF_Wang(2,idxs{i});
                    scts{i,3} = Phi1TtoF_Wang(3,idxs{i});
                end
                % scatter3(Phi1TtoF_Lin(1,:),Phi1TtoF_Lin(2,:),Phi1TtoF_Lin(3,:),20,YT1,'f'), hold on, scatter3(Phi2TtoF_Lin(1,:),Phi2TtoF_Lin(2,:),Phi2TtoF_Lin(3,:),20,YT2),colormap(jet),hold off
                hold on
                chevron     = scatter3(scts{1,1},  scts{1,2},  scts{1,3},  20, 'r', 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                complex     = scatter3(scts{2,1},  scts{2,2},  scts{2,3},  20, [0.65 0.65 0.65], 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                down_fm     = scatter3(scts{3,1},  scts{3,2},  scts{3,3},  20, 'b', 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                flat        = scatter3(scts{4,1},  scts{4,2},  scts{4,3},  20, 'y', 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                mult_steps  = scatter3(scts{5,1},  scts{5,2},  scts{5,3},  20, 'm', 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                %     noise_dist  = scatter3(axh,scts{6,1},  scts{6,2},  scts{6,3},  20, 'c', 'filled');
                rev_chevron = scatter3(scts{6,1},  scts{6,2},  scts{6,3},  20, 'k', 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3,'MarkerFaceAlpha',.3);
                shorts      = scatter3(scts{7,1},  scts{7,2},  scts{7,3},  20, [0.49 0.18 0.56], 'filled','MarkerEdgeAlpha',.5,'MarkerFaceAlpha',.3);
                step_down   = scatter3(scts{8,1},  scts{8,2},  scts{8,3},  20, [0.333333333333333 1 0.666666666666667], 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                step_up     = scatter3(scts{9,1}, scts{9,2}, scts{9,3}, 20, [1 0.666666666666667 0], 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                two_steps   = scatter3(scts{10,1}, scts{10,2}, scts{10,3}, 20, [0.47 0.67 0.19], 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                up_fm       = scatter3(scts{11,1}, scts{11,2}, scts{11,3}, 20, [0 0.666666666666667 1], 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                
                % title('Projected data (Linear K)'),grid on
                
                idxs = {};
                scts = {};
                for i=1:11
                    %     idxs{i} = T.DL_out == i;
                    idxs{i} = YT2(:,1)==i;
                    scts{i,1} = Phi2TtoF_Wang(1,idxs{i});
                    scts{i,2} = Phi2TtoF_Wang(2,idxs{i});
                    scts{i,3} = Phi2TtoF_Wang(3,idxs{i});
                end
                % scatter3(Phi1TtoF_Lin(1,:),Phi1TtoF_Lin(2,:),Phi1TtoF_Lin(3,:),20,YT1,'f'), hold on, scatter3(Phi2TtoF_Lin(1,:),Phi2TtoF_Lin(2,:),Phi2TtoF_Lin(3,:),20,YT2),colormap(jet),hold off
                hold on
                chevron     = scatter3(scts{1,1},  scts{1,2},  scts{1,3},  20, 'r', 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                complex     = scatter3(scts{2,1},  scts{2,2},  scts{2,3},  20, [0.65 0.65 0.65], 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                down_fm     = scatter3(scts{3,1},  scts{3,2},  scts{3,3},  20, 'b', 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                flat        = scatter3(scts{4,1},  scts{4,2},  scts{4,3},  20, 'y', 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                mult_steps  = scatter3(scts{5,1},  scts{5,2},  scts{5,3},  20, 'm', 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                %     noise_dist  = scatter3(axh,scts{6,1},  scts{6,2},  scts{6,3},  20, 'c', 'filled');
                rev_chevron = scatter3(scts{6,1},  scts{6,2},  scts{6,3},  20, 'k', 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3,'MarkerFaceAlpha',.3);
                shorts      = scatter3(scts{7,1},  scts{7,2},  scts{7,3},  20, [0.49 0.18 0.56], 'filled','MarkerEdgeAlpha',.5,'MarkerFaceAlpha',.3);
                step_down   = scatter3(scts{8,1},  scts{8,2},  scts{8,3},  20, [0.333333333333333 1 0.666666666666667], 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                step_up     = scatter3(scts{9,1}, scts{9,2}, scts{9,3}, 20, [1 0.666666666666667 0], 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                two_steps   = scatter3(scts{10,1}, scts{10,2}, scts{10,3}, 20, [0.47 0.67 0.19], 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                up_fm       = scatter3(scts{11,1}, scts{11,2}, scts{11,3}, 20, [0 0.666666666666667 1], 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                title('Projected data (Wang)'),grid on
                legend([chevron, complex, down_fm, flat, mult_steps, rev_chevron, shorts, step_down, step_up, two_steps, up_fm], {'chevron','complex','down_fm','flat','mult_steps','rev_chevron','short','step_down','step_up','two_steps','up_fm'}, 'interpreter', 'none', 'FontSize', 15,'Location','northeast');
                % axis([-2.5 2.5 -2.5 2.5])
                axis image
                set(gca,'fontsize', 15);
                set(gca, 'TickLabelInterpreter', 'none');
                view(-50, 10);
                % saveas(gcf,[path_to_save 'projected_linear_' X1_group '_' X2_group '.fig'])
                % axis([-2.5 2.5 -2.5 2.5])
                % view(-50, 10);
                
                subplot(1,2,2)
                plot3(Phi1TtoF_Wang(1,:),Phi1TtoF_Wang(2,:),Phi1TtoF_Wang(3,:),'r.'), hold on, plot3(Phi2TtoF_Wang(1,:),Phi2TtoF_Wang(2,:),Phi2TtoF_Wang(3,:),'b.'),colormap(jet),hold off
                title(['Projected data (Wang, domains) - ' X1_group ' vs ' X2_group] ,'Interpreter','none'),grid on
                legend({X1_group, X2_group}, 'interpreter', 'none','Location','northeast')
                % axis([-2.5 2.5 -2.5 2.5])
                axis image
                set(gca,'fontsize', 15);
                set(gca, 'TickLabelInterpreter', 'none');
                view(-50, 10);
                saveas(gcf,[path_to_save 'projected_Wang_' X1_group '_' X2_group '.fig'])
            end
            
            %Alignment per class
            % c = categorical({'chevron','complex','down_fm','flat','mult_steps','rev_chevron','short','step_down','step_up','two_steps','up_fm'});
            % figure('units','normalized','outerposition',[0 0 1 1]), bar(c,Reslatent2T.User)
            % ylabel('Matching labels (%)')
            % set(gca, 'TickLabelInterpreter', 'none'); grid on
            % title(['Alignment performance per class - ' X1_group ' vs ' X2_group] )
            % set(gca,'fontsize', 15);
            % saveas(gcf,[path_to_save 'alignment_performance_Wang_' X1_group '_' X2_group '.fig'])
            
            %         %Redo for eigenvector that gives best alignment
            max_x1 = 3; %[max_x1,max_x1] = max(rWT1); Because only matter until the 3rd eigen vector according to Wang's paper.
            max_x2 = 3; %[max_x2,max_x2] = max(rWT2);
            %         c = categorical({'chevron','complex','down_fm','flat','mult_steps','rev_chevron','short','step_down','step_up','two_steps','up_fm'});
            %         figure('units','normalized','outerposition',[0 0 1 1]), bar(c,Reslatent2T_Wang{max_x2}.User)
            %         ylabel('Matching labels (%)')
            %         set(gca, 'TickLabelInterpreter', 'none'); grid on
            %         title(['Alignment performance per class - 2nd domain - ' X1_group ' vs ' X2_group ' - eigen: ' num2str(max_x2)] )
            %         set(gca,'fontsize', 15);
            %         saveas(gcf,[path_to_save 'alignment_performance_best_align_2nd_Wang_' X1_group '_' X2_group '.fig'])
            %
            %         c = categorical({'chevron','complex','down_fm','flat','mult_steps','rev_chevron','short','step_down','step_up','two_steps','up_fm'});
            %         figure('units','normalized','outerposition',[0 0 1 1]), bar(c,Reslatent1T_Wang{max_x1}.User)
            %         ylabel('Matching labels (%)')
            %         set(gca, 'TickLabelInterpreter', 'none'); grid on
            %         title(['Alignment performance per class - 1st domain - ' X1_group ' vs ' X2_group ' - eigen: ' num2str(max_x1)] )
            %         set(gca,'fontsize', 15);
            %         saveas(gcf,[path_to_save 'alignment_performance_best_align_1st_Wang_' X1_group '_' X2_group '.fig'])
            %
            %         c = categorical({'chevron','complex','down_fm','flat','mult_steps','rev_chevron','short','step_down','step_up','two_steps','up_fm'});
            %         figure('units','normalized','outerposition',[0 0 1 1]), bar(c,mean([Reslatent1T_Wang{max_x1}.User,Reslatent2T_Wang{max_x2}.User],2))
            %         ylabel('Matching labels (%)')
            %         set(gca, 'TickLabelInterpreter', 'none'); grid on
            %         title(['Alignment performance per class - combined (mean) - ' X1_group ' vs ' X2_group ' - eigen: ' num2str(max_x1)] )
            %         set(gca,'fontsize', 15);
            %         saveas(gcf,[path_to_save 'alignment_performance_best_align_mean_Wang_' X1_group '_' X2_group '.fig'])
            %
            close all
            
            if wang==1 && show_plots ==1
                figure('units','normalized','outerposition',[0 0 1 1])
                subplot(1,2,1)
                idxs = {};
                scts = {};
                for i=1:11
                    %     idxs{i} = T.DL_out == i;
                    idxs{i} = YT1(:,1)==i;
                    scts{i,1} = Phi1TtoF_Wang_all{max_x1}(1,idxs{i});
                    scts{i,2} = Phi1TtoF_Wang_all{max_x1}(2,idxs{i});
                    scts{i,3} = Phi1TtoF_Wang_all{max_x1}(3,idxs{i});
                end
                % scatter3(Phi1TtoF_Lin(1,:),Phi1TtoF_Lin(2,:),Phi1TtoF_Lin(3,:),20,YT1,'f'), hold on, scatter3(Phi2TtoF_Lin(1,:),Phi2TtoF_Lin(2,:),Phi2TtoF_Lin(3,:),20,YT2),colormap(jet),hold off
                hold on
                chevron     = scatter3(scts{1,1},  scts{1,2},  scts{1,3},  20, 'r', 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                complex     = scatter3(scts{2,1},  scts{2,2},  scts{2,3},  20, [0.65 0.65 0.65], 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                down_fm     = scatter3(scts{3,1},  scts{3,2},  scts{3,3},  20, 'b', 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                flat        = scatter3(scts{4,1},  scts{4,2},  scts{4,3},  20, 'y', 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                mult_steps  = scatter3(scts{5,1},  scts{5,2},  scts{5,3},  20, 'm', 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                %     noise_dist  = scatter3(axh,scts{6,1},  scts{6,2},  scts{6,3},  20, 'c', 'filled');
                rev_chevron = scatter3(scts{6,1},  scts{6,2},  scts{6,3},  20, 'k', 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3,'MarkerFaceAlpha',.3);
                shorts      = scatter3(scts{7,1},  scts{7,2},  scts{7,3},  20, [0.49 0.18 0.56], 'filled','MarkerEdgeAlpha',.5,'MarkerFaceAlpha',.3);
                step_down   = scatter3(scts{8,1},  scts{8,2},  scts{8,3},  20, [0.333333333333333 1 0.666666666666667], 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                step_up     = scatter3(scts{9,1}, scts{9,2}, scts{9,3}, 20, [1 0.666666666666667 0], 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                two_steps   = scatter3(scts{10,1}, scts{10,2}, scts{10,3}, 20, [0.47 0.67 0.19], 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                up_fm       = scatter3(scts{11,1}, scts{11,2}, scts{11,3}, 20, [0 0.666666666666667 1], 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                
                % title('Projected data (Linear K)'),grid on
                
                idxs = {};
                scts = {};
                for i=1:11
                    %     idxs{i} = T.DL_out == i;
                    idxs{i} = YT2(:,1)==i;
                    scts{i,1} = Phi2TtoF_Wang_all{max_x2}(1,idxs{i});
                    scts{i,2} = Phi2TtoF_Wang_all{max_x2}(2,idxs{i});
                    scts{i,3} = Phi2TtoF_Wang_all{max_x2}(3,idxs{i});
                end
                % scatter3(Phi1TtoF_Lin(1,:),Phi1TtoF_Lin(2,:),Phi1TtoF_Lin(3,:),20,YT1,'f'), hold on, scatter3(Phi2TtoF_Lin(1,:),Phi2TtoF_Lin(2,:),Phi2TtoF_Lin(3,:),20,YT2),colormap(jet),hold off
                hold on
                chevron     = scatter3(scts{1,1},  scts{1,2},  scts{1,3},  20, 'r', 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                complex     = scatter3(scts{2,1},  scts{2,2},  scts{2,3},  20, [0.65 0.65 0.65], 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                down_fm     = scatter3(scts{3,1},  scts{3,2},  scts{3,3},  20, 'b', 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                flat        = scatter3(scts{4,1},  scts{4,2},  scts{4,3},  20, 'y', 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                mult_steps  = scatter3(scts{5,1},  scts{5,2},  scts{5,3},  20, 'm', 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                %     noise_dist  = scatter3(axh,scts{6,1},  scts{6,2},  scts{6,3},  20, 'c', 'filled');
                rev_chevron = scatter3(scts{6,1},  scts{6,2},  scts{6,3},  20, 'k', 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3,'MarkerFaceAlpha',.3);
                shorts      = scatter3(scts{7,1},  scts{7,2},  scts{7,3},  20, [0.49 0.18 0.56], 'filled','MarkerEdgeAlpha',.5,'MarkerFaceAlpha',.3);
                step_down   = scatter3(scts{8,1},  scts{8,2},  scts{8,3},  20, [0.333333333333333 1 0.666666666666667], 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                step_up     = scatter3(scts{9,1}, scts{9,2}, scts{9,3}, 20, [1 0.666666666666667 0], 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                two_steps   = scatter3(scts{10,1}, scts{10,2}, scts{10,3}, 20, [0.47 0.67 0.19], 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                up_fm       = scatter3(scts{11,1}, scts{11,2}, scts{11,3}, 20, [0 0.666666666666667 1], 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                title('Projected data - best alignment (Wang)'),grid on
                legend([chevron, complex, down_fm, flat, mult_steps, rev_chevron, shorts, step_down, step_up, two_steps, up_fm], {'chevron','complex','down_fm','flat','mult_steps','rev_chevron','short','step_down','step_up','two_steps','up_fm'}, 'interpreter', 'none', 'FontSize', 15,'Location','northeast');
                % axis([-2.5 2.5 -2.5 2.5])
                axis image
                set(gca,'fontsize', 15);
                view(-50, 10);
                box on
                % saveas(gcf,[path_to_save 'projected_linear_' X1_group '_' X2_group '.fig'])
                % axis([-2.5 2.5 -2.5 2.5])
                % view(-50, 10);
                
                subplot(1,2,2)
                plot3(Phi1TtoF_Wang_all{max_x1}(1,:),Phi1TtoF_Wang_all{max_x1}(2,:),Phi1TtoF_Wang_all{max_x1}(3,:),'r.'), hold on, plot3(Phi2TtoF_Wang_all{max_x2}(1,:),Phi2TtoF_Wang_all{max_x2}(2,:),Phi2TtoF_Wang_all{max_x2}(3,:),'b.'),colormap(jet),hold off
                title(['Projected data 3D (Wang, domains)'] ,'Interpreter','none'),grid on
                legend({X1_group, X2_group}, 'interpreter', 'none','Location','northeast')
                % axis([-2.5 2.5 -2.5 2.5])
                axis image
                set(gca,'fontsize', 15);
                view(-50, 10);
                saveas(gcf,[path_to_save 'projected_best_align_Wang_' X1_group '_' X2_group '.fig'])
            end
            
            %plot orig projection
            if wang==1 && show_plots ==1
                figure('units','normalized','outerposition',[0 0 1 1])
                subplot(1,2,1)
                idxs = {};
                scts = {};
                for i=1:11
                    %     idxs{i} = T.DL_out == i;
                    idxs{i} = Y1_orig(:,1)==i;
                    scts{i,1} = Phi1TtoF_Wang_orig{max_x1}(1,idxs{i});
                    scts{i,2} = Phi1TtoF_Wang_orig{max_x1}(2,idxs{i});
                    scts{i,3} = Phi1TtoF_Wang_orig{max_x1}(3,idxs{i});
                end
                % scatter3(Phi1TtoF_Lin(1,:),Phi1TtoF_Lin(2,:),Phi1TtoF_Lin(3,:),20,YT1,'f'), hold on, scatter3(Phi2TtoF_Lin(1,:),Phi2TtoF_Lin(2,:),Phi2TtoF_Lin(3,:),20,YT2),colormap(jet),hold off
                hold on
                chevron     = scatter3(scts{1,1},  scts{1,2},  scts{1,3},  20, 'r', 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                complex     = scatter3(scts{2,1},  scts{2,2},  scts{2,3},  20, [0.65 0.65 0.65], 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                down_fm     = scatter3(scts{3,1},  scts{3,2},  scts{3,3},  20, 'b', 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                flat        = scatter3(scts{4,1},  scts{4,2},  scts{4,3},  20, 'y', 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                mult_steps  = scatter3(scts{5,1},  scts{5,2},  scts{5,3},  20, 'm', 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                %     noise_dist  = scatter3(axh,scts{6,1},  scts{6,2},  scts{6,3},  20, 'c', 'filled');
                rev_chevron = scatter3(scts{6,1},  scts{6,2},  scts{6,3},  20, 'k', 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3,'MarkerFaceAlpha',.3);
                shorts      = scatter3(scts{7,1},  scts{7,2},  scts{7,3},  20, [0.49 0.18 0.56], 'filled','MarkerEdgeAlpha',.5,'MarkerFaceAlpha',.3);
                step_down   = scatter3(scts{8,1},  scts{8,2},  scts{8,3},  20, [0.333333333333333 1 0.666666666666667], 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                step_up     = scatter3(scts{9,1}, scts{9,2}, scts{9,3}, 20, [1 0.666666666666667 0], 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                two_steps   = scatter3(scts{10,1}, scts{10,2}, scts{10,3}, 20, [0.47 0.67 0.19], 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                up_fm       = scatter3(scts{11,1}, scts{11,2}, scts{11,3}, 20, [0 0.666666666666667 1], 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                
                % title('Projected data (Linear K)'),grid on
                
                idxs = {};
                scts = {};
                for i=1:11
                    %     idxs{i} = T.DL_out == i;
                    idxs{i} = Y2_orig(:,1)==i;
                    scts{i,1} = Phi2TtoF_Wang_orig{max_x2}(1,idxs{i});
                    scts{i,2} = Phi2TtoF_Wang_orig{max_x2}(2,idxs{i});
                    scts{i,3} = Phi2TtoF_Wang_orig{max_x2}(3,idxs{i});
                end
                % scatter3(Phi1TtoF_Lin(1,:),Phi1TtoF_Lin(2,:),Phi1TtoF_Lin(3,:),20,YT1,'f'), hold on, scatter3(Phi2TtoF_Lin(1,:),Phi2TtoF_Lin(2,:),Phi2TtoF_Lin(3,:),20,YT2),colormap(jet),hold off
                hold on
                chevron     = scatter3(scts{1,1},  scts{1,2},  scts{1,3},  20, 'r', 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                complex     = scatter3(scts{2,1},  scts{2,2},  scts{2,3},  20, [0.65 0.65 0.65], 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                down_fm     = scatter3(scts{3,1},  scts{3,2},  scts{3,3},  20, 'b', 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                flat        = scatter3(scts{4,1},  scts{4,2},  scts{4,3},  20, 'y', 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                mult_steps  = scatter3(scts{5,1},  scts{5,2},  scts{5,3},  20, 'm', 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                %     noise_dist  = scatter3(axh,scts{6,1},  scts{6,2},  scts{6,3},  20, 'c', 'filled');
                rev_chevron = scatter3(scts{6,1},  scts{6,2},  scts{6,3},  20, 'k', 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3,'MarkerFaceAlpha',.3);
                shorts      = scatter3(scts{7,1},  scts{7,2},  scts{7,3},  20, [0.49 0.18 0.56], 'filled','MarkerEdgeAlpha',.5,'MarkerFaceAlpha',.3);
                step_down   = scatter3(scts{8,1},  scts{8,2},  scts{8,3},  20, [0.333333333333333 1 0.666666666666667], 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                step_up     = scatter3(scts{9,1}, scts{9,2}, scts{9,3}, 20, [1 0.666666666666667 0], 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                two_steps   = scatter3(scts{10,1}, scts{10,2}, scts{10,3}, 20, [0.47 0.67 0.19], 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                up_fm       = scatter3(scts{11,1}, scts{11,2}, scts{11,3}, 20, [0 0.666666666666667 1], 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
                title('Projected whole data - best alignment (Wang)'),grid on
                legend([chevron, complex, down_fm, flat, mult_steps, rev_chevron, shorts, step_down, step_up, two_steps, up_fm], {'chevron','complex','down_fm','flat','mult_steps','rev_chevron','short','step_down','step_up','two_steps','up_fm'}, 'interpreter', 'none', 'FontSize', 15,'Location','northeast');
                % axis([-2.5 2.5 -2.5 2.5])
                axis image
                set(gca,'fontsize', 15);
                view(-50, 10);
                box on
                % saveas(gcf,[path_to_save 'projected_linear_' X1_group '_' X2_group '.fig'])
                % axis([-2.5 2.5 -2.5 2.5])
                % view(-50, 10);
                
                
                subplot(1,2,2)
                plot3(Phi1TtoF_Wang_orig{max_x1}(1,:),Phi1TtoF_Wang_orig{max_x1}(2,:),Phi1TtoF_Wang_orig{max_x1}(3,:),'r.'), hold on, plot3(Phi2TtoF_Wang_orig{max_x2}(1,:),Phi2TtoF_Wang_orig{max_x2}(2,:),Phi2TtoF_Wang_orig{max_x2}(3,:),'b.'),colormap(jet),hold off
                title(['Projected whole data 3D (Wang, domains)'] ,'Interpreter','none'),grid on
                legend({X1_group, X2_group}, 'interpreter', 'none','Location','northeast')
                % axis([-2.5 2.5 -2.5 2.5])
                axis image
                set(gca,'fontsize', 15);
                view(-50, 10);
                saveas(gcf,[path_to_save 'projected_whole_data_best_align_Wang_' X1_group '_' X2_group '.fig'])
            end
            
            %Get distance between centroids after projection
            idxs = {}; idxs2 = {};
            scts = {}; scts2 = {}; dist_centroids=[];
            for i=1:11
                idxs2{i} = Y2_orig(:,1)==i;
                idxs{i} = Y1_orig(:,1)==i;
                
                scts{i,1} = Phi1TtoF_Wang_orig{max_x1}(1,idxs{i});
                scts{i,2} = Phi1TtoF_Wang_orig{max_x1}(2,idxs{i});
                scts{i,3} = Phi1TtoF_Wang_orig{max_x1}(3,idxs{i});
                
                scts2{i,1} = Phi2TtoF_Wang_orig{max_x2}(1,idxs2{i});
                scts2{i,2} = Phi2TtoF_Wang_orig{max_x2}(2,idxs2{i});
                scts2{i,3} = Phi2TtoF_Wang_orig{max_x2}(3,idxs2{i});
                
                centroid(i,:) = [mean(scts{i,1}), mean(scts{i,2}) mean(scts{i,3})];
                centroid2(i,:) = [mean(scts2{i,1}), mean(scts2{i,2}) mean(scts2{i,3})];
                dist_centroids(i,:) =  vecnorm(centroid2(i,:) - centroid(i,:), 2, 2); %General Vector Norm between centroids
            end
            dist_centroids_all = [dist_centroids_all; string([X1_group(1:end-4) '_' X2_group(1:end-4)]) dist_centroids'];
            all_correlations = [ all_correlations; string([X1_group(1:end-4) '_' X2_group(1:end-4)]) Reslatent1T_Wang{1,3}.OA Reslatent1T_Wang{1,3}.Kappa Reslatent2T_Wang{1,3}.OA Reslatent2T_Wang{1,3}.Kappa];
            confusion_matrix_OA_1(list_idx,list2_idx) = Reslatent1T_Wang{1,3}.OA;
            confusion_matrix_OA_2(list_idx,list2_idx) = Reslatent2T_Wang{1,3}.OA;
            confusion_matrix_OA = triu(confusion_matrix_OA_1)+triu(confusion_matrix_OA_2,1)';
            confusion_matrix_kappa_1(list_idx,list2_idx) = Reslatent1T_Wang{1,3}.Kappa;
            confusion_matrix_kappa_2(list_idx,list2_idx) = Reslatent2T_Wang{1,3}.Kappa;
            confusion_matrix_kappa(list_idx,list2_idx) = Reslatent1T_Wang{1,3}.Kappa;
            confusion_matrix_kappa(list2_idx,list_idx) = Reslatent2T_Wang{1,3}.Kappa;
            confusion_matrix_rho(list2_idx,list_idx) = rho(1,2); confusion_matrix_rho(list_idx,list2_idx) = rho(1,2);
            
            %show correlation per class
            chevron_corr(list_idx,list2_idx) = dist_centroids(1);
            complex_corr(list_idx,list2_idx) = dist_centroids(2);
            down_fm_corr(list_idx,list2_idx) = dist_centroids(3);
            flat_corr(list_idx,list2_idx) = dist_centroids(4);
            mult_steps_corr(list_idx,list2_idx) = dist_centroids(5);
            rev_chevron_corr(list_idx,list2_idx) = dist_centroids(6);
            short_corr(list_idx,list2_idx) = dist_centroids(7);
            step_down_corr(list_idx,list2_idx) = dist_centroids(8);
            step_up_corr(list_idx,list2_idx) = dist_centroids(9);
            two_steps_corr(list_idx,list2_idx) = dist_centroids(10);
            up_fm_corr(list_idx,list2_idx) = dist_centroids(11);
            
            save([path_to_save X1_group '_' X2_group])
            
        catch
            disp(['There was a problem with ' path_to_save])
        end
    end
    
    
    
end