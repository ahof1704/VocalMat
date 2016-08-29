function motr()

% set up the path to find all the motr code
fnSetupFolders();

% Check that compilation has been done, do it if not
% Use parsejpg8 as the canary in the coalmine
if ~isParsejpg8MexFilePresent()
  compileMexFunctions();
end

% If linux, check for the cluster executable, build it if absent
if islinux() && ~isClusterExecutablePresent()
  buildClusterExecutable();
end

% Launch the GUI
MouseHouse();

end
