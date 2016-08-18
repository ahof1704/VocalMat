function row_vector = f(filename)

data_fid = fopen(filename,'r');
row_vector=fscanf(data_fid,'%f',[1 inf]);
fclose(data_fid);

