function [c_algcsqr,c_algcsqr_se]=algcsqr_se_jackknife(c,c_taos)

% c is n_t x n_signals
% c_taos is n_t x n_signals x n_tapers

n_t=size(c,1);
n_signals=size(c,2);
n_tapers=size(c_taos,3);

c_algcsqr=antilogistic(c.^2);
c_taos_algcsqr=antilogistic(c_taos.^2);
c_taos_algcsqr_mean=mean(c_taos_algcsqr,3);  % mean across TAOs
c_algcsqr_se=...
  sqrt((n_tapers-1)/n_tapers*...
         sum((c_taos_algcsqr-...
              repmat(c_taos_algcsqr_mean,[1 1 n_tapers])).^2,3));
