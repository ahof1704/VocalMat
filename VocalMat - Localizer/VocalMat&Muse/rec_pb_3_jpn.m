function rec_pb_3_jpn
% rec_pb_3_jpn: function to record audio, sync video and playback sounds
%
% form: rec_pb_3_jpn
%
% pops up a gui, can change filename and sampling rate and can record
% manually with a button press.  
%
% based on function to calibate avisoft microphones written by JPN on
% 3/6/2001


% clear any data acquisition objects and unload data acquisition DLLs
daqreset

data_dir = uigetdir('select directory for saving data');
data_dir = [data_dir '\'];
cd (data_dir);

% defaults
number_AI_chan = 5;% 4 channels for avisoft; 1 channel for pulses from function generator for video sync; 1 channel for b&k 
recdata.fc= 450450;% sampling_rate
recdata.nfft=2^10;
recdata.chunk_s=.1; % size of fft window AND size of chunk saved to a file 
recdata.chunk=recdata.chunk_s*recdata.fc; % prolly should be related to timer period, need to consider
recdata.channel_to_watch=1; % (8)
recdata.specgram_time_width=4; % in seconds
mtx=zeros((recdata.nfft/2)+1,(recdata.specgram_time_width*recdata.fc)/recdata.chunk); 
recdata.f=[0 recdata.fc/3003];%];
recdata.t=[0 recdata.specgram_time_width];
recdata.precision='float32';
recdata.dir_prefix=data_dir;
if isdir(recdata.dir_prefix)==0
    mkdir(recdata.dir_prefix)
end
disp(['saving files to ' recdata.dir_prefix ]);
recdata.filenum=1;
recdata.fid=[];
% recdata.low_freq=27000; % filter cutoffs
recdata.low_freq=5000; % filter cutoffs
recdata.hz_per_pix=(recdata.fc/2)/((recdata.nfft/2)+1);
recdata.low_freq_pix=ceil(recdata.low_freq/recdata.hz_per_pix)
recdata.x=sin(0:.8:recdata.fc*1); 
recdata.sound_fname='default.wav';

%  initialize and hide the GUI as it is being constructed.
scrsz = get(0,'ScreenSize');
scx=ceil(scrsz(3)/100); % (1) 
scy=ceil(scrsz(4)/100);
recdata.hmain = figure('Visible','off','Position',[scx*20 scy*50 scx*50 scy*40]);

% make and plot the initial spectrogram figure
recdata.ha = axes('Units','Pixels','Position',[scx*28,scy*24,scx*20,scy*14]); 
recdata.hspecgram=image(recdata.t,recdata.f,mtx,'Parent',recdata.ha);
axis xy
xlabel('time (s)');
ylabel('frequency (kHz)');

% make the start/stop record button
recdata.hrecord = uicontrol(recdata.hmain,'style','togglebutton','BackgroundColor',[1 0 0],'String','audio record','Value',0,'Position',[scx*1 scy*2 scx*4 scy*2]);

% make the start/stop video button
recdata.hvideorecord = uicontrol(recdata.hmain,'style','togglebutton','BackgroundColor',[1 0 0],'String','video record','Value',0,'Position',[scx*6 scy*2 scx*4 scy*2]);

% create an analog input object (Dev1 is the PCI)
%function for selecting input and output devices

[analogout_val analogin_val] = select_device;
%finds devices and creates structure
output = daqhwinfo('nidaq');
%assigns analog input device based on choise
analogin_setup = output.ObjectConstructorName{analogin_val,1};
ai = eval(analogin_setup);
%assigns analog output device based on choise
analogout_setup = output.ObjectConstructorName{analogout_val,2};
ao = eval(analogout_setup);

% data will be acquired from number_AI_chan channels
addchannel(ai,0:(number_AI_chan-1)); % 
% data will be sent from analog output channel 0
addchannel(ao,0);

% create instrument object
% matlab control of frequency generator

%deviceObj = icdevice('Agilent33220_Agilent33220.mdd', 'Agilent3220A');
%vu = visa('agilent', 'USB0::0x0957::0x0407::MY44031891::0::INSTR');
vu = visa('agilent', 'USB0::0x0957::0x0407::MY44053577::0::INSTR'); % The long/complicated string is the visa address for the USB port that the function generator is plugged into. This info can be found in the Agilent Connection Expert program.
deviceObj = icdevice('agilent_33220a.mdd', vu); % 'agilent_33220a.mmd' is the driver for the function generator.
% Connect device object to hardware.
connect(deviceObj);


