function pdf_x=chi2scaledpdf(x,dof,a)

% calculates the pdf of an RV X defined by
% 
%   X=a/dof*Z, where Z is chi2 with dof degrees-of-freedom

z=x*(dof/a);
pdf_z=chi2pdf(z,dof);
pdf_x=(dof/a)*pdf_z;

end
