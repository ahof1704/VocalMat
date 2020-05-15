function [proj] = KMAproject(labeled,unlabeled,test,ALPHA,options)


% Kernel manifold alignment
% 
% Usage :    [eigenvectors,eigenvalues] = KMA(Labeled,Unlabeled,NumDomains,options)
%
% Inputs: 
%
% - labeled:    structure with labeled data [1,NumDomains].
%               each cell has X (n1 x dim1) and Y (n1 x 1) fields
%
% - unlabeled:  structure with unlabeled data [1,NumDomains].
%               each cell has U (u1 x dim1)
%
% - test:       structure with test data [1,numDomains]
%               each cell has X (n1 x dim1) and Y (n1 x 1) fields
%
% - ALPHA: eigenvectors issued from KMA.m
%
% - options:    .numDomains
%               .kernelt = 'lin','rbf','int','Wan'
%               .sigma (only in rbf case)
%               .nn = nearest neighbors in graph
%               .mu = mu in the mixture geometry/labels
%               .nVect = max number of projections
%
%
% Outputs:
%
% - proj = projected data (each cells is n1 x options.nVect)



%% Create data matrices
Y = [];
n = 0;
d = 0;



for i = 1:options.numDomains
    eval(sprintf('X%i = [labeled{1,i}.X,unlabeled{1,i}.X];',i));
    eval(sprintf('XT%i = [test{1,i}.X];',i));
    eval(sprintf('Y%i = [labeled{1,i}.Y];',i));
    eval(sprintf('Y%iU = zeros(size(unlabeled{1,i}.X,2),1);',i));
    eval(sprintf('Y = [Y; Y%i;zeros(size(unlabeled{1,i}.X,2),1)];',i));
    
    eval(sprintf('[d%i n%i] = size(X%i);[z nT%i] = size(XT%i);n = n+n%i;d = d + d%i;',i,i,i,i,i,i,i));
    
end

%% The kernels

switch lower(options.kernelt)      
      
    case 'wan'
        for i = 1:options.numDomains
            eval(sprintf('n%i = d%i;',i,i));
            eval(sprintf('K%i = X%i;',i,i));
            eval(sprintf('KT%i = XT%i;',i,i));
            
        end
    
    case 'lin'
       
        for i = 1:options.numDomains 
            eval(sprintf('K%i = [X%i]''*[X%i];',i,i,i)); 
            eval(sprintf('KT%i = [X%i]''*[XT%i];',i,i,i));
        end
        
        
    case {'rbf','chi2','histlag'}

        for i = 1:options.numDomains
            eval(sprintf('K%i = kernelmatrix(''%s'',X%i,X%i,options.sigma);',i,options.kernelt,i,i));
            eval(sprintf('KT%i = kernelmatrix(''%s'',X%i,XT%i,options.sigma);',i,options.kernelt,i,i));
        end
        
    case {'pga'}

        for i = 1:options.numDomains
            eval(sprintf('K%i = kernelmatrix(''%s'',X%i,X%i,options.sigma{1,i},options.b);',i,options.kernelt,i,i));
            eval(sprintf('KT%i = kernelmatrix(''%s'',X%i,XT%i,options.sigma{1,i},options.b);',i,options.kernelt,i,i));
        end
        
    case {'int','jen'}
        for i = 1:options.numDomains
            eval(sprintf('K%i = kernelmatrix(''%s'',X%i,X%i);',i,options.kernelt,i,i));
            eval(sprintf('KT%i = kernelmatrix(''%s'',X%i,XT%i);',i,options.kernelt,i,i));
        end
        
    otherwise
        disp('unknown kernel type. Exiting')
        return
        
end

%% project the data



b = 1;
e = n1;

for i = 1:options.numDomains

    eval(sprintf('E%i = ALPHA(b:e,:);',i));
    if i < options.numDomains
        eval(sprintf('b = b+n%i;e=e+n%i;',i,i+1));
    end
    
    eval(sprintf('PhitoF = E%i''*K%i;',i,i));
    eval(sprintf('PhiTtoF = E%i''*KT%i;',i,i));
    
    
    % 5) IMPORTAT: Normalize!!!!
    m = mean(PhitoF');
    s =  std(PhitoF');
    
    PhitoF = zscore(PhitoF');
    
    
    eval(sprintf('PhiTtoF = ((PhiTtoF'' - repmat(m,nT%i,1))./ repmat(s,nT%i,1))'';',i,i));
    
    proj{1,i}.train = PhitoF';
    proj{1,i}.test= PhiTtoF;
    
end

