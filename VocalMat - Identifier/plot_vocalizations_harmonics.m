% Aug 31, 2016: The harmonics detection is working pretty fine, but the
% scatter plot is too slow (plotting point by point)... Try some alternatives to make it faster.

clc
clear all
raiz = pwd;
[vfilename,vpathname] = uigetfile({'*.mat'},'Select the output file');
cd(vpathname);
list = dir('*output*.mat');

vfilename = vfilename(1:end-4);
vfile = fullfile(vpathname,vfilename);

disp(['Reading ' vfilename])
load(vfile);

dx = 0.4;

figure('Name',vfilename,'NumberTitle','off')
xlabel('Time (s)'); ylabel('Freq (Hz)')
% colorbar
% close all
cd(raiz)
hold on

disp('Showing segmented points')
tic
for k=1:size(time_vocal,2)
   c = [rand() rand() rand()]; %randi([0 256],1,1)
%    c = randn(size(time_vocal{k},2),1);
   for time_stamp = 1:size(time_vocal{k},2)
        scatter(time_vocal{k}(time_stamp)*ones(size(freq_vocal{k}{time_stamp}')),freq_vocal{k}{time_stamp}',[],repmat(c,size(freq_vocal{k}{time_stamp}',2),1)) 
   end
end
disp(['Time to plot all the vocalizations: ' num2str(toc)]);

% hold off
view(2)

tic
disp('Plotting names on spectrogram and organizing table')
for i=1:size(time_vocal,2)
   text(time_vocal{i}(round(end/2)),freq_vocal{i}{round(end/2)}(round(end/2))+5000,[num2str(i)],'HorizontalAlignment','left','FontSize',20,'Color','r');
%     output = [output; i, size(time_vocal{i},2) , min(time_vocal{i}), max(time_vocal{i}), (max(time_vocal{i})-min(time_vocal{i})) , max(freq_vocal{i}), mean(freq_vocal{i}),(max(freq_vocal{i})-min(freq_vocal{i})) , min(freq_vocal{i}), min(intens_vocal{i}), max(intens_vocal{i}), mean(intens_vocal{i})];
end
disp(['Time to plot text: ' num2str(toc)]);

tic
set(gca,'xlim',[0 dx]);
set(gca,'ylim',[0 max(F_orig)]);
disp(['Time to set axes limits: ' num2str(toc)]);
% Generate constants for use in uicontrol initialization
tic
pos=get(gca,'position');
disp(['Time to get postion: ' num2str(toc)]);

yourcell = 1:size(time_vocal,2);
tic
hb = uicontrol('Style', 'listbox','Position',[pos(1)+10 pos(2)+100 100 pos(4)+700],...
     'string',yourcell,'Callback',... 
     ['if get(hb, ''Value'')>0 ',...
     ' tic; ',...
     ' Stri=[''set(gca,''''xlim'''',[-dx/2 dx/2]+['' num2str(time_vocal{get(hb, ''Value'')}(1)) '' '' num2str(time_vocal{get(hb, ''Value'')}(1)) ''])'']; ',...
     ' eval(Stri); ', ...
     ' disp([''Time to update position: '' num2str(toc)]); ',...
     'end']);
 disp(['Time to update position: ' num2str(toc)]);
 %      ' update_slide(get(hb, ''Value''), time_vocal,xmax, maxF), ',...

% This avoids flickering when updating the axis
% set(gca,'xlim',[0 dx]);
% set(gca,'ylim',[0 max(F)]);
% Generate constants for use in uicontrol initialization
% pos=get(gca,'position');
Newpos=[pos(1) pos(2)-0.1 pos(3) 0.05];
xmax=max(T_orig);
Stri=['set(gca,''xlim'',get(gcbo,''value'')+[0 ' num2str(dx) '])'];
h=uicontrol('style','slider',...
    'units','normalized','position',Newpos,...
    'callback',Stri,'min',0,'max',xmax-dx,'SliderStep',[0.0001 0.010]);
% set(gcf,'Renderer','OpenGL')

% close all
% save(['output_' vfilename])
warning('off', 'MATLAB:save:sizeTooBigForMATFile')
disp('Cleaning variables: y y1 S F T P fs q nd vocal id' ) 
clear y y1 S F T P fs q nd vocal id
toc 
