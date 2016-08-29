function [D, acRefInd, aiPairs] = fnCalcDistances(X, Y)
%
N = size(X, 1);
L = size(X, 2);
D = zeros(N*(N-1)/2, L);
k = 1;
acRefInd = cell(N,1);
aiPairs = zeros(N,2);
for i=1:N-1
   for j=i+1:N
      D(k, :) = sqrt( (X(i,:)-X(j,:)).^2 + (Y(i,:)-Y(j,:)).^2 );
      acRefInd{i} = [acRefInd{i} k];
      acRefInd{j} = [acRefInd{j} k];
      aiPairs(k,:) = [i j];
      k = k + 1;
   end
end
