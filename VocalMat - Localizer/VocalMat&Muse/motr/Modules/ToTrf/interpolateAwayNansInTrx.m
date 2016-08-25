function trx=interpolateAwayNansInTrx(trx)

% Looks for nans in the trajectories of trx, interpolates
% to get rid of them

nTracks=length(trx);
isAngular=true;
for k=1:nTracks
  trx(k).x=interpolateAwayNans(trx(k).x);
  trx(k).y=interpolateAwayNans(trx(k).y);
  trx(k).a=interpolateAwayNans(trx(k).a);
  trx(k).b=interpolateAwayNans(trx(k).b);
  trx(k).theta=interpolateAwayNans(trx(k).theta,isAngular);
end

end

