function [t,data,units_chan_this] = ...
  load_abf_channel_by_name(file_name,name_chan_this,zero_t)

% Loads a specific named channel from an ABF file.
% [t,data,chan_units,h] = load_abf(file_name,chan_name) loads
%   the .abf file  given by file_name.
% The timebase (t) is in s, and is a col vector (n_samples x 1).  
% data is n_samples x n_episodes
% chan_units is a string holding the channel units
%
% [t,data,chan_units,h] = load_abf(filename,chan_name,zero_t), 
%   if zero_t is true, shifts the timebase so that it begins at 
%   time zero.
%
% This is based on some code I found on the Matlab File Exchange.

% zero says whether or not t(1) should equal 0
if nargin<3 || isempty(zero_t)
  zero_t=false;
end

% open the file
fid = fopen(file_name,'r','ieee-le');  % Open the file.
if fid==-1  % If fopen returns a -1, we did not open the file successfully.
  error(sprintf('File %s has not been found or permission denied',file_name));
  return;
end % if

% load the header into a record
h=get_abf_header(fid);

% check that data was acquired in gap-free mode
if h.nOperationMode~=3 && h.nOperationMode~=5
  fclose(fid); 
  error('Right now, only works on gap-free or episodic data');
end

% check that file is a recent version
if h.fHeaderVersionNumber < 1.6
  warning(['ABF file is earlier than version 1.6 (the file is version ' ...
           '%0.1f) --- this may not work ' ...
           'correctly'],h.fHeaderVersionNumber);
end 

% get dimensions, check that they're consistent
n_channels=h.nADCNumChannels;
n_samples=h.lActualAcqLength;
% this next if statement makes me uncomfortable.  Isn't there a more
% general way to do this?
if h.nOperationMode==3
  % gap-free
  n_episodes=h.lEpisodesPerRun;
elseif h.nOperationMode==5
  % episodic
  n_episodes=h.lActualEpisodes;  
else
  fclose(fid); 
  error('Right now, only works on gap-free or episodic data');
end
if n_episodes==0
  n_episodes=1;  % patch for ATF->ABF files
end
n_times=fix(n_samples/n_episodes/n_channels);
if n_times*n_channels*n_episodes ~= n_samples
  fclose(fid); 
  error('Number of samples not an integral multiple of the number of channels');
end

% get which channels were actually sampled, and the order
i_adc_from_i_data_raw=h.nADCSamplingSeq;  
  % 16x1, the first n_channel elements give the index into the 16 channel 
  % names for each of the n_channels data traces, the rest are -1.  Note 
  % that these indexes go from 0 to 15
i_adc_from_i_data=i_adc_from_i_data_raw(1:n_channels)+1;
  % at this point i_adc_from_i_data(i_data) gives you the channel index in
  % the ADC order given i_data, the channel index in the data order

% get the channel names, convert to cell array
name_chan_from_i_adc_raw=h.sADCChannelName;  % 16x10 char
name_chan_from_i_adc=cell(16,1);
for i_adc=1:16
  name_chan_from_i_adc{i_adc,1}=deblank(name_chan_from_i_adc_raw(i_adc,:));
end

% now remap in terms of i_data
name_chan_from_i_data=cell(n_channels,1);
for i_data=1:n_channels
  name_chan_from_i_data{i_data,1}=...
    name_chan_from_i_adc{i_adc_from_i_data(i_data)};
end

% what's the i_data of the channel we want
i_data_this=find(strcmp(name_chan_this,name_chan_from_i_data))
if isempty(i_data_this)
  fclose(fid);
  error('no channel named %s in file %s',name_chan_this,file_name);
end

% Data representation. 0 = 2-byte integer; 1 = IEEE 4 byte float.
if h.nDataFormat == 0
  n_byte_per=2;
  type_string='short'; 
else 
  n_byte_per=4;
  type_string='float'; 
end

% skip to where the first element of this channel is
fseek(fid,512*h.lDataSectionPtr+n_byte_per*(i_data_this-1),'bof');

