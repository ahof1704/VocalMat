function [suspicious,dataperfly,params] = suspicious_sequences(matname,annname,varargin)

[MINERRJUMPFRAC,CLOSELENGTH,MINORIENTCHANGE,MAXMAJORFRAC,MINWALKVEL,MATCHERRCLOSE,...
  MINANGLEDIFF,MAXDISTCLOSEFRAC] = ...
  myparse(varargin,'minerrjumpfrac',.2,'closelength',20,'minorientchange',pi/4,...
  'maxmajorfrac',2/3,'minwalkvel',1,'matcherrclose',10,'minanglediff',pi/2,...
  'maxdistclosefrac',2);

%% load data
if ~isstr(matname),
  dataperfly = matname;
else
  dataperfly = load_tracks(matname);
  %dataperfly = createdata_perfile('',matname,'',false);
end
nflies = length(dataperfly);
nframes = max(getstructarrayfield(dataperfly,'endframe'));

%% read parameters
[center_dampen,angle_dampen,max_jump,maxmajor,meanmajor,vel_angle_wt] = ...
  read_ann(annname,'center_dampen','angle_dampen','max_jump','maxmajor','meanmajor',...
  'velocity_angle_weight');
MINERRJUMP = MINERRJUMPFRAC*max_jump;
LARGEMAJOR = meanmajor + MAXMAJORFRAC * (maxmajor-meanmajor);
MAXDISTCLOSE = 4*maxmajor*MAXDISTCLOSEFRAC;

suspicious = [];

%% find births of tracks in the middle of the movie
fprintf('detecting births...\n');
for fly = 1:nflies,
  if isdummytrx(dataperfly(fly)),
    continue;
  end
  if dataperfly(fly).firstframe > 1,
    addsequence(fly,'birth',dataperfly(fly).firstframe,inf);
  end
end

%% find deaths of tracks in the middle of the movie
fprintf('detecting deaths...\n');
for fly = 1:nflies,
  if isdummytrx(dataperfly(fly)),
    continue;
  end
  if dataperfly(fly).endframe < nframes,
    addsequence(fly,'death',dataperfly(fly).endframe,inf);
  end
end

%% find frames, flies where the fly jumps
fprintf('detecting jumps...\n');
se = strel(ones(1,CLOSELENGTH));
for fly = 1:nflies,
  if isdummytrx(dataperfly(fly)),
    continue;
  end
  if dataperfly(fly).nframes == 1
    dataperfly(fly).xpred = dataperfly(fly).x;
    dataperfly(fly).ypred = dataperfly(fly).y;
    continue;
  elseif dataperfly(fly).nframes == 2
    dataperfly(fly).xpred = dataperfly(fly).x;
    dataperfly(fly).ypred = dataperfly(fly).y;
    continue;
  end
  
  % predicted position for frames 3:T
  xpred = (1+center_dampen)*dataperfly(fly).x(2:end-1) - center_dampen*dataperfly(fly).x(1:end-2);
  ypred = (1+center_dampen)*dataperfly(fly).y(2:end-1) - center_dampen*dataperfly(fly).y(1:end-2);
  dataperfly(fly).xpred = [dataperfly(fly).x(1:2),xpred];
  dataperfly(fly).ypred = [dataperfly(fly).y(1:2),ypred];
  
  % error of prediction
  err = sqrt((dataperfly(fly).xpred - dataperfly(fly).x).^2 + ...
    (dataperfly(fly).ypred - dataperfly(fly).y).^2);
  
  % find frames where error is greater than MINERRJUMP
  framesjump = err > MINERRJUMP;

  if ~any(framesjump), continue; end;

  % dilate to get discrete events
  framesjump = imclose(framesjump,se);
  [starts,ends] = get_interval_ends(framesjump);
  
  % add to list
  for jump = 1:length(starts),
    idx = starts(jump):ends(jump)-1;
    addsequence(fly,'jump',idx+dataperfly(fly).firstframe-1,err(idx)-MINERRJUMP);
  end
  
end

%% find frames, flies where there is a large change in orientation
fprintf('detecting orientation changes...\n');

for fly = 1:nflies,

  if isdummytrx(dataperfly(fly)),
    continue;
  end

  if dataperfly(fly).nframes <= 2
    dataperfly(fly).thetapred = dataperfly(fly).theta;
    continue;
  end
  
  % predicted position for frames 3:T
  dtheta = modrange(dataperfly(fly).theta(2:end-1) - dataperfly(fly).theta(1:end-2),-pi,pi);
  thetapred = dataperfly(fly).theta(2:end-1) + angle_dampen*dtheta;
  dataperfly(fly).thetapred = [dataperfly(fly).theta(1:2),thetapred];
  
  % error of prediction
  err = abs(modrange(dataperfly(fly).theta-dataperfly(fly).thetapred,-pi,pi));
  
  % find frames where error is greater than MINERRJUMP
  framesjump = err > MINORIENTCHANGE;

  if ~any(framesjump), continue; end;

  % dilate to get discrete events
  framesjump = imclose(framesjump,se);
  [starts,ends] = get_interval_ends(framesjump);
  
  % add to list
  for jump = 1:length(starts),
    idx = (starts(jump):ends(jump)-1);
    addsequence(fly,'orientchange',idx+dataperfly(fly).firstframe-1,err(idx)-MINORIENTCHANGE);
  end
  
