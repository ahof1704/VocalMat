net = alexnet;
net.Layers

% -- remove fully-connected layers from AlexNet
lgraph     = net.Layers(1:end-3);
numClasses = 12;

% -- create appropriate fully-connected layers for our dataset
lgraph     = [
                lgraph
                fullyConnectedLayer(numClasses, 'WeightLearnRateFactor', 20, 'BiasLearnRateFactor', 20)
                softmaxLayer
                classificationLayer];

% -- reset all fc layer weights and bias
lgraph(17).Weights = randn([4096 9216]) * 0.0001;
lgraph(17).Bias    = randn([4096 1]) * 0.0001;

lgraph(20).Weights = randn([4096 4096]) * 0.0001;
lgraph(20).Bias    = randn([4096 1]) * 0.0001;


lgraph(23).Weights = randn([12 4096]) * 0.0001;
lgraph(23).Bias    = randn([12 1]) * 0.0001;

net = lgraph
clear lgraph

save model_alexnet_scratch_fc.mat net

% -- reset all conv layer weights and bias
net(2).Weights  = randn([11 11 3 96]) * 0.0001;
net(2).Bias     = randn([1 1 96]) * 0.0001;

net(6).Weights  = randn([5 5 48 256]) * 0.0001;
net(6).Bias     = randn([1 1 256]) * 0.0001;

net(10).Weights = randn([3 3 256 384]) * 0.0001;
net(10).Bias    = randn([1 1 384]) * 0.0001;

net(12).Weights = randn([3 3 192 384]) * 0.0001;
net(12).Bias    = randn([1 1 384]) * 0.0001;

net(14).Weights = randn([3 3 192 256]) * 0.0001;
net(14).Bias    = randn([1 1 256]) * 0.0001;

save model_alexnet_scratch_all.mat net