% sets object property values.
set(deviceObj,'Output','off');%output of function generator
set(deviceObj,'Waveform','square');%waveform type
set(deviceObj,'Frequency',29);%hertz
set(deviceObj,'Amplitude',0.85);%amplitude of square wave
set(deviceObj,'Dutycycle',20);%duty cycle (duration of pulse)
set(deviceObj,'Output','on');%output of function generator

% Initialize the analog input object (sampling rate etc)
set(ai,'InputType','Differential');
set(ai, 'SampleRate',recdata.fc);
%actual_samplerate=get(ai,'SampleRate');
set(ai, 'SamplesPerTrigger', Inf);  % how many samples per trigger (duh)
set(ai, 'TimerPeriod', recdata.chunk_s);
set(ai,'LogFileName','c:\roian\experiments\testing\mousetest00.daq');
set(ai,'LogToDiskMode','Index');
set(ai,'LoggingMode','Memory'); 
set(ai,'TimerFcn',{@plot_save,recdata.hmain,deviceObj});
set(recdata.hmain,'CloseRequestFcn',{@delete_object,ai,deviceObj});

% Initialize the analog output object (sampling rate etc) 
set(ao,'SampleRate',recdata.fc);

% make the filename input box, sampling rate box, start program box
recdata.hfname=uicontrol(recdata.hmain,'style','edit','string','Test_A','position',[scx,scy*35,scx*5,scy*2],'backgroundcolor','w','horizontalalignment','left');
set(recdata.hfname,'Callback',{@update_fname,recdata.hmain});
hfnamestat=uicontrol(recdata.hmain,'style','text','string','filename:','position',[scx,scy*37,scx*5,scy],'backgroundcolor',[.8 .8 .8],'horizontalalignment','left');
recdata.fname_prefix=[recdata.dir_prefix get(recdata.hfname,'string')]; % assign the full filename
recdata.hfc=uicontrol(recdata.hmain,'style','edit','string',num2str(recdata.fc),'position',[scx,scy*31,scx*5,scy*2],'backgroundcolor','w','horizontalalignment','left'); 
set(recdata.hfc,'Callback',{@update_fc,ai,recdata.hmain});
hfcstat=uicontrol(recdata.hmain,'style','text','string','sampling rate:','position',[scx,scy*33,scx*5,scy],'backgroundcolor',[.8 .8 .8],'horizontalalignment','left');
recdata.hchannel=uicontrol(recdata.hmain,'style','edit','string',num2str(recdata.channel_to_watch),'position',[scx,scy*27,scx*5,scy*2],'backgroundcolor','w','horizontalalignment','left'); % channel box
hcwstat=uicontrol(recdata.hmain,'style','text','string','channel:','position',[scx,scy*29,scx*5,scy],'backgroundcolor',[.8 .8 .8],'horizontalalignment','left'); % channel box label
set(recdata.hchannel,'Callback',{@update_channel,recdata.hmain});
recdata.hstart=uicontrol(recdata.hmain,'style','togglebutton','string','start session','position',[scx*44,scy,scx*5,scy*5],'backgroundcolor',[.5 .5 .5]); 

% playing buttons and boxes SINGLE files
recdata.hplay_sound = uicontrol('Style','pushbutton','String','play single sound','position',[scx*1 scy*13 scx*8 scy*2],'parent',recdata.hmain,'Callback',{@play_sound,ao,recdata.hmain});
recdata.hload_sound_txt = uicontrol('style','text','string','sound filename:','position',[scx*1 scy*17 scx*8 scy*2],'parent',recdata.hmain,'horizontalalignment','left');
recdata.hload_sound = uicontrol('style','pushbutton','string','load single sound','position',[scx*1 scy*20 scx*8 scy*2],'parent',recdata.hmain,'Callback',{@load_sound,recdata.hmain});
recdata.hsndfname=uicontrol(recdata.hmain,'style','edit','string','default.wav','position',[scx*1,scy*16,scx*8,scy*2],'backgroundcolor','w','horizontalalignment','left');
set(recdata.hsndfname,'Callback',{@update_snd_fname,recdata.hmain});

