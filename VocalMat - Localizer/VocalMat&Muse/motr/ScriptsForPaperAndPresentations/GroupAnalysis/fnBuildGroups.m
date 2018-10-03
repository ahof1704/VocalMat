function acNewGroups= fnBuildGroups(iFemale1,iFemale2,iMale1,iMale2)
acNewGroups= ...
    {{[iFemale1,iFemale2,iMale1,iMale2]},...
    {[iFemale1,iFemale2],[iMale1,iMale2]},...
    {[iFemale1,iMale1],[iFemale2,iMale2]},...
    {[iFemale1,iMale2],[iFemale2,iMale1]},...
    {[iFemale1,iFemale2,iMale1],[iMale2]},...
    {[iFemale1,iFemale2,iMale2],[iMale1]},... 
    {[iFemale1,iMale1,iMale2],[iFemale2]},...
    {[iFemale2,iMale1,iMale2],[iFemale1]},...
    {[iFemale1,iFemale2],[iMale1],[iMale2]},...
    {[iFemale1,iMale1],[iFemale2],[iMale2]},...
    {[iFemale1,iMale2],[iFemale2],[iMale1]},...
    {[iFemale2,iMale1],[iFemale1],[iMale2]},...
    {[iFemale2,iMale2],[iFemale1],[iMale1]},...
    {[iMale1,iMale2],[iFemale1],[iFemale2]},...
    {[iFemale1],[iFemale2],[iMale1],[iMale2]}};