function Kbag=generateKcluster(Xl)

[n d] = size(Xl);
iterations  = 10;
maxclusters = 4;
options = statset('Display','off');

scale=0;
KK = zeros(n,n);
for k = 2:maxclusters
    for it=1:iterations
        scale = scale+1;
        try
            obj = gmdistribution.fit(Xl,k,'Options',options);
            Pgmm = posterior(obj,Xl);
            Kc = Pgmm*Pgmm';
            KK = KK + Kc;          
        catch
             disp('GMM failed due to low samples/dim ratio')
        end
    end
end
Kbag = KK/max(KK(:));
