function f(event_times,color,y_span,z)

% process args
if nargin<2
  color=[0 0 0];
elseif isempty(color)
  color=[0 0 0];
end
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

% draw the raster lines
for i=1:length(event_times)
  line([event_times(i) event_times(i)],...
       y_span,...
       [z z],...
       'Color',color);
end

% turn the plot box on, so it looks like a real plot window
set(gca,'box','on');