% playing buttons and boxes SERIES of files
recdata.hplay_series_sound = uicontrol('Style','pushbutton','String','play series','position',[scx*10 scy*13 scx*8 scy*2],'parent',recdata.hmain,'Callback',{@play_series_sound,ao,recdata.hmain});
recdata.hload_series_sound_txt = uicontrol('style','text','string','number of repetitions:','position',[scx*10 scy*17 scx*8 scy*2],'parent',recdata.hmain,'horizontalalignment','left'); % **** Needs to be updated to be able to change the number of reps!***
recdata.hload_series_sound_dir = uicontrol('style','pushbutton','string','select wave file directory','position',[scx*10 scy*20 scx*8 scy*2],'parent',recdata.hmain,'Callback',{@dir_series_sound,recdata.hmain});
recdata.hseries_reps=uicontrol(recdata.hmain,'style','edit','string','5','position',[scx*10,scy*16,scx*8,scy*2],'backgroundcolor','w','horizontalalignment','left','Callback',{@update_reps,recdata.hmain});
set(recdata.hsndfname,'Callback',{@update_snd_fname,recdata.hmain});

% make the gui visible
set(recdata.hmain,'Visible','on');
set(recdata.hstart,'Callback',{@run_program,ai,recdata.hmain});
guidata(recdata.hmain,recdata); 


%-------------------------------------------------------------
% function to delete the object - only called if try to close window
%-------------------------------------------------------------
function delete_object(~,~,ai,deviceObj)
set(deviceObj,'Amplitude',0.85)
deviceObj.Output = 'off';
disconnect(deviceObj);
delete(deviceObj);
delete(ai);
closereq % (6) 

%-------------------------------------------------------------
% function to run the program
%-------------------------------------------------------------
function run_program(hstart,~,ai,hmain)

recdata=guidata(hmain);
sval=get(hstart,'Value');

if sval==1  % if the run program button is pressed, run the program
    % start the object
    start(ai);
%     set(deviceObj,'Output','on');%output of function generator
    set(hstart,'string','stop session','backgroundcolor','r');
elseif sval==0 % if the run program is unpressed, stop the program
    set(ai, 'TimerPeriod', 100);  
    pause(recdata.chunk/recdata.fc) % to make sure the last getdata finishes
    stop(ai);
    set(hstart,'string','start session','backgroundcolor',[0 0 0]);
   
end;

%-------------------------------------------------------------
% function to update things that depend on the sampling rate, if the
% sampling rate changes
%-------------------------------------------------------------
function update_fc(hfc,~,ai,hmain)

recdata=guidata(hmain);
recdata.fc=str2double(get(hfc,'string'));   % update the sampling rate in the summary data structure 
set(ai, 'SampleRate',recdata.fc);           % update the hardware sampling rate
recdata.f=[0 recdata.fc/2000];              % update the frequency axis
mtx=zeros((recdata.nfft/2)+1,(recdata.specgram_time_width*recdata.fc)/recdata.chunk); % make the new blank (5)
recdata.hspecgram=image(recdata.t,recdata.f,mtx,'Parent',recdata.ha);
axis xy
xlabel('time (s)');
ylabel('frequency (kHz)')
guidata(recdata.hmain,recdata);  % save the new sampling rate and handles

%-------------------------------------------------------------
% function to update the filename
%-------------------------------------------------------------
function update_fname(~,~,hmain)

recdata=guidata(hmain);
recdata.fname_prefix=[recdata.dir_prefix get(recdata.hfname,'string')]; % assign the full filename 
guidata(recdata.hmain,recdata);  % save the new sampling rate and handles

%-------------------------------------------------------------
% function to update the saving directory
%-------------------------------------------------------------
%function update_saving_directory(~,~,hmain)

%recdata=guidata(hmain);
%recdata.fname_prefix=[recdata.dir_prefix get(recdata.save_file_dir,'string')]; % assign the full filename 
%guidata(recdata.hmain,recdata);  % save the new sampling rate and handles
%disp('switched saving directory to %s',recdata.fname_prefix)

