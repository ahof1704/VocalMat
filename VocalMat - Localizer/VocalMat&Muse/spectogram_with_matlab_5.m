% close all
% clear all

% [vfilename,vpathname] = uigetfile({'*.wav'},'Select the sound track');
% cd(vpathname);
% list = dir('*.wav');
function [output] = spectogram_with_matlab_5(y,fs,start_vocal)
figure
for col =  1:2%size(list,1)
% vfilename = list(Name).name;
% vfilename = vfilename(1:end-4);
% vfile = fullfile(vpathname,vfilename);

clear S F T P q nd vocal id time_vocal freq_vocal intens_vocal output

% [y,fs]=audioread([vfile '.wav']);
y1 = y(:,col); % y(1:10000000,:);
nfft = 1024;
nover = (128);
window = hamming(256);
db_threshold = -115; %original
% db_threshold = -100; 
dx = 0.4;
[S,F,T,P] = spectrogram(y1, window, nover, nfft, fs, 'yaxis', 'MinThreshold',db_threshold);

%cutoff frequency
min_freq = find(F>45000);
F = F(min_freq);
S = S(min_freq,:);
P = P(min_freq,:);
T = T+start_vocal;

% T = size(y1,1)+T;
% figure
subplot(2,1,col)
surf(T,F,10*log10(P),'edgecolor','none')
axis tight; view(0,90);
% scrollplot
% colormap(hot);
% shading interp
colormap(gray);
xlabel('Time (s)'); ylabel('Freq (Hz)')
% colorbar

[q,nd] = max(10*log10(P));
vocal = find(q>-110); %original
% vocal = find(q>-95);
q = q(vocal);
T = T(vocal);
nd = nd(vocal);
F = F(nd);

hold on

% plot3(T,F(nd),q,'r','linewidth',4)
scatter3(T,F,q,'filled')
hold off
% c = colorbar;
% c.Label.String = 'dB';
view(2)
% scrollplot('WindowSizey',120000)

%Vocalization Segmentating
%If there a huge diff between a point and the next point in time domain, it
%means that one vocalization ended and another just started.

id = 0;

for k = 1:size(T,2)-1
   
    if T(k+1)-T(k)> 0.01 %If >0.002s, it is a new vocalization
        id=id+1;
        time_vocal{id} = [];
        freq_vocal{id} = [];
        intens_vocal{id} = [];
    
    else %if it is not a new vocalization
        if k==1
            id=1;
            time_vocal{id} = [];
            freq_vocal{id} = [];
            intens_vocal{id} = [];
        end
        time_vocal{id}=[time_vocal{id}, T(k)]; %Storing vector time for that vocalization
        freq_vocal{id} = [freq_vocal{id} , F(k)]; %Storing vector frequency for that vocalization
        intens_vocal{id} = [intens_vocal{id}, q(k)];
    end
end

%Remove too small vocalizations (< 5 points)
for k=1:size(time_vocal,2)
   if  size(time_vocal{k},2) < 8
       time_vocal{k}=[];
       freq_vocal{k}=[];
       intens_vocal{k}=[];
   end
end

time_vocal = time_vocal(~cellfun('isempty',time_vocal));
freq_vocal = freq_vocal(~cellfun('isempty',freq_vocal));
intens_vocal = intens_vocal(~cellfun('isempty',intens_vocal));

output = [];
%Plot names on spectrogram and organize table
for i=1:size(time_vocal,2)
    text(time_vocal{i}(round(end/2)),freq_vocal{i}(round(end/2))+5000,[num2str(i)],'HorizontalAlignment','left','FontSize',20,'Color','r');
    output = [output; i, size(time_vocal{i},2) , min(time_vocal{i}), max(time_vocal{i}), (max(time_vocal{i})-min(time_vocal{i})) , max(freq_vocal{i}), mean(freq_vocal{i}),(max(freq_vocal{i})-min(freq_vocal{i})) , min(freq_vocal{i}), min(intens_vocal{i}), max(intens_vocal{i}), mean(intens_vocal{i})];
end

end

% output = array2table(output,'VariableNames', {'ID','Num_points','Start_sec','End_sec','Duration_sec','Max_Freq_Hz','Mean_Freq_Hz','Range_Freq_Hz','Min_Freq_Hz','Min_dB','Max_dB','Mean_dB'});
% warning('off','MATLAB:xlswrite:AddSheet');

% xlswrite(vfile,output,filename)
% writetable(output,[vpathname '_VocalMat'],'FileType','spreadsheet','Sheet',vfilename)
% vfilename
% size(time_vocal,2)
% size(output,1)
% X = [vfilename,' has ',num2str(size(output,1)),' vocalizations.'];
% disp(X)
% This avoids flickering when updating the axis
% set(gca,'xlim',[0 dx]);
% set(gca,'ylim',[0 max(F)]);
% % Generate constants for use in uicontrol initialization
% pos=get(gca,'position');
% Newpos=[pos(1) pos(2)-0.1 pos(3) 0.05];
% xmax=max(T);
% Stri=['set(gca,''xlim'',get(gcbo,''value'')+[0 ' num2str(dx) '])'];
% h=uicontrol('style','slider',...
%     'units','normalized','position',Newpos,...
%     'callback',Stri,'min',0,'max',xmax-dx,'SliderStep',[0.0001 0.010]);

% close all


% end
