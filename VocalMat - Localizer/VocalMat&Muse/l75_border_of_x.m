function clr=f(x)

%  x is a col vector

L=75;
x=mod(x,1);
red_on= x<0.25 ;
blue_off= x>=0.25 & x<0.5 ;
red_off= x>=0.5 & x<0.75 ;
blue_on= x>=0.75 ;
clr_red_on=red_on_edge(L,4*x(red_on));
clr_blue_off=blue_off_edge(L,4*x(blue_off)-1);
clr_red_off=red_off_edge(L,4*x(red_off)-2);
clr_blue_on=blue_on_edge(L,4*x(blue_on)-3);
clr=zeros(length(x),3);
clr(red_on,:)=clr_red_on;
clr(blue_off,:)=clr_blue_off;
clr(red_off,:)=clr_red_off;
clr(blue_on,:)=clr_blue_on;

