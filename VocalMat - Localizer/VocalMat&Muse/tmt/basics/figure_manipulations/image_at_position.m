function h_im=f(im,im_dpi,offset_im_inches,xalign,yalign,varargin)

% deal w/ args
if nargin<5 || isempty(xalign)
  xalign='left';
end
if nargin<6 || isempty(yalign)
  yalign='bottom';
end

% get dimensions of plotbox (this is tricky because the apparent plotbox don't
%   always fill the true plotbox!)
% actually, this gets the dimensions of the plot box, which is okay since
% that's what I care about
h_probe=text(0,0,'.','visible','off','units','normalized');
set(h_probe,'units','data');
offset_plotbox_data=get(h_probe,'position');  
offset_plotbox_data=offset_plotbox_data(1:2);  % trim z
set(h_probe,'units','inches');
offset_plotbox_inches=get(h_probe,'position');  
offset_plotbox_inches=offset_plotbox_inches(1:2);  % trim z
delete(h_probe);
h_probe=text(1,1,'.','visible','off','units','normalized');
set(h_probe,'units','data');
corner_plotbox_data=get(h_probe,'position');  
corner_plotbox_data=corner_plotbox_data(1:2);  % trim z
set(h_probe,'units','inches');
corner_plotbox_inches=get(h_probe,'position');  
corner_plotbox_inches=corner_plotbox_inches(1:2);  % trim z
delete(h_probe);
sz_plotbox_data=corner_plotbox_data-offset_plotbox_data;
sz_plotbox_inches=corner_plotbox_inches-offset_plotbox_inches;

% calc size of image in data coords
sz_im_inches=[size(im,2) size(im,1)]/im_dpi;
sz_im_data=sz_plotbox_data./sz_plotbox_inches.*sz_im_inches;

% calc offset of image in data coords
offset_im_data=offset_plotbox_data+sz_plotbox_data./sz_plotbox_inches.*offset_im_inches;

% adjust offset, given the alignment mode
if strcmp(lower(xalign),'left')
  offset_im_data_aligned(1)=offset_im_data(1);  
elseif strcmp(lower(xalign),'center')
  offset_im_data_aligned(1)=offset_im_data(1)-sz_im_data(1)/2;
elseif strcmp(lower(xalign),'right')
  offset_im_data_aligned(1)=offset_im_data(1)-sz_im_data(1);
else
  error('xalign not recognized');
end
if strcmp(lower(yalign),'bottom')
  offset_im_data_aligned(2)=offset_im_data(2);  
elseif strcmp(lower(yalign),'center');
  offset_im_data_aligned(2)=offset_im_data(2)-sz_im_data(2)/2;
elseif strcmp(lower(yalign),'top');
  offset_im_data_aligned(2)=offset_im_data(2)-sz_im_data(2);
else
  error('yalign not recognized');
end

% place image in plotbox
axis manual;
h_im=...
  image('Cdata',flipdim(im,1),...
        'XData',[offset_im_data_aligned(1) offset_im_data_aligned(1)+sz_im_data(1)],...
        'YData',[offset_im_data_aligned(2) offset_im_data_aligned(2)+sz_im_data(2)],...
        varargin{:});
