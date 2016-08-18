% set default figure background to white
set(0,'DefaultFigureColor','w');

% set the default to be that figures print the same size as on-screen
set(0,'DefaultFigurePaperPositionMode','auto');

% set up so the default is not to change the figure axis limits and ticks
% when printing
newPrintTemplate=printtemplate;
newPrintTemplate.AxesFreezeTicks=1;
newPrintTemplate.AxesFreezeLimits=1;
newPrintTemplate.DriverColor=1;
set(0, 'DefaultFigurePrintTemplate',newPrintTemplate); 
clear newPrintTemplate

% seed the RNG
rand('state',sum(100*clock));
