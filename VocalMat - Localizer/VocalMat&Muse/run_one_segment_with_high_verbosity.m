% calculate stuff for all vocalizations
options.verbosity=1;  % how much output or intermediate results the user wants to 
                      % see
options.read_from_map_cache=false;  % whether to try to use the map cache 
                                    % to save time
options.write_to_map_cache=false;  % whether to write to the map cache after 
                                   % calculating a map de novo
options.return_big_things=true;  % return the full map and other large
                                 % data structures

% directories where to find stuff
%base_dir_name='~/egnor_stuff/ssl_vocal_structure_bizarro';
% base_dir_name='/groups/egnor/egnorlab/Neunuebel/ssl_vocal_structure';
if ispc() ,
    base_dir_name='z:/Neunuebel/ssl_sys_test';
else
    base_dir_name='/groups/egnor/egnorlab/Neunuebel/ssl_sys_test';
end
data_analysis_dir_name='Data_analysis10';

% identifying info for the segment
% date_str='06132012';
% letter_str='D';
% i_segment=51;

date_str='06052012';
letter_str='D';
i_segment=636;

% run the segment
results= ...
  r_est_from_segment_indicators(base_dir_name, ...
                                data_analysis_dir_name, ...
                                date_str, ...
                                letter_str, ...
                                i_segment, ...
                                options)
