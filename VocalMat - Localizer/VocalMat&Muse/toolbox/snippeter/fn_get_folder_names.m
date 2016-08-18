function [found_file] = fn_get_folder_names(dir1,file_of_interest)
clc
y = dir(dir1);
dir_values = find([y.isdir]==1);
for i = dir_values
    dir_name{i,1} = y(i).name;
end
for i = 1:size(dir_name,1)
    tmp = dir_name(i,1);
    tmp2 = cell2mat(strfind(tmp,file_of_interest));
    if isempty(tmp2)==0
        found_file = dir_name{i,1};
        disp(found_file)
        break
    end
end
