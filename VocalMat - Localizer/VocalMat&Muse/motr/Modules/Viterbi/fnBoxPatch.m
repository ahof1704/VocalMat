function hPatch = fnBoxPatch(iStartX,iEndX,iStartY,iEndY, strCol)
% 
% iStartX, iStartY ->  iStartX, iEndY
% iStartX, iEndY   ->  iEndX, iEndY
% iEndX, iEndY     ->  iEndX, iStartY 
% iEndX, iStartY   -> iStartX, iStartY
x = [iStartX iStartX; iStartX iEndX; iEndX iEndX;iEndX, iStartX]; 
y = [iStartY iEndY;   iEndY iEndY;   iEndY iStartY;  iStartY iStartY];
hPatch = patch(x,y,strCol,'EdgeColor','none');