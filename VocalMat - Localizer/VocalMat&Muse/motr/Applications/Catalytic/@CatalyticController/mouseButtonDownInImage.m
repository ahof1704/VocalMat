function mouseButtonDownInImage(self,source,event)  %#ok

%fprintf('entered mouseButtonDownInImage()\n');
if self.zoomingIn ,
  sel_type=get(self.fig,'SelectionType');
  switch sel_type
    case 'extend'
      self.zoomOut();
    case 'alternate'
      self.zoomOut();
    case 'open'
      self.zoomOut();
    otherwise
      self.drawZoomRect('start');
  end
elseif self.zoomingOut,
  self.zoomOut();
end

end
