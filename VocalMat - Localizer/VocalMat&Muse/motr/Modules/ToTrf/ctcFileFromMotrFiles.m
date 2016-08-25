function ctcFileFromMotrFiles(ctcFileName, ...
                              seqFileName, ...
                              motrTrackFileName, ...
                              pxPerMm, ...
                              minSuspectPredictionErrorInBodyLengths, ...
                              minSuspectOrientationChangeInDegrees, ...
                              minSuspiciouslyLargeMajorAxisInMm, ...
                              minSuspiciousOrientationDirectionMismatchInDeg, ...
                              minWalkingSpeedInBodyLengthsPerSec, ...
                              maxAmbiguousIdentityErrorInBodyLengthsSquared)

% Just set these, since answering every time is annoying                      
if ~exist('minSuspectPredictionErrorInBodyLengths','var') || isempty(minSuspectPredictionErrorInBodyLengths) , 
  minSuspectPredictionErrorInBodyLengths=2;
end
if ~exist('minSuspectOrientationChangeInDegrees','var') || isempty(minSuspectOrientationChangeInDegrees) , 
  minSuspectOrientationChangeInDegrees=45;
end
if ~exist('minSuspiciousOrientationDirectionMismatchInDeg','var') || isempty(minSuspiciousOrientationDirectionMismatchInDeg) , 
  minSuspiciousOrientationDirectionMismatchInDeg=90;
end
if ~exist('minWalkingSpeedInBodyLengthsPerSec','var') || isempty(minWalkingSpeedInBodyLengthsPerSec) , 
  minWalkingSpeedInBodyLengthsPerSec=0.07;
end

% % First write the .ann file
% annFileFromMotrFiles(annFileName, ...
%                      seqFileName, ...
%                      motrTrackFileName);

% Compute the background frame
%[medianFrame,medianAbsDiffFrame]=seqMedianFrameFromNonRandomSample(seqFileName);
backgroundImage=seqMedianFrameFromNonRandomSample(seqFileName);

% Convert the Motr track file (whose name often ends in '_tracks.mat') to
% a Ctrax/Jaaba-style .trx file
%trxFileName=trxFileNameFromMotrTrackFileName(motrTrackFileName);
s=load(motrTrackFileName);
astrctTrackers=s.astrctTrackers;
clear('s');
[meanObservedQuarterMajorAxisInPels,maxObservedQuarterMajorAxisInPels]= ...
  sizeStatisticsFromShayTrack(astrctTrackers)
trx=trxFromShayTrack(astrctTrackers);

% Interpolate to get rid of nan's
trx=interpolateAwayNansInTrx(trx);

% Add frames per second and time stamps, getting from .seq file
seqInfo=fnReadSeqInfo(seqFileName);
fps=seqInfo.m_fFPS;  % Hz
timeStamps=seqInfo.m_afTimestamp;  % seconds
nTracks=length(trx);
for iTrack=1:nTracks
  trx(iTrack).fps=fps;
  trx(iTrack).timestamps=timeStamps;
end

% add the trajectories in physical units, if we can
nTracks=length(trx);
for iTrack=1:nTracks
  trx(iTrack).pxpermm=pxPerMm;
  trx(iTrack).x_mm=trx(iTrack).x/pxPerMm;
  trx(iTrack).y_mm=trx(iTrack).y/pxPerMm;
  trx(iTrack).a_mm=trx(iTrack).a/pxPerMm;
  trx(iTrack).b_mm=trx(iTrack).b/pxPerMm;
end  

% % Write out the .trp file
% % Stands for "TRacks with Physical units"
% save(trpFileName,'trx');
trp=trx;






%
% fixMouseErrors
%
                      
% script that prompts user for mat, annotation, and movie files, parameters
% for computing suspicious frames, then computes suspicious frames, then
% brings up the fixerrors gui

% [readframe,nframes,fid] = get_readframe_fcn(seqFileName);
% readframe_fcn.readframe = readframe;
% readframe_fcn.nframes = nframes;
% readframe_fcn.fid = fid;

% try
%   if exist('savedsettingsfile','file'),
%     save('-append',savedsettingsfile,'moviename','moviepath');
%   else
%     save(savedsettingsfile,'moviename','moviepath');
%   end
% catch ME,
%   fprintf('Could not save to rc file %s -- not a big deal\n',savedsettingsfile);
%   getReport(ME)
% end

%DORESTART = false;
 

%% set parameters for detecting suspicious frames

%if ~DORESTART,

%[max_jump,maxmajor,meanmajor,arena_radius] = ...
%  read_ann(annFileName,'max_jump','maxmajor','meanmajor','arena_radius');
% [maxJumpDistanceInPels,maxObservedQuarterMajorAxisInPels,meanObservedQuarterMajorAxisInPels] = ...
%   read_ann(annFileName,'max_jump','maxmajor','meanmajor');
maxJumpDistanceInPels=50;
meanObservedMajorAxisInPels = meanObservedQuarterMajorAxisInPels * 4;
maxObservedMajorAxisInPels = maxObservedQuarterMajorAxisInPels * 4;

%   pxPerMm = trx(1).pxpermm; % pixels per millimeter
%    try
%       save('-append',savedsettingsfile,'px2mm');
%    catch ME
%       fprintf('Could not save to settings file %s -- not a big deal\n',savedsettingsfile);
%       getReport(ME)
%    end

maxJumpDistanceInMm= maxJumpDistanceInPels / pxPerMm;
maxObservedMajorAxisInMm = maxObservedMajorAxisInPels / pxPerMm;
meanObservedMajorAxisInMm = meanObservedMajorAxisInPels / pxPerMm;
%arena_radius = arena_radius / pxPerMm;

