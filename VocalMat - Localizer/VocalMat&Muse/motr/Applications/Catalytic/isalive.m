function v = isalive(track,f)

v = ~isdummytrk(track) && track.firstframe <= f && track.endframe >= f;
% if isdummytrk(track), fprintf( 1, 'track at frame %d is dummy\n', f ); end %%%%%%%
