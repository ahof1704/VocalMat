function r=lateration_nr2_jpn_3d(dtx,M,v,R,r_guess, ...
                         verbosity)

% Uses the Newton-Raphson argorithm to solve the lateration problem.                              
                              
% deal with args
if nargin<6 || isempty(verbosity)
   verbosity=0;
end

% NaN's in dtx count as "I don't know"s.  Delete the corresponding rows of
% M and dtx and proceed.
known=~isnan(dtx);
M=M(known,:);
dtx=dtx(known);

% unmix the times
dt=pinv(M)*dtx;  % the dt elements will sum to zero

% translate times to distances
dd=v*dt;
%dd_sum=sum(dd)

% use Newton-Raphson to solve
F_threshold=1e-4;  % m
n_iter_max=10000;
r=r_guess;
if verbosity>0
  line(r(1),r(2),'marker','.','color','r')
end
for i=1:n_iter_max
   [F,J]=FJ_lateration_jpn_3d(r,R,dd,v);
   if max(abs(F))<F_threshold
       break;
   end
   %dr=pinv(J)*(-F);
   dr=J\(-F);
   r=r+dr;
   if verbosity>0
     line(r(1),r(2),'marker','.','color','r')
   end
end
if max(abs(F))>=F_threshold
   warning('Final error is above threshold.');
end


end
