function astrct = fnAddFieldToStructArray(astrct0, strField, val)
%
astrct = cell(size(astrct0));
for i=1:length(astrct0)
    if ~isempty(astrct0{i})
        astrct{i}(1) = setfield(astrct0{i}(1), strField, val);
    end
end
for i=1:length(astrct0)
    for j=1:length(astrct0{i})
        astrct{i}(j) = setfield(astrct0{i}(j), strField, val);
    end
end
