function trx = addOffsetsToTracks(trx)

for i = 1:length(trx),
  trx(i).off = -trx(i).firstframe + 1;
  %trx(i).matname = matname;
end

end
