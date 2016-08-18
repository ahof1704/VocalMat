function [M,iArrayUpper,jArrayUpper]=mixing_matrix_from_n_mics(n_mics)

% Returns a n_pairs x n_mic array, where each row corresponds to a pair of
% mics.  If the pair is (i,j), with i<j, then M(i_pair,i)==+1, and
% M(i_pair,j)==-1, and the rest of the row is zeros.
%
% E.g. for n_mics==4, this should return
%
% M=[ 1 -1  0  0 ; ...
%     1  0 -1  0 ; ... 
%     1  0  0 -1 ; ...
%     0  1 -1  0 ; ...
%     0  1  0 -1 ; ...
%     0  0  1 -1 ];

iMatrix=repmat((1:n_mics)',[1 n_mics]);  % row of each element
jMatrix=repmat((1:n_mics) ,[n_mics 1]);  % col of each element

iArray=reshape(iMatrix',[n_mics^2 1]);  % the above matrices as arrays, with things taken in row-major order
jArray=reshape(jMatrix',[n_mics^2 1]);

iLessThanJ=(iArray<jArray);  % true iff i<j, i.e. part of the upper triangle

iArrayUpper=iArray(iLessThanJ);  % row index of each upper-triangular element
jArrayUpper=jArray(iLessThanJ);  % col index of each upper-triangular element

n_pairs=length(iArrayUpper);
M=zeros(n_pairs,n_mics);
for i_pair=1:n_pairs
  iThis=iArrayUpper(i_pair);
  jThis=jArrayUpper(i_pair);
  M(i_pair,iThis)=+1;
  M(i_pair,jThis)=-1;
end

end
