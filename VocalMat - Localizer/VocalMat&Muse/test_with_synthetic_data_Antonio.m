%Importing the real signal
clear all
close all

n_mikes=2;
% fs=1e6;  % Hz
% dt=1/fs;  % s
% T_want=0.040;  % s
% n_t=round(T_want/dt);
%fs=450450;  % Hz
f_lo=45000;  % The lower bound of the frequency band used for analysis, in Hz.  Frequency compenents outside this band are zeroed after the data is intially FFT'ed.
f_hi=120000;  % The upper bound of the frequency band used for analysis, in Hz.	
Temp=25;  % The ambient temperature at which data was taken, in degrees celsius.
dx=250e-6;  % The fine space of the grid (0.25mm)
xl=[-0.325 +0.325]; %Lenght in meters (considering the center of the chamber as the origin)
yl=[-0.21 +0.21]; % Width in meters
radius_perturbation=0.1;  % m
%theta=unifrnd(0,2*pi);
% R1_x=+0.3; %Original
R1_x=-0.325;
%R1_y=radius_perturbation*sin(theta);
%R1_z=radius_perturbation*cos(theta);
R1_y=-0.21;
R1_z=0.23;
%theta=unifrnd(0,2*pi);
R2_x=0.325;
%R2_y=radius_perturbation*sin(theta);
%R2_z=radius_perturbation*cos(theta);
%R2_y=+0.05;
R2_y=0.21;
R2_z=0.23;
R3_y=+0.3;
%R3_x=radius_perturbation*sin(theta);
%R3_z=radius_perturbation*cos(theta);
%R3_x=0.1;
R3_x=0;
R3_z=0;
theta=unifrnd(0,2*pi);
R4_y=-0.3;
%R4_x=radius_perturbation*sin(theta);
%R4_z=radius_perturbation*cos(theta);
%R4_x=0.05;
R4_x=0;
R4_z=0;
R=[ R1_x R1_y R1_z ; ...
    R2_x R2_y R2_z]' ; ...
%     R3_x R3_y R3_z ; ...
%     R4_x R4_y R4_z ]';  % m
r_head=[0.1 0]';  % m
r_tail=[-0.1 0]';  % m
title_str='test';
verbosity=0;

[vfilename1,vpathname] = uigetfile({'*.wav'},'Select the sound track for ch1');
vfile = fullfile(vpathname,vfilename1);
[ch1,fs]=audioread([vfile]);