mmPerBodyLength = meanObservedMajorAxisInMm; % millimeters per body-length

% set default values
% if ~exist('minerrjump','var')
%   minerrjump = .2*max_jump;
% end
% if ~exist('minorientchange','var'),
%   minorientchange = 45;
% end
% if ~exist('minanglediff','var'),
%   minanglediff = 90;
% end
% if ~exist('minwalkvel','var'),
%   minwalkvel = 1 / 4;
% end
% if ~exist('matcherrclose','var'),
%   matcherrclose = 10/4^2;
% end

% Based on what we know, set user params if not already set
if ~exist('minSuspiciouslyLargeMajorAxisInMm','var') || isempty(minSuspiciouslyLargeMajorAxisInMm) , 
 minSuspiciouslyLargeMajorAxisInMm=meanObservedMajorAxisInMm + 2/3*(maxObservedMajorAxisInMm-meanObservedMajorAxisInMm);
end
if ~exist('maxAmbiguousIdentityErrorInBodyLengthsSquared','var') || isempty(maxAmbiguousIdentityErrorInBodyLengthsSquared) , 
 maxAmbiguousIdentityErrorInBodyLengthsSquared=10/4^2/mmPerBodyLength/mmPerBodyLength;
end

minSuspectPredictionErrorInBodyLengths  %#ok
minSuspectOrientationChangeInDegrees  %#ok
minSuspiciouslyLargeMajorAxisInMm  %#ok
minSuspiciousOrientationDirectionMismatchInDeg  %#ok
minWalkingSpeedInBodyLengthsPerSec  %#ok
maxAmbiguousIdentityErrorInBodyLengthsSquared  %#ok

minSuspectPredictionErrorInMm = minSuspectPredictionErrorInBodyLengths*mmPerBodyLength;  % convert back to mm
minWalkingSpeedInMmPerFrameInterval = minWalkingSpeedInBodyLengthsPerSec*mmPerBodyLength/trx(1).fps;
maxAmbiguousIdentityErrorInMmSquared = maxAmbiguousIdentityErrorInBodyLengthsSquared*mmPerBodyLength*mmPerBodyLength;


% % convert to the units expected by suspicious_sequences

center_dampen=0;  % what is this?
angle_dampen=0.5;  % what is this?
%vel_angle_wt=[];  % not used inside suspicious_sequences_in_memory()
                        
minSuspectPredictionErrorOverMaxJumpDistance = minSuspectPredictionErrorInMm / maxJumpDistanceInMm;
minSuspectOrientationChangeInRadians = minSuspectOrientationChangeInDegrees*pi/180;
maxmajorfrac = (minSuspiciouslyLargeMajorAxisInMm - meanObservedMajorAxisInMm)/(maxObservedMajorAxisInMm - meanObservedMajorAxisInMm);
minWalkingSpeedInPelsPerFrameInterval = minWalkingSpeedInMmPerFrameInterval*pxPerMm;
maxAmbiguousIdentityErrorInPelsSquared = maxAmbiguousIdentityErrorInMmSquared*pxPerMm^2;
minSuspiciousOrientationDirectionMismatchInRadians = minSuspiciousOrientationDirectionMismatchInDeg*pi/180;
[seqs,trx0,params] = ...
  suspicious_sequences_in_memory(...
    trp, ...
    center_dampen, ...
    angle_dampen, ...
    maxJumpDistanceInPels, ...
    maxObservedMajorAxisInPels, ...
    meanObservedMajorAxisInPels, ...
    'minerrjumpfrac',minSuspectPredictionErrorOverMaxJumpDistance, ...
    'minorientchange',minSuspectOrientationChangeInRadians,...
    'maxmajorfrac',maxmajorfrac, ...
    'minwalkvel',minWalkingSpeedInPelsPerFrameInterval,...
    'matcherrclose',maxAmbiguousIdentityErrorInPelsSquared, ...
    'minanglediff',minSuspiciousOrientationDirectionMismatchInRadians);
   


%fixerrorsgui(seqs,seqFileName,trx0,annFileName,params,trpFileName,loadname);

%end  % fixMouseErrors functions







%
% Stuff from the old fixerrorsgui
%

% store stuff in a single struct
ctc.version=1;  % .ctc file version number
ctc.seqs = seqs;
ctc.moviename = seqFileName;
ctc.trx = trx0;
%trf.annname = annFileName;
ctc.ang_dist_wt=65/(pi/2);  % mm/radian, used to convert angle errors to distances,
                            % for computing an "overall" distance between mice
                            % ellipses
ctc.maxjump=maxJumpDistanceInPels; 
ctc.bgthresh=100;  
  % threshold difference from the background image for a pel to be 
  % declared foreground (assumes grayvals are coded 0-255)
ctc.foregroundSign=0;  % foreground segmentation will be based on absolute diff from backgroundImage
ctc.backgroundImage=backgroundImage;
ctc.params = params;
ctc.originalTrackFileName = motrTrackFileName;
ctc.doneseqs=[];
ctc.seqi=fif(isempty(seqs),[],1);
ctc.center_dampen=center_dampen;
ctc.angle_dampen=angle_dampen;
ctc.maxMajorAxisInPels=maxObservedMajorAxisInPels;
ctc.meanMajorAxisInPels=meanObservedMajorAxisInPels;

% write the fields of that struct to the .ctc file
% .ctc is for CaTalytiC
save(ctcFileName,'-struct','ctc');

end

