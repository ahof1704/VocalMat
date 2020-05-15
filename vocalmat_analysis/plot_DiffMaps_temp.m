% T(strcmp(T.Testing_label,'chevron'),17)=array2table(1);
% T(strcmp(T.Testing_label,'complex'),17)=array2table(2);
% T(strcmp(T.Testing_label,'down_fm'),17)=array2table(3);
% T(strcmp(T.Testing_label,'flat'),17)=array2table(4);
% T(strcmp(T.Testing_label,'mult_steps'),17)=array2table(5);
% T(strcmp(T.Testing_label,'noise_dist'),17)=array2table(6);
% T(strcmp(T.Testing_label,'rev_chevron'),17)=array2table(7);
% T(strcmp(T.Testing_label,'short'),17)=array2table(8);
% T(strcmp(T.Testing_label,'step_down'),17)=array2table(9);
% T(strcmp(T.Testing_label,'step_up'),17)=array2table(10);
% T(strcmp(T.Testing_label,'two_steps'),17)=array2table(11);
% T(strcmp(T.Testing_label,'up_fm'),17)=array2table(12);
%
% combined_AJmom_AJpups_prob(strcmp(combined_AJmom_AJpups_prob(:,15),'chevron'),15)={1};
% combined_AJmom_AJpups_prob(strcmp(combined_AJmom_AJpups_prob(:,15),'complex'),15)={2};
% combined_AJmom_AJpups_prob(strcmp(combined_AJmom_AJpups_prob(:,15),'down_fm'),15)={3};
% combined_AJmom_AJpups_prob(strcmp(combined_AJmom_AJpups_prob(:,15),'flat'),15)={4};
% combined_AJmom_AJpups_prob(strcmp(combined_AJmom_AJpups_prob(:,15),'mult_steps'),15)={5};
% combined_AJmom_AJpups_prob(strcmp(combined_AJmom_AJpups_prob(:,15),'rev_chevron'),15)={6};
% combined_AJmom_AJpups_prob(strcmp(combined_AJmom_AJpups_prob(:,15),'short'),15)={7};
% combined_AJmom_AJpups_prob(strcmp(combined_AJmom_AJpups_prob(:,15),'step_down'),15)={8};
% combined_AJmom_AJpups_prob(strcmp(combined_AJmom_AJpups_prob(:,15),'step_up'),15)={9};
% combined_AJmom_AJpups_prob(strcmp(combined_AJmom_AJpups_prob(:,15),'two_steps'),15)={10};
% combined_AJmom_AJpups_prob(strcmp(combined_AJmom_AJpups_prob(:,15),'up_fm'),15)={11};

% labels = {'chevron','complex','down_fm','flat','mult_steps','noise_dist',...
%     'rev_chevron','short','step_down''step_up','two_steps','up_fm'};

% labels = labels';
% clear all
close all
build_table=0;
workingfolder1 = 'Z:\Dietrich_Server\Gabriela\Backup\idisco_90mins_isolation\B6';
cd(workingfolder1)

if build_table==1
T_out2=[];
T = [];
raiz = pwd;
list = dir;
isdir = [list.isdir].';
list_dir = list(isdir,:); list_dir(1:2)=[];
not_validated = [];

