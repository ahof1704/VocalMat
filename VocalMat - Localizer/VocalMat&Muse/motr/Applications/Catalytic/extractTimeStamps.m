function timeStamps=extractTimeStamps(trx,nFrames)

timeStamps = nan(1,nFrames);
for i = 1:numel(trx),
  if isdummytrk( trx(i) ), continue, end
  t0 = trx(i).firstframe;
  t1 = trx(i).endframe;
  if isempty( trx(i).timestamps ) && ~isempty( t0 )
     timeStamps(t0:t1) = (t0:t1)/trx(i).fps;
  else
     if any(~isnan(timeStamps(t0:t1)) & ...
            (trx(i).timestamps ~= timeStamps(t0:t1))),
       error('Timestamps don''t match for fly %d',i);
     end
     timeStamps(t0:t1) = trx(i).timestamps;
  end
end
nan_ind = find( isnan( timeStamps ) );
if ~isempty( nan_ind ) && length( nan_ind ) ~= length( timeStamps )
   t0 = nan_ind(1);
   t1 = nan_ind(1);
   for f = 2:length( nan_ind )
      if nan_ind(f) ~= t0 + 1 % not consecutive
         t1 = nan_ind(f - 1);
         v = (1:(t1 - t0 + 1))/trx(1).fps;
         timeStamps(t0:t1) = timeStamps(t1 + 1) - v(end:-1:1);
         t0 = nan_ind(f);
      end
   end
   if t1 <= t0
      t1 = nan_ind(end);
      v = (1:(t1 - t0 + 1))/trx(1).fps;
      timeStamps(t0:t1) = timeStamps(t0 - 1) + v;
   end
end

end
