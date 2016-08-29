function [colors0,colorOrder,colors] = colorOrderFromNumberOfAnimals(nFlies)
% set the order we will assign colors to flies, but do it in a pure
% function
% splintered from fixerrorsgui 6/23/12 JAB

%nFlies=handles.nflies;
%colorOrder=determineColorOrder(nFlies);
% handles.colors0 = jet(nFlies);
% handles.colors = handles.colors0(colorOrder,:);
% handles.colororder=colorOrder;

% For mice, just want color to correspong to index:
%   red, green, blue, cyan

colorOrder=(1:nFlies);
colorsTemplate=[    1      0      0    ; ...
                    0      0.7    0    ; ...
                    0      0      1    ; ...
                    0      0.7    0.7  ; ...
                    0.7    0      0.7  ; ...
                    0.6    0.6    0    ];
nColorsInTemplate=size(colorsTemplate,1);                  
nRepeats=ceil(nFlies/nColorsInTemplate);
colors0=repmat(colorsTemplate,[nRepeats 1]);
colors0=colors0(1:nFlies,:);  % trim to correct size
colors=colors0(colorOrder,:);

end
