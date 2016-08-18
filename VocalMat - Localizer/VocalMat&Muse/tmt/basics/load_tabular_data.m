function data = load_tabular_data(filename)

data_fid = fopen(filename,'r');
first_line=fgetl(data_fid);
[first_row_trans,n_cols]=sscanf(first_line,'%f',inf);
rest_rows_trans=fscanf(data_fid,'%f',[n_cols inf]);
data=[first_row_trans rest_rows_trans]';
fclose(data_fid);