%-------------------------------------------------------------
% function to update the channel to watch
%-------------------------------------------------------------
function update_channel(~,~,hmain)

recdata=guidata(hmain);

% update the channel to watch
recdata.channel_to_watch=str2num(get(recdata.hchannel,'string')); % get the new channel number (1-4)

if ismember(recdata.channel_to_watch,[1,2,3,4,5,6])==0  
   disp('channel to watch must be: 1, 2, 3 , 4, 5, or 6 setting to 1');
   recdata.channel_to_watch=1;
end;

% save the new value
guidata(recdata.hmain,recdata);  

%--------------------------------------------------------------------------
% function to plot the data to rolling spectrogram and record if indicated
%--------------------------------------------------------------------------
function plot_save(ai,~,hmain,deviceObj)

recdata=guidata(hmain);
x=getdata(ai,recdata.chunk); 

val=get(recdata.hrecord,'Value');

val_video = get(recdata.hvideorecord,'Value');
if val_video == 0
    set(deviceObj,'Amplitude',0.8);%amplitude of square wave
    set(recdata.hvideorecord,'backgroundcolor','r'); 
elseif val_video == 1
    set(deviceObj,'Amplitude',2.5);%amplitude of square wave
    set(recdata.hvideorecord,'backgroundcolor','g'); 
end

if isempty(recdata.fid)==0  % if the data file is open
    if val==1
        % keep writing data and timestamps to files
        count=fwrite(recdata.fid,x,recdata.precision);          % write data to disk                
        %timestamp=now;
        %fwrite(recdata.tms_fid,timestamp,'double');        
    elseif val==0                                       % record button is unpushed, stop recording
        set(deviceObj,'Output','off');%output of function generator is turned on
        fclose(recdata.fid);
        %fclose(recdata.tms_fid);
        recdata.fid=[];
        recdata.filenum=recdata.filenum+1;
        set(recdata.hrecord,'String','audio record');  
        set(recdata.hrecord,'backgroundcolor',[1 0 0]);
        
        % save metadata to mat file
        if isfield(recdata,'fname')
            tempstring=['save ' recdata.fname(1:end-4) '.inf recdata -mat'];
            eval(tempstring);
        end;        
    end;
elseif isempty(recdata.fid)==1
    if val==1                                           % record button is pushed, start recording
        set(recdata.hrecord,'backgroundcolor','g');        
                
        % open the data file
        recdata.fname=[recdata.fname_prefix '_' num2str(recdata.filenum) '.raw'];
        recdata.fid=fopen(recdata.fname,'w');
        
        % open the timestamp file
        %recdata.tmstmp_fname=([recdata.fname(1:end-4) '.tms']);
        %recdata.tms_fid=fopen(recdata.tmstmp_fname,'w');
        
        % save data
        count=fwrite(recdata.fid,x,recdata.precision);          % write data to disk  
        
        % save timestamps
        %timestamp=now;
        %fwrite(recdata.tms_fid,timestamp,'double'); 
%         set(deviceObj,'Amplitude',2.5);%amplitude of square wave
        %set(deviceObj,'Output','on');%output of function generator is turned on
    end;
end;

guidata(hmain,recdata);  % save the filenum index and the fid

% plot data to screen 
% specgram plotting
mtx=get(recdata.hspecgram,'cdata');
mtx(:,1:end-1)=mtx(:,2:end);

% calculate the fft  
y=fft(x(:,recdata.channel_to_watch),recdata.nfft);
mtx(:,end)=abs(y(1:(recdata.nfft/2)+1));

% cut out the low frequency noise
mtx(1:recdata.low_freq_pix,end)=0;

set(recdata.hspecgram,'cdata',mtx);
axis xy
set(recdata.hspecgram,'cdatamapping','scaled');
ca=gca;
% set(ca,'clim',[0 8]);
set(ca,'clim',[0.01 2]);
%toc
%daqmem


%-------------------------------------------------------------
% function to stop and delete the analog input object
%-------------------------------------------------------------
function clean_up(hmain,~,ai)

recdata=guidata(hmain);

stop(ai);
pause(10*(recdata.chunk/recdata.fc));  
delete(ai);


%-------------------------------------------------------------
% function to play a sound file
%-------------------------------------------------------------
function play_sound(~,~,ao,hmain)

