function trx=trxFromShayTrack(astrctTrackers)

% Convert a Shay-style astrctTrackers structure array to a
% Ctrax/Jaaba-style trx structure array

n_mice=length(astrctTrackers);
n_t=length(astrctTrackers(1).m_afX);
trx=struct('firstframe',cell(n_mice,1), ...
           'endframe',cell(n_mice,1), ...
           'nframes',cell(n_mice,1), ...
           'x',cell(n_mice,1), ...
           'y',cell(n_mice,1), ...
           'theta',cell(n_mice,1), ...
           'a',cell(n_mice,1), ...
           'b',cell(n_mice,1));           
for k=1:n_mice
  trx(k).firstframe=1;
  trx(k).endframe=n_t;
  trx(k).nframes=n_t;
  trx(k).x=astrctTrackers(k).m_afX;
  trx(k).y=astrctTrackers(k).m_afY;
  trx(k).a=astrctTrackers(k).m_afA/2;  % convert to quarter-major
  trx(k).b=astrctTrackers(k).m_afB/2;  % convert to quarter-minor
  trx(k).theta=-astrctTrackers(k).m_afTheta;  % trx files use a different (and probably better) theta convention
end

end