end

%% find frames, pairs of flies in which there is another assignment of identity to
% observation with near optimal value

fprintf('detecting swaps...\n');

% data structures

% swapppairs(frame,flypair2idx(fly1,fly2)) is 1 if ids fly1 and fly2 may
% swap in frame frame. 
nentries = nflies*(nflies-1)/2;
swappairs = sparse(nframes,nentries);

% flypair2idx(fly1,fly2) is the index corresponding to the id pair
% (fly1,fly2)
flypair2idx = zeros(nflies,nflies);
[tmp1,tmp2] = find(tril(ones(nflies),-1));
flypair2idx(sub2ind([nflies,nflies],tmp1,tmp2)) = 1:nentries;
flypair2idx(sub2ind([nflies,nflies],tmp2,tmp1)) = 1:nentries;

% idx2flypair(idx,:) is the pair of ids corresponding to index idx
idx2flypair = [tmp1,tmp2];

% loop through frames
for i = 2:nframes,

  % flies alive in the current frame
  isalive = getstructarrayfield(dataperfly,'firstframe') <= i-1 & ...
    getstructarrayfield(dataperfly,'endframe') >= i;
  ids = find(isalive);
  nfliesalive = length(ids);
  % index into dataperfly(fly) for each fly alive
  iperfly = zeros(1,nfliesalive);
  for j = 1:nfliesalive,
    iperfly(j) = dataperfly(ids(j)).off+(i);
  end

  % get predicted and observed positions of all flies in the current frame
  xpred = zeros(1,nfliesalive);
  ypred = zeros(1,nfliesalive);
  thetapred = zeros(1,nfliesalive);
  xcurr = xpred;
  ycurr = ypred;
  thetacurr = thetapred;
  for j = 1:nfliesalive,
    xpred(j) = dataperfly(ids(j)).xpred(iperfly(j));
    ypred(j) = dataperfly(ids(j)).ypred(iperfly(j));
    thetapred(j) = dataperfly(ids(j)).thetapred(iperfly(j));
    xcurr(j) = dataperfly(ids(j)).x(iperfly(j));
    ycurr(j) = dataperfly(ids(j)).y(iperfly(j));
    thetacurr(j) = dataperfly(ids(j)).theta(iperfly(j));
  end
  
  % compute all pairs distances
  dcenter = dist2([xpred',ypred'],[xcurr',ycurr']);
  dtheta = modrange(repmat(thetacurr,[length(thetapred),1])-repmat(thetapred',[1,length(thetacurr)]),-pi,pi).^2;
  d = sqrt(dcenter + dtheta*100);
  
  % compute optimal
  dopt = sum(diag(d));
  
  % try all possible swaps
  if length(xpred) < 2,
    pairs = [];
  else
    pairs = nchoosek(1:length(xpred),2);
  end
  
  for j = 1:rows(pairs),
  
    i1 = pairs(j,1);
    i2 = pairs(j,2);
    dcurr = dopt - d(i1,i1) - d(i2,i2) + d(i1,i2) + d(i2,i1);
    err = dopt + MATCHERRCLOSE - dcurr;
    
    if err > 0,
      fly1 = ids(i1); fly2 = ids(i2);
      swappairs(i,flypair2idx(fly1,fly2)) = err;
    end
    
  end
  
end

% loop through each pair of flies
for i = 1:cols(swappairs),
  if ~any(swappairs(:,i)), continue; end;
  % dilate to get discrete events
  swappairscurr = full(swappairs(:,i))';
  if ~all( isreal( swappairscurr ) )
     fprintf( 1, 'imaginary numbers in pair-swapping detection... skipping event %d\n', i );
     continue
  end
  swappairscurr = imclose(swappairscurr,se);

  fly1 = idx2flypair(i,1); fly2 = idx2flypair(i,2);
  [starts,ends] = get_interval_ends(swappairscurr);
  for j = 1:length(starts),
    idx = starts(j):ends(j)-1;
    addsequence([fly1,fly2],'swap',idx,swappairscurr(idx));
  end
end

%% find frames, flies in which the major axis length is large
fprintf('detecting large major axes...\n');
for fly = 1:nflies,
  
  if isdummytrx(dataperfly(fly)),
    continue;
  end

  
  islargemajor = dataperfly(fly).a > LARGEMAJOR;

  fs = find(islargemajor);
  if isempty(fs), continue; end
  isclose = false(size(fs));
  for j = 1:length(fs)
    f = fs(j)+dataperfly(fly).firstframe-1;
    isclose(j) = false;
    i = fs(j);
    for fly2 = 1:nflies,
      if isdummytrx(dataperfly(fly2)),
        continue;
      end
      if fly2 == fly, continue; end
      if (dataperfly(fly2).firstframe > f) || (dataperfly(fly2).endframe < f), continue; end
      i2 = dataperfly(fly2).off+(f);
      d = sqrt((dataperfly(fly2).x(i2) - dataperfly(fly).x(i)).^2 + ...
        (dataperfly(fly2).y(i2) - dataperfly(fly).y(i)).^2);
      isclose(j) = d <= MAXDISTCLOSE;
      if isclose(j)
        break
      end
    end
  end
  islargemajor(fs(~isclose)) = false;
  if ~any(islargemajor), continue; end
  islargemajor = imclose(islargemajor,se);
  [starts,ends] = get_interval_ends(islargemajor);
  for i = 1:length(starts),
    idx = starts(i):ends(i)-1;
    addsequence(fly,'largemajor',idx+dataperfly(fly).firstframe-1,dataperfly(fly).a(idx)-LARGEMAJOR);
  end
end

%% find frames, flies in which the velocity direction and orientation don't
% match

fprintf('detecting orientation-velocity mismatches...\n');

% compute velocity
for fly = 1:nflies,

  if isdummytrx(dataperfly(fly)),
    continue;
  end
  
  if dataperfly(fly).nframes < 3,
    continue;
  end
  dataperfly(fly).dx = (dataperfly(fly).x(3:end) - dataperfly(fly).x(1:end-2))/2;
  dataperfly(fly).dx = [ dataperfly(fly).x(2)-dataperfly(fly).x(1),...
    dataperfly(fly).dx,dataperfly(fly).x(end)-dataperfly(fly).x(end-1)];
  dataperfly(fly).dy = (dataperfly(fly).y(3:end) - dataperfly(fly).y(1:end-2))/2;
  dataperfly(fly).dy = [ dataperfly(fly).y(2)-dataperfly(fly).y(1),...
    dataperfly(fly).dy,dataperfly(fly).y(end)-dataperfly(fly).y(end-1)];
  dataperfly(fly).v = sqrt(dataperfly(fly).dx.^2+dataperfly(fly).dy.^2);
end

if isnan(MINWALKVEL),
  % estimate walking velocity
  v = [];
  for fly = 1:nflies,
    if isdummytrx(dataperfly(fly)),
      continue;
    end
    if dataperfly(fly).nframes < 3, continue; end
    v = [v,dataperfly(fly).v];
  end
  v = log(v);
  mu = mygmm(v',2,'replicates',3);
  MINWALKVEL = mean(exp(mu));
  fprintf('minwalkvel chosen = %f\n',MINWALKVEL);
end

for fly = 1:nflies,
  if isdummytrx(dataperfly(fly)),
    continue;
  end

  if dataperfly(fly).nframes < 3,
    continue;
  end
  velang = atan2(dataperfly(fly).dy,dataperfly(fly).dx);
  err = abs(modrange(velang-dataperfly(fly).theta,-pi,pi));
  isreverse = (dataperfly(fly).v >= MINWALKVEL) & (err > MINANGLEDIFF);
  
  fs = find(isreverse);
  if isempty(fs), continue; end
  isclose = false(size(fs));
  for j = 1:length(fs)
    f = fs(j)+dataperfly(fly).firstframe-1;
    isclose(j) = false;
    i = fs(j);
    for fly2 = 1:nflies,
      if isdummytrx(dataperfly(fly2)),
        continue;
      end
      if fly2 == fly, continue; end
      if (dataperfly(fly2).firstframe > f) || (dataperfly(fly2).endframe < f), continue; end
      i2 = dataperfly(fly2).off+(f);
      d = sqrt((dataperfly(fly2).x(i2) - dataperfly(fly).x(i)).^2 + ...
        (dataperfly(fly2).y(i2) - dataperfly(fly).y(i)).^2);
      isclose(j) = d <= MAXDISTCLOSE;
      if isclose(j)
        break
      end
    end
  end
  isreverse(fs(~isclose)) = false;

  if ~any(isreverse), continue; end  
  isreverse = imclose(isreverse,se);  
  [starts,ends] = get_interval_ends(isreverse);
  for i = 1:length(starts),
    idx = starts(i):ends(i)-1;
    addsequence(fly,'orientvelmismatch',idx+dataperfly(fly).firstframe-1,err(idx)-MINANGLEDIFF);
  end

end

%% make a fake sequence so fixerrors doesn't exit
% if isempty( suspicious )
%    fprintf( 1, '...adding a fake track birth to prevent exit\n' )
%    addsequence( 1, 'birth', 1, 1 );
% end

params = {'minerrjumpfrac',MINERRJUMPFRAC,'closelength',CLOSELENGTH,...
  'minorientchange',MINORIENTCHANGE,...
  'maxmajorfac',MAXMAJORFRAC,'minwalkvel',MINWALKVEL,...
  'matcherrclose',MATCHERRCLOSE,'minanglediff',MINANGLEDIFF};

%% addsequence updates the suspicious data structure
  function addsequence(flies,type,frames,suspiciousness)

    newevent = struct('flies',flies,'type',type,'frames',frames,'suspiciousness',suspiciousness);
    if isempty(suspicious),
      suspicious = newevent;
    else
      suspicious(end+1) = newevent;
    end
    
  end

  function v = isdummytrx(trk)
    v = isnan(trk.firstframe);
  end

end % end main function
