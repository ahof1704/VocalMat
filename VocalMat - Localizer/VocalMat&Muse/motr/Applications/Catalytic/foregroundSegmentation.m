function [isForeground,diffFromBackground]= ...
  foregroundSegmentation(im,backgroundImage,foregroundSign,backgroundThreshold)
  
  im=double(im);
  diffFromBackground = im - backgroundImage;  %#ok

%     figure; imagesc(im); colormap(gray); axis image; title('im');
%     figure; imagesc(backgroundImage); colormap(gray); axis image; title('backgroundImage');
%     maxAbs=max(abs(diffFromBackground(:)));
%     figure; imagesc(diffFromBackground,[-maxAbs +maxAbs]); colormap(bipolar()); axis image; title('diffFromBackground'); colorbar();

  if foregroundSign == 1
    diffFromBackgroundRectified = max(diffFromBackground,0);
  elseif foregroundSign == -1
    diffFromBackgroundRectified = max(-diffFromBackground,0);
  else
    diffFromBackgroundRectified = abs(diffFromBackground);
  end
  isForeground = (diffFromBackgroundRectified>=backgroundThreshold);
  se = strel('disk',1);
  isForeground = imclose(isForeground,se);
  isForeground = imopen(isForeground,se);
end  % function
