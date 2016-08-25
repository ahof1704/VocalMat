function [iRowLow,iRowHigh,iColLow,iColHigh] = ...
  computeTrackingROI(trx,iFlies,iFrameInVideo,nRows,nCols,trackingROIHalfWidth)
  
  trx = trx(iFlies);
  nFlies = length(iFlies);

  xPredicted = zeros(1,nFlies);
  yPredicted = zeros(1,nFlies);
  thetaPredicted = zeros(1,nFlies);
  for iFly = 1:nFlies,
    iFrameInTrack = max( trx(iFly).off+(iFrameInVideo), 2 ); % first frame
    xPrevious = trx(iFly).x(iFrameInTrack-1);
    yPrevious = trx(iFly).y(iFrameInTrack-1);
    thetaPrevious = trx(iFly).theta(iFrameInTrack-1);
    if iFrameInTrack == 2,
      xPredicted(iFly) = xPrevious;
      yPredicted(iFly) = yPrevious;
      thetaPredicted(iFly) = thetaPrevious;
    else
      xTwoBack = trx(iFly).x(iFrameInTrack-2);
      yTwoBack = trx(iFly).y(iFrameInTrack-2);
      thetaTwoBack = trx(iFly).theta(iFrameInTrack-2);
      [xPredicted(iFly),yPredicted(iFly),thetaPredicted(iFly)] = ...
        cvpred(xTwoBack,yTwoBack,thetaTwoBack, ...
               xPrevious,yPrevious,thetaPrevious);
    end
  end

  iRowLow = max(floor(min(yPredicted)-trackingROIHalfWidth),1); 
  iRowHigh = min(ceil(max(yPredicted)+trackingROIHalfWidth),nRows);
  iColLow = max(floor(min(xPredicted)-trackingROIHalfWidth),1); 
  iColHigh = min(ceil(max(xPredicted)+trackingROIHalfWidth),nCols);
end  % function
