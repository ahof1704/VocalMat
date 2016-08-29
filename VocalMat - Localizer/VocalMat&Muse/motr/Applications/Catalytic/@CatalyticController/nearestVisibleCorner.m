function point=nearestVisibleCorner(self,current_point)

% get just the x and y
point_raw=[current_point(1,1) ; current_point(1,2)];

% change to 'corner' coords
point=round(point_raw-0.5)+0.5;

% get to the visible image dimensions
%image_axes_h=findobj(self.figure_h,'Tag','image_axes_h');
image_axes_h=self.mainAxes;
xl=get(image_axes_h,'XLim');
yl=get(image_axes_h,'YLim');

% constrain the returned point to the visible image dims
if point(1)<xl(1)    
  point(1)=xl(1); 
elseif point(1)>xl(2)
  point(1)=xl(2); 
end
if point(2)<yl(1)
  point(2)=yl(1);
elseif point(2)>yl(2)
  point(2)=yl(2); 
end

end
