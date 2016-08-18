function fn_save_associated_struct_parts(full_mouse, saving_dir, video_fname_prefix )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%%
index = [full_mouse.index];
%%
%formating data matrices
uniqueX = unique(index);
countOfX = hist(index,uniqueX);
indexToRepeatedValue = (countOfX~=1);
numberOfAppearancesOfRepeatedValues = countOfX(indexToRepeatedValue);

last_spot = 1;
cd (saving_dir)
for i = 1:size(numberOfAppearancesOfRepeatedValues,2)
    mouse = full_mouse(last_spot:last_spot+numberOfAppearancesOfRepeatedValues(i));
%     old_syl = mouse(1).
    save_file_name = sprintf('%s_Mouse_syl%d',video_fname_prefix,old_syl);
    save(save_file_name,'mouse')
    clear mouse save_file_name old_syl
    last_spot = numberOfAppearancesOfRepeatedValues(i);
end



    

end

