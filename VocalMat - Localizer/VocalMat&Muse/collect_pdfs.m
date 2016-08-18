function collect_pdfs(pdf_page_dir_name,final_pdf_file_name)

% get this list of PDF page files
d=dir(fullfile(pdf_page_dir_name,'*.pdf'));
pdf_page_file_names=sort({d.name}');

% make a big-ass command line string to concatenate them all, using pdftk
n_pages=length(pdf_page_file_names);
sys_str='pdftk';
for i=1:n_files
  sys_str=sprintf('%s "%s"',sys_str,fullfile(pdf_page_dir_name,pdf_page_file_names{i}));
end
sys_str=sprintf('%s cat output "%s"',sys_str,final_pdf_file_name);

% % make a big-ass command line string to concatenate them all, using gs
% % this seems to be super-slow
% n_pages=length(pdf_page_file_names);
% if ispc
%   if strcmp(computer('arch'),'win64')
%     command_name='gswin64c';
%   else
%     command_name='gswin32c';
%   end
% else
%   command_name='gs';
% end
% sys_str=sprintf(['%s -dBATCH -dNOPAUSE -sDEVICE=pdfwrite ' ...
%                  '-sOutputFile="%s"'], ...
%                 command_name, ...
%                 final_pdf_file_name);                
% for i=1:n_pages
%   sys_str=sprintf('%s "%s"',sys_str,fullfile(pdf_page_dir_name,pdf_page_file_names{i}));
% end

% show the big-ass command line string
fprintf('%s\n',sys_str);

% invoke the big-ass command line string
[status,stdout_str]=system(sys_str);
status
fprintf('%s\n',stdout_str);

% % traverse the blob, generate a list of files to be concatenated, 
% % and concatenate them
% % append the most recent PDF to a growing summary doc
% final_pdf_file_name='r_est_for_single_mouse_data.pdf';
% temp_file_name='/opt/tmp/temp_pdf_from_voc_indicators_and_ancillary.pdf'
% if isempty(dir(final_pdf_file_name))
%   % if the output file does not exist, create it
%   sys_str=sprintf('cp %s %s', ...
%                   this_pdf_file_name,pdf_file_name);
%   fprintf('%s\n',sys_str);
%   system(sys_str);                  
% else
%   % if the output file exists, append to it
%   sys_str=sprintf('cp "%s" "%s"',pdf_file_name,temp_file_name);
%   fprintf('%s\n',sys_str);
%   system(sys_str);                  
%   sys_str=sprintf('pdftk "%s" "%s" cat output "%s"', ...
%                   temp_file_name,this_pdf_file_name,pdf_file_name);
%   fprintf('%s\n',sys_str);
%   system(sys_str);                  
%   sys_str=sprintf('rm "%s"',temp_file_name);
%   fprintf('%s\n',sys_str);
%   system(sys_str);                  
% end
% sys_str=sprintf('rm "%s"',this_pdf_file_name);
% fprintf('%s\n',sys_str);
% system(sys_str);                  

end
