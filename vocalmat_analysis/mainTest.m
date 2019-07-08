clear 
close all

%% 1) read data and prepare them
%addpath('../TOY/data')


load ellipses2D.mat

exp = '4';
options.kernelt = 'rbf';

modif = createModif(exp);
modif.additDim = 1; % number of replication of the dimensions

%% create data
N=20;
load ../TOY/data/ellipses2D.mat

r = 0.15; % noise in the multidim data

%Add the third discriminant dimension
if modif.X1_3D
    X1 = [X1 linspace(0,1,length(X1))'];
end

if modif.X2_3D
    X2 = [X2 linspace(0,1,length(X2))'];
end
    
X1 = repmat(X1,1,modif.additDim);%ceil(d/size(X1,2))
X2 = repmat(X2,1,modif.additDim);%ceil(d/size(X2,2)

%         for r = linspace(0,1,20)
%
%             X1pr = X1+rand(size(X1))*r;
%             X2pr = X2+rand(size(X2))*r;
%
%             figure(1)
%             plot(X1pr(:,1),X1pr(:,2),'r.')
%             hold on
%             plot(X2pr(:,1),X2pr(:,2),'.')
%             hold off
%             title(num2str(r));pause
%
%
%         end
%         return
%
X1 = X1+rand(size(X1))*r;
X2 = X2+rand(size(X2))*r;



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

[X1 Y1 U1 Y1U indices] = ppc(Xtemp1,Ytemp1,N,0);
[X2 Y2 U2 Y2U indices] = ppc(Xtemp2,Ytemp2,N,0);

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

% if modif.additDim
%    X1 = [X1;zeros(1,length(X1))];
%    U1 = [U1;zeros(1,length(U1))];
%    XT1 = [XT1;zeros(1,length(XT1))];
%    
%    X1(3,:) = linspace(min(X1(1,:)),max(X1(1,:)),length(X1))+rand(1,length(X1))/10;
%    U1(3,:) = linspace(min(U1(1,:)),max(U1(1,:)),length(U1))+rand(1,length(U1))/10;
%    XT1(3,:) = linspace(min(XT1(1,:)),max(XT1(1,:)),length(XT1))+rand(1,length(XT1))/10; 
% end

if modif.additDimNoise
   X1 = [X1;rand(1,length(X1))/1];
   U1 = [U1;rand(1,length(U1))/1];
   XT1 = [XT1;rand(1,length(XT1))/1];
   
    
    
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

[dT1 T1] = size(XT1)
[dT2 T2] = size(XT2)

dT = dT1+dT2;

labeled{1,1}.X = X1;
labeled{1,2}.X = X2;
labeled{1,1}.Y = Y1;
labeled{1,2}.Y = Y2;

unlabeled{1,1}.X = U1;
unlabeled{1,2}.X = U2;


test{1,1}.X = XT1;
test{1,2}.X = XT2;




%% 2) Find projections

[ALPHA,LAMBDA,options] = KMA(labeled,unlabeled,options);

%% 3) project test data

[Phi] = KMAproject(labeled,unlabeled,test,ALPHA,options);


%% 4) Classify

Phi1toF = Phi{1,1}.train;
Phi1TtoF = Phi{1,1}.test;
Phi2toF = Phi{1,2}.train;
Phi2TtoF = Phi{1,2}.test;

r1 = [];
r2 = [];
rT1 = [];
rT2 = [];

for NF = 1:options.nVect
    
    
   
    % 6) Plot results
    Ypred           = classify([Phi1toF(1:NF,1:ncl*N)]',[Phi1toF(1:NF,1:ncl*N),Phi2toF(1:NF,1:ncl*N)]',[Y1;Y2]);
    Reslatent1Kernel2 = assessment(Y1,Ypred,'class');
    
    Ypred           = classify([Phi1TtoF(1:NF,:)]',[Phi1toF(1:NF,1:ncl*N),Phi2toF(1:NF,1:ncl*N)]',[Y1;Y2]);
    Reslatent1Kernel2T = assessment(YT1,Ypred,'class');
    
    Ypred           = classify([Phi2toF(1:NF,1:ncl*N)]',[Phi1toF(1:NF,1:ncl*N),Phi2toF(1:NF,1:ncl*N)]',[Y1;Y2]);
    Reslatent2Kernel2 = assessment(Y2,Ypred,'class');
    
    Ypred           = classify([Phi2TtoF(1:NF,:)]',[Phi1toF(1:NF,1:ncl*N),Phi2toF(1:NF,1:ncl*N)]',[Y1;Y2]);
    Reslatent2Kernel2T = assessment(YT2,Ypred,'class');
    
    
    r1 = [r1; Reslatent1Kernel2.Kappa];
    rT1 = [rT1; Reslatent1Kernel2T.Kappa];
    
    r2 = [r2; Reslatent2Kernel2.Kappa];
    rT2 = [rT2; Reslatent2Kernel2T.Kappa];
    
end

%% 5) plot

figure(1)
plot(1:options.nVect,1-rT1,'r-'),grid on


figure(2)
plot(1:options.nVect,1-rT2,'r-'),grid on

figure(3),
scatter(Phi1TtoF(1,:),Phi1TtoF(2,:),20,YT1,'f'), hold on, scatter(Phi2TtoF(1,:),Phi2TtoF(2,:),20,YT2),colormap(jet),hold off
grid on
axis([-2.5 2.5 -2.5 2.5])
 
 
figure(4),
 plot(Phi1TtoF(1,:),Phi1TtoF(2,:),'r.'), hold on, plot(Phi2TtoF(1,:),Phi2TtoF(2,:),'.'),colormap(jet),hold off
 grid on
 axis([-2.5 2.5 -2.5 2.5])
 
tile