% read the data
data=zeros(n_times,n_episodes);
count=0;
for i=1:n_episodes
  [data_temp,count_this]=...
    fread(fid,[n_times 1],type_string,(n_channels-1)*n_byte_per);
  data(:,i)=data_temp;
  count=count+count_this;
end

% check that we read as many data as the header said there were
if count ~= n_times
  fclose(fid); 
  error(['Number of samples read not equal to number of samples ' ...
         'determined from header']);
end

% if we're in gap-free mode, and there's a synch section, we need to read
% it to get the time of the first sample
if h.nOperationMode==3 && h.lSynchArraySize>0
  fseek(fid,512*h.lSynchArrayPtr,'bof');
  t0_synchtimeunits=fread(fid,1,'long');
else
  t0_synchtimeunits=0;
end;

% close the file
fclose(fid);

% get the various scaling factors in the same order as in data
adc_sampling_seq=h.nADCSamplingSeq(h.nADCSamplingSeq>=0)+1;
adc_programmable_gain=h.fADCProgrammableGain(adc_sampling_seq);
instrument_scale_factor=h.fInstrumentScaleFactor(adc_sampling_seq);
instrument_offset=h.fInstrumentOffset(adc_sampling_seq);
signal_gain=h.fSignalGain(adc_sampling_seq);
signal_offset=h.fSignalOffset(adc_sampling_seq);

% now take into account the gain and offset
if strcmp(type_string,'short')
  gain=h.fADCRange/(h.lADCResolution*instrument_scale_factor(i_data_this)*...
                    adc_programmable_gain(i_data_this)*signal_gain(i_data_this));
  offset=signal_offset(i_data_this)+instrument_offset(i_data_this);
  data=gain*data+offset;  
end

% determine the timeline offset, t0
if t0_synchtimeunits==0
  t0=0;  % s
else
  if h.fSynchTimeUnit==0
    dt_synch=1e-6*h.fADCSampleInterval;  % us -> s
  else
    dt_synch=1e-6*h.fSynchTimeUnit;
  end
  t0=dt_synch*t0_synchtimeunits;
end

% make the timeline
dt=1e-6*(n_channels*h.fADCSampleInterval);  % us -> s
t=t0+dt*(0:(n_times-1))';
if zero_t
  t=t-t(1);
end

% get the channel units, convert to cell array
units_chan_from_i_adc_raw=h.sADCUnits;  % 16x8 char
units_chan_from_i_adc=cell(16,1);
for i_adc=1:16
  units_chan_from_i_adc{i_adc,1}=...
    deblank(units_chan_from_i_adc_raw(i_adc,:));
end

% now remap in terms of i_data
units_chan_from_i_data=cell(n_channels,1);
for i_data=1:n_channels
  units_chan_from_i_data{i_data,1}=...
    units_chan_from_i_adc{i_adc_from_i_data(i_data)};
end

% get the units for this channel
units_chan_this=units_chan_from_i_data{i_data_this};

end  % function



