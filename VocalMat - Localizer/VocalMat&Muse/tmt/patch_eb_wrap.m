function patch_h = patch_eb_wrap(x,y,y_eb,y_lim,c,varargin)

% plots an angular error bar as a number of patch objects.  Usually used
% in conjunction with line_wrap()

% calc simple functions of the wrap limits
y_lo=y_lim(1);
y_hi=y_lim(2);
y_span=y_hi-y_lo;

% break into segments
[x_seg,~,y_eb_wrapped_seg]=...
  break_at_wrap_points(x,y,y_lim,y_eb);
n_seg=length(x_seg);

% for each seg, draw the error bar patch
patch_h=zeros(0,1);
for i=1:n_seg
  patch_h_1=...
    patch_eb(x_seg{i},y_eb_wrapped_seg{i}       ,c,varargin{:});
  patch_h_2=...
    patch_eb(x_seg{i},y_eb_wrapped_seg{i}-y_span,c,varargin{:});
  patch_h_3=...
    patch_eb(x_seg{i},y_eb_wrapped_seg{i}+y_span,c,varargin{:});
  patch_h=[patch_h;patch_h_1;patch_h_2;patch_h_3];
end
