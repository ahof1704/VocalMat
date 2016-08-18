function [fig_h,axes_hs]= ...
  figure_objective_map_per_pair_grid(x_grid,y_grid,objective_grid_per_pair, ...
                                     color_function, ...
                                     color_limits, ...
                                     clr_mike, ...
                                     clr_anno, ...
                                     r_est,r_cr, ...
                                     R,r_head,r_tail)

% deal with args
%abs_max=max(max(abs(rsrp_per_pair_grid_normed(:,:,i_pair))));                                 

% get dimensions
n_mics=size(R,2);                               
[~,iMicFirst,iMicSecond]=mixing_matrix_from_n_mics(n_mics);
n_pairs=length(iMicFirst);

% set up the figure and place all the axes                                   
w_fig=332/72; % in
h_fig=332/72; % in
n_row=n_mics-1;
n_col=n_mics-1;
w_axes=1.2;  % in
h_axes=1.2;  % in
w_space=0.05;  % in
h_space=0.05;  % in                              
[fig_h,axes_hs]=layout_axes_grid(w_fig,h_fig,...
                                 n_row,n_col,...
                                 w_axes,h_axes,...
                                 w_space,h_space);
set(fig_h,'color','w');                               
set(axes_hs,'visible','off');
set(axes_hs,'fontsize',7);

% % extrapolate a mouse ellipse
% r_center=(r_head+r_tail)/2;
% a_vec=r_head-r_center;  % vector
% b=norm(a_vec)/3;  % scalar, and a guess at the half-width of the mouse

for i_pair=1:n_pairs
  iMicThis=iMicFirst(i_pair);
  jMicThis=iMicSecond(i_pair);
  axes_h_this=axes_hs(iMicThis,jMicThis-1);
%   title_str_this=sprintf('%s Mic pair %d,%d', ...
%                          title_str_prefix,iMicThis,jMicThis);
  title_str_this='';
  place_objective_map_in_axes(axes_h_this, ...
                              x_grid,y_grid,objective_grid_per_pair(:,:,i_pair), ...
                              color_function, ...
                              color_limits, ...
                              title_str_this, ...
                              clr_mike, ...
                              clr_anno, ...
                              r_est,r_cr, ...
                              R,r_head,r_tail);
  % delete the axis labels                            
  h=ylabel(axes_h_this,'');
  delete(h);
  h=xlabel(axes_h_this,'');
  delete(h);
  % the bottom corner is special
  if (iMicThis==n_mics-1) && (jMicThis==n_mics) ,
    set(axes_h_this,'xtick',[40 60]);
    set(axes_h_this,'ytick',[]);  
    colorbar_handle=add_colorbar(axes_h_this,0.1,0.075);
    set(colorbar_handle,'fontsize',7);
    % ylabel(colorbar_handle,'Corr Coeff');
  else
    set(axes_h_this,'xtick',[]);  
    set(axes_h_this,'ytick',[]);  
    set(axes_h_this,'xticklabel',{});
  end    
  % If in top row, add Mic label for col
  if iMicThis==1 ,
    title(axes_h_this,sprintf('Mic %d',jMicThis),'fontsize',7);
  end
  % If just above diag, add mic label for row
  if iMicThis+1==jMicThis ,
    ylabel(axes_h_this,sprintf('Mic %d',iMicThis));
  end
  set(axes_h_this,'visible','on');
end  

end
