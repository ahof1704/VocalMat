function fnCompile()
% % Compile MEX files, and build cluster executable on Linux

compileMexFunctions();

% Build the executable to use on the cluster, if Linux
if islinux()
  buildClusterExecutable();
end

end
