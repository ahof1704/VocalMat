function fnRel=relFromAbs(fnAbs,originDirName)

lenOrigin=length(originDirName);
fnRel=fnAbs(lenOrigin+1:end);
if strcmp(fnRel(1),filesep)
    fnRel=fnRel(2:end);
end

end
