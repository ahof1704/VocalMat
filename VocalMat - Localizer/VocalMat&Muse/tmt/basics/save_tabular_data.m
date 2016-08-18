function f(filename,data)

data_fid=fopen(filename,'wt');
n_rows=size(data,1);
for j=1:n_rows
  fprintf(data_fid,'%26.16e  ',data(j,:));
  fprintf(data_fid,'\n');
end
fclose(data_fid);

