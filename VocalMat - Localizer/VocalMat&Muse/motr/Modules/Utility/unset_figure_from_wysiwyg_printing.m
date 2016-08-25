function unset_figure_from_wysiwyg_printing(h,vals_old)

% restore old values
set(h,'PaperPositionMode',vals_old.PaperPositionMode);
set(h,'InvertHardCopy',vals_old.InvertHardCopy);
set(h,'PrintTemplate',vals_old.PrintTemplate); 

end
