count = 0;
% for letter = 'B':'F'
%     for number = 1:8
%         count = count + 1;
%         filename = sprintf('Test_%s%s_1_voc_list.mat',letter,num2str(number));
%         Experiment_list{count,1} = filename;
%     end
% end

for letter = 'B':'N'
%     for number = 1:8
        count = count + 1;
        filename = sprintf('Test_%s_1_voc_list.mat',letter);
        Experiment_list{count,1} = filename;
%     end
end