%import vocalization file for ch1
path = strsplit(vpathname,'\');
path = char(strcat(vpathname,path(end-2), '_', path(end-1), '_VocalMat.xls'));
table_ch1 = xlsread(path,vfilename1(1:end-4)); 
% vocal_ch1 = find(table_ch1(:,4)<T_want); %Vocalizations detected in this T_want interval
% table_ch1 = table_ch1(vocal_ch1,:);
T_want = max(table_ch1(:,3));

[vfilename,vpathname] = uigetfile({'*.wav'},'Select the sound track for ch2',vpathname);
vfile = fullfile(vpathname,vfilename);
[ch2,fs]=audioread([vfile]);

path = strsplit(vpathname,'\');
path = char(strcat(vpathname,path(end-2), '_', path(end-1), '_VocalMat.xls'));
table_ch2 = xlsread(path,vfilename(1:end-4)); 
% vocal_ch2 = find(table_ch2(:,4)<T_want);
% table_ch2 = table_ch2(vocal_ch2,:);
if max(table_ch2(:,3))>T_want
    T_want = max(table_ch2(:,3));
end

global v_single_true;
dt=1/fs;  % s
% T_want=500;  % Time in seconds that we are actually analyzing from the original signal
n_t=round(T_want/dt);


%The idea now is to use the results from the spectogram to select the
%interval where vocalization were detected. Once a vocalization was
%detected in both channels, we go back to the original .wav file and
%identify sound source for that segment.

if size(table_ch1,1)>size(table_ch2,1) %Assuming that the table with more vocalizations probably has more noise segmented as vocalizations
    number_vocalizations = size(table_ch2,1);
    ch=2;
else
    number_vocalizations = size(table_ch1,1);
    ch=1;
end

v_single_true = [ch1(1:n_t)*(-1) ch2(1:n_t)];

mkdir(vpathname,'output')

%Import XY coordinates of the files
[vfilename_xy,vpathname_xy] = uigetfile({'*.xlsx'},'Select the tracking file',vpathname);
filename_xy = vfilename_xy(1:end-5);
vfile_xy = fullfile(vpathname_xy,vfilename_xy);

[type,sheetname_xy] = xlsfinfo(vfile_xy); 
m=size(sheetname_xy,2); 

alldata_xy = cell(1, m);

%Load all sheets from the tracking file
for i=1:1:m;
Sheet = char(sheetname_xy(1,i)) ;
alldata_xy{i} = xlsread(vfile_xy, Sheet);
alldata_xy{i}(isnan(alldata_xy{i}(:,1)),:)=[]; %remove lines with NaN
end

%Correcting time in all the sheets
for h=1:size(alldata_xy,2)
    t = datestr(alldata_xy{1,h}(:,1),'HH:MM:SS.FFF');  %Transforms time from excel (which was converted to number) to this format
    t = datevec(t);  %Separates time in columns (hours, minutes, seconds, mili)
    t = t(:,5)*60+t(:,6); 
    alldata_xy{1,h}(:,1)=t;
    
    %Correcting the coordinates
    alldata_xy{1,h}(:,2) = alldata_xy{1,h}(:,2)/1000 + xl(1) ;
    alldata_xy{1,h}(:,3) = alldata_xy{1,h}(:,3)/1000 + yl(1);
end

%Where is the tracking file we want
track_file = strfind(sheetname_xy,vfilename(1:end-4),'ForceCellOutput',true);
h = find(~cellfun(@isempty,track_file));


% make some grids and stuff
x_line=(xl(1):dx:xl(2))';
y_line=(yl(1):dx:yl(2))';
n_x=length(x_line);
n_y=length(y_line);
x_grid=repmat(x_line ,[1 n_y]);
y_grid=repmat(y_line',[n_x 1]);

% everything in the case
in_cage=true(size(x_grid));

% generate the noise-free synthetic data
% no time delays, implies that the source is at the origin
% t=dt*((-n_t/2):(n_t/2-1))';
t = linspace(0,T_want,n_t);
% %slope_f=1e6;  % Hz/s
% slope_f=0.2e6;  % Hz/s
% f0_0=80000;  % Hz
% f0=f0_0+slope_f*t;
% tau=8e-3;  % s
% %tau=0.1e-3;  % s
% A=0.1;  % V
% global v_single_true;
% v_single_true=A*exp(-(t/tau).^2).*cos(2*pi*(f0.*t));
%v_single_true=A*exp(-(t/tau).^2);

% global gain;
% gain=[1 0.5 0.3 0.1]; %Original
% gain=[1 0.5];
r_true=[0.1 0]' %Original
% r_true=[0 0 0]'

% delay the signals appropriately
% rsubR=bsxfun(@minus,[r_true;0],R);  % 3 x n_mike, pos rel to each mike
% d=reshape(sqrt(sum(rsubR.^2,1)),[n_mikes 1]);  % m, n_mike x 1
% vel=velocity_sound(Temp);  % m/s
% global delay_true;
% delay_true=(1/vel)*d  % true time delays, s, n_mike x 1
% phi=phi_base(n_t);
% V_single_true=fft(v_single_true);
% V_true_delayed=zeros(n_t,n_mikes);

%apply delay to each mic. As I have my original sound sources, I dont need it
% for i=1:n_mikes
%   V_true_delayed=V_single_true.*exp(-1i*2*pi*phi*delay_true(i)/dt);
% end
% v_true_delayed=real(ifft(V_true_delayed));  

% multiple by the respective gain factors
% v_true_delayed_amped=bsxfun(@times,gain,v_true_delayed);

% colors for microphones
clr_mike=[0 0   1  ; ...
          0 0.7 0  ; ...
          1 0   0  ; ...
          0 0.8 0.8];

% % plot the true signals, without noise
% if (verbosity>=1)
%   figure('color','w');
%   for k=1:n_mikes
%     subplot(n_mikes,1,k);
%     plot(1000*t,1000*v_true_delayed_amped(:,k),'color',clr_mike(k,:));
%     if k==1
%       title('Synthetic signals, without noise');
%     end
%     ylim(ylim_tight(1000*v_true_delayed_amped(:,k)));
%     ylabel(sprintf('Mic %d (mV)',k));
%   end
%   xlabel('Time (ms)');
%   ylim_all_same();
% %   tl(1000*t(1),1000*t(end));
%   drawnow;
% end

% add noise, But I dont need it
% sigma_v=0.020;  % V
% noise=normrnd(0,sigma_v,n_t,n_mikes);
% v_clip=v_true_delayed_amped+noise;

for vocal = 1:number_vocalizations
    
if ch==1 %Match channels to find same vocalization in both tables and where the mom was
    [minimum_diff,idx] = min(abs((table_ch1(vocal,3)-table_ch2(:,3))));
    [minimum_diff_mom,idx_mom] =  min(abs((table_ch1(vocal,3)-alldata_xy{1,h}(:,1))));
    r_true = [alldata_xy{1,h}(idx_mom,2) alldata_xy{1,h}(idx_mom,3)]';
else
    [minimum_diff,idx] = min(abs((table_ch2(vocal,3)-table_ch1(:,3))));
    [minimum_diff_mom,idx_mom] =  min(abs((table_ch2(vocal,3)-alldata_xy{1,h}(:,1))));
    r_true = [alldata_xy{1,h}(idx_mom,2) alldata_xy{1,h}(idx_mom,3)]';
end

if minimum_diff<=0.005 && ch==1
    %Find where the vocalization starts and end in both channels
    if table_ch1(vocal,3)<table_ch2(idx,3)
        start_vocal = table_ch1(vocal,3);
    else
        start_vocal = table_ch2(idx,3);
    end
    
     if table_ch1(vocal,4)>table_ch2(idx,4)
         end_vocal = table_ch1(vocal,4);
     else
        end_vocal = table_ch2(idx,4);
     end
     
        [minimum_diff,idx_min] = min(abs((start_vocal-t(:,:))));
        [minimum_diff,idx_max] = min(abs((end_vocal-t(:,:))));
        v_clip = v_single_true(idx_min:idx_max,:);

        % plot the true signals, with noise
        if (verbosity>=0)
          figure('color','w');
          for k=1:n_mikes
            subplot(n_mikes,1,k);
            plot(1000*t(idx_min:idx_max),1000*v_clip(:,k),'color',clr_mike(k,:));
            if k==1
              title('Signals with noise');
            end
            ylim(ylim_tight(1000*v_clip(:,k)));
            ylabel(sprintf('Mic %d (mV)',k));
          end
          xlabel('Time (ms)');
          ylim_all_same();
          maxfig(gcf,1)
          saveas(gcf,[vpathname 'output\' vfilename1(1:end-4) '_' vfilename(1:end-4) 'Signal_ Ch= ' num2str(ch) '_Start = ' num2str(start_vocal) '.jpg']);
          output = spectogram_with_matlab_5(v_clip(:,:),fs,start_vocal);
          ylim_all_same();
        %   tl(1000*t(1),1000*t(end));
          drawnow;
        end
        maxfig(gcf,1)
        saveas(gcf,[vpathname 'output\' vfilename1(1:end-4) '_' vfilename(1:end-4) 'Spec_ Ch= ' num2str(ch) '_Start = ' num2str(start_vocal) '.jpg']);

        % estimate the mouse position with the true mic positions
        [r_est,rsrp_max,rsrp_grid,a,vel,N_filt,V_filt,V]= ...
          r_est_from_clip_simplified(v_clip,fs, ...
                                     f_lo,f_hi, ...
                                     Temp, ...
                                     x_grid,y_grid,in_cage, ...
                                     R, ...
                                     verbosity);

        % make a figure of that
        [fig_h,axes_h,axes_cb_h]= ...
          figure_objective_map(x_grid,y_grid,rsrp_grid, ...
                               'jet', ...
                               [], ...
                               ['Estimate with true mic positions: Vocal #' num2str(table_ch1(vocal,1)) ' in table_ch1'], ...
                               'RSRP (V^2)', ...
                               clr_mike, ...
                               [1 1 1], ...
                               r_est,[], ...
                               R,r_true,r_true+[-0.08 0]');
                           maxfig(gcf,1)
                           saveas(gcf,[vpathname 'output\' vfilename1(1:end-4) '_' vfilename(1:end-4) 'Position_ Ch= ' num2str(ch) '_Start = ' num2str(start_vocal) '.jpg']);
                           
elseif minimum_diff<=0.005 && ch==2
    %Find where the vocalization starts and end in both channels
    if table_ch2(vocal,3)<table_ch1(idx,3)
        start_vocal = table_ch2(vocal,3);
    else
        start_vocal = table_ch1(idx,3);
    end
    
     if table_ch2(vocal,4)>table_ch1(idx,4)
         end_vocal = table_ch2(vocal,4);
     else
        end_vocal = table_ch1(idx,4);
     end
     
        [minimum_diff,idx_min] = min(abs((start_vocal-t(:,:))));
        [minimum_diff,idx_max] = min(abs((end_vocal-t(:,:))));
        v_clip = v_single_true(idx_min:idx_max,:);

        % plot the true signals, with noise
        if (verbosity>=0)
          figure('color','w');
          for k=1:n_mikes
            subplot(n_mikes,1,k);
            plot(1000*t(idx_min:idx_max),1000*v_clip(:,k),'color',clr_mike(k,:));
            if k==1
              title('Synthetic signals, with noise');
            end
            ylim(ylim_tight(1000*v_clip(:,k)));
            ylabel(sprintf('Mic %d (mV)',k));
          end
          xlabel('Time (ms)');
          ylim_all_same();
          maxfig(gcf,1)
          saveas(gcf,[vpathname 'output\' vfilename1(1:end-4) '_' vfilename(1:end-4) '_Signal_ Ch= ' num2str(ch) '_Start = ' num2str(start_vocal) '.jpg']);
          output = spectogram_with_matlab_5(v_clip(:,:),fs,start_vocal);
          ylim_all_same();
        %   tl(1000*t(1),1000*t(end));
          drawnow;
        end
        maxfig(gcf,1)
        saveas(gcf,[vpathname 'output\' vfilename1(1:end-4) '_' vfilename(1:end-4) 'Spect_ Ch= ' num2str(ch) '_Start = ' num2str(start_vocal) '.jpg']);

        % estimate the mouse position with the true mic positions
        [r_est,rsrp_max,rsrp_grid,a,vel,N_filt,V_filt,V]= ...
          r_est_from_clip_simplified(v_clip,fs, ...
                                     f_lo,f_hi, ...
                                     Temp, ...
                                     x_grid,y_grid,in_cage, ...
                                     R, ...
                                     verbosity);

        % make a figure of that
        [fig_h,axes_h,axes_cb_h]= ...
          figure_objective_map(x_grid,y_grid,rsrp_grid, ...
                               'jet', ...
                               [], ...
                                ['Estimate with true mic positions: Vocal #' num2str(table_ch2(vocal,1)) ' in table_ch2'], ...
                               'RSRP (V^2)', ...
                               clr_mike, ...
                               [1 1 1], ...
                               r_est,[], ...
                               R,r_true,r_true+[-0.08 0]');
                           maxfig(gcf,1)
                           saveas(gcf,[vpathname 'output\' vfilename1(1:end-4) '_' vfilename(1:end-4) 'Position_ Ch= ' num2str(ch) '_Start = ' num2str(start_vocal) '.jpg']);
end 
close all
end
                     