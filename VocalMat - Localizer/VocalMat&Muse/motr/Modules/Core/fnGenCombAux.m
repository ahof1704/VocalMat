function Out=fnGenCombAux(N,M,aiCurrComb,iIndex,Out)
% Generates all vector of length N, with domain 1..M (N^M) using
% backtracking
% Use:
% Out=fnGenCombAux(N,M,zeros(1,N),1,[])

%iNumComb = N^M;
%a2fComb = zeros(iNumComb, N);
%aiCurrComb = zeros(1,N);
if iIndex > N
    Out(end+1,:)=aiCurrComb;
    return;
end;

for k=1:M
    aiCurrComb(iIndex) = k;
    Out=fnGenCombAux(N,M, aiCurrComb, iIndex+1,Out);
end;
return;