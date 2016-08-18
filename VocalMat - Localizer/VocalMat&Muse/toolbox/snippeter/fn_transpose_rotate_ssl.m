function [ so ] = fn_transpose_rotate_ssl( theta,mouse_head,ssl )
%UNTITLED Summary of this function goes here
%   vars in:
%       theta in radians;
%       mouse_head location
%       sound_source_location
%
so = zeros(size(ssl));
for i = 1:size(theta,2)
    this_theta = theta(1,i);
    %mouse head center point and will rotate around center    
    center = mouse_head(:,i);
    % x & y coord of sound source localization
    v = ssl(:,i);
    if v(1,1) ~= -69;
        R = [cos(this_theta) -sin(this_theta); sin(this_theta) cos(this_theta)];
        
        % define the x- and y-data for the original line we would like to rotate
        mouse_head_x = 2;
        mouse_head_y = 2;
        
        s = v - center; % shift points in the plane so that the center of rotation is at the origin
        so(:,i) = R*s; % apply the rotation about the origin
    else
        so(:,i) = v;
    end
        
    %make a plot
%     h = figure;
%     ha = gca;
%     scatter(center(1), center(2), 5,'k','filled')
%     hold on
%     scatter(v(1),v(2),5,'g','filled');
%     
%     scatter(so(1), so(2), 5,'r','filled');
%     scatter(s(1),s(2),5,'b','filled');
%     axis equal
%     % set(ha,'markersize',5)
%     
%     xlim([-2 6])
%     ylim([-2 6])
end



