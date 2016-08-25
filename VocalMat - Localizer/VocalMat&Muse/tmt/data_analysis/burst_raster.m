function f(t_event,t_burst_start,y_span,z)

% process args
if nargin<3
  y_span=[-1 +1];
elseif isempty(y_span)
  y_span=[-1 +1];
end
if nargin<4
  z=0;
elseif isempty(z)
  z=0;
end

% make an array that tells what burst each spike is in
burst_ind=zeros(size(t_event));
n_bursts=length(t_burst_start);
for i=1:n_bursts
  in_or_after_this_burst=t_event>=t_burst_start(i);
  burst_ind(in_or_after_this_burst)= ...
      burst_ind(in_or_after_this_burst)+1;
end

% want to alternate colors red-blue
colors=[1 0 0 ; 0 0 1];

% plot the raster lines
for i=1:length(t_event)
  line([t_event(i) t_event(i)],...
       y_span,...
       [z z],...
       'Color',colors(mod(burst_ind(i),2)+1,:));
end

% turn the plot box on, so it looks like a real plot window
set(gca,'box','on');

