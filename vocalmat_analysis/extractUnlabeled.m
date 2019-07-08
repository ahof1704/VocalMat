function [unlabeled] = extractUnlabeled(data,options)

nDomains = size(data,2);

switch options.un
    
    case 0
        % Unlabeled 'labels' vector
        for i = 1:nDomains
            L = zeros(size(data{1,i}.X,1),1);
            eval(sprintf('[Xtr%iu Ytr%iu] = ppc(data{1,%i}.X,L,options.puT,options.real);',i,i,i));
            clear L
        end
        
        
        
        
    case 2
        
        kmeansOptions = options.kmeansOptions;
        
        
        % Unlabeled 'labels' vector
        L1 = zeros(length(data{1,1}.X),1);
        L2 = zeros(length(data{1,2}.X),1);
        L3 = zeros(length(data{1,3}.X),1);
        
       
        
        fname = ['Centers_setting' num2str(options.setting) '_' num2str(options.puT) '.mat'];
        
        if exist(fname,'file')
            fprintf('Loading centers from file...')
            load(fname)
        else
            
            
            
            jump = kmeansOptions.jump;
            
            disp('Kmeans, source...')
            [node] = clustering_kmeans(data{1,1}.X(1:jump:end,:),kmeansOptions);
            crit = @(e) (e.lchild == -1);
            indices = find(arrayfun(crit,node));
            Xtr1u = reshape([node(indices).center],size(node(1).center,2),[])';
            clear node indices
            % Brute force kmeans, inefficient for options.puT > 1000
            %[~,Xtr1u] = kmeans(sourceX_un(1:3:end,:),options.puT,'Start','cluster','EmptyAction','singleton');
            
            disp('Kmeans, target...')
            [node] = clustering_kmeans(data{1,2}.X(1:jump:end,:),kmeansOptions);
            crit = @(e) (e.lchild == -1);
            indices = find(arrayfun(crit,node));
            Xtr2u = reshape([node(indices).center],size(node(1).center,2),[])';
            clear node indices
            % Brute force kmeans, inefficient for options.puT > 1000
            %[~,Xtr2u] = kmeans(targetX_un(1:3:end,:),options.puT,'Start','cluster','EmptyAction','singleton');
            
            disp('Kmeans, target2...')
            [node] = clustering_kmeans(data{1,3}.X(1:jump:end,:),kmeansOptions);
            crit = @(e) (e.lchild == -1);
            indices = find(arrayfun(crit,node));
            Xtr3u = reshape([node(indices).center],size(node(1).center,2),[])';
            clear node indices
            % Brute force kmeans, inefficient for options.puT > 1000
            %[~,Xtr2u] =
            %kmeans(targetX_un(1:3:end,:),options.puT,'Start','cluster','EmptyAction','singleton');
            
            
            save(fname,'Xtr1u','Xtr2u','Xtr3u');
        end
        disp('Done.')
        
        
        
        clear t t2 sourceX_* targetX_*
        
        
        
        
        
    otherwise
        disp('unlabeled strategy unknown!')
        
        
end

for i = 1:nDomains
    eval(sprintf('unlabeled{1,%i}.X = Xtr%iu'';',i,i));
    
end