h = figure(1);
psname = 'Options882.ps';
iKFnum = length(acOption);
for i=1:iKFnum
   l(i) = length(acOption{i}.afMaxCorr);
end
[sl, il] = sort(l, 'descend');
iKFnum = sum(l==3);
acOption = acOption(il);
acFrame = acFrame(il);
for p=1:ceil(iKFnum/3)
   clf;
   for k=p*3-2:min(iKFnum,p*3)
      fnShowOptions(acOption{k}, acFrame{k}, k-3*p+3);
   end
   if p==1
      print (h, '-dpsc2', psname );
   else
      print (h, '-dpsc2', psname, '-append' );
   end
end

