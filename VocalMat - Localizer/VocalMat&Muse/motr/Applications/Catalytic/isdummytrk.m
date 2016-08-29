function v = isdummytrk(trk)

v = any(isnan(trk.x));
% if v, fprintf( 1, '%d of %d are NaN\n', length(find(isnan(trk.x))), length(trk.x) ); end %%%%%%%%
