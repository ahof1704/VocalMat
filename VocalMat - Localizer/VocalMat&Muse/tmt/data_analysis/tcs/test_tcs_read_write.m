file_name='~/stefan_data/2011-08-05/ROI AND EPHYS TRANSFER/may26a_1_A7R/6_ROIs_stretch_may26a_1.tcs';
file_name_check='~/stefan_data/2011-08-05/ROI AND EPHYS TRANSFER/may26a_1_A7R/6_ROIs_stretch_may26a_1_check.tcs';

[name,t,x,units]=read_tcs(file_name);
write_tcs(file_name_check,name,t,x,units);
[name_check,t_check,x_check,units_check]=read_tcs(file_name);


