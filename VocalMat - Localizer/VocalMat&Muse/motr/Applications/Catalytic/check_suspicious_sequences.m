function [seqs,params] = check_suspicious_sequences(dataperfly,annname,seqs,varargin)

[MINERRJUMPFRAC,CLOSELENGTH,MINORIENTCHANGE,MAXMAJORFRAC,MINWALKVEL,MATCHERRCLOSE,...
  MINANGLEDIFF] = ...
  myparse(varargin,'minerrjumpfrac',.2,'closelength',20,'minorientchange',pi/4,...
  'maxmajorfac',2,'minwalkvel',1,'matcherrclose',10,'minanglediff',pi/2);

%% input data
nframes = max(getstructarrayfield(dataperfly,'endframe'));
nseqs = length(seqs);

%% read parameters
[center_dampen,angle_dampen,max_jump,maxmajor,meanmajor,vel_angle_wt,ang_dist_wt] = ...
  read_ann(annname,'center_dampen','angle_dampen','max_jump','maxmajor','meanmajor',...
  'velocity_angle_weight','ang_dist_wt');
MINERRJUMP = MINERRJUMPFRAC*max_jump;
LARGEMAJOR = meanmajor + MAXMAJORFRAC * (maxmajor-meanmajor);

%% make sure flies haven't been deleted
for s = 1:nseqs,
   if ~isempty( strfindi( seqs(s).type, 'dummy' ) ), continue; end
  isdeleted = false;
  for fly = seqs(s).flies,
    if any(isnan(dataperfly(fly).x))
      isdeleted = true;
      break;
    end
  end
  if isdeleted
    seqs(s).type = ['dummy', seqs(s).type];
  end
end

%% find births of tracks in the middle of the movie
for s = 1:nseqs,
  if strcmpi(seqs(s).type,'birth')
    fly = seqs(s).flies;
    if dataperfly(fly).firstframe ~= seqs(s).frames
      if dataperfly(fly).firstframe == 1
        seqs(s).type = ['dummy', seqs(s).type];
      else
        seqs(s).frames = dataperfly(fly).firstframe;
      end
    end
  end
end

%% find deaths of tracks in the middle of the movie
for s = 1:nseqs,
  if strcmpi(seqs(s).type,'death')
    fly = seqs(s).flies;
    if dataperfly(fly).endframe ~= seqs(s).frames
      if dataperfly(fly).endframe == nframes
         seqs(s).type = ['dummy', seqs(s).type];;
      else
        seqs(s).frames = dataperfly(fly).endframe;
      end
    end
  end
end

%% make sure flies are alive in some frame
for s = 1:nseqs,
  if any(strcmpi(seqs(s).type,{'dummy','death','birth'})), continue; end
  f = seqs(s).frames;
  for fly = seqs(s).flies;
    isalive = f >= dataperfly(fly).firstframe & f <= dataperfly(fly).endframe;
    if ~any(isalive)
       seqs(s).type = ['dummy', seqs(s).type];;
      break;
    end
  end
end

%% shorten seqs to be where flies are alive

for s = 1:nseqs,
  flies = seqs(s).flies;
  frames = seqs(s).frames;
  badidx = false(1,length(frames));
  for j = 1:length(flies),
    badidx = badidx | frames < dataperfly(flies(j)).firstframe | ...
      frames > dataperfly(flies(j)).endframe;
  end
  if all(badidx),
     seqs(s).type = ['dummy', seqs(s).type];;
  else
    seqs(s).frames = seqs(s).frames(~badidx);
  end
end

%% find frames, flies where the fly jumps

for s = 1:nseqs
  if ~strcmpi(seqs(s).type,'jump'), continue; end
  fly = seqs(s).flies;
  f = seqs(s).frames;
  i = dataperfly(fly).off+(f);
  [xpred,ypred] = predcenter(fly,f);
  % error of prediction
  err = sqrt((xpred - dataperfly(fly).x(i)).^2 + (ypred - dataperfly(fly).y(i)).^2);
  if ~any(err > MINERRJUMP)
    seqs(s).type = ['dummy', seqs(s).type];;
  else
    i0 = find(err>MINERRJUMP,1);
    i1 = find(err>MINERRJUMP,1,'last');
    seqs(s).frames = dataperfly(fly).firstframe-1 + i(i0:i1);
  end
end


%% find frames, flies where there is a large change in orientation

for s = 1:nseqs
  if ~strcmpi(seqs(s).type,'orientchange'), continue; end
  fly = seqs(s).flies;
  f = seqs(s).frames;
  i = dataperfly(fly).off+(f);
  thetapred = predtheta(fly,f);
  % error of prediction
  err = abs(modrange(dataperfly(fly).theta(i)-thetapred,-pi,pi));
  if ~any(err > MINORIENTCHANGE)
    seqs(s).type = ['dummy', seqs(s).type];;
  else
    i0 = find(err>MINORIENTCHANGE,1);
    i1 = find(err>MINORIENTCHANGE,1,'last');
    seqs(s).frames = dataperfly(fly).firstframe-1 + i(i0:i1);
  end
end

%% find frames, pairs of flies in which there is another assignment of identity to
% observation with near optimal value

