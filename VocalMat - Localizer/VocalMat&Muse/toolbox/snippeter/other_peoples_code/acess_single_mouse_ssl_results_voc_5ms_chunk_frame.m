clc
clear
close all

fc = 450450;
to_do = 3;

scale_size = 14;%size of ruler for scale calibration
video_fname_prefix = 'Test_D_1';
min_seg_time = 5;%ms
% load('U:\Matlab\progs\v33_multiple_mice_cleaned_up\r_est_raw_for_06052012_D_voc_frame_chunk_DA3_pdfs.mat')
% load('A:\Neunuebel\ssl_sys_test\sys_test_06052012\Data_analysis3\Test_D_1_Mouse.mat')
part1 = 'A:\Neunuebel\ssl_sys_test\sys_test_06052012\';
folder1 = 'Data_analysis8\';
folder2 = 'demux\';
dir1 = sprintf('%s%s',part1,folder1);
dir2 = part1;
dir3 = sprintf('%s%s',part1,folder2);

load('U:\Matlab\progs\v33_multiple_mice_cleaned_up\r_est_raw_for_06052012_D_voc_5ms_chunk_DA8_pdfs.mat')
cd (dir1)
load('Test_D_1_Mouse.mat')

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
%%%%%%%%%%%%%%%%%%%%%%%cage corner positions
strSeekFilename = [dir1,video_fname_prefix,'_RMS_signal_amp.mat'];
if ~exist(strSeekFilename,'file') %check if exist
    signal = zeros(1,size(mouse,2));
    cd (dir3)
    for i=1:size(mouse,2)
        voc_num = char(mouse(i).syl_name);
        pos1 = strfind(voc_num,'_');
        char_value = str2num(sprintf('%d',voc_num(pos1+1:end)));
        if char_value == 48;
            signal(1:4,i) = NaN;
        else
            start_ts = mouse(i).start_sample_fine;
            stop_ts = mouse(i).stop_sample_fine;
            hf = mouse(i).hf_fine;
            lf = mouse(i).lf_fine;
            foo = start_ts:stop_ts;
            if lf>hf
                tmp = lf;
                hf = lf;
                lf = tmp;
                clear tmp
            end
            tmp_sig = zeros(4,size(foo,2));
            for ch_num = 1:4
                filename_prefix1 = sprintf('%s.ch%d',video_fname_prefix,ch_num);
                fid = fopen(filename_prefix1,'r');
                fseek(fid, start_ts*4, -1);
                tmp_sig(ch_num,:) = fread(fid,size(foo,2),'float32');
                fclose(fid);
                signal(ch_num,i) = calculate_channel_rms2(tmp_sig(ch_num,:), hf, lf, fc);
                clear filename_prefix1 fid
            end
            clear tmp_sig foo lf hf start_ts stop_ts
        end
        clear voc_num pos1 char_value
    end
else
    cd (dir1);
    load('Test_D_1_RMS_signal_amp.mat')
end
clear strSeekFilename
%% asigns name
r_est = [r_est_blob_per_voc_per_trial{1,1}.r_est];
r_head = [r_est_blob_per_voc_per_trial{1,1}.r_head];
r_tail = [r_est_blob_per_voc_per_trial{1,1}.r_tail];
i_syl = [r_est_blob_per_voc_per_trial{1,1}.i_syl];
%%
error = fn_calculate_distance3( r_head, r_est);
%%
index = [mouse.index];
start_ts = [mouse.start_sample_fine];
stop_ts = [mouse.stop_sample_fine];
dur = (stop_ts-start_ts)/fc;
dur = dur*1000; %ms

%%
%might want to remove outliers and track which chunks were removed
%(i.e., r_est estimates that were located outside of cage)


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
head_error = nan(num_vocs,max_num_chunks);
pos_x_mat = head_error;
pos_y_mat = head_error;
r_est_x_mat = head_error;
r_est_y_mat = head_error;
dur_mat = head_error;
color_list = zeros(1,size(i_syl,2));

for i = 1:size(i_syl,2)
    voc_num = char(i_syl{i});
    pos1 = strfind(voc_num,'_');
    char_value = str2num(sprintf('%d',voc_num(pos1+1:end)));
    if char_value == 48;
        col = 1;
    else
        col = char_value - 95;
    end
    %     color_list{1,i} = color_v;
    color_list(1,i) = col;
    head_error(mouse(i).index,col) = error(1,i);
    dur_mat(mouse(i).index,col) = dur(1,i);
    pos_x_mat(mouse(i).index,col) = r_head(1,i);
    pos_y_mat(mouse(i).index,col) = r_head(2,i);
    r_est_x_mat(mouse(i).index,col) = r_est(1,i);
    r_est_y_mat(mouse(i).index,col) = r_est(2,i);
    %      num{i} = regexprep(fileName{i},'[^\d]*','');
