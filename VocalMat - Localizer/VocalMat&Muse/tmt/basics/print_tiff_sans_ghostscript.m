function print_tiff_sans_ghostscript(fig_h,basename,res)

% prints to an TIFF file.
% This doesn't use ghostscript to RIP an .eps, so it isn't as good as
% print_png in that respect (no antialiasing), but it all doesn't require 
% ghostscript, so that's nice.

tic
if nargin<1 || isempty(fig_h)
  fig_h=gcf;
end
if nargin<2 || isempty(basename)
  if isempty(get(fig_h,'name'))
    basename=sprintf('fig-%03d',fig_h);
  else
    basename=get(fig_h,'name');
  end
end
if nargin<3 || isempty(res)
  res=300;
end
fprintf(1,'Writing TIFF file %s:\n',basename);
temp_file_path=[tempname '.eps'];
old_vals=set_figure_to_wysiwyg_printing(fig_h);
print(fig_h,'-dtiff',sprintf('-r%d',res),sprintf('%s.tif',basename));
unset_figure_from_wysiwyg_printing(fig_h,old_vals);
t=toc;
fprintf(1,'Elapsed time: %0.1f sec\n',t);