for s = 1:nseqs,
  if ~strcmpi(seqs(s).type,'swap'), continue; end
  flies = seqs(s).flies;
  fs = seqs(s).frames;
  seqs(s).frames = fs;

  isswap = false(size(fs));
  % loop through frames
  for f = fs,
    % get predicted and observed positions of all flies in the current frame
    xpred = zeros(1,2);
    ypred = zeros(1,2);
    thetapred = zeros(1,2);
    xcurr = xpred;
    ycurr = ypred;
    thetacurr = thetapred;
    for j = 1:2,
      ii = dataperfly(flies(j)).off+(f);
      [xpred(j),ypred(j)] = predcenter(flies(j),f);
      thetapred(j) = predtheta(flies(j),f);
      xcurr(j) = dataperfly(flies(j)).x(ii);
      ycurr(j) = dataperfly(flies(j)).y(ii);
      thetacurr(j) = dataperfly(flies(j)).theta(ii);
    end  
    
    % compute all pairs distances
    dcenter = dist2([xpred',ypred'],[xcurr',ycurr']);
    dtheta = modrange(repmat(thetacurr,[length(thetapred),1])-repmat(thetapred',[1,length(thetacurr)]),-pi,pi).^2;
    d = sqrt(dcenter + dtheta*ang_dist_wt);
    % compute optimal
    dopt = sum(diag(d));
  
    % compute swap
    i1 = 1;
    i2 = 2;
    dcurr = dopt - d(i1,i1) - d(i2,i2) + d(i1,i2) + d(i2,i1);
    err = dopt + MATCHERRCLOSE - dcurr;
    
    isswap(f-fs(1)+1) = err > 0;
  end
  
  if ~any(isswap)
    seqs(s).type = ['dummy', seqs(s).type];;
  else
    i0 = find(isswap,1);
    i1 = find(isswap,1,'last');
    seqs(s).frames = fs(i0:i1);
  end
  
end

%% find frames, flies in which the major axis length is large
for s = 1:nseqs
  if ~strcmpi(seqs(s).type,'largemajor'), continue; end
  fly = seqs(s).flies;
  f = seqs(s).frames;
  i = dataperfly(fly).off+(f);
  islargemajor = dataperfly(fly).a(i) > LARGEMAJOR;
  if ~any(islargemajor),
    seqs(s).type = ['dummy', seqs(s).type];;
  else
    i0 = find(islargemajor,1);
    i1 = find(islargemajor,1,'last');
    seqs(s).frames = dataperfly(fly).firstframe+i(i0:i1)-1;
  end
end

%% find frames, flies in which the velocity direction and orientation don't
% match

% compute velocity
for s = 1:nseqs,
  if ~strcmpi(seqs(s).type,'orientvelmismatch'), continue; end
  fly = seqs(s).flies;  
  if dataperfly(fly).nframes < 3,
    continue;
  end
  f = seqs(s).frames;
  i = sort(dataperfly(fly).off+(f));
  if i(1) == 1, i0 = 2; else i0 = 1; end
  if i(end) == dataperfly(fly).nframes, i1 = length(i)-1; else i1 = length(i); end
  dx = (dataperfly(fly).x(i(i0:i1)+1) - dataperfly(fly).x(i(i0:i1)-1))/2;
  dy = (dataperfly(fly).y(i(i0:i1)+1) - dataperfly(fly).y(i(i0:i1)-1))/2;
  if i(1) == 1,
    dx = [dataperfly(fly).x(2)-dataperfly(fly).x(1),dx];
    dy = [dataperfly(fly).y(2)-dataperfly(fly).y(1),dy];
  end
  if i(end) == dataperfly(fly).nframes,
    dx = [dx,dataperfly(fly).x(end)-dataperfly(fly).x(end-1)];
    dy = [dy,dataperfly(fly).y(end)-dataperfly(fly).y(end-1)];
  end
  v = sqrt(dx.^2+dy.^2);
  velang = atan2(dy,dx);
  err = abs(modrange(velang-dataperfly(fly).theta(i),-pi,pi));
  isreverse = (v >= MINWALKVEL) & (err > MINANGLEDIFF);
  if ~any(isreverse), 
    seqs(s).type = ['dummy', seqs(s).type];;
    seqs(s).suspiciousness = 0;
  else
    i0 = find(isreverse,1);
    i1 = find(isreverse,1,'last');
    seqs(s).suspiciousness = err(i0:i1)-MINANGLEDIFF;
    seqs(s).frames = dataperfly(fly).firstframe+i(i0:i1)-1;
  end
end

params = {'minerrjumpfrac',MINERRJUMPFRAC,'closelength',CLOSELENGTH,...
  'minorientchange',MINORIENTCHANGE,...
  'maxmajorfac',MAXMAJORFRAC,'minwalkvel',MINWALKVEL,...
  'matcherrclose',MATCHERRCLOSE,'minanglediff',MINANGLEDIFF};

  function [xpred,ypred] = predcenter(fly,f)
  
    i = dataperfly(fly).off+(f);
    xpred = zeros(size(f));
    ypred = zeros(size(f));
    if any(i < 3),
      xpred(i<3) = dataperfly(fly).x(1);
      ypred(i<3) = dataperfly(fly).y(1);
    end
    xpred(i>=3) = (1+center_dampen)*dataperfly(fly).x(i(i>=3)-1) - center_dampen*dataperfly(fly).x(i(i>=3)-2);
    ypred(i>=3) = (1+center_dampen)*dataperfly(fly).y(i(i>=3)-1) - center_dampen*dataperfly(fly).y(i(i>=3)-2);

  end

  function thetapred = predtheta(fly,f)

    i = dataperfly(fly).off+(f);
    thetapred = zeros(size(f));
    if any(i) < 3,
      thetapred(i<3) = dataperfly(fly).theta(1);
    end
    dtheta = modrange(dataperfly(fly).theta(i(i>=3)-1) - dataperfly(fly).theta(i(i>=3)-2),-pi,pi);
    thetapred(i>=3) = angle_dampen*dtheta + dataperfly(fly).theta(i(i>=3)-1);
 
  end
  
end % end main function