end
%%
% figure('color','w')
% tmp_dur = dur(color_loc);
% tmp_error = error(color_loc);
% short = find(dur<min_seg_time);
% signal(:,short) = NaN;
% step_size = 100;
% for i = 1:size(signal,1)+1
%     if i<=size(signal,1)
%         locs = isnan(signal(i,:))==0;
% %         tmp_signal = log(signal(i,locs));
% %         xlabel_s = sprintf('Log Signal Amplitude ch%d (rms)',i);
%         tmp_signal = (signal(i,locs));
%         xlabel_s = sprintf('Signal Amplitude ch%d (rms)',i);
%     else
%         tmp = min(signal,[],1);
%         locs = isnan(tmp(1,:))==0;
% %         tmp_signal = log(tmp(1,locs));
% %         xlabel_s = 'Log Signal Amplitude Smallest Ch (rms)';
%         tmp_signal = (tmp(1,locs));
%         xlabel_s = 'Signal Amplitude Smallest Ch (rms)';
%     end
% %     tmp_error = log(error(locs));
% %     ylabel_s = 'Log Error (m)';
%     tmp_error = (error(locs));
%     ylabel_s = 'Error (m)';
%
%     x2 = linspace(min(tmp_error), max(tmp_error),step_size);
%     y2 = linspace(min(tmp_signal), max(tmp_signal),step_size);
%     nbins = [size(x2,2),size(y2,2)];
%
%     data = [tmp_signal' tmp_error'];
%     figure('color','w')
%     hold on
%     n = hist3(data,nbins);
%     n1 = n';
%     n1( size(n,1) + 1 ,size(n,2) + 1 ) = 0;
%     xb = linspace(min(data(:,1)),max(data(:,1)),size(n,1)+1);
%     yb = linspace(min(data(:,2)),max(data(:,2)),size(n,1)+1);
%     imagesc(xb,yb,n1)
%     colormap(jet(254))
%     xlim([xb(1) xb(end)])
%     ylim([yb(1) yb(end)])
% %     hl1 = line([min_seg_time min_seg_time],[0 0.9]);
% %     hl2 = line([7 7],[0 0.9]);
%     colorbar
%     xlabel(xlabel_s)
%     ylabel(ylabel_s)
%     title('06052012-D-solo male')
% %     set(hl1,'color','r','linestyle','-','linewidth',3)
% %     set(hl2,'color','r','linestyle',':','linewidth',3)
%     disp(1)
%
% end
%%
% checking to see if correlation in data to determine if each chunk is independent
if to_do <= 1
    for i = 1:size(r_est_x_mat,1)
        r_est_x_tmp =  r_est_x_mat(i,:);
        r_est_y_tmp = r_est_y_mat(i,:);
        small = fn_find_short_chunks(min_seg_time,dur_mat,i);
        r_est_x_tmp(1,small) = NaN;
        r_est_y_tmp(1,small) = NaN;
        locs = isnan(r_est_x_tmp)==0;
        X_tmp = r_est_x_tmp(1,locs);
        Y_tmp = r_est_y_tmp(1,locs);
        if i == 1
            Xs = X_tmp(2:end-1);
            Xsplus = X_tmp(3:end);
            Ys = Y_tmp(2:end-1);
            Ysplus = Y_tmp(3:end);
        else
            Xs = cat(2,Xs,X_tmp(2:end-1));
            Xsplus = cat(2,Xsplus,X_tmp(3:end));
            Ys = cat(2,Ys,Y_tmp(2:end-1));
            Ysplus = cat(2,Ysplus,Y_tmp(3:end));
        end
        clear X_tmp Y_tmp locs
    end
    figure
    scatter(Xs,Xsplus,'filled')
    xlabel('R EST X n')
    ylabel('R EST X n+1')
    x_corr = corr(Xs',Xsplus');
    title(x_corr)
    figure
    scatter(Ys,Ysplus,'filled')
    xlabel('R EST Y n')
    ylabel('R EST Y n+1')
    y_corr = corr(Ys',Ysplus');
    title(y_corr)
