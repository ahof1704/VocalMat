function mouseMovedWhileDraggingEllipseHandle(self,hObject,eventdata)  %#ok
  if isempty(self.motionobj), return; end

  if strcmpi(self.motionobj{1},'center'),
    self.move_center(self.motionobj{2});
  elseif strcmpi(self.motionobj{1},'head'),
    self.move_head(self.motionobj{2});
  elseif strcmpi(self.motionobj{1},'tail'),
    self.move_tail(self.motionobj{2});
  elseif strcmpi(self.motionobj{1},'left'),
    self.move_left(self.motionobj{2});
  elseif strcmpi(self.motionobj{1},'right'),
    self.move_right(self.motionobj{2});
  end
end  % method
