function [burst_index,t_start,t_end,t_start_rel,t_end_rel,period,f_burst,duration,...
 duty_cycle,IBI,n_spikes,f_spikes,data] = f(filename)

data_fid = fopen(filename,'r');
first_line=fgetl(data_fid);
second_line=fgetl(data_fid);
third_line=fgetl(data_fid);
fourth_line=fgetl(data_fid);
[first_row_trans,n_cols]=sscanf(fourth_line,'%f%*[, \r\f\n\t]',inf);
rest_rows_trans=fscanf(data_fid,'%f%*[, \r\f\n\t]',[n_cols inf]);
data=[first_row_trans rest_rows_trans]';
fclose(data_fid);

% break out the stats
burst_index=data(:,1);
t_start=data(:,2);
t_end=data(:,3);
t_start_rel=data(:,4);
t_end_rel=data(:,5);
period=data(:,6);
f_burst=data(:,7);
duration=data(:,8);
duty_cycle=data(:,9);
IBI=data(:,10);
n_spikes=data(:,11);
f_spikes=data(:,12);


