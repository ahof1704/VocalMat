function F=chi2scaledcdf(x,dof,a)

% calculates the cdf of an RV X defined by
% 
%   X=a/dof*Z, where Z is chi2 with dof degrees-of-freedom

z=x*(dof/a);
F=chi2cdf(z,dof);

end
