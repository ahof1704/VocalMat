function updatePointer(self)

persistent above_image;

% init above_image
if isempty(above_image)
  if self.zoomingIn || self.zoomingOut ,
    image_axes_h=self.mainAxes;
    cp=get(image_axes_h,'CurrentPoint');
    cp=cp(1,1:2);
    xlim=get(image_axes_h,'XLim');
    ylim=get(image_axes_h,'YLim');
    above_image=~isempty(self.frameImageGH) && ...
                xlim(1)<=cp(1) && ...
                cp(1)<=xlim(2) && ...
                ylim(1)<=cp(2) && ...
                cp(2)<=ylim(2);
    if above_image
      if self.zoomingIn,
        setFigurePointerToZoomIn(self.fig);
      else
        setFigurePointerToZoomOut(self.fig);
      end
    else
      set(self.fig,'Pointer','arrow');
    end
  else    
    above_image=false;
    set(self.fig,'Pointer','arrow');
  end
end

% if we are above the image now and weren't before, or vice-versa, change
% the pointer appropriately
if self.zoomingIn || self.zoomingOut ,
  image_axes_h=self.mainAxes;
  cp=get(image_axes_h,'CurrentPoint');
  cp=cp(1,1:2);
  xlim=get(image_axes_h,'XLim');
  ylim=get(image_axes_h,'YLim');
  above_image_now=~isempty(self.frameImageGH) && ...
                  xlim(1)<=cp(1) && ...
                  cp(1)<=xlim(2) && ...
                  ylim(1)<=cp(2) && ...
                  cp(2)<=ylim(2);
  if above_image_now~=above_image
    if above_image_now
      if self.zoomingIn,
        setFigurePointerToZoomIn(self.fig);
      else
        setFigurePointerToZoomOut(self.fig);
      end
      %set(self.fig,'Pointer','crosshair');
    else
      set(self.fig,'Pointer','arrow');
    end
    above_image=above_image_now;
  end
end

