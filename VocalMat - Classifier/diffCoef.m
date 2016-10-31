function [diffsCoefs]=diffCoef(Sound1,Sound2,mindur)

% find minimum number of windows
a=size(Sound1);
b=size(Sound2);
minwin=min(a(1),b(1));

if exist('mindur','var')==0
mindur=4;
end

%get correlation coefficient for entire sound
cc_Pitch=corr(Sound1(1:minwin,2),Sound2(1:minwin,2));
%cc_Entropy=corr(Sound1(1:minwin,1),Sound2(1:minwin,1));

% determine difference at each time point, then scale from -1 to 1
diffPitch=abs(Sound1(1:minwin,2)-Sound2(1:minwin,2))./85000;
diffPitch=1-(sum(diffPitch)/minwin);

%diffEnt=abs(Sound1(1:minwin,1)-Sound2(1:minwin,1))./6;
%diffEnt=1-(sum(diffEnt)/minwin);

%make matrix of Pitchs/Entropies from both Sounds
P=[Sound1(1:minwin,2) Sound2(1:minwin,2)];
%E=[Sound1(1:minwin,1) Sound2(1:minwin,1)];

% find closet matches of features to account for possible offset
%mindur = 4 (~4ms)

%initialize variables
mindiffs_P(1:minwin)=0;
%mindiffs_E(1:minwin)=0;

Pdiff(1:minwin,1)=0;
%Ediff(1:minwin,1)=0;

for i=1:minwin
    %find "data" matrix for finding min value
    if i-mindur<=0 && i+mindur<minwin; 
        dataP=P(1:i+mindur,2);
        %dataE=E(1:i+mindur,2);
    elseif i-mindur>=1 && i+mindur<=minwin
        dataP=P(i-mindur:i+mindur,2);
        %dataE=E(i-mindur:i+mindur,2);
    elseif i-mindur>=1 && i+mindur>=minwin
        dataP=P(i-mindur:minwin,2);
        %dataE=E(i-mindur:minwin,2);
    else dataP=P(:,2);
        %dataE=E(:,2);
    end
    
    bP=P(i,1);
    %bE=E(i,1);
    
    [~,IP]=min(abs(dataP-bP));
    %[~,IE]=min(abs(dataE-bE));
    
    mindiffs_P(i)=dataP(IP);
    %mindiffs_E(i)=dataE(IE);
    
    Pdiff(i,1)=abs(bP-mindiffs_P(i))/85000;
    %Ediff(i,1)=abs(bE-mindiffs_E(i))/6;
    
end

diffPitchA=1-(sum(Pdiff)/minwin);
%diffEntA=1-(sum(Ediff)/minwin);
diffsCoefs=[cc_Pitch, diffPitchA];
%diffsCoefs=[cc_Pitch,cc_Entropy, diffPitch,diffEnt,diffPitchA, diffEntA]; %'A's are adjusted (offset by mindur)