% for i = 1:size(list_dir,1)
% %     load(['output_shorter_' list_dir(i).name '.mat']) ;
%     cd([raiz '\' list_dir(i).name])
%     list = dir('*_DL.xlsx');
%     disp(['Loading ' list_dir(i).name])
%     [GT,txt,raw] = xlsread(list(1).name);
%     
%     T = [T; [raw(2:end,[13,1:12,14])] ];
%     
% end

% T = cell2table(combined_AJmom_AJpups_prob,'Variablenames',['File', txt(1,:)]);
% T = array2table(vocalizations_Agrp_2nd_all,'Variablenames',['File', txt(1,:)]);
T = T_all;
load('Z:\Dietrich_Server\MZimmer\with_diffusion_maps\Agrp_2nd\maps_1_vocalizations_Agrp_2nd_all.mat');
T3D = maps_1;
% aux = ~strcmp(T.DL_out,'noise_dist');
% T = T(aux,:); T3D = T3D(aux,:);

% labels = table2array((T(:,15)));
% v = double(categorical(labels));

% vocalizations = table2array(T(:,2:13)); % v];
end

% labels = table2array((T(:,4)));
% v = double(categorical(labels));
load('Z:\test\1304_Agrp_Trpv1_2nd_Stage\map_1304_Agrp_Trpv1_2nd_Stage.mat')
T3D = map_1304_Agrp_Trpv1_2nd_Stage;
% T3D = T3D(combined_aj_b6(:,14)==2,:);
% temp_group = combined_aj_b6(combined_aj_b6(:,14)==2,:);
idxs = {};
scts = {};
for i=1:11
%     idxs{i} = T.DL_out == i;
    idxs{i} = label_1304_Agrp_Trpv1_2nd_Stage(:,1)==i;
    scts{i,1} = T3D(idxs{i},1);
    scts{i,2} = T3D(idxs{i},2);
    scts{i,3} = T3D(idxs{i},3);
end

% hFig = figure();
% axh = axes('Parent', hFig);
% hold(axh, 'all');
%
% chevron     = scatter3(scts{1,1},  scts{1,2},  scts{1,3},  20, 'r', 'filled');
% complex     = scatter3(scts{2,1},  scts{2,2},  scts{2,3},  20, [0.65 0.65 0.65], 'filled');
% down_fm     = scatter3(scts{3,1},  scts{3,2},  scts{3,3},  20, 'b', 'filled');
% flat        = scatter3(scts{4,1},  scts{4,2},  scts{4,3},  20, 'y', 'filled');
% mult_steps  = scatter3(scts{5,1},  scts{5,2},  scts{5,3},  20, 'm', 'filled');
% noise_dist  = scatter3(scts{6,1},  scts{6,2},  scts{6,3},  20, 'c', 'filled');
% rev_chevron = scatter3(scts{7,1},  scts{7,2},  scts{7,3},  20, 'k', 'filled');
% shorts      = scatter3(scts{8,1},  scts{8,2},  scts{8,3},  20, [0.49 0.18 0.56], 'filled');
% step_down   = scatter3(scts{9,1},  scts{9,2},  scts{9,3},  20, [0.333333333333333 1 0.666666666666667], 'filled');
% step_up     = scatter3(scts{10,1}, scts{10,2}, scts{10,3}, 20, [1 0.666666666666667 0], 'filled');
% two_steps   = scatter3(scts{11,1}, scts{11,2}, scts{11,3}, 20, [0.47 0.67 0.19], 'filled');
% up_fm       = scatter3(scts{12,1}, scts{12,2}, scts{12,3}, 20, [0 0.666666666666667 1], 'filled');
%
% view(axh, -50, 22);
% grid(axh, 'on');
% legend(axh, [chevron, complex, down_fm, flat, mult_steps, noise_dist, rev_chevron, shorts, step_down, step_up, two_steps, up_fm], {'chevron','complex','down_fm','flat','mult_steps','noise_dist','rev_chevron','short','step_down','step_up','two_steps','up_fm'}, 'interpreter', 'none', 'FontSize', 15);
% title('3-D Embedding, sigma: 0.5')

%redirect paths
hFig = figure('units','normalized','outerposition',[0 0 1 1]);
axh = axes('Parent', hFig);
title('3-D Embedding, sigma: 0.5, AJ_control','interpreter', 'none')
p = get(axh, 'Position');
% h = axes('Parent', gcf, 'Position', [p(1)+0.65 p(2) 0.2 0.2]);

int=1;k=1;offset=200;
while k<2
%     k = round(1+(size(T,1)-1)*rand(1,1));
    if mod(int,10)==1
        k
        if exist('current_dot')
           delete(current_dot) 
           clear current_dot
        end
%     newStr = strrep(T.AA21{k+offset},'/gpfs/ysm/scratch60/ahf38/USVs/MZ_data/Agrp_2nd/','Z:\Dietrich_Server\MZimmer\with_diffusion_maps\Agrp_2nd\');
%     newStr = strrep(newStr,'/','\');
%     im = imread(newStr); %figure, imshow(im)
    %     cla(axh)
    %     subplot(2,1,2,axh)
    hold(axh, 'on');
    chevron     = scatter3(axh,scts{1,1},  scts{1,2},  scts{1,3},  20, 'r', 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
    complex     = scatter3(axh,scts{2,1},  scts{2,2},  scts{2,3},  20, [0.65 0.65 0.65], 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
    down_fm     = scatter3(axh,scts{3,1},  scts{3,2},  scts{3,3},  20, 'b', 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
    flat        = scatter3(axh,scts{4,1},  scts{4,2},  scts{4,3},  20, 'y', 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
    mult_steps  = scatter3(axh,scts{5,1},  scts{5,2},  scts{5,3},  20, 'm', 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
%     noise_dist  = scatter3(axh,scts{6,1},  scts{6,2},  scts{6,3},  20, 'c', 'filled');
    rev_chevron = scatter3(axh,scts{6,1},  scts{6,2},  scts{6,3},  20, 'k', 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3,'MarkerFaceAlpha',.3);
    shorts      = scatter3(axh,scts{7,1},  scts{7,2},  scts{7,3},  20, [0.49 0.18 0.56], 'filled','MarkerEdgeAlpha',.5,'MarkerFaceAlpha',.3);
    step_down   = scatter3(axh,scts{8,1},  scts{8,2},  scts{8,3},  20, [0.333333333333333 1 0.666666666666667], 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
    step_up     = scatter3(axh,scts{9,1},  scts{9,2},  scts{9,3},  20, [1 0.666666666666667 0], 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
    two_steps   = scatter3(axh,scts{10,1}, scts{10,2}, scts{10,3}, 20, [0.47 0.67 0.19], 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
    up_fm       = scatter3(axh,scts{11,1}, scts{11,2}, scts{11,3}, 20, [0 0.666666666666667 1], 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
%     hold on, current_dot = scatter3(axh,T3D(k+offset,1),T3D(k+offset,2),T3D(k+offset,3),400, 'MarkerEdgeColor','k',...
%         'MarkerFaceColor',[1 0 .75]); hold off
    %     if k==1
    grid(axh, 'on');set(gca, 'Projection','perspective'),
%     legend(axh, [chevron, complex, down_fm, flat, mult_steps, noise_dist, rev_chevron, shorts, step_down, step_up, two_steps, up_fm], {'chevron','complex','down_fm','flat','mult_steps','noise_dist','rev_chevron','short','step_down','step_up','two_steps','up_fm'}, 'interpreter', 'none', 'FontSize', 15);
    legend(axh, [chevron, complex, down_fm, flat, mult_steps, rev_chevron, shorts, step_down, step_up, two_steps, up_fm], {'chevron','complex','down_fm','flat','mult_steps','rev_chevron','short','step_down','step_up','two_steps','up_fm'}, 'interpreter', 'none', 'FontSize', 15);
    
    %     end
    k=k+1;
    end
    axis(axh,'equal'); view(axh, -50+0.5*int, 10);
%     imagesc(h,im), %drawnow, pause(0.2)
%     hold on, current_dot = scatter3(axh,T3D(k,1),T3D(k,2),T3D(k,3),400, 'MarkerEdgeColor','k',...
%         'MarkerFaceColor',[1 0 .75]); hold off
    F(int) = getframe(gcf) ;
%     if mod(int,10)==1
%     delete(current_dot)
%     end
%     if mod(int,10)==1
%     cla(axh)
%     cla(h)
%     set(h,'xtick',[])
%     set(h,'xticklabel',[])
%     set(h,'ytick',[])
%     set(h,'yticklabel',[])
%     end
    int=int+1;
end

cd(workingfolder1)
writerObj = VideoWriter('B6_control_scaled_2.avi');
writerObj.FrameRate = 15;
open(writerObj);
% write the frames to the video
for i=1:length(F)
    % convert the image to a frame
    frame = F(i) ;
    writeVideo(writerObj, frame);
end
% close the writer object
close(writerObj);