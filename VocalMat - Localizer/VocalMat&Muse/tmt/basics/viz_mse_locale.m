function f(theta,mse,theta_values,mse_values,index_labels,same_ylim,yl)

% theta is a col vector
% theta_values is n_parameters by n_samples
% mse_values is n_parameters by n_samples
% n_samples reflects the 'grain' of the perturbations

if nargin<6
  same_ylim=false;
end
if nargin<7
  yl=[];
end

n_parameters=length(theta);
n_samples=size(theta_values,2);
%perturbation_mag=...
%  (theta_values(1,n_samples)-theta_values(1,1))/...
%  (theta_values(1,n_samples)+theta_values(1,1));
max_mse_value=max(mse_values(:));
% theta values
%for i=1:n_parameters
%  figure;
%  plot(theta_values(i,:),mse_values(i,:));
%  title_string=sprintf('theta(%d)',i);
%  title(title_string);
%  xlim([min(theta_values(i,:))...
%        max(theta_values(i,:))]);
%  y_min=min(mse_values(i,:)); y_max=max(mse_values(i,:));
%  y_mid=(y_max+y_min)/2; y_span=y_max-y_min;
%  y_min=y_mid-1.1*y_span/2; y_max=y_mid+1.1*y_span/2;
%  ylim([y_min y_max]);
%  xlabel(sprintf('theta(%d) value',i));
%  ylabel('MSE (mV\^2)');
%end
% dimensions for the big collage
w=sqrt(n_parameters);
w_fl=floor(w);
if w_fl*w_fl>=n_parameters
    w=w_fl; h=w_fl;
elseif w_fl*(w_fl+1)>=n_parameters
    w=w_fl+1; h=w_fl;
else
    w=w_fl+1; h=w_fl+1;
end
% calc common ylims, if necessary
if same_ylim && isempty(yl)
  y_min=min(mse_values(:));
  y_max=max(mse_values(:));
  y_mid=(y_max+y_min)/2; y_span=y_max-y_min;
  if y_span==0
    if y_mid==0
      y_span=1;
    else
      y_span=0.2*abs(y_mid);
    end
  end
  y_min=y_mid-1.1*y_span/2; y_max=y_mid+1.1*y_span/2;
  yl=[y_min y_max];
end    
% draw it
figure;
k=1;
for i=1:h
    for j=1:w
        if k<=n_parameters
            subplot(h,w,k);
            plot(theta_values(k,:),mse_values(k,:));
            hold on;
            plot(theta(k),mse,'o');
            hold off;
            title_string=index_labels{k};  % sprintf('%d',k);
            title(title_string,'interpreter','none');
            xlim([min(theta_values(k,:))...
                  max(theta_values(k,:))]);
            if same_ylim
              ylim(yl);
            else
              y_min=min(mse_values(k,:)); y_max=max(mse_values(k,:));
              y_mid=(y_max+y_min)/2; y_span=y_max-y_min;
              if y_span==0
                if y_mid==0
                  y_span=1;
                else
                  y_span=0.2*abs(y_mid);
                end
              end
              y_min=y_mid-1.1*y_span/2; y_max=y_mid+1.1*y_span/2;
              ylim([y_min y_max]);
            end
            k=k+1;
        end
    end
end
drawnow;