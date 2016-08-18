function trp = load_tracks_in_memory(trp)

% member functions can be weird
for i = 1:length(trp),
  trp(i).off = -trp(i).firstframe + 1;
  trp(i).matname = matname;
end

end
