function strctConfig = fnLoadConfigXML(strConfigurationFile)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology. 
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

strctTmp = fnXMLToStruct(strConfigurationFile);
strctConfig.m_acstrVideoFiles = {};

for iIter=1:length(strctTmp)
    strctSub = strctTmp(iIter);
    if strcmpi(strctSub.Name,'Config')
        strctSub = strctSub.Children;
        for iChildren = 1:length(strctSub)
            if strcmpi(strctSub(iChildren).Name,'VideoList')
                for iChildIter=1:length(strctSub(iChildren).Children)
                    if strcmpi(strctSub(iChildren).Children(iChildIter).Name,'Video')
                        strctConfig.m_acstrVideoFiles{end+1} = strctSub(iChildren).Children(iChildIter).Attributes.Value;
                    end;
                end;
            end;
            
            if strcmpi(strctSub(iChildren).Name,'Directories') || ...
                    strcmpi(strctSub(iChildren).Name,'Configuration') 
                for iAttribute = 1:length(strctSub(iChildren).Attributes)
                    strFieldName = ['m_str',strctSub(iChildren).Attributes(iAttribute).Name];
                    strValue = strctSub(iChildren).Attributes(iAttribute).Value;
                    strCmd = ['strctConfig.',strFieldName,' = ''',strValue,''';'];
                    eval(strCmd);
                end;
            end;
            
        end;
    end;
end;

if isempty(strctConfig.m_acstrVideoFiles)
    strctConfig.m_acstrctVideoFiles = cell(0);
end;

j=1;
for k=1:length(strctConfig.m_acstrVideoFiles)
    
    if exist(strctConfig.m_acstrVideoFiles{k},'file')
        strctConfig.m_acstrctVideoFiles{j} = ...
            fnReadVideoInfo(strctConfig.m_acstrVideoFiles{k});
        j=j+1;
    end;
end;

return;
