function cmap=f(n_colors);

% generate a non-smooth colormap on a very fine grid
% calculate the path length, and from that get the phase for each
% point on the fine grid
n_samples=4000;  % want divisible by 4
x=linspace(0,1,n_samples+1)';
clr=oppo_of_x(x);
clr_lab=srgb2lab(clr);
ds=dist_lab(clr_lab(1:end-1,:),clr_lab(2:end,:));
s=[0 ; cumsum(ds)];
%phase=s/s(end);  % normalized path length == phase in cycles

% normalize in a special way, to leave certain points where we want
% them
s1=interp1(x,s,0.25,'linear*');
s2=interp1(x,s,0.50,'linear*');
s3=interp1(x,s,0.75,'linear*');
s4=interp1(x,s,1.00,'linear*');
span1= x<0.25;
span2= x>=0.25 & x<0.50;
span3= x>=0.50 & x<0.75;
span4= x>=0.75;
phase=zeros(size(s));
phase(span1)=0.25/s1*s(span1);
phase(span2)=0.25/(s2-s1)*(s(span2)-s1)+0.25;
phase(span3)=0.25/(s3-s2)*(s(span3)-s2)+0.50;
phase(span4)=0.25/(s4-s3)*(s(span4)-s3)+0.75;

% make a colormap with inter-color spacings equal to circum/n_colors
phase_samples=linspace(0,1,n_colors+1)';
phase_samples=phase_samples(1:end-1);
x_samples=interp1(phase,x,phase_samples,'linear');
cmap=oppo_of_x(x_samples);

