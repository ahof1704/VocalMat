function [F,J]=FJ_lateration(r,R,dd_true)

% Calculates the error vector and Jacobian.
% r contains the current guess (2x1)
% R is a matrix with the mic sites in the cols
% dd_true is the n x 1 vector of distance differences, n the number of mics

n=size(R,2);  % number of mics
rsubR=repmat(r,[1 n])-R;  % 2 x n
d=sqrt(sum(rsubR.^2,1))';  % n x 1
dd=d-mean(d);  % n x 1
F=dd-dd_true;  % n x 1

J=rsubR'./repmat(d,[1 2]);

end
