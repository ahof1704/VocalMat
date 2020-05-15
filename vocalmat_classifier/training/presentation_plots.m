% top1
% models_comparison(:,1) =  models{1,1}(:,1);
% models_comparison(:,2) =  models{1,1}(:,7);
% models_comparison(:,3) =  models{2,1}(:,7);
% models_comparison(:,4) =  models{3,1}(:,7);
% models_comparison(:,5) =  models{4,1}(:,7);
% models_comparison(:,6) =  models{5,1}(:,7);
% models_comparison(:,7) =  models{6,1}(:,7);


september = [78.5918    79.2578    81.9220    71.4558    81.5414    64.0343];
october   = [78.8773    81.5414    83.6346    74.5956    82.9686    73.1684];
november  = [75.0714    82.7783    81.2559    75.0714    77.3549    74.8811];

segments = [100-september ; 100-october ; 100-november];

figure
    bar(segments, 'hist')
        set(gca,'fontsize', 18);
        title(['Top1 Error by Dataset']);
        xlabel('dataset');
        ylabel('error');
        yticks([0 10 15 18 20 22 25 30 40]);
        grid minor;
        axis([0 4 0.00 40.0]);
        set(gca,'XTickLabel', {'18-september', '18-october', '18-november'});
        legend("alexnet-adam", "alexnet-sgdm", "inception-adam", "inception-sgdm", "resnet-adam", "resnet-sgdm", 'Location', 'Best');

% top2
% models_comparison(:,1) =  models{1,1}(:,1);
% models_comparison(:,2) =  models{1,1}(:,8);
% models_comparison(:,3) =  models{2,1}(:,8);
% models_comparison(:,4) =  models{3,1}(:,8);
% models_comparison(:,5) =  models{4,1}(:,8);
% models_comparison(:,6) =  models{5,1}(:,8);
% models_comparison(:,7) =  models{6,1}(:,8);
september = [90.1998   90.3901   91.627    86.9648   91.627    80.3045];
october   = [90.7707   91.9125   91.8173   87.4405   93.2445   87.3454];
november  = [88.2017   93.0542   91.4367   87.6308   90.1998   88.1066];

segments = 100 - [september ; october ; november];

figure
    bar(segments, 'hist')
        set(gca,'fontsize', 18);
        title(['Top2 Error by Dataset']);
        xlabel('dataset');
        ylabel('error');
        yticks([0 8 10 15 20 40]);
        grid minor;
        axis([0 4 0.00 40.0]);
        set(gca,'XTickLabel', {'18-september', '18-october', '18-november'});
        legend("alexnet-adam", "alexnet-sgdm", "inception-adam", "inception-sgdm", "resnet-adam", "resnet-sgdm", 'Location', 'Best');




% october                 = [90.7707   91.9125   91.8173   87.4405   93.2445   87.3454];
% octoberplus             = [90.5804   93.0542   93.3397   89.4386   90.4853   87.0599];
% octoberaugment          = [94.862    94.862    95.0523   94.5766   95.2426   92.3882];
% octoberaugmentplus      = [94.5766   93.8154   94.0057   94.9572   95.7184   93.0542];
% octoberdirty            = [92.2931   93.4348   93.9106   88.5823   93.1494   88.1066];
% octoberdirtyplus        = [87.2502   94.1009   93.0542   88.4872   93.3397   88.8677];
% octoberdirtyaugment     = [94.6717   94.0057   94.3863   95.3378   96.099    95.1475];
% octoberdirtyaugmentplus = [95.5281   94.862    96.5747   95.1475   96.2892   94.1009];

october                 = [91.9125   87.4405   93.2445];
octoberplus             = [93.0542   89.4386   90.4853];
octoberaugment          = [94.862    94.5766   95.2426];
octoberaugmentplus      = [93.8154   94.9572   95.7184];
octoberdirty            = [93.4348   88.5823   93.1494];
octoberdirtyplus        = [94.1009   88.4872   93.3397];
octoberdirtyaugment     = [94.0057   95.3378   96.099 ];
octoberdirtyaugmentplus = [94.862    95.1475   96.2892];

segments = 100 - [october ; octoberplus ; octoberaugment ; octoberaugmentplus ; octoberdirty ; octoberdirtyplus ; octoberdirtyaugment ; octoberdirtyaugmentplus];

