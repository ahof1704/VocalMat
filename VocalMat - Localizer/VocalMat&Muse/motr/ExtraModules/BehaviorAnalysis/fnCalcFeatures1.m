function F=fnCalcFeatures1(strctAllPos, aTimeScales)
%
T = max(aTimeScales);
iNumMice = length(strctAllPos);
iNumFrames = length(strctAllPos(1).Cx) - T;
a = zeros(1, iNumFrames);
F = zeros(iNumMice, iNumFrames);
i = 1;
PI = 2*asin(1);
for j=1:iNumMice
    for k=1:length(aTimeScales)
        t1 = T - aTimeScales(k) + 1;
        t2 = aTimeScales(k);
        a= strctAllPos(j).a(T+1:end) - strctAllPos(j).a(t1:end-t2);
        a = mod(a,2*PI);
        a(a>PI) = abs(a(a>PI) - 2*PI);
        F(i:i+1,:) = [sqrt((strctAllPos(j).Cx(T+1:end)-strctAllPos(j).Cx(t1:end-t2)).^2 + ...
                               (strctAllPos(j).Cy(T+1:end)-strctAllPos(j).Cy(t1:end-t2)).^2);
            a];
        i = i+2;
    end
end