end
%%
%diff in whole vs. chunk error
if to_do<=2
    step_size = 0.05;
    tmp = head_error;
    for i = 1:size(tmp,2)
        tmp2 = dur_mat(:,i);
        short = find(tmp2<min_seg_time);
        tmp(short,i) = NaN;
        clear short tmp2
    end
    for i = 2:size(tmp,2)
        diff_wv_chunk = tmp(:,1)-tmp(:,i);
        %         figure
        %         hist(diff_wv_chunk,min(diff_wv_chunk):step_size:max(diff_wv_chunk))
        %         title(i)
        if i == 2
            all_diff_wv_chunk =diff_wv_chunk;
        else
            all_diff_wv_chunk = cat(1,all_diff_wv_chunk,diff_wv_chunk);
        end
    end
    figure
    hist(all_diff_wv_chunk,min(all_diff_wv_chunk):step_size:max(all_diff_wv_chunk))
    title('All')
    locs = find(isnan(all_diff_wv_chunk)==0);
    median_all_diff_wv_chunk = median(all_diff_wv_chunk(locs));
    max_y = max(get(gca,'ylim'));
    hold on
    plot([median_all_diff_wv_chunk median_all_diff_wv_chunk],[0 max_y],'r')
    min_x = min(get(gca,'xlim'));
    xlim([min_x abs(min_x)])
    clear locs
end
close all
%%
%Jackknife, mean and STD
%degrees of circle
ang=0:0.01:2*pi;
%sets up tmp data
clear tmp1 tmp2 tmp3 tmp4 tmp5
tmp1 = dur_mat(:,2:end);
tmp2 = pos_x_mat(:,2:end);
tmp3 = pos_y_mat(:,2:end);
tmp4 = r_est_x_mat(:,2:end);
tmp5 = r_est_y_mat(:,2:end);
% tmp6 = head_error(:,2:end);

%preallocate space for jackknife procedures
mean_x = zeros(size(tmp1,1),1);
std_x = zeros(size(tmp1,1),1);
mean_y = zeros(size(tmp1,1),1);
std_y = zeros(size(tmp1,1),1);
std_error = zeros(size(tmp1,1),1);
mean_error = zeros(size(tmp1,1),1);
cov_loc = zeros(size(tmp1,1),2);
n = 50;
Xrange = linspace(min(corners_x),max(corners_x),n);
Yrange = linspace(min(corners_y),max(corners_y),n);
[Xrange_m,Yrange_m] = meshgrid(Xrange,Yrange);

