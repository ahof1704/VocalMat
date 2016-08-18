function x=fnLoadAnonymous(file_name)

% Allows loading of data from a .mat file, but without relying on
% side-effects.  Someone reading x=fnLoadAnonymous('foo.mat') knows exactly
% what variables are set after the call (x, and only x), without having to 
% run the code or look at the file foo.mat.

s=load(file_name);
fn=fieldnames(s);
if length(fn)==0  %#ok
    error('No data in file %s.',file_name);
elseif length(fn)==1
    x=getfield(s,fn{1});  %#ok
else
    error('More than one variable in file %s.',file_name);
end 

end

