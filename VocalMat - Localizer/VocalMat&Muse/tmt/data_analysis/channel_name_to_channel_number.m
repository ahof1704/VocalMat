function channel_number=channel_name_to_channel_number(fid,channel_name)

% Determines a channel number given a channel name, for .smr files.
% if there is no channel by that name, it returns an empty array

channel_list=SONChanList(fid);
channel_numbers=cell2mat({channel_list.number})';
channel_names={channel_list.title}';
channel_number=find(strcmp(channel_name,channel_names));