recdata = guidata(hmain);

% have the sound be ramped ahead of time
dur=length(recdata.x)/recdata.fc;

putdata(ao,recdata.x)
start(ao)
pause(dur)
stop (ao)

% DATA must have a column of data for each channel in OBJ

%-------------------------------------------------------------
% function to load a sound file
%-------------------------------------------------------------
function load_sound(~,~,hmain)

recdata = guidata(hmain);

% have the sound be ramped ahead of time

% see if recdata.sound_fname exists, if not, have a default ready to go
% also, good to check if it is a wav file, be able to read a snf file...

if exist(recdata.sound_fname,'file')==2
    [recdata.x,fs]=wavread(recdata.sound_fname);
    if fs~=recdata.fc
        disp('sampling rate of sound not matched to output sampling rate!');
    end;
    
    if size(recdata.x,2)>1
        recdata.x=recdata.x';
    end;
else
    recdata.x=(sin(0:.8:recdata.fc*1))'; % this could stand to be more precise*****
end;

% set the amplitude (heh)***

guidata(hmain,recdata);  % save the sound 

%-------------------------------------------------------------
% function to update the sound filename for single load and play
%-------------------------------------------------------------
function update_snd_fname(~,~,hmain)

recdata=guidata(hmain);
recdata.sound_fname=[recdata.dir_prefix get(recdata.hsndfname,'string')]; 
guidata(recdata.hmain,recdata);  % save the new sound file name

%-------------------------------------------------------------
% function to pick directory with wave files
%-------------------------------------------------------------
function dir_series_sound(~,~,hmain)

recdata = guidata(hmain);

fn = uigetdir('select directory with wavefiles');
recdata.hload_series_sound_dir = fn;
disp(sprintf('Directory with wavefiles is %s',fn)) 
% set the amplitude (heh)***

guidata(recdata.hmain,recdata);  % save the sound 

%-------------------------------------------------------------
% function to load and play series of sound files
%-------------------------------------------------------------
function play_series_sound(~,~,ao,hmain)

recdata = guidata(hmain);
% foo = dir(recdata.hload_series_sound_dir);
foo = dir(recdata.dir_prefix);
set(recdata.hplay_series_sound,'BackgroundColor','g')

count = 0;
for amp = 1:1 %0.2 : .1 : 1 %amp range 10 % steps    
    for loop = 1:5  %number of reps...hard coded by need to change to add user input from gui
        for i = 1:1:size(foo,1)
            
            % Seems to be failing the following 'if' statement:
            if ~isempty(strfind(foo(i).name,'.wav'))
                count = count + 1;
                wavefilename = foo(i).name;
                
                [wavefile,fs]=wavread(wavefilename);
                wavefile = wavefile * amp;
                if fs~=recdata.fc
                    disp('sampling rate of sound not matched to output sampling rate!');
                end;
                
                if size(wavefile,2)>1
                    wavefile=wavefile';
                end;
                % have the sound be ramped ahead of time
                dur=length(wavefile)/recdata.fc;
                
                putdata(ao,wavefile)
                start(ao)
                pause(dur)
                stop (ao)
                pause(1) % Pauses for 1 second
                data_set_info{count,1} = wavefilename;
                data_set_info{count,2} = loop;
                data_set_info{count,3} = amp;
                
                data_set_info
                clear wavefile wavefilename fs dur
            end
        end
    end
end
save('playback_data_set_info','data_set_info')
set(recdata.hplay_series_sound,'BackgroundColor',[0.831373 0.815686 0.784314])

% DATA must have a column of data for each channel in OBJ

%-------------------------------------------------------------
% function to update the Number of Repetitions
%-------------------------------------------------------------
function update_reps(~,~,hmain)

recdata=guidata(hmain);
recdata.hseries_reps = get(recdata.hseries_reps,'string'); 
guidata(recdata.hmain,recdata);  % save the new number of repetitions


% %-------------------------------------------------------------
% % function to update the sound filename for single load and play
% %-------------------------------------------------------------
% function update_snd_fname(~,~,hmain)
% 
% recdata=guidata(hmain);
% recdata.sound_fname=[recdata.dir_prefix get(recdata.hsndfname,'string')]; 
% guidata(recdata.hmain,recdata);  % save the new sound file name


