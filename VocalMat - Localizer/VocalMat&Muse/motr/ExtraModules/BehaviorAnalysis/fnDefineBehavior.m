function aBehaviorExamples=fnDefineBehavior(strctMovInfo, astrctTrackers, strctHeadPos, iTimeScale, iMouseNum, aBehaviorExamples)
%
% b-98, s-115 , e-101, f-102, a-97, d-100, u-117, <delete>-127
% begin, start, end, finish, approach, depart, update
% , -44, . -46
if nargin<5
    astrctBehaviorExamples = [];
end
iFrame = iTimeScale + 1;
button = 29;
btoi = [1, 3, 2];
 [aMiceInd, iChosenInd, eventInd, b, s, e, f, a, d] = resetEvent(iMouseNum);
while (1)
%     iChosenInd = find(aMiceInd>0);
%     if ~isempty(chosenInd)
%         aMarkInd = aMiceInd(chosenInd);
%     end
    showFrame(iFrame, strctMovInfo, astrctTrackers, strctHeadPos, aMiceInd, iChosenInd);
    displayTitle(iFrame, aMiceInd, size(aBehaviorExamples,2), b, s, e, f, a, d);
    [x,y,button] = ginput(1);
    if isempty(button)
        break;
    end
    if any(button==btoi(1:iMouseNum))
        iChosenInd = btoi(button);
        aMiceInd(iChosenInd) = setMouseInd(x, y, astrctTrackers, iFrame);
        [b ,s, e, f, a, d, eventInd] = getEvent(iFrame, aMiceInd, aBehaviorExamples);
    else
        switch button
            case 28 % <-
                iFrame = max(iTimeScale+1, iFrame-1);
            case 29 % ->
                iFrame = min(strctMovInfo.m_iNumFrames, iFrame+1);
            case 44 % ,
                iFrame = max(iTimeScale+1, iFrame-10);
            case 46 % .
                iFrame = min(strctMovInfo.m_iNumFrames, iFrame+10);
            case 60 % <
                iFrame = max(iTimeScale+1, iFrame-100);
            case 62 % >
                iFrame = min(strctMovInfo.m_iNumFrames, iFrame+100);
            case 30 % up-arrow
                [iFrame, aMiceInd, iChosenInd, eventInd, b, s, e, f, a, d] =findNextEvent(iFrame, aBehaviorExamples, iMouseNum);
            case 31 % down-arrow
                 [iFrame, aMiceInd, iChosenInd, eventInd, b, s, e, f, a, d] = findPrevEvent(iFrame, aBehaviorExamples, iMouseNum);
            case 98 % b - begin
                b = iFrame; s = max(s, b); e = max(e, b); f = max(f, b);
            case 115 % s - start
                s= iFrame; b = min(b, s); e = max(e, s); f = max(f, s);
            case 101 % e - end
                e = iFrame; b = min(b, e); s = min(s, e); f = max(f, e);
            case 102 % f - finish
                f = iFrame;  b = min(b, f); s = min(s, f);  e = min(e, f);
            case 97 % a - approach
                if iChosenInd>0
                    a(iChosenInd) = 1 - a(iChosenInd);
                end
            case 100 % d - depart
                if iChosenInd>0
                    d(iChosenInd) = 1 - d(iChosenInd);
                end
            case 117 % u - update
                if all(aMiceInd > 0)
                    if b<s && s<e && e<f
                        if eventInd==0
                            aBehaviorExamples = [aBehaviorExamples [b s e f a d aMiceInd]'];
                        else
                            aBehaviorExamples(:, eventInd) = [b s e f a d aMiceInd]';
                        end
                    elseif eventInd>0
                        aBehaviorExamples(:, eventInd) = [];
                    end
                end
                aMiceInd = zeros(1, iMouseNum);
                iChosenInd = [];
            case 127 % delete
                if eventInd > 0
                    aBehaviorExamples(:, eventInd) = [];
                end
                [aMiceInd, iChosenInd, eventInd, b, s, e, f, a, d] = resetEvent(iMouseNum);
            case 110 % n - new
                [aMiceIndDummy, iChosenIndDummy, eventInd, b, s, e, f, a, d] = resetEvent(iMouseNum);
        end
    end
end
% b-98, s-115 , e-101, f-102, a-97, d-100, 

function  [aMiceInd, iChosenInd, eventInd, b, s, e, f, a, d] = resetEvent(iMouseNum)
aMiceInd = zeros(1, iMouseNum);
iChosenInd = 0;
eventInd = 0;
b = 0; s = 0; e = 0; f = 0; 
a = zeros(1, iMouseNum); 
d = zeros(1, iMouseNum);

function [iFrame, aMiceInd, iChosenInd, eventInd, b, s, e, f, a, d] =findNextEvent(iFrame, aBehaviorExamples, iMouseNum)
[aMiceInd, iChosenInd, eventInd, b, s, e, f, a, d] = resetEvent(iMouseNum);
if ~isempty(aBehaviorExamples)
    aFrames = aBehaviorExamples(2:3,:);
    i = find(aFrames > iFrame);
    if ~isempty(i)
        iPointer = 5;
        [m, j] = min(aFrames(i));
        iFrame = aFrames(i(j));
        eventInd = floor((i(j)+1)/2);
        B = aBehaviorExamples(:, eventInd);
        b = B(1); s = B(2); e = B(3); f = B(4);
        a = B(iPointer:iPointer+iMouseNum-1)'; iPointer = iPointer + iMouseNum;
        d = B(iPointer:iPointer+iMouseNum-1)'; iPointer = iPointer + iMouseNum;
        aMiceInd = B(iPointer:iPointer+iMouseNum-1)';
        iChosenInd = 0;
    end
end

function  [iFrame, aMiceInd, iChosenInd, eventInd, b, s, e, f, a, d] =findPrevEvent(iFrame, aBehaviorExamples, iMouseNum)
[aMiceInd, iChosenInd, eventInd, b, s, e, f, a, d] = resetEvent(iMouseNum);
if ~isempty(aBehaviorExamples)
    aFrames = aBehaviorExamples(2:3,:);
    i = find(aFrames < iFrame);
    if ~isempty(i)
        iPointer = 5;
        [m, j] = max(aFrames(i));
        iFrame = aFrames(i(j));
        eventInd = floor((i(j)+1)/2);
        B = aBehaviorExamples(:, eventInd);
        b = B(1); s = B(2); e = B(3); f = B(4);
        a = B(iPointer:iPointer+iMouseNum-1)'; iPointer = iPointer + iMouseNum;
        d = B(iPointer:iPointer+iMouseNum-1)'; iPointer = iPointer + iMouseNum;
        aMiceInd = B(iPointer:iPointer+iMouseNum-1)';
        iChosenInd = 0;
   end
end

function mouseInd=setMouseInd(x, y, astrctTrackers, iFrame)
X =  reshape([astrctTrackers.m_afX], [], length(astrctTrackers));
Y =  reshape([astrctTrackers.m_afY], [], length(astrctTrackers));
[d, mouseInd] = min( (x-X(iFrame,:)).^2 + (y-Y(iFrame,:)).^2 );

function [b ,s, e, f, a, d, eventInd] = getEvent(iFrame, aMiceInd, aBehaviorExamples)
iMouseNum = length(aMiceInd);
b = iFrame;
s = iFrame+1;
e = iFrame+2;
f = iFrame+3;
a = zeros(1, iMouseNum); 
d = zeros(1, iMouseNum);
eventInd = 0;
iMiceIndPointer = 5+2*iMouseNum;
if isempty(aBehaviorExamples)
    return
end
i = find(aBehaviorExamples(iMiceIndPointer,:) == aMiceInd(1));
if isempty(i)
    return
end
if length(aMiceInd)>1
    j = find(aBehaviorExamples(iMiceIndPointer+1,i) == aMiceInd(2));
    if isempty(j)
        return
    end
   i = i(j);
    if length(aMiceInd)>2
        j = find(aBehaviorExamples(iMiceIndPointer+2,i) == aMiceInd(3));
        if isempty(j)
            return
        end
        i = i(j);
    end
end
j = find(aBehaviorExamples(1,i) <= iFrame);
if isempty(j)
    return
end
i = i(j);
j = find(aBehaviorExamples(4,i) >= iFrame);
if isempty(j)
    return
end
if length(j) > 1
    i = i(j);
    [d, j] = min(abs(aBehaviorExamples(2,i) - iFrame));
end
eventInd = i(j);
b = aBehaviorExamples(1, eventInd);
s = aBehaviorExamples(2, eventInd);
e = aBehaviorExamples(3, eventInd);
f = aBehaviorExamples(4, eventInd);
a = aBehaviorExamples(5:4+iMouseNum, eventInd)';
d = aBehaviorExamples(5+iMouseNum:4+2*iMouseNum, eventInd)';



function displayTitle(iFrame, aMiceInd, examplesNum, b, s, e, f, a, d)
if all(aMiceInd==0)
    title(['frame ' num2str(iFrame) '  there are ' num2str(examplesNum) ' stored examples']);
    return
end
Str = ['Mice '];
for i=1:length(aMiceInd)
    str = [num2str(aMiceInd(i)) '('];
    if a(i)==1
        str = [str 'a'];
    end
    if d(i)==1
        str = [str 'd'];
    end
    Str = [Str str ') '];
end
Str = [Str ' event frames: '];
str = '';
if b>=s
    str = ['\fontsize{16}{\color{magenta}b>=s} '];
elseif s>=e
    str = ['\fontsize{16}{\color{magenta}s>=e} '];
elseif e>=f
    str = ['\fontsize{16}{\color{magenta}e>=f} '];
end    
Str = [Str str ' '];
% if ~(b<s && s<e && e<f)
%     title(['frame ' num2str(iFrame) '  inconsistant time tags order:   b: ' num2str(b) ' s: ' num2str(b) ' e: ' num2str(e) ' f: ' num2str(f)]);
% else
t = [iFrame b-0.1 s-0.1 e+0.1 f+0.1];
[T, i] = sort(t);

for j=1:5
    if T(j)==iFrame
        str = [' ' '\fontsize{16}{\color{red} ' num2str(iFrame) '} '];
    else
        str = [' '  '\fontsize{12}' num2str(round(T(j))) ' '];
    end
    Str = [Str str];
end
title(Str);
% end
