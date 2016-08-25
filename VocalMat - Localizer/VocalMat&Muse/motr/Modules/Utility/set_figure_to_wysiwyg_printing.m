function vals_old=set_figure_to_wysiwyg_printing(h)

% save original stuff
vals_old.PaperPositionMode=get(h,'PaperPositionMode');
vals_old.InvertHardCopy=get(h,'InvertHardCopy');
vals_old.PrintTemplate=get(h,'PrintTemplate'); 
  
% set so that figure prints the same size as on-screen
set(h,'PaperPositionMode','auto');

% make it so that it doesn't change the figure or axes background of
% printed figure
set(h,'InvertHardCopy','off');

% set up so the default is not to change the figure axis limits and ticks
% when printing
newPrintTemplate=printtemplate;
newPrintTemplate.AxesFreezeTicks=1;
newPrintTemplate.AxesFreezeLimits=1;
newPrintTemplate.DriverColor=1;
set(h,'PrintTemplate',newPrintTemplate); 

end
