function write_e_and_o_to_tcs(file_name,...
                              t_e,e_phys,e_phys_name,e_phys_units,...
                              t_o,roi,roi_label)

% t_e and t_o must be in seconds                            
                            
% get number signals
n_e=length(e_phys_name);
n_o=length(roi_label);
                            
% make up some optical units
units_o=cell(n_o,1);
unit_o{:}='';

% write the stuff
fid=open_tcs_for_writing(file_name);
write_int32_to_tcs(fid,n_o+n_e);  % write number of traces
write_traces_to_tcs(fid,e_phys_name,t_e,e_phys,e_phys_units);
write_traces_to_tcs(fid,roi_label,t_o,roi,units_o);
close_tcs(fid);
