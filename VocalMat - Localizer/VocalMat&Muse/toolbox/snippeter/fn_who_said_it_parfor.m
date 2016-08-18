function fn_who_said_it_parfor(date_str,let_str,folder1,num_virtual_mice,num_mice,chunk_start_num,scale_size,min_seg_time,hot_pix_threshold,max_freq_threshold,dsn)
%fn_who_said_it_parfor
%   determines source of vocalization-does not actually run with parfor

%plot options
subplot_options.on_off = 'on';
subplot_options.num_rows = 4;
subplot_options.num_cols = 2;
subplot_options.vis = 'off';

%data_set_name
video_fname_prefix = sprintf('Test_%s_1',let_str);
%directories
if dsn>8
    part1 = sprintf('A:\\Neunuebel\\ssl_vocal_structure\\%s\\',date_str);
else
    part1 = sprintf('A:\\Neunuebel\\ssl_sys_test\\sys_test_%s\\',date_str);
end
dir1 = sprintf('%s%s',part1,folder1);
dir2 = part1;
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

corners_x = [corners_out.x_m];
corners_x(1,end+1) = corners_x(1,1);
corners_y = [corners_out.y_m];
corners_y(1,end+1) = corners_y(1,1);

%%
%loads MUSE_index dur hot_pix r_est r_head
cd (dir1)
fn1 = sprintf('results_MUSE_matrix_%s',let_str);
s=load (fn1);
r_est = s.r_est;
r_head = s.r_head;
MUSE_index = s.index;
dur = s.dur;
% hf = s.hf;
% lf = s.lf;
hot_pix = s.hot_pix;
% syl_name_old = s.syl_name_old;
clear s
%%
num_vocs = max(MUSE_index);

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

subplot_options.max_size = num_vocs;

centroid_chunks = nan(2,num_vocs);%x y cords for snippits
area = nan(1,num_vocs);%
coords_mouse2 = nan(2,num_mice+num_virtual_mice,num_vocs);
p = nan(num_mice+num_virtual_mice,num_vocs);%top row = density bottom row = p value, columns = 1:mice number + virtual mice, z-stack = voc segment number
density = nan(num_mice+num_virtual_mice,num_vocs);
outliers = cell(1,num_vocs);
ce_x = cell(1,num_vocs);
ce_y = cell(1,num_vocs);
repeated_snippet = cell(1,num_vocs);%record of deleted snippets that had same x y pos
cov_value = nan(2,num_vocs);
odd_vocs = nan(1,num_vocs);%record of odd things...removed to many points after outliers removed,repeated snippets etc...
cd (dir1)
tic
for par_loop_number =1:num_vocs
    %     for par_loop_number = 1:num_vocs;
    %gets all data from single segment
    %     error('need to fix and correct tracking errors')
    [coords_chunks,coords_mouse,delete_locs,odd_voc] = fn_determine_coords(par_loop_number,num_mice,chunk_start_num,MUSE_index,dur,hot_pix,r_est,r_head,min_seg_time,hot_pix_threshold);
    repeated_snippet{1,par_loop_number} = delete_locs;
    odd_vocs(1,par_loop_number) = odd_voc;
    if strcmp(date_str,'03032013')==1 && par_loop_number == 50528
        odd_vocs(1,par_loop_number) = 1;
        clear coords_chunks coords_mouse
        coords_chunks = [];
        coords_mouse = [];
    end
    %         if (isempty(coords_chunks(1,:))==0)
    if size(coords_chunks,2)>2
        if (all(coords_chunks(1,:)==coords_chunks(1,1)) && all(coords_chunks(2,:)==coords_chunks(2,1))) == 0
            if num_virtual_mice>0
                vc_cat = fn_cat_fake_mouse(num_virtual_mice,range_x, range_y, scale_factor);
            else
                vc_cat = [];
            end
            %             disp(sprintf('%s %d',date_str,par_loop_number))
            [idx2,dm,mm,C] = kur_rce(coords_chunks',1);
            size_wo_outliers = numel(find(idx2==0));
            if size_wo_outliers>2
                outliers_k = find(idx2==1);
                if isempty(outliers_k) == 0
                    outliers{1,par_loop_number} = outliers_k;
                end
                centroid_chunks(:,par_loop_number) = mm'; %mean x y of all snippets
                rc_cat = fn_cat_real_mouse(mm,num_mice,coords_mouse);
                tmp_coords = cat(2,rc_cat,vc_cat);
                coords_mouse2(:,:,par_loop_number) = tmp_coords;
                
                density(:,par_loop_number) = mvnpdf(coords_mouse2(:,:,par_loop_number)',centroid_chunks(:,par_loop_number)',C);
                p(:,par_loop_number) = density(:,par_loop_number)/sum(density(:,par_loop_number));
                cov_value(1,par_loop_number) = C(1,1);
                cov_value(2,par_loop_number) = C(2,2);
                %                 error('need to return x y values of elipse')
                [area(1,par_loop_number),ce_x{1,par_loop_number},ce_y{1,par_loop_number}] = fn_plot_chunks2(dir1,...
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
                if isnan(area(1,par_loop_number))==1
                    disp(1)
                end
            end
        end
    end
end
toc

save_filename1 = sprintf('Results_who_said_it_single_mouse_%s',let_str);
cd (dir1)
save(save_filename1,'area','outliers','p',...
    'density','coords_mouse2','centroid_chunks','cov_value',...
    'repeated_snippet','odd_vocs','ce_x','ce_y')
fprintf('Done with %s!\n',date_str)
end

