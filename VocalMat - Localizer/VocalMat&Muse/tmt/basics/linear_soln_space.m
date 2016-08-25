function [x0,Basis]=f(A,b)

% returns a vector and matrix that can be used to scan the solution space
% of A*x=b.  If A is mxn, b is mx1, with m<n, then x0 is nx1, and Basis is
% nx(n-m), and x=x0+Basis*lambda is a soln of A*X=b, for any lambda.  (lambda
% should thus be (n-m)x1.)

m=size(A,1);
[U,S,V]=svd(A);
S_plus=pinv(S);
A_plus=V*S_plus*U';
x0=A_plus*b;
Basis=V(:,m+1:end);