figure
    bar(segments, 'hist')
        set(gca,'fontsize', 18);
        title(['Top2 Error by Dataset']);
        xlabel('dataset');
        ylabel('error');
        yticks([0 3 5 8 10 15 20 40]);
        grid minor;
        axis([0 9 0.0 40.0]);
        set(gca,'XTickLabel', {'oct', 'oct-plus', 'oct-aug', 'oct-aug-plus', 'oct-dirty', 'oct-dirty-plus', 'oct-dirty-aug', 'oct-dirty-aug-plus'});
        legend("alexnet-adam", "alexnet-sgdm", "inception-adam", "inception-sgdm", "resnet-adam", "resnet-sgdm", 'Location', 'Best');

% october                 = [78.8773   81.5414   83.6346   74.5956   82.9686   73.1684];
% octoberplus             = [79.2578   83.5395   85.9182   76.784    79.0676   72.7878];
% octoberaugment          = [84.5861   85.157    85.9182   83.7298   85.823    79.6384];
% octoberaugmentplus      = [84.0152   85.157    85.5376   83.3492   86.1085   80.019];
% octoberdirty            = [80.4948   82.8735   84.5861   76.2131   81.0657   74.3102];
% octoberdirtyplus        = [74.7859   83.9201   82.0171   78.0209   83.6346   76.118];
% octoberdirtyaugment     = [84.491    84.3958   85.0618   84.3007   88.1066   85.3473];
% octoberdirtyaugmentplus = [83.5395   84.5861   88.7726   84.491    86.2988   83.8249];

october                 = [81.5414   83.6346   82.9686];
octoberplus             = [83.5395   85.9182   79.0676];
octoberaugment          = [85.157    85.9182   85.823 ];
octoberaugmentplus      = [85.157    85.5376   86.1085];
octoberdirty            = [82.8735   84.5861   81.0657];
octoberdirtyplus        = [83.9201   82.0171   83.6346];
octoberdirtyaugment     = [84.3958   85.0618   88.1066];
octoberdirtyaugmentplus = [84.5861   88.7726   86.2988];

segments = 100 - [october ; octoberplus ; octoberaugment ; octoberaugmentplus ; octoberdirty ; octoberdirtyplus ; octoberdirtyaugment ; octoberdirtyaugmentplus];

figure
    bar(segments, 'hist')
        set(gca,'fontsize', 18);
        title(['Top1 Error by Dataset']);
        xlabel('dataset');
        ylabel('error');
        yticks([0 10 12 15 20 25 30 40]);
        grid minor;
        axis([0 9 0.0 40.0]);
        set(gca,'XTickLabel', {'oct', 'oct-plus', 'oct-aug', 'oct-aug-plus', 'oct-dirty', 'oct-dirty-plus', 'oct-dirty-aug', 'oct-dirty-aug-plus'});
        legend("alexnet-adam", "alexnet-sgdm", "inception-adam", "inception-sgdm", "resnet-adam", "resnet-sgdm", 'Location', 'Best');
        

%%
% alexnet_scratch  = [0   0   0   0   0   1   0   0   0   0   0   0];
% alexnet_transfer = [0.95567   1   0.66667   0.84211   0   0.97241   0.50000   0.92593   0.73810   0.42500   0.93511   0.83178];
segments = [0 0.95567 ; 0 1 ; 0 0.66667 ; 0 0.84211 ; 0 0 ; 1 0.97241 ; 0 0.5 ; 0 0.92593 ; 0 0.73810 ; 0 0.42500 ; 0 0.93511 ; 0 0.83178];
figure
    bar(segments, 'hist')
        set(gca,'fontsize', 18);
        title(['Call Type Accuracy; ']);
        xlabel('call type');
        ylabel('accuracy');
        % yticks([0 0.8 0.9 1 1.5]);
        grid minor;
        axis([0 13 0.00 1.0]);
        set(gca,'XTickLabel', {'chevron', 'complex', 'down fm', 'flat', 'mult steps', 'noise', 'revchevron', 'short', 'step down', 'step up', 'two steps', 'up fm'});
        legend('AlexNet Trained from Scratch', 'AlexNet with Transfer Learning', 'Location', 'Best');