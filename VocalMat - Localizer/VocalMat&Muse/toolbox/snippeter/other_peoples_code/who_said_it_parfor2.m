
%data_set_name
video_fname_prefix = 'Test_B_1';

%directories
part1 = 'A:\Neunuebel\ssl_vocal_structure\';
folder2 = 'demux\';
dir1 = sprintf('%s%s',part1,folder1);
dir2 = part1;
dir3 = sprintf('%s%s',part1,folder2);

%%%%%%%%%%%%%%%%%%%%%%%conversion factor
strSeekFilename = [dir2,'meters_2_pixels.mat'];
if ~exist(strSeekFilename,'file') %check if exist
    load_saved_conversion_factor = 'n';
else
    load_saved_conversion_factor = 'y';
end
clear strSeekFilename

scale_vfilename = sprintf('%s.seq',video_fname_prefix);
[meters_2_pixels handle1] = fn_scale_factor(dir2, scale_vfilename , scale_size, load_saved_conversion_factor);
close (handle1)

%%%%%%%%%%%%%%%%%%%%%%%cage corner positions
strSeekFilename = [dir2,video_fname_prefix,'_mark_corners.mat'];
if ~exist(strSeekFilename,'file') %check if exist
    load_saved_corners = 'n';
else
    load_saved_corners = 'y';
end
clear strSeekFilename

vfilename = [video_fname_prefix '.seq'];
[corners_out, handle1] = fn_corner_pos_location(dir2,vfilename,meters_2_pixels,load_saved_corners, video_fname_prefix);
close (handle1)
clc
corners_x = [corners_out.x_m];
corners_x(1,end+1) = corners_x(1,1);
corners_y = [corners_out.y_m];
corners_y(1,end+1) = corners_y(1,1);

%%
%loads index dur hot_pix r_est r_head
cd (dir1)
load ('results_MUSE_matrix')
%%
%formating data matrices
[n, bin] = histc(index, unique(index));
multiple = find(n > 1);
loc_repeats  = find(ismember(bin, multiple));

uniqueX = unique(index);
countOfX = hist(index,uniqueX);
indexToRepeatedValue = (countOfX~=1);
repeatedValues = uniqueX(indexToRepeatedValue);
numberOfAppearancesOfRepeatedValues = countOfX(indexToRepeatedValue);

num_vocs = max(index);
max_num_chunks = max(numberOfAppearancesOfRepeatedValues);
%%
%sets up tmp data
clear tmp1 tmp2 tmp3 tmp4 tmp5
% tmp1 = dur_mat(:,chunk_start_num:end);

%preallocate space
n = 50;
Xrange = linspace(min(corners_x),max(corners_x),n);
Yrange = linspace(min(corners_y),max(corners_y),n);
[Xrange_m,Yrange_m] = meshgrid(Xrange,Yrange);
scale_factor = 100;
range_x = [ceil(min(corners_x)*scale_factor),floor(max(corners_x)*scale_factor)];
range_y = [ceil(min(corners_y)*scale_factor),floor(max(corners_y)*scale_factor)];

odd_voc_count = 0;
odd_voc = 'n';
subplot_options.max_size = num_vocs;

var1 = subplot_options.on_off;
rows = subplot_options.num_rows;
cols = subplot_options.num_cols;
vis = subplot_options.vis;
max_size = num_vocs;

centroid_chunks = nan(2,num_vocs);
area = nan(1,num_vocs);
coords_mouse2 = nan(2,num_mice+num_virtual_mice,num_vocs);
p = nan(num_mice+num_virtual_mice,num_vocs);%top row = density bottom row = p value, columns = 1:mice number + virtual mice, z-stack = voc segment number
density = nan(num_mice+num_virtual_mice,num_vocs);
outliers = cell(1,num_vocs);
odd_voc_list = nan(2,num_vocs);

cd (dir1)
tic
parfor par_loop_number = 1:num_vocs
    %     for par_loop_number = 1:num_vocs;
    %gets all data from single segment
    [coords_chunks coords_mouse] = fn_determine_coords(par_loop_number,num_mice,chunk_start_num,index,dur,hot_pix,r_est,r_head,min_seg_time,hot_pix_threshold);
    
    %         if (isempty(coords_chunks(1,:))==0)
    if size(coords_chunks,2)>2
        if (all(coords_chunks(1,:)==coords_chunks(1,1)) && all(coords_chunks(2,:)==coords_chunks(2,1))) == 0
            if num_virtual_mice>0
                vc_cat = fn_cat_fake_mouse(num_virtual_mice,range_x, range_y, scale_factor);
            end
            
            [idx2,dm,mm,C] = kur_rce(coords_chunks',0);
            outliers_k = find(idx2==1);
            if isempty(outliers_k) == 0
                outliers{1,par_loop_number} = outliers_k;
            end
            
            centroid_chunks(:,par_loop_number) = mm';
            rc_cat = fn_cat_real_mouse(mm,num_mice,coords_mouse);
            tmp_coords = cat(2,rc_cat,vc_cat);
            coords_mouse2(:,:,par_loop_number) = tmp_coords;
            
            density(:,par_loop_number) = mvnpdf(coords_mouse2(:,:,par_loop_number)',centroid_chunks(:,par_loop_number)',C);
            p(:,par_loop_number) = density(:,par_loop_number)/sum(density(:,par_loop_number));
            
            area(1,par_loop_number) = fn_plot_chunks2(dir1,...
                video_fname_prefix,...
                C,...
                par_loop_number,...
                mm,...
                coords_mouse2(:,:,par_loop_number),...
                coords_mouse,...
                Xrange,...
                Yrange,...
                Xrange_m,...
                Yrange_m,...
                corners_x,...
                corners_y,...
                coords_chunks,...
                outliers_k,...
                p(:,par_loop_number),...
                subplot_options,...
                num_mice+num_virtual_mice);
        end
    end
end
toc


cd (dir1)
save('Results_who_said_it_single_mouse.mat','area','odd_voc_list','outliers','p')
matlabpool close
