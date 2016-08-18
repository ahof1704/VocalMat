function [strctConfig] = fnLoadAlgorithmsConfigXML(strConfigurationFile)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

tree = xmltree(strConfigurationFile);
iNumModules = 0;
iNumElectrodes = 0;
iElectrodesRoot = 0;
for k=1:length(tree)
    strctRoot=get(tree,k);
    if strcmpi(strctRoot.type,'element')
        if strcmpi(strctRoot.name,'Module')
            iNumModules = iNumModules + 1;
            
            iModuleNameIndex = -1;
            for iIter=1:length(strctRoot.attributes)
                if strcmp(strctRoot.attributes{iIter}.key,'Name')
                    iModuleNameIndex = iIter;
                end
                
            end
            
            strHostVar = ['strctConfig.m_strct', strctRoot.attributes{iModuleNameIndex}.val];
            strctRoot.name = '';
            
            for iIter=1:length(strctRoot.attributes)
                if strcmp(strctRoot.attributes{iIter}.key,'Name')
                    continue;
                end
                
                val = strctRoot.attributes{iIter}.val;
                afval = fnMyStringToDouble(val);
                bNumeric = ~isempty(afval);
                if bNumeric
                    if length(afval) > 1
                        strCmd = [strHostVar,strctRoot.name,'.m_af',strctRoot.attributes{iIter}.key,' = [',val,']; '];
                    else
                        strCmd = [strHostVar,strctRoot.name,'.m_f',strctRoot.attributes{iIter}.key,' = ',val,'; '];
                    end;
                else
                    strCmd = [strHostVar,strctRoot.name,'.m_str',strctRoot.attributes{iIter}.key,' = ''',val,'''; '];
                end;
                eval(strCmd);
            end;
            
        end;
    end;
end

return;



function Result = fnMyStringToDouble(str)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
%

% Converts a potential numeric string to a number (or array)
aiSep = find(str == ' ');
if isempty(aiSep)
    Tmp = str2double(str);
    if ~isnan(Tmp)
        Result = Tmp;
    else
        Result = [];
    end
    return;
end

% Need to split and handle each one:
aiParts = [0, aiSep, length(str)+1];
for k=1:length(aiParts)-1
    strPartial = str(aiParts(k)+1:aiParts(k+1)-1);
    Tmp = str2double(strPartial);
    if ~isnan(Tmp)
        Result(k) = Tmp;
    else
        Result = [];
        return;
    end
end