if to_do<=3
    for i = 1:size(head_error,1)
        
        %gets all data from single segment
        pos_x_tmp = tmp2(i,:);
        pos_y_tmp = tmp3(i,:);
        r_est_x_tmp = tmp4(i,:);
        r_est_y_tmp = tmp5(i,:);
        %         head_error_tmp = tmp6(i,:);
        
        %finds and removes small chunks at i from tmp1 -  whole voc ssl
        %estimate removed
        small = fn_find_short_chunks(min_seg_time,tmp1,i);
        pos_x_tmp(1,small) = NaN;
        pos_y_tmp(1,small) = NaN;
        r_est_x_tmp(1,small) = NaN;
        r_est_y_tmp(1,small) = NaN;
        
        %removes NaN;
        locs = isnan(r_est_x_tmp)==0;
        X = r_est_x_tmp(1,locs);
        Y = r_est_y_tmp(1,locs);
        Pos_X = pos_x_tmp(1,locs);
        Pos_Y = pos_y_tmp(1,locs);
        
        if size(X,2)>1
            mean_x(i,1) = mean(X);
            mean_y(i,1) = mean(Y);
            mu(1) = mean(X);
            mu(2) = mean(Y);
            std_x(i,1) = std(X);
            std_y(i,1) = std(Y);
            C = cov(X,Y);
            [R,err] = cholcov(C,0);
            if err==0
                coords_chunks = cat(1,X,Y);
                coords_mouse = cat(1,Pos_X,Pos_Y);
                %standard distance error between jackknife center and r_est
                
                tmp_center = [mean_x(i,1);mean_y(i,1)];
                tmp_center_mat = ones(size(coords_mouse));
                tmp_center_mat(1,:) = tmp_center_mat(1,:)*tmp_center(1,1);
                tmp_center_mat(2,:) = tmp_center_mat(2,:)*tmp_center(2,1);
                error_tmp = fn_calculate_distance3( coords_mouse, tmp_center_mat);
                error_tmp2 = fn_calculate_distance3( coords_chunks, tmp_center_mat);
                
                [a b] = min(error_tmp);
                coords_mouse2(:,1) = coords_mouse(:,b);
                coords_mouse2(:,2) = [0.6; 0.7];
                coords_mouse2(:,3) = [0.1; 0.5];
                coords_mouse2(:,4) = [0.5; 0.2];
                %             coords_mouse2(:,5) = [mu(1); mu(2)];
                
                figure
                F = mvnpdf([Xrange_m(:) Yrange_m(:)],mu,C);
                F = reshape(F,length(Xrange_m),length(Xrange_m));
                surf(Xrange,Yrange,F);
                caxis([min(F(:))-.5*range(F(:)),max(F(:))]);
                % axis([-3 3 -3 3 0 .4])
                xlabel('x'); ylabel('y'); zlabel('Probability Density');
                
                
                % axis([-3 3 -3 3 0 .4])
                %             xlabel('x'); ylabel('y'); zlabel('Probability Density')
                
                
                %             coords_mouse2(:,2) =
                
                %             mean_error(i,1) = mean(error_tmp);
                %             std_error(i,1) = std(error_tmp);
                
                %error distance for chunks
                std_error(i,1) = std(error_tmp2);%std error in meters
                mean_error(i,1) = mean(error_tmp2);%mean error in meters
                %                             outliers = find(error_tmp2>std_error(i,1)*3)
                %                             coords_chunks(:,outliers)

                %             clear tmp_center_mat error_tmp coords
                %finds error between mouse positions and jackknifed mean
                
                %             tmp_center = [mean_x(i,1);mean_y(i,1)];
                %             tmp_center_mat = ones(size(coords));
                %             tmp_center_mat(1,:) = tmp_center_mat(1,:)*tmp_center(1,1);
                %             tmp_center_mat(2,:) = tmp_center_mat(2,:)*tmp_center(2,1);
                %             error_tmp = fn_calculate_distance3( coords, tmp_center_mat);
                %             error_range(1) = min(error_tmp);
                %             error_range(2) = max(error_tmp);
                %             z_error_range(1) = (error_range(1)-mean_error(i,1))/std_error(i,1);
                %             z_error_range(2) = (error_range(2)-mean_error(i,1))/std_error(i,1);
                %           probablity mouse was source--needs work
                %             onetailed =
                %             onetailed = normcdf(-abs(error_range),mean_error(i,1),std_error(i,1));
                %             twotailed = 2*onetailed
                
                %             onetailed(2) = normcdf(-abs(z_error_range(2)),mean_error(i,1),std_error(i,1))
                %             twotailed(2) = 2*onetailed(2);
                
                 clear tmp_center_mat error_tmp coords
                %plotting
                figure
                plot(corners_x,corners_y,'k')
                axis equal
                ylim([min(corners_y)*0.8 max(corners_y)*1.2])
                xlim([min(corners_x)*0.8 max(corners_x)*1.2])
                hold on
                plot(Pos_X,Pos_Y,'k.-')
                scatter(X,Y,3,'filled','r')
                plot([mean_x(i,1)-std_x(i,1) mean_x(i,1)+std_x(i,1)],[mean_y(i,1) mean_y(i,1)],'b')
                plot([mean_x(i,1) mean_x(i,1)],[mean_y(i,1)-std_y(i,1) mean_y(i,1)+std_y(i,1)],'b')
                plot(mean_x(i,1),mean_y(i,1),'bo', 'MarkerFace','b')
                scatter(coords_mouse2(1,:),coords_mouse2(2,:),'g')
                %             %plot error cicle
                %             xp1=std_error(i,1)*cos(ang);
                %             yp1=std_error(i,1)*sin(ang);
                %             xp3=3*std_error(i,1)*cos(ang);
                %             yp3=3*std_error(i,1)*sin(ang);
                %             plot(mean_x(i,1)+xp1,mean_y(i,1)+yp1,'g-');
                %             plot(mean_x(i,1)+xp3,mean_y(i,1)+yp3,'g');
                %             error_ellipse(C,mu)
                ppd = mvnpdf(coords_mouse2',mu,C);
%                 coords_mouse2';
                p = ppd/sum(ppd);
                error_ellipse(C,mu,0.95)
                
                if size(coords_chunks,2)>3
                    [idx,dm,mm,Ss] = kur_rce(coords_chunks',0);
                    outliers_k = find(idx==1);
                    if isempty(outliers_k) == 0
                        coords_chunks(:,outliers_k)
                        plot(coords_chunks(1,outliers_k),coords_chunks(2,outliers_k),'ko')
                    end
                end
                
                clear tmp_center_mat error_tmp coords
                close all
                clc
            else
                figure
                figure
            end
            %             N = size(X,2);
            %             D1 = (2*pi)^(N/2)*(abs(C))^(1/2)
            %             M = (-1(x-
            clear X Y locs xp1 xp3 yp1 yp3
        else
            mean_x(i,1) = NaN;
            std_x(i,1) = NaN;
            mean_y(i,1) = NaN;
            std_y(i,1) = NaN;
        end
    end
end
