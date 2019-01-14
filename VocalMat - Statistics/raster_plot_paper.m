clear all
list = dir('output_*.mat');



for j=1:size(list,1)
    name = list(j).name;
    clear time_vocal time_list
    load(name,'time_vocal');
    
    names{j} = name(8:end-13);
    load(['vocal_classified_' name(8:end-4) '.mat'])
    
    for k=1:size(time_vocal,2)
        if isempty(vocal_classified{k}.noise_dist) 
            time_list(k) = time_vocal{k}(1);
        end
    end
    
    total{j}= time_list;
    save(['time_vocal_' names{j} '.mat'],'time_vocal');
end

figure, plotSpikeRaster(total,'PlotType','vertline');
set(gca,'TickLabelInterpreter','none','YTick',[1:size(list,1)], 'YTickLabel',names','YColor','black');

xlabel('Time(s)')
title('Agrp-Vgat animals')