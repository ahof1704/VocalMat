function drawZoomRect(self,action)

persistent anchor;
persistent rect_h;

%fprintf('entered drawZoomRect()\n');

figure_h=self.fig;
image_axes_h=self.mainAxes;

switch(action)
  case 'start'
    %fprintf('entered drawZoomRect() start branch\n');
    point=self.nearestVisibleCorner(get(image_axes_h,'CurrentPoint'));
    anchor=point;
    % create a new rectangle
    rect_h=...
      line('Parent',image_axes_h,...
           'Color',[0 0 0], ...
           'Tag','border_h', ...
           'XData',[anchor(1) anchor(1) point(1) point(1)  anchor(1)], ...
           'YData',[anchor(2) point(2)  point(2) anchor(2) anchor(2)], ...
           'ZData',[1 1 1 1 1]);
    % set the callbacks for the drag
    set(figure_h,'WindowButtonMotionFcn',...
                 @(src,event)(self.drawZoomRect('move')));
    set(figure_h,'WindowButtonUpFcn',...
                 @(src,event)(self.drawZoomRect('stop')));
  case 'move'
    % fprintf('entered drawZoomRect() move branch\n');
    point=self.nearestVisibleCorner(get(image_axes_h,'CurrentPoint'));
    set(rect_h,...
        'XData',[anchor(1) anchor(1) point(1) point(1)  anchor(1)]);
    set(rect_h,...
        'YData',[anchor(2) point(2)  point(2) anchor(2) anchor(2)]);
  case 'stop'
    % fprintf('entered drawZoomRect() stop branch\n');
    % change the move and buttonup calbacks
    set(figure_h,'WindowButtonMotionFcn', ...
                 @(src,event)(self.updatePointer()));
    set(figure_h,'WindowButtonUpFcn',[]);
    % now do the stuff we'd do for a move also
    point=self.nearestVisibleCorner(get(image_axes_h,'CurrentPoint'));
    set(rect_h,...
        'XData',[anchor(1) anchor(1) point(1) point(1)  anchor(1)]);
    set(rect_h,...
        'YData',[anchor(2) point(2)  point(2) anchor(2) anchor(2)]);
    % do the zoom
    delete(rect_h);
    self.zoomIn(point,anchor);
end  % switch
