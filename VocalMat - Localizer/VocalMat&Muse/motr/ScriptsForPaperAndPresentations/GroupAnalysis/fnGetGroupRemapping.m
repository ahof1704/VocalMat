function aiRemapInd = fnGetGroupRemapping(iMale1,iMale2,iFemale1,iFemale2)
% This function will find the remapping of an experiment to the original
% group formulation
% i.e.,
% if your experiment had F1=1,F2=2,M1=3,M2=4, then you will get the
% identity map, but if F1=2,F2=1,M1=3,M2=4, you will get a different
% remapping to the correct groups.
% this will preserve the order of gender when presenting data...


acOriginal = fnBuildGroups(1,2,3,4);
acNewGroup= fnBuildGroups(iFemale1,iFemale2,iMale1,iMale2); %[1,2],[3,4] (3->2)

% Convert to binary representaiton. 
% Max four groups.
clear a3bGroupOrig a3bGroupNew
for k=1:15
   iNumSubGroups = length(acOriginal{k});
   for j=1:iNumSubGroups
       a3bGroupOrig(k,j, acOriginal{k}{j}) = true;
       a3bGroupNew(k,j, acNewGroup{k}{j}) = true;
   end
end


aiRemapInd = zeros(1,15);
a2iPerms = perms(1:4);
for k=1:15
 a2bTarget = squeeze(a3bGroupNew(k,:,:));
 % Find a similar matrix (up to row switching....)
 
 for j=1:15
     % if one of the permutation works, we are done!
     bMatch = false;
     a2bSource = squeeze(a3bGroupOrig(j,:,:));
     for p=1:size(a2iPerms,1)
         if all(all(a2bTarget(a2iPerms(p,:),:) == a2bSource))
             bMatch = true;
         end
     end
     if bMatch
         aiRemapInd(k) = j;
         break;
     end
 end
 
end

