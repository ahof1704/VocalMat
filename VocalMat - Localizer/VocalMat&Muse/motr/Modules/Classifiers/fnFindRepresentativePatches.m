function a3iRepresentativePatch= ...
  fnFindRepresentativePatches(acPatches, ...
                              acA, ...
                              acB)

% For each mouse, find the patch image where the corresponding ellipse is
% as close to the median size as exists.
%
% Inputs:
%   acPatches: A 1 x iNumMice cell array, where each element is 
%              a 3-D array with each page a patch, and iNumFrames pages.
%              Also, each element is a uint8 array.
%   acA: A 1 x iNumMice cell array, where each element is 
%        a vector with iNumFrames elements, giving the semi-major axis 
%        of the ellipse for each frame.
%   acB: A 1 x iNumMice cell array, where each element is 
%        a vector with iNumFrames elements, giving the semi-minor axis 
%        of the ellipse for each frame.
%
% Output:
%   a3iRepresentativePatch: a 3-D uint8 array with iNumMice pages.  Each
%                           page is the representative patch for that
%                           mouse.

iNumMice=length(acPatches);
for i=1:iNumMice
  % Get the data for this mouse
  afA=acA{i};
  afB=acB{i};
  a3iPatches=acPatches{i};  % uint8
  % On the first iter, prealloc the return var
  if i==1
    [iH,iW,iNumFrames]=size(a3iPatches);  %#ok
    a3iRepresentativePatch=zeros(iH,iW,iNumMice,'uint8');
  end    
  % Find the representative ellipse
  [dummy,iIndexRep]=min(abs(afA-median(afA))+abs(afB-median(afB)));  %#ok
  % Get the patch for it.
  a3iRepresentativePatch(:,:,i) = a3iPatches(:,:,iIndexRep);
  % Log it up.
  fnLog(['A good representative of mouse ' num2str(i) ...
         ' (size closest to median), is exemplar ' ...
         num2str(iIndexRep)], ...
        1, ...
        double(a3iRepresentativePatch(:,:,i))/255);
end

end
