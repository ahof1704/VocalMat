function x_pieces=f(command,x)

% command is piecewise constant,
% this function breaks the x array into pieces, each corresponding
% to one of the constant pieces of command

% command should take on only two possible values, possibly with some
% noise.  But the noise had better be small compared to the difference
% between the two possible values!

% figure out when the command steps occur
edges=find_edges(command);  % edges is +1 for rising edges, 
                            % -1 for falling edges, and 0 otherwise
edge_indices=find(edges~=0);
n_edges=length(edge_indices);
n_pieces=n_edges+1;  % command is piecewise constant, this
                     % is the number of constant pieces

% cut out the pieces of x corresponding to each constant piece of command
x_pieces=cell(n_pieces,1);  % need cell arrays because pieces
% first piece is special
x_pieces{1}=x(1:edge_indices(1)-1);
% middle pieces
for j=2:(n_pieces-1)
  % note: it is very important that the jth piece spans from
  % edge_indices(j-1) to edge_indices(j)-1, rather than some other seemingly
  % equally reasonable choice, such as from edge_indices(j-1)+1 to
  % edge_indices(j).  This is because the latter choice misses the first
  % part of the capacitance-charging current spike (if this data came from a
  % votlage-clamp experiment), thus leading to
  % underestimation of the capacitor charge, and of the capacitance
  x_pieces{j}=x(edge_indices(j-1):edge_indices(j)-1);
end
% last piece is special too
x_pieces{n_pieces}=x(edge_indices(n_pieces-1):length(x));
