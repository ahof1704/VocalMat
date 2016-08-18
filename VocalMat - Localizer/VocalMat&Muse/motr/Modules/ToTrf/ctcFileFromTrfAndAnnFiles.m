function ctcFileFromTrfAndAnnFiles(ctcFileName, ...
                                   trfFileName, ...
                                   annFileName, ...
                                   annBackgroundImageInRowMajorOrder)

% deal with args
if ~exist('annBackgroundImageInRowMajorOrder','var') || isempty(annBackgroundImageInRowMajorOrder) ,
  % if not specified, assume the .ann backgroundImage is in the correct order
  annBackgroundImageInRowMajorOrder=true;
end
                                 
% Load the .trf file
trf=load(trfFileName,'-mat');
ctc=trf;

% Read the first frame from the movie file, to get the frame dimensions,
% since the .ann doesn't store them
[readframe,nframes] = get_readframe_fcn(trf.moviename);
if nframes<1
  error('The movie has no frames!');
end
im = readframe(1);
[nRows,nCols]=size(im);

% Read needed things from the .ann file
ann=read_ann(annFileName);

% Populate ann-derived fields of the .ctc file         
ctc.ang_dist_wt=ann.ang_dist_wt;
ctc.maxjump=ann.max_jump;
if isfield(ann,'n_bg_std_thresh_low')
  ctc.bgthresh=ann.n_bg_std_thresh_low;
else
  ctc.bgthresh=100;
end
ctc.foregroundSign = 0;

%
% Populate the background image field of the .ctc
%
if strcmpi(ann.bg_algorithm,'median'),
  backgroundImageAsVector = ann.background_median;
else
  backgroundImageAsVector = ann.background_mean;
end

% Make the background image the right shape
if annBackgroundImageInRowMajorOrder
  % this is the normal case, where the background image was written in
  % row-major order, which is what the file format dictates
  ctc.backgroundImage = reshape(backgroundImageAsVector,[nCols nRows])';
else
  % this case deals with .ann files where the background image was written
  % in col-major order, which is _not_ what the file format dictates
  ctc.backgroundImage = reshape(backgroundImageAsVector,[nRows nCols]);
end

% tag the file format version
ctc.version=1;

% other things
ctc.center_dampen=ann.center_dampen;
ctc.angle_dampen=ann.angle_dampen;
ctc.maxMajorAxisInPels=ann.maxmajor;
ctc.meanMajorAxisInPels=ann.meanmajor;

% rename one thing
ctc.originalTrackFileName=trf.matname;
ctc=rmfield(ctc,'matname');  %#ok

%
% write the ctc file
%
save(ctcFileName,'-struct','ctc');

end
