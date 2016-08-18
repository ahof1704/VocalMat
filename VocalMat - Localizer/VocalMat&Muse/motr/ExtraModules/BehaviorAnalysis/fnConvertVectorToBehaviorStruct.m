function astrctBehaviors= fnConvertVectorToBehaviorStruct(abBehavior, aiOtherMouse, sBehaviorType, iMouse, bIncludeNeg, iMinLength,  iStartFrame)
 %
 if nargin < 7
     iStartFrame = 1;
 end
 if nargin < 6
     iMinLength = 1;
 end
  if nargin < 5
     bIncludeNeg = false;
  end
  iOtherSize = length(aiOtherMouse);
 abBehavior([1 end]) = 0;
 y = abBehavior > 0;
 astrctBehaviors = [];
 for iter=1:(1+bIncludeNeg)
     s = find(y & ~[false y(1:end-1)]);
     e = find(y & ~[y(2:end) false]);
     if any(s) && any(e)
         bLong = e - s >= iMinLength;
         if any(bLong)
             s = s(bLong);
             e = e(bLong);
             bDetached = s(2:end) - e(1:end-1) > iMinLength;
             if any(bDetached)
                 s = s([true bDetached]);
                 e = e([bDetached true]);
                 for ind=1:length(s)
                     strctBehavior.m_iMouse = iMouse;
                     strctBehavior.m_iStart = s(ind) + iStartFrame-1;
                     strctBehavior.m_iEnd = e(ind) + iStartFrame-1;
                     strctBehavior.m_strAction = sBehaviorType;
                     strctBehavior.m_iOtherMouse = aiOtherMouse(min(s(ind), iOtherSize));
                     strctBehavior.m_fScore = sum(max(abBehavior(s(ind):e(ind)), 0));
                     astrctBehaviors = [astrctBehaviors strctBehavior];
                 end
             end
         end
     end
     y = abBehavior < 0;
     sBehaviorType =  ['-' sBehaviorType];
 end