function [h] = get_abf_header(fid);
% Get header information from a pClamp 6.x Axon Binary File (ABF).
% h = get_abf_header(FID) returns a structure with all header information.
% ABF files should be opened with the appropriate machineformat (IEEE 
% floating point with little-endian byte ordering, e.g., 
% fopen(file,'r','l').  For a description of the fields, see the 
% "abf.asc" file included with the "Axon PC File Support Package for 
% Developers".

% Set the pointer to beginning of the file.
fseek(fid,0,'bof');

% This next was '2048' (bytes long) in the Axon Binary Format version 1.5.
h.size  =   6144;  

%-----------------------------------------------------------------------------
% File ID and Size information
h.lFileSignature        = fread(fid,1,'int');   % Pointing to byte 0
h.fFileVersionNumber    = fread(fid,1,'float'); % 4
h.nOperationMode        = fread(fid,1,'short'); % 8
h.lActualAcqLength      = fread(fid,1,'int');   % 10
h.nNumPointsIgnored     = fread(fid,1,'short'); % 14
h.lActualEpisodes       = fread(fid,1,'int');   % 16
h.lFileStartDate        = fread(fid,1,'int');   % 20
h.lFileStartTime        = fread(fid,1,'int');   % 24
h.lStopwatchTime        = fread(fid,1,'int');   % 28
h.fHeaderVersionNumber  = fread(fid,1,'float'); % 32
h.nFileType             = fread(fid,1,'short'); % 36
h.nMSBinFormat          = fread(fid,1,'short'); % 38
%-----------------------------------------------------------------------------
% File Structure
h.lDataSectionPtr       = fread(fid,1,'int');   % 40
h.lTagSectionPtr        = fread(fid,1,'int');   % 44
h.lNumTagEntries        = fread(fid,1,'int');   % 48
h.lScopeConfigPtr       = fread(fid,1,'int');   % 52
h.lNumScopes            = fread(fid,1,'int');   % 56
h.x_lDACFilePtr         = fread(fid,1,'int');   % 60
h.x_lDACFileNumEpisodes = fread(fid,1,'int');   % 64
h.sUnused68             = fread(fid,4,'char');  % 4char % 68
h.lDeltaArrayPtr        = fread(fid,1,'int');   % 72
h.lNumDeltas            = fread(fid,1,'int');   % 76
h.lVoiceTagPtr          = fread(fid,1,'int');   % 80
h.lVoiceTagEntries      = fread(fid,1,'int');   % 84
h.lUnused88             = fread(fid,1,'int');   % 88
h.lSynchArrayPtr        = fread(fid,1,'int');   % 92
h.lSynchArraySize       = fread(fid,1,'int');   % 96
h.nDataFormat           = fread(fid,1,'short'); % 100
h.nSimultaneousScan     = fread(fid,1,'short'); % 102
h.sUnused104            = fread(fid,16,'char'); % 16char % 104
%-----------------------------------------------------------------------------
% Trial Hierarchy Information
h.nADCNumChannels       = fread(fid,1,'short'); % 120
h.fADCSampleInterval    = fread(fid,1,'float'); % 122
h.fADCSecondSampleInterval=fread(fid,1,'float');% 126
h.fSynchTimeUnit        = fread(fid,1,'float'); % 130
h.fSecondsPerRun        = fread(fid,1,'float'); % 134
h.lNumSamplesPerEpisode = fread(fid,1,'int');   % 138
h.lPreTriggerSamples    = fread(fid,1,'int');   % 142
h.lEpisodesPerRun       = fread(fid,1,'int');   % 146
h.lRunsPerTrial         = fread(fid,1,'int');   % 150
h.lNumberOfTrials       = fread(fid,1,'int');   % 154
h.nAveragingMode        = fread(fid,1,'short'); % 158
h.nUndoRunCount         = fread(fid,1,'short'); % 160
h.nFirstEpisodeInRun    = fread(fid,1,'short'); % 162
h.fTriggerThreshold     = fread(fid,1,'float'); % 164
h.nTriggerSource        = fread(fid,1,'short'); % 168
h.nTriggerAction        = fread(fid,1,'short'); % 170
h.nTriggerPolarity      = fread(fid,1,'short'); % 172
h.fScopeOutputInterval  = fread(fid,1,'float'); % 174
h.fEpisodeStartToStart  = fread(fid,1,'float'); % 178
h.fRunStartToStart      = fread(fid,1,'float'); % 182
h.fTrialStartToStart    = fread(fid,1,'float'); % 186
h.lAverageCount         = fread(fid,1,'int');   % 190
h.lClockChange          = fread(fid,1,'int');   % 194
h.nAutoTriggerStrategy  = fread(fid,1,'short'); % 198
%-----------------------------------------------------------------------------
% Display Parameters
h.nDrawingStrategy      = fread(fid,1,'short'); % 200
h.nTiledDisplay         = fread(fid,1,'short'); % 202
h.nEraseStrategy        = fread(fid,1,'short'); % 204
h.nDataDisplayMode      = fread(fid,1,'short'); % 206
h.lDisplayAverageUpdate = fread(fid,1,'int');   % 208
h.nChannelStatsStrategy = fread(fid,1,'short'); % 212
h.lCalculationPeriod    = fread(fid,1,'int');   % 214
h.lSamplesPerTrace      = fread(fid,1,'int');   % 218
h.lStartDisplayNum      = fread(fid,1,'int');   % 222
h.lFinishDisplayNum     = fread(fid,1,'int');   % 226
h.nMultiColor           = fread(fid,1,'short'); % 230
h.nShowPNRawData        = fread(fid,1,'short'); % 232
h.fStatisticsPeriod     = fread(fid,1,'float'); % 234
h.lStatisticsMeasurements=fread(fid,1,'int');   % 238
h.nStatisticsSaveStrategy=fread(fid,1,'short'); % 242
%-----------------------------------------------------------------------------
% Hardware Information
h.fADCRange             = fread(fid,1,'float'); % 244
h.fDACRange             = fread(fid,1,'float'); % 248
h.lADCResolution        = fread(fid,1,'int');   % 252
h.lDACResolution        = fread(fid,1,'int');   % 256
%-----------------------------------------------------------------------------
% Environmental Information
h.nExperimentType       = fread(fid,1,'short'); % 260
h.x_nAutosampleEnable   = fread(fid,1,'short'); % 262
h.x_nAutosampleADCNum   = fread(fid,1,'short'); % 264
h.x_nAutosampleInstrument=fread(fid,1,'short'); % 266
h.x_fAutosampleAdditGain= fread(fid,1,'float'); % 268
h.x_fAutosampleFilter   = fread(fid,1,'float'); % 272
h.x_fAutosampleMembraneCapacitance=fread(fid,1,'float'); % 276
h.nManualInfoStrategy   = fread(fid,1,'short'); % 280
h.fCellID1              = fread(fid,1,'float'); % 282
h.fCellID2              = fread(fid,1,'float'); % 286
h.fCellID3              = fread(fid,1,'float'); % 290
h.sCreatorInfo          = fread(fid,16,'char'); % 16char % 294
h.x_sFileComment        = fread(fid,56,'char'); % 56char % 310
h.sUnused366            = fread(fid,12,'char'); % 12char % 366
%-----------------------------------------------------------------------------
% Multi-channel Information
h.nADCPtoLChannelMap    = fread(fid,16,'short');    % 378
h.nADCSamplingSeq       = fread(fid,16,'short');    % 410
h.sADCChannelName       = char(fread(fid,[10 16],'char')');  % 442
h.sADCUnits             = char(fread(fid,[8 16],'char')');   % 8char % 602
h.fADCProgrammableGain  = fread(fid,16,'float');    % 730
h.fADCDisplayAmplification=fread(fid,16,'float');   % 794
h.fADCDisplayOffset     = fread(fid,16,'float');    % 858
h.fInstrumentScaleFactor= fread(fid,16,'float');    % 922
h.fInstrumentOffset     = fread(fid,16,'float');    % 986
h.fSignalGain           = fread(fid,16,'float');    % 1050
h.fSignalOffset         = fread(fid,16,'float');    % 1114
h.fSignalLowpassFilter  = fread(fid,16,'float');    % 1178
h.fSignalHighpassFilter = fread(fid,16,'float');    % 1242
h.sDACChannelName       = char(fread(fid,[10 4],'char')');   % 1306
h.sDACChannelUnits      = char(fread(fid,[8 4],'char')');    % 8char % 1346
h.fDACScaleFactor       = fread(fid,4,'float');     % 1378
h.fDACHoldingLevel      = fread(fid,4,'float');     % 1394
h.nSignalType           = fread(fid,1,'short');     % 12char % 1410
h.sUnused1412           = fread(fid,10,'char');     % 10char % 1412
%-----------------------------------------------------------------------------
% Synchronous Timer Outputs
h.nOUTEnable            = fread(fid,1,'short');     % 1422
h.nSampleNumberOUT1     = fread(fid,1,'short');     % 1424
h.nSampleNumberOUT2     = fread(fid,1,'short');     % 1426
h.nFirstEpisodeOUT      = fread(fid,1,'short');     % 1428
h.nLastEpisodeOUT       = fread(fid,1,'short');     % 1430
h.nPulseSamplesOUT1     = fread(fid,1,'short');     % 1432
h.nPulseSamplesOUT2     = fread(fid,1,'short');     % 1434
%-----------------------------------------------------------------------------
% Epoch Waveform and Pulses
h.nDigitalEnable        = fread(fid,1,'short');     % 1436
h.x_nWaveformSource     = fread(fid,1,'short');     % 1438
h.nActiveDACChannel     = fread(fid,1,'short');     % 1440
h.x_nInterEpisodeLevel  = fread(fid,1,'short');     % 1442
h.x_nEpochType          = fread(fid,10,'short');    % 1444
h.x_fEpochInitLevel     = fread(fid,10,'float');    % 1464
h.x_fEpochLevelInc      = fread(fid,10,'float');    % 1504
h.x_nEpochInitDuration  = fread(fid,10,'short');    % 1544
h.x_nEpochDurationInc   = fread(fid,10,'short');    % 1564
h.nDigitalHolding       = fread(fid,1,'short');     % 1584
h.nDigitalInterEpisode  = fread(fid,1,'short');     % 1586
h.nDigitalValue         = fread(fid,10,'short');    % 1588
h.sUnavailable1608      = fread(fid,4,'char');      % 1608
h.sUnused1612           = fread(fid,8,'char');      % 8char % 1612
%-----------------------------------------------------------------------------
% DAC Output File
h.x_fDACFileScale       = fread(fid,1,'float');     % 1620
h.x_fDACFileOffset      = fread(fid,1,'float');     % 1624
h.sUnused1628           = fread(fid,2,'char');      % 2char % 1628
h.x_nDACFileEpisodeNum  = fread(fid,1,'short');     % 1630
h.x_nDACFileADCNum      = fread(fid,1,'short');     % 1632
h.x_sDACFileName        = fread(fid,12,'char');     % 12char % 1634
h.sDACFilePath=fread(fid,60,'char');                % 60char % 1646
h.sUnused1706=fread(fid,12,'char');                 % 12char % 1706
%-----------------------------------------------------------------------------
% Conditioning Pulse Train
h.x_nConditEnable       = fread(fid,1,'short');     % 1718
h.x_nConditChannel      = fread(fid,1,'short');     % 1720
h.x_lConditNumPulses    = fread(fid,1,'int');       % 1722
h.x_fBaselineDuration   = fread(fid,1,'float');     % 1726
h.x_fBaselineLevel      = fread(fid,1,'float');     % 1730
h.x_fStepDuration       = fread(fid,1,'float');     % 1734
h.x_fStepLevel          = fread(fid,1,'float');     % 1738
h.x_fPostTrainPeriod    = fread(fid,1,'float');     % 1742
h.x_fPostTrainLevel     = fread(fid,1,'float');     % 1746
h.sUnused1750           = fread(fid,12,'char');     % 12char % 1750
%-----------------------------------------------------------------------------
% Variable Parameter User List
h.x_nParamToVary        = fread(fid,1,'short');     % 1762
h.x_sParamValueList     = fread(fid,80,'char');     % 80char % 1764
%-----------------------------------------------------------------------------
% Statistics Measurement
h.nAutopeakEnable       = fread(fid,1,'short'); % 1844
h.nAutopeakPolarity     = fread(fid,1,'short'); % 1846
h.nAutopeakADCNum       = fread(fid,1,'short'); % 1848
h.nAutopeakSearchMode   = fread(fid,1,'short'); % 1850
h.lAutopeakStart        = fread(fid,1,'int');   % 1852
h.lAutopeakEnd          = fread(fid,1,'int');   % 1856
h.nAutopeakSmoothing    = fread(fid,1,'short'); % 1860
h.nAutopeakBaseline     = fread(fid,1,'short'); % 1862
h.nAutopeakAverage      = fread(fid,1,'short'); % 1864
h.sUnavailable1866      = fread(fid,2,'char');  % 1866
h.lAutopeakBaselineStart= fread(fid,1,'int');   % 1868
h.lAutopeakBaselineEnd  = fread(fid,1,'int');   % 1872
h.lAutopeakMeasurements = fread(fid,1,'int');   % 1876
%-----------------------------------------------------------------------------
% Channel Arithmetic
h.nArithmeticEnable     = fread(fid,1,'short'); % 1880
h.fArithmeticUpperLimit = fread(fid,1,'float'); % 1882
h.fArithmeticLowerLimit = fread(fid,1,'float'); % 1886
h.nArithmeticADCNumA    = fread(fid,1,'short'); % 1890
h.nArithmeticADCNumB    = fread(fid,1,'short'); % 1892
h.fArithmeticK1         = fread(fid,1,'float'); % 1894
h.fArithmeticK2         = fread(fid,1,'float'); % 1898
h.fArithmeticK3         = fread(fid,1,'float'); % 1902
h.fArithmeticK4         = fread(fid,1,'float'); % 1906
h.sArithmeticOperator   = fread(fid,2,'char');  % 2char % 1910
h.sArithmeticUnits      = fread(fid,8,'char');  % 8char % 1912
h.fArithmeticK5         = fread(fid,1,'float'); % 1920
h.fArithmeticK6         = fread(fid,1,'float'); % 1924
h.nArithmeticExpression = fread(fid,1,'short'); % 1928
h.sUnused1930           = fread(fid,2,'char');  % 2char % 1930
%-----------------------------------------------------------------------------
% On-line Subtraction
h.x_nPNEnable           = fread(fid,1,'short'); % 1932
h.nPNPosition           = fread(fid,1,'short'); % 1934
h.x_nPNPolarity         = fread(fid,1,'short'); % 1936
h.nPNNumPulses          = fread(fid,1,'short'); % 1938
h.x_nPNADCNum           = fread(fid,1,'short'); % 1940
h.x_fPNHoldingLevel     = fread(fid,1,'float'); % 1942
h.fPNSettlingTime       = fread(fid,1,'float'); % 1946
h.fPNInterpulse         = fread(fid,1,'float'); % 1950
h.sUnused1954           = fread(fid,12,'char'); % 12char % 1954
%-----------------------------------------------------------------------------
% Unused Space at End of Header Block
h.x_nListEnable         = fread(fid,1,'short'); % 1966
h.nBellEnable           = fread(fid,2,'short'); % 1968
h.nBellLocation         = fread(fid,2,'short'); % 1972
h.nBellRepetitions      = fread(fid,2,'short'); % 1976
h.nLevelHysteresis      = fread(fid,1,'int');   % 1980
h.lTimeHysteresis       = fread(fid,1,'int');   % 1982
h.nAllowExternalTags    = fread(fid,1,'short'); % 1986
h.nLowpassFilterType    = fread(fid,16,'char'); % 1988
h.nHighpassFilterType   = fread(fid,16,'char');% 2004
h.nAverageAlgorithm     = fread(fid,1,'short'); % 2020
h.fAverageWeighting     = fread(fid,1,'float'); % 2022
h.nUndoPromptStrategy   = fread(fid,1,'short'); % 2026
h.nTrialTriggerSource   = fread(fid,1,'short'); % 2028
h.nStatisticsDisplayStrategy= fread(fid,1,'short'); % 2030
h.sUnused2032           = fread(fid,16,'char'); % 2032

%-----------------------------------------------------------------------------
% File Structure 2
h.lDACFilePtr           = fread(fid,2,'int'); % 2048
h.lDACFileNumEpisodes   = fread(fid,2,'int'); % 2056
h.sUnused2              = fread(fid,10,'char');%2064
%-----------------------------------------------------------------------------
% Multi-channel Information 2
h.fDACCalibrationFactor = fread(fid,4,'float'); % 2074
h.fDACCalibrationOffset = fread(fid,4,'float'); % 2090
h.sUnused7              = fread(fid,190,'char');% 2106
%-----------------------------------------------------------------------------
% Epoch Waveform and Pulses 2
h.nWaveformEnable       = fread(fid,2,'short'); % 2296
h.nWaveformSource       = fread(fid,2,'short'); % 2300
h.nInterEpisodeLevel    = fread(fid,2,'short'); % 2304
h.nEpochType            = fread(fid,10*2,'short');% 2308
h.fEpochInitLevel       = fread(fid,10*2,'float');% 2348
h.fEpochLevelInc        = fread(fid,10*2,'float');% 2428
h.lEpochInitDuration    = fread(fid,10*2,'int');  % 2508
h.lEpochDurationInc     = fread(fid,10*2,'int');  % 2588
h.sUnused9              = fread(fid,40,'char');   % 2668
%-----------------------------------------------------------------------------
% DAC Output File 2
h.fDACFileScale         = fread(fid,2,'float');     % 2708
h.fDACFileOffset        = fread(fid,2,'float');     % 2716
h.lDACFileEpisodeNum    = fread(fid,2,'int');       % 2724
h.nDACFileADCNum        = fread(fid,2,'short');     % 2732
h.sDACFilePath          = fread(fid,2*256,'char');  % 2736
h.sUnused10             = fread(fid,12,'char');     % 3248
%-----------------------------------------------------------------------------
% Conditioning Pulse Train 2
h.nConditEnable         = fread(fid,2,'short');     % 3260
h.lConditNumPulses      = fread(fid,2,'int');       % 3264
h.fBaselineDuration     = fread(fid,2,'float');     % 3272
h.fBaselineLevel        = fread(fid,2,'float');     % 3280
h.fStepDuration         = fread(fid,2,'float');     % 3288
h.fStepLevel            = fread(fid,2,'float');     % 3296
h.fPostTrainPeriod      = fread(fid,2,'float');     % 3304
h.fPostTrainLevel       = fread(fid,2,'float');     % 3312
h.nUnused11             = fread(fid,2,'short');     % 3320
h.sUnused11             = fread(fid,36,'char');     % 3324
%-----------------------------------------------------------------------------
% Variable Parameter User List 2
h.nULEnable             = fread(fid,4,'short');     % 3360
h.nULParamToVary        = fread(fid,4,'short');     % 3368
h.sULParamValueList     = fread(fid,4*256,'char');  % 3376
h.sUnused11             = fread(fid,56,'char');     % 4400
%-----------------------------------------------------------------------------
% On-line Subtraction 2
h.nPNEnable             = fread(fid,2,'short');     % 4456
h.nPNPolarity           = fread(fid,2,'short');     % 4460
h.nPNADCNum             = fread(fid,2,'short');     % 4464
h.fPNHoldingLevel       = fread(fid,2,'float');     % 4468
h.sUnused15             = fread(fid,36,'char');     % 4476
%-----------------------------------------------------------------------------
% Environmental Information 2
h.nTelegraphEnable      = fread(fid,16,'short');     % 4512
h.nTelegraphInstrument  = fread(fid,16,'short');     % 4544
h.fTelegraphAdditGain   = fread(fid,16,'float');     % 4576
h.fTelegraphFilter      = fread(fid,16,'float');     % 4640
h.fTelegraphMembraneCap = fread(fid,16,'float');     % 4704
h.nTelegraphMode        = fread(fid,16,'short');     % 4768
h.nManualTelegraphStrategy= fread(fid,16,'short');   % 4800
h.nAutoAnalyseEnable    = fread(fid,1,'short');      % 4832
h.sAutoAnalysisMacroName= fread(fid,64,'char');      % 4834
h.sProtocolPath         = fread(fid,256,'char');     % 4898
h.sFileComment          = fread(fid,128,'char');     % 5154
h.sUnused6              = fread(fid,128,'char');     % 5282
h.sUnused2048           = fread(fid,734,'char');     % 5410
%
%-----------------------------------------------------------------------------
%
return;

end  % function
