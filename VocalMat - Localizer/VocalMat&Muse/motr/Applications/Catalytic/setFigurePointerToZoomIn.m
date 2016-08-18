function setFigurePointerToZoomIn(fig)

cdata = zoomInPointerCData();
hotspot = [6 5];

set(fig,'pointerShapeCData',cdata, ...
        'pointerShapeHotSpot',hotspot, ...
        'pointer','custom');

end
