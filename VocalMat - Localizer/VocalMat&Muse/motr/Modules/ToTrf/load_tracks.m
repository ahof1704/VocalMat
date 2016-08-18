% [trx,matname,succeeded] = load_tracks(matname,[moviename])
%
% Load tracking data from a MAT-file. If the file was a raw export from Ctrax,
% then do some cleanup on it. Otherwise, just load and return.

function [trx,matname,succeeded] = load_tracks(matname,moviename,varargin)

[dosave,savename,annname] = myparse(varargin,'dosave',false,'savename','','annname','');

succeeded = false;
trx = [];

% get a filename if one wasn't passed in
if ~exist('matname','var'),
  helpmsg = 'Choose mat file containing trajectories to load';
  [matname,matpath] = uigetfilehelp('*.mat','Choose mat file containing trajectories','','helpmsg',helpmsg);
  if ~ischar(matname),
    return;
  end
  matname = [matpath,matname];
end

tmp = load(matname, '-mat');
fprintf('loaded %s\n',matname);

if isfield(tmp,'pairtrx'),
   % a paired track, so use it ...?
  tmp.trx = tmp.pairtrx;
end
  
% figure out what type the loaded data are
if ~isfield(tmp,'trx'),
   % a Ctrax file
  if isfield(tmp,'ntargets'),
    fprintf('Ctrax output file; converting to trx file\n');
    if ~exist('moviename','var') || isempty( moviename ),
      moviename = '?';
    end
    %ds = datestr(now,30);
    fprintf('Calling cleanup_ctrax_data\n');
    [trx,matname,timestamps] = cleanup_ctrax_data(matname,moviename,tmp,'','dosave',dosave,'savename',savename,'annname',annname);
  else
    msgbox('Could not load data from %s, exiting',matname);
    return;
  end
  
else
   % a previously opened trx file
  trx = tmp.trx;
  if exist('moviename','var') && ~isfield(trx,'moviename'),
     % add moviename field, if possible
    for i = 1:length(trx),
      trx(i).moviename = moviename;
    end
  end
  
  if dosave && ~isempty(savename),
      [didcopy,msg,~] = copyfile(matname,savename);
      if ~didcopy,
          error('Could not copy %s to %s:\n%s',matname,savename,msg);
      end
  end
      
end

% member functions can be weird
for i = 1:length(trx),
  trx(i).off = -trx(i).firstframe + 1;
  trx(i).matname = matname;
end

succeeded = true;
