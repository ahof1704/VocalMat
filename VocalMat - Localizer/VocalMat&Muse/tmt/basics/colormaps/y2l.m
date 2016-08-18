function L = f(Y)

% convert luminance to lightness
low=(Y<=0.008856);
high=~low;
lightness=zeros(size(Y));
lightness(low)=7.787*Y(low)+16/116;
lightness(high)=Y(high).^(1/3);

% Now do the Lab scaling
L=116*lightness-16;
