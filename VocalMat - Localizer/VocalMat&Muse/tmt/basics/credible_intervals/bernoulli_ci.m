function [p_map,p_ci,posterior]=f(r,n,p_grid,prior,alpha,plotiness)

% deal w/ args
if nargin<6
  plotiness=0;
end

% get grid features
p_min=p_grid(1);
p_max=p_grid(end);
dp=(p_max-p_min)/(length(p_grid)-1);

%
% calc the Bayesian posterior, and thence the 'credible interval' on p
%
likelihood=p_grid.^r.*...
           (1-p_grid).^(n-r);
posterior_unnormed=likelihood.*prior;

% get the max
[posterior_max,i_max]=max(posterior_unnormed);
p_map=p_grid(i_max);

% get rid of infs in the pdf
posterior_unnormed_finite=posterior_unnormed;
posterior_unnormed_finite(~isfinite(posterior_unnormed))=0;

% calc area
posterior_unnormed_area=dp*trapz(posterior_unnormed_finite);

% normalize, and change NaNs, Infs to zeros
posterior=posterior_unnormed/posterior_unnormed_area;
posterior_finite=posterior;
posterior_finite(~isfinite(posterior))=0;

% plot these
if plotiness>=2
  figure;
  plot(p_grid,posterior);
  title('Posterior PDF');
  xl(0,1);
  xlabel('p');
end

% compute the CDF
posterior_cdf=dp*cumtrapz(posterior_finite);

% plot this
if plotiness>=2
  figure;
  plot(p_grid,posterior_cdf);
  title('Posterior CDF');
  xl(0,1);
  yl(0,1.05);
  xlabel('p');
end

% get rid of repeats in the CDF
[posterior_cdf_trimmed,i]=unique(posterior_cdf);
p_grid_trimmed=p_grid(i);

% set the alpha for CI's
perunitity_of_ci=(1-alpha)                             
percentity_of_ci=100*(1-alpha)

% plot the ci width squared as a function of Fl
Fl_grid=0:0.001:alpha;
ci_width2=...
  bernoulli_interval_size_from_P(Fl_grid,...
                                 p_grid_trimmed,...
                                 posterior_cdf_trimmed,...
                                 perunitity_of_ci);
if plotiness>=2
  figure;
  plot(Fl_grid,ci_width2);
end

% compute the Bayesian 'credible intervals'
% we use the 'shortest interval' method because it doesn't give
% stupid answers when f(0)!=0 or f(1)!=0
options=optimset('MaxFunEvals',1e6);
Fl=fminbnd(@bernoulli_interval_size_from_P,0,alpha,options,...
           p_grid_trimmed,posterior_cdf_trimmed,perunitity_of_ci);
Fu=Fl+perunitity_of_ci 
l=interp1(posterior_cdf_trimmed,p_grid_trimmed,Fl,'linear');
u=interp1(posterior_cdf_trimmed,p_grid_trimmed,Fu,'linear');
p_ci=[l u]

% check that the sol'n covers the right amount of prob mass
% this should equal perunitity_of_ci
perunitity_of_ci_check=interp1(p_grid,posterior_cdf,p_ci(2))-...
                       interp1(p_grid,posterior_cdf,p_ci(1))

% check that the pdf values are approx equal at the CI endpoints
posterior_at_l=interp1(p_grid,posterior,p_ci(1))
posterior_at_u=interp1(p_grid,posterior,p_ci(2))
         
% plot the p estimates and the error bars
% plot these
if plotiness>=1
  figure;
  plot(p_grid,posterior);
  title('Posterior PDF');
  xl(0,1);
  line(p_ci,[0 0],'color',[1 0 0],'linewidth',3);
  line(p_map,0,'color',[1 0 0],'linestyle','none','Marker','o');
  line([p_ci(1) p_ci(1)],[0 posterior_at_l],'color',[1 0 0]);
  line([p_ci(2) p_ci(2)],[0 posterior_at_u],'color',[1 0 0]);
  xlabel('p');

  figure;
  plot(p_grid,posterior_cdf);
  title('Posterior CDF');
  xl(0,1);
  yl(0,1.05);
  line(p_ci,[0 0],'color',[1 0 0],'linewidth',3);
  line(p_map,0,'color',[1 0 0],'linestyle','none','Marker','o');
  line([p_ci(1) p_ci(1)],[0 Fl],'color',[1 0 0]);
  line([p_ci(2) p_ci(2)],[0 Fu],'color',[1 0 0]);
  xlabel('p');
end
