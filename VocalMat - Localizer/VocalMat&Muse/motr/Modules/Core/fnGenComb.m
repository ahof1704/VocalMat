function Out=fnGenComb(N,M)
% Returns an (N^M) x N matrix.  Each row is a different combination of the
% numbers 1...M, and all possible combinations are enumerated in the rows.
% Another way of saying this is that each row contains a different N-digit
% number in base M, with each element a digit, and all the N-digit numbers 
% in base M are enumerated.  (But note that each digit is one of 1...M, not
% 0...(M-1).)  These "numbers" are in increasing order, with the first 
% column containing the most-significant digits, and the last column
% contains the least-significant digits.  I.e. the digits are in big-endian
% order.  

if N<=0
    Out=zeros(0,0);
elseif N==1
    Out=(1:M)';
else
    Temp=fnGenComb(N-1,M);
    nRowsTemp=size(Temp,1);
    Out=zeros(0,0);
    for m=1:M
        ThisBlock=[repmat(m,[nRowsTemp 1]) Temp];
        Out=[Out;ThisBlock];
    end
end

end

%Out=fnGenCombAux(N,M,zeros(1,N),1,[]);
