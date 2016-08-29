function setFigurePointerToZoomOut(fig)

cdata = zoomOutPointerCData();
hotspot = [6 5];

set(fig,'pointerShapeCData',cdata, ...
        'pointerShapeHotSpot',hotspot, ...
        'pointer','custom');

end
 