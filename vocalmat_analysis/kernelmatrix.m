% function K = kernelmatrix(ker,X,X2,sigma)
%
% Inputs: 
%	ker:    'lin','poly','rbf','sam'
%	X:	data matrix with training samples in columns and features in rows
%	X2:	data matrix with test samples in columnsand features in rows
%	sigma: width of the RBF kernel
% 	b:     bias in the linear and polinomial kernel 
%	d:     degree in the polynomial kernel
%
% Output:
%	K: kernel matrix

% With Fast Computation of the RBF kernel matrix
% To speed up the computation, we exploit a decomposition of the Euclidean distance (norm)
%
% Gustavo Camps-Valls, 2006
% Jordi (jordi@uv.es),
%   2007-11: if/then -> switch, and fixed RBF kernel
%   2010-04: RBF can be computed now also on vectors with only one feature (ie: scalars)

function K = kernelmatrix(ker,X,X2,sigma,b)

switch ker
    case 'lin'
        if exist('X2','var')
          K = X' * X2;
        else
          K = X' * X;
        end

    case 'poly'
        if exist('X2','var')
          K = (X' * X2 + b).^d;
        else
          K = (X' * X + b).^d;
        end

    case 'rbf'
        if size(X,1) == 1
            n1sq = X.^2;
        else
            n1sq = sum(X.^2);
        end
        n1 = size(X,2);

        if exist('X2','var');
            if size(X2,1) == 1
                n2sq = X2.^2;
            else
              n2sq = sum(X2.^2);
            end
            n2 = size(X2,2);
            D = (ones(n2,1)*n1sq)' + ones(n1,1)*n2sq -2*X'*X2;
        else
            D = (ones(n1,1)*n1sq)' + ones(n1,1)*n1sq -2*X'*X;
        end
        K = exp(-D/(2*sigma^2));
        
    case 'pga'
        if size(X,1) == 1
            n1sq = X.^2;
        else
            n1sq = sum(X.^2);
        end
        n1 = size(X,2);
        
        if exist('X2','var');
            if size(X2,1) == 1
                n2sq = X2.^2;
            else
                n2sq = sum(X2.^2);
            end
            n2 = size(X2,2);
            D = (ones(n2,1)*n1sq)' + ones(n1,1)*n2sq -2*X'*X2;
        else
            D = (ones(n1,1)*n1sq)' + ones(n1,1)*n1sq -2*X'*X;
        end
        K = exp(-D.^b/(sigma^b));
	
    case 'sam'
        if exist('X2','var');
          D = X'*X2;
        else
          D = X'*X;
        end
        K = exp(-acos(D).^2/(2*sigma^2));
        
    case 'int'
        a = size(X,2); b = size(X2,2); 
        K = zeros(a, b);
        for i = 1:a
            Va = repmat(X(:,i),1,b);
            K(i,:) = 0.5*sum(Va + X2 - abs(Va - X2));
        end
        
    case 'chi2'
        a = size(X,2); b = size(X2,2); d = size(X,1);
        K = zeros(a, b);
        Va = zeros(d,b);
        for i = 1:a
            Va = repmat(X(:,i),1,b);
            VaNum = (Va-X2).^2;
            VaDen = (Va + X2);
            Va = max(0,VaNum./VaDen);
            
            K(i,:)= exp(-sum(Va)/(2*sigma^2));
        end
       
    case 'Jen'
        X = X+1;
        X2 = X2+1;
        a = size(X,2); b = size(X2,2); d = size(X,1);
        K = zeros(a, b);
        
        for i = 1:a
            Va = repmat(X(:,i),1,b);
            
            D = Va + X2;
            
            value = (Va ./ (2*log10(D ./ Va))) + (X2 ./ (2*log10(D ./ X2)));
            
            
            K(i,:)= sum(value);
            
        end
        
        
        
        
        %     case 'histlag'
        %         a = size(X,2);
        %         b = size(X2,2);
        %         d = size(X,1);
        %         LAG =2;%d-1; % (critical) linear kernel parameter to be chosen between 1 and d-1
        %
        %         D = zeros(a,b); % d_{ii}=0;
        %
        %         for i=1:a
        %             for j=1:b
        %                 A = autocorr(X(:,i)-X2(:,j),LAG);
        %                 %         plot(A),drawnow
        %                 D(i,j)=sum(A);
        %                 D(j,i)=D(i,j);
        %             end
        %         end
        %
        %         %sigma =1; % rbf kernel parameter
        %         K = exp(-D/(sigma^2));
        
    otherwise
        error(['Unsupported kernel ' ker])
end
