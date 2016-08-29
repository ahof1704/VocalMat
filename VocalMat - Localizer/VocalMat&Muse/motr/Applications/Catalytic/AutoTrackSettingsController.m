classdef AutoTrackSettingsController < handle
  
  properties
    catalyticController  % the parent CatalyticController
    isFillRectangleDragInProgress  % true iff the user is currently in the process of drawing a rectangle in view.mainAxes
    model
    view    
  end  % properties
  
  methods
    % ---------------------------------------------------------------------
    function self=AutoTrackSettingsController(catalyticController)
      self.catalyticController=catalyticController;
      self.isFillRectangleDragInProgress=false;
      self.model=AutoTrackSettingsModel(catalyticController);
      self.view=AutoTrackSettingsView(self.model,self);
    end
    
    
    % ---------------------------------------------------------------------
    function thresholdPlusButtonTwiddled(self, hObject, eventdata)  %#ok
      % hObject    handle to thresholdPlusButton (see GCBO)
      % eventdata  reserved - to be defined in a future version of MATLAB
      % self    structure with self and user data (see GUIDATA)
      
      self.model.incrementBackgroundThreshold(1);
      self.view.updateBackgroundThresholdText();
      self.view.updateSegmentationPreview();
    end
    
    
    % ---------------------------------------------------------------------
    function thresholdMinusButtonTwiddled(self, hObject, eventdata)  %#ok
      % hObject    handle to thresholdMinusButton (see GCBO)
      % eventdata  reserved - to be defined in a future version of MATLAB
      % self    structure with self and user data (see GUIDATA)
      
      self.model.incrementBackgroundThreshold(-1);
      self.view.updateBackgroundThresholdText();
      self.view.updateSegmentationPreview();
    end
        
    
    % ---------------------------------------------------------------------
    function foregroundSignPopupTwiddled(self, source, event)  %#ok
      % hObject    handle to foregroundSignPopup (see GCBO)
      % eventdata  reserved - to be defined in a future version of MATLAB
      % self    structure with self and user data (see GUIDATA)
      
      % Hints: contents = get(hObject,'String') returns foregroundSignPopup contents as cell array
      %        contents{get(hObject,'Value')} returns selected item from foregroundSignPopup
      
      iSelection = get(source,'value');
      if iSelection == 1
        self.model.setForegroundSign(1);
      elseif iSelection == 2
        self.model.setForegroundSign(-1);
      else
        self.model.setForegroundSign(0);
      end
      self.view.updateSegmentationPreview();
    end
   
    
    
    % ---------------------------------------------------------------------
    function doneButtonTwiddled(self, hObject, eventdata)  %#ok
      self.catalyticController.setBackgroundImageForCurrentAutoTrack(self.model.backgroundImage);
      self.catalyticController.setBackgroundThreshold(self.model.backgroundThreshold);
      self.catalyticController.setMaximumJump(self.model.trackingROIHalfWidth);      
      self.catalyticController.setForegroundSign(self.model.foregroundSign);
      self.view.close();
    end
    
    
    
    % ---------------------------------------------------------------------
    function cancelButtonTwiddled(self, hObject, eventdata)  %#ok
      self.view.close()
    end
    
    
    
    % ---------------------------------------------------------------------
    function eyedropperRadiobuttonTwiddled(self, source, event)  %#ok
      % nothing to do -- eyedropper state not kept in model
      
      %value=get(source,'value');
      %self.model.setIsInEyedropperMode(value);
      % no need to update view in this case
    end
    
    
    
    % ---------------------------------------------------------------------
    function debugButtonTwiddled(self, hObject, eventdata)  %#ok
      keyboard;
    end
    
    
    % ---------------------------------------------------------------------
    function fillButtonTwiddled(self, hObject, eventdata)  %#ok
      self.model.doBackgroundFill();
      self.view.updateSegmentationPreview();
    end
    
    
    
    % ---------------------------------------------------------------------
    function mouseButtonDownInMainAxes(self, source, event)  %#ok
      %fprintf('Entered mouseButtonDownInMainAxes()\n');
      %source
      %event
      [x,y]=self.view.getMainAxesCurrentPoint();
      isEyedropperOn=get(self.view.eyedropperRadiobutton,'value');
      if isEyedropperOn ,
        self.model.setBackgroundColorToSample(x,y);
        self.view.updateBackgroundColorImage();
      else
        self.isFillRectangleDragInProgress = true;
        self.model.startFillRegionDrag(x,y);
        self.view.updateFillRegionBoundLine();
      end
    end
    
    
    % ---------------------------------------------------------------------
    function mouseMoved(self,source,event)  %#ok
      %if isfield(self,'choosepatch') || ~self.choosepatch
      %fprintf('Entered mouseMoved()\n');
      if isempty(self.isFillRectangleDragInProgress) || ~self.isFillRectangleDragInProgress
        return
      end
      %source
      %event
      %fprintf('Entered mouseMoved() inner sanctum\n');
      
      [x,y]=self.view.getMainAxesCurrentPoint();
      self.model.continueFillRegionDrag(x,y);
      self.view.updateFillRegionBoundLine();      
    end
    
    
    % ---------------------------------------------------------------------
    function mouseButtonReleased(self,source,event)  %#ok
      if isempty(self.isFillRectangleDragInProgress) || ~self.isFillRectangleDragInProgress
        return
      end
      [x,y]=self.view.getMainAxesCurrentPoint();
      %source
      %event
      self.isFillRectangleDragInProgress = false;
      self.model.continueFillRegionDrag(x,y);
      self.model.endFillRegionDrag();
      self.view.updateFillRegionBoundLine();      
      self.view.updateFillButtonEnablement();
    end
    
    
    % ---------------------------------------------------------------------
    function trackingROIHalfWidthPlusButtonTwiddled(self, hObject, eventdata)  %#ok
      %self.catalyticController.incrementMaximumJump(+1);
      self.model.incrementTrackingROIHalfWidth(1);
      self.view.updateTrackingROIHalfWidthText();
      self.view.updateSegmentationPreview();
    end
    
    
    
    % ---------------------------------------------------------------------
    function trackingROIHalfWidthMinusButtonTwiddled(self, hObject, eventdata)  %#ok
      self.model.incrementTrackingROIHalfWidth(-1);
      self.view.updateTrackingROIHalfWidthText();
      self.view.updateSegmentationPreview();
    end
    
    
    
    % ---------------------------------------------------------------------
    function closeRequested(self)  %#ok
      % do nothing: user must click done or cancel
      %delete(self.fig);
    end
    end
    
end  % classdef
