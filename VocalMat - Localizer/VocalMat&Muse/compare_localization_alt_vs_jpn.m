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
base_dir_name='/groups/egnor/egnorlab/Neunuebel/ssl_sys_test';
data_analysis_dir_name='Data_analysis10';


load('localized_etc_alt.mat');
load('localized_etc_alt_jpn.mat');
alt=localized_etc_alt;
jpn=localized_etc_alt_jpn';

localized_alt=[alt.localized]';
localized_jpn=[jpn.localized]';

is_different=(localized_alt~=localized_jpn);
i_different=find(is_different);
n_different=length(i_different)

is_localized_by_alt_only=(localized_alt&~localized_jpn);
i_localized_by_alt_only=find(is_localized_by_alt_only);
n_localized_by_alt_only=length(i_localized_by_alt_only)

is_localized_by_jpn_only=(~localized_alt&localized_jpn);
i_localized_by_jpn_only=find(is_localized_by_jpn_only);
n_localized_by_jpn_only=length(i_localized_by_jpn_only)

% JPN localized 7 more than ALT on balance, but
% they differ for 105 segments of 3724 !

alt_different=alt(is_different);
jpn_different=jpn(is_different);
alt_localized_by_jpn_only=alt(is_localized_by_jpn_only);
alt_localized_by_alt_only=alt(is_localized_by_alt_only);

% % look at the ones localized by JPN only
% %i_different_shuffled=randperm(n_localized_by_jpn_only);
% for j=1:n_localized_by_jpn_only
%   i=j
%   results= ...
%     r_est_from_segment_indicators(base_dir_name, ...
%                                   data_analysis_dir_name, ...
%                                   alt_localized_by_jpn_only(i).date_str, ...
%                                   alt_localized_by_jpn_only(i).letter_str, ...
%                                   alt_localized_by_jpn_only(i).i_segment, ...
%                                   options)
%   drawnow;                              
% end

% look at the ones localized by ALT only
i_localized_by_alt_only_shuffled=randperm(n_localized_by_alt_only);
for j=1:n_localized_by_alt_only
  i=i_localized_by_alt_only_shuffled(j);
  results= ...
    r_est_from_segment_indicators(base_dir_name, ...
                                  data_analysis_dir_name, ...
                                  alt_localized_by_alt_only(i).date_str, ...
                                  alt_localized_by_alt_only(i).letter_str, ...
                                  alt_localized_by_alt_only(i).i_segment, ...
                                  options)
  drawnow;                              
end


