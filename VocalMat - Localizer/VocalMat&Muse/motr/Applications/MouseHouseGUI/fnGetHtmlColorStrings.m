function Chtml = fnGetHtmlColorStrings(C)
%
for i=1:size(C, 1)
   Chtml{i,1,1} = sprintf('rgb(%f,%f,%f)', 255*C(i,:));
   Chtml{i,2,1} = sprintf('rgb(%f,%f,%f)', [0 0 0]); % 255*(1-C(i,:)));
   Chtml{i,1,2} = sprintf('rgb(%f,%f,%f)', 230*C(i,:));
   Chtml{i,2,2} = sprintf('rgb(%f,%f,%f)', [0 0 0]); % 255-230*C(i,:));
end


