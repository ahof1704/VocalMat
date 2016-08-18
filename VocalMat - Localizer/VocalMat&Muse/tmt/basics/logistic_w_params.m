function result = f(v,theta,sigma)

result=1./(1+exp(-(v-theta)./sigma));
