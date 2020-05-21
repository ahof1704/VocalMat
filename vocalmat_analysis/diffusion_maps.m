% ----------------------------------------------------------------------------------------------
% -- Title       : VocalMat Analysis
% -- Project     : VocalMat - A Tool for Automated Mouse Vocalization Detection and Classification
% ----------------------------------------------------------------------------------------------
% -- File        : diffusion_maps.m
% -- Group       : Dietrich Lab - Department of Comparative Medicine @ Yale University
% -- Standard    : <MATLAB 2018a>
% ----------------------------------------------------------------------------------------------
% -- Copyright (c) 2020 Dietrich Lab - Yale University
% ----------------------------------------------------------------------------------------------

T_classProb_orig = T_classProb;
T_classProb(strcmp(T_classProb.DL_out,'noise_dist'),:)=[]; %Remove noise
T_classProb.DL_out(strcmp(T_classProb.DL_out,'chevron'))={1};
T_classProb.DL_out(strcmp(T_classProb.DL_out,'complex'))={2};
T_classProb.DL_out(strcmp(T_classProb.DL_out,'down_fm'))={3};
T_classProb.DL_out(strcmp(T_classProb.DL_out,'flat'))={4};
T_classProb.DL_out(strcmp(T_classProb.DL_out,'mult_steps'))={5};
T_classProb.DL_out(strcmp(T_classProb.DL_out,'rev_chevron'))={6};
T_classProb.DL_out(strcmp(T_classProb.DL_out,'short'))={7};
T_classProb.DL_out(strcmp(T_classProb.DL_out,'step_down'))={8};
T_classProb.DL_out(strcmp(T_classProb.DL_out,'step_up'))={9};
T_classProb.DL_out(strcmp(T_classProb.DL_out,'two_steps'))={10};
T_classProb.DL_out(strcmp(T_classProb.DL_out,'up_fm'))={11};

%remove extra columns and noise
T_classProb.AA21=[]; T_classProb.NumVocal=[];
T_classProb.DL_out = cell2mat(T_classProb.DL_out);
T_classProb = table2array(T_classProb);

data = T_classProb(:,1:end-1); label = T_classProb(:,end);
Y = squareform(pdist(data,'euclidean'));
disp(['plotting for sigma= ', num2str(sigma), '...'])
[maps,vals] = DiffMaps(data,sigma,t,m);
eval(['maps_' vfilename '= maps;'])
eval(['label_maps_' vfilename '= label;'])
save(fullfile(vfile,['maps_' vfilename '.mat']),['maps_' vfilename],['label_maps_' vfilename])
% end

%plotting the diff maps result
if plot_diff_maps==1
    T3D = maps;
    idxs = {};
    scts = {};
    for i=1:11
        %     idxs{i} = T.DL_out == i;
        idxs{i} = label(:,1)==i;
        scts{i,1} = T3D(idxs{i},1);
        scts{i,2} = T3D(idxs{i},2);
        scts{i,3} = T3D(idxs{i},3);
    end
    
    hFig = figure('units','normalized','outerposition',[0 0 1 1]);
    axh = axes('Parent', hFig);
    title('3-D Embedding, sigma: 0.5','interpreter', 'none')
    p = get(axh, 'Position');
    % h = axes('Parent', gcf, 'Position', [p(1)+0.65 p(2) 0.2 0.2]);
    
    int=1;k=1;offset=200;
    while k<20
        if mod(int,10)==1
%             k
            if exist('current_dot')
                delete(current_dot)
                clear current_dot
            end
          
            hold(axh, 'on');
            chevron     = scatter3(axh,scts{1,1},  scts{1,2},  scts{1,3},  20, 'r', 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
            complex     = scatter3(axh,scts{2,1},  scts{2,2},  scts{2,3},  20, [0.65 0.65 0.65], 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
            down_fm     = scatter3(axh,scts{3,1},  scts{3,2},  scts{3,3},  20, 'b', 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
            flat        = scatter3(axh,scts{4,1},  scts{4,2},  scts{4,3},  20, 'y', 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
            mult_steps  = scatter3(axh,scts{5,1},  scts{5,2},  scts{5,3},  20, 'm', 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
            rev_chevron = scatter3(axh,scts{6,1},  scts{6,2},  scts{6,3},  20, 'k', 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3,'MarkerFaceAlpha',.3);
            shorts      = scatter3(axh,scts{7,1},  scts{7,2},  scts{7,3},  20, [0.49 0.18 0.56], 'filled','MarkerEdgeAlpha',.5,'MarkerFaceAlpha',.3);
            step_down   = scatter3(axh,scts{8,1},  scts{8,2},  scts{8,3},  20, [0.333333333333333 1 0.666666666666667], 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
            step_up     = scatter3(axh,scts{9,1}, scts{9,2}, scts{9,3}, 20, [1 0.666666666666667 0], 'filled','MarkerEdgeAlpha',.2,'MarkerFaceAlpha',.3);
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
        F(int) = getframe(gcf) ;
        int=int+1;
    end
    
    cd(vfile)
    writerObj = VideoWriter(fullfile(vfile, [vfilename '.avi']));
    writerObj.FrameRate = 15;
    open(writerObj);
    % write the frames to the video
    for i=1:size(F,2)
        % convert the image to a frame
        frame = F(i) ;
        writeVideo(writerObj, frame);
    end
    % close the writer object
    close(writerObj);
end
% End of plotting

function [maps,vals2] = DiffMaps(xs,sigma,t,m)
Y = squareform(pdist(xs,'euclidean'));

W = NaN(size(Y),'like',Y); %Similarity matrix
for j=1:size(W,1)
    for k=1:size(W,1)
        W(j,k) = exp((-(Y(j,k).^2))/(2*(sigma^2)));
    end
end

M = NaN(size(W),'like',W); % Walk matrix M by normalizing the rows
for j=1:size(M,1)
    M(j,:) = W(j,:)/sum(W(j,:));
end
[vecs,vals] = eig(M); % Compute eigenvectors and eigenvalues
vals2 = vals(2:m+1,2:m+1).^t;
maps = (vecs(:,2:m+1))*vals2;

end