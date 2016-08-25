function colorizedImage=colorizeSegmentation(originalImage,isForeground)

% originalImage a grayscale image on [0,255]
% isForeground a boolean image of the same size, with each element true iff
%   that element is a foreground element

%clrPos=reshape([0 0.481 1],[1 1 3]);  % approx same luminance as clr_neg
%clrNeg=reshape([1 0 0],[1 1 3]);
%clrPos=reshape([0 1 1],[1 1 3]);
%clrNeg=reshape([1 0 1],[1 1 3]);
clrPos=reshape([1 0 1],[1 1 3]);  % approx same luminance as clr_neg
clrNeg=reshape([0.6 0.6 0.6],[1 1 3]);

originalImage01=double(originalImage)/255;
colorizedImage=bsxfun(@times,clrNeg,(        originalImage01).*~isForeground) + ...
               bsxfun(@times,clrPos,(0.3+0.7*originalImage01).* isForeground) ;

end
