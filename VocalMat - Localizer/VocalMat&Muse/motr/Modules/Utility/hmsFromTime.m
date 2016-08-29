function hms=hmsFromTime(t)

% t in seconds, generally a frame timestamp

r=t;
h=floor(r/3600);
r=r-h*3600;
m=floor(r/60);
r=r-m*60;
s=floor(r);
hms=[h m s]';
