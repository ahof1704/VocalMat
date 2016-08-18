function mouse=load_ax_segments(file_name)

s=load(file_name);
voc_list=s.voc_list;
clear s;

tmp_good = voc_list(:,6);
good_vocs = tmp_good == 1;
list = voc_list(good_vocs,1:5);

n_segments_from_ax=size(list,1);
mouse=struct('syl_name',cell(1,n_segments_from_ax));  % josh-style mouse structure
for i = 1:n_segments_from_ax
    %voc number
    mouse(i).syl_name = sprintf('Voc%g',list(i,1));
    %voc freq info
    mouse(i).lf_fine = floor(list(i,4));
    mouse(i).hf_fine = ceil(list(i,5));
    %voc start/stop times(samples)
    mouse(i).start_sample_fine = list(i,2);
    mouse(i).stop_sample_fine = list(i,3);
end

end
