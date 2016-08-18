function plotBoostingSteps(classifier, x)
%
Nstages = length(classifier);
figure(3)
hold off
Fx = 0;
for m = 1:Nstages
    featureNdx = classifier(m).featureNdx;
    th = classifier(m).th;
    a = classifier(m).a;
    b = classifier(m).b;
    
    Fx = Fx + (a * (x(featureNdx,:)>th) + b); %add regression stump
    
    plot([m-1 m], [Fx Fx])
    hold on
end
hold off
