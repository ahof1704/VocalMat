% distanceEllipsePoint      Computes the distances between an ellipse and
%                           an arbitrary number of points (in 3D)
%
% USAGE:
%   [min_dist, f_min] = distanceEllipsePoint(XYZ, a,b,c,u,v)
%
% The input arguments are 
%
% =============================================================
%  name     description                           size
% =============================================================
%   XYZ     array of points                       (Nx3)
%   a       Ellipse's semi-major axis             (1x1)
%   b       Ellipse's semi-minor axis             (1x1)
%   c       Location of Ellipse's center          (1x3)
%   u       Direction of Ellipse's primary axis   (1x3)
%           (unit vector towards [a])             
%   v       Direction of Ellipse's secondary axis (1x3)
%           (unit vector towards [b])             
%
% The output arguments are
% =============================================================
%  name     description                           size
% =============================================================
% min_dist  distances between the points and the  (Nx1)
%           ellipse                 
% f_min     corresponding true anomalies on the   (Nx1)
%           ellipse (-pi <= f <= +pi)         
%
% Based on:
% Ik-Sung Kim: "An algorithm for finding the distance between two 
% ellipses". Commun. Korean Math. Soc. 21 (2006), No.3, pp.559-567

function [min_dist, f_min] = distanceEllipsePoints(XYZ, a,b,c,u,v)
% Author:
% Name       : Rody P.S. Oldenhuis
% E-mail     : oldenhuis@dds.nl / oldenhuis@gmail.com
% Affiliation: Delft University of Technology
%
% please report any bugs or suggestions to oldnhuis@dds.nl.    
    
    % error traps
    assert( any(size(XYZ)==3),'distanceEllipsePoint:points_not_3D',...
            'At least one dimension of the array of points must be equal to 3.'); 
    assert( isscalar(a) && isscalar(b), 'distanceEllipsePoint:ab_not_scalar',...
            'Arguments [a] and [b] must be scalar.');  
    assert( isvector(c) && numel(c)==3, 'distanceEllipsePoint:c_not_3Dvector',...
            'Coordinates of the center [c] must be given as 3-D Cartesian coordinates.');    
    assert( isvector(u) && numel(u)==3, 'distanceEllipsePoint:u_not_3Dvector',...
            'Primary axis [u] must be given as 3-D Cartesian coordinates.');    
    assert( isvector(v) && numel(v)==3, 'distanceEllipsePoint:v_not_3Dvector',...
            'Secondary axis [v] must be given as 3-D Cartesian coordinates.');
        
    % make sure everything is correct shape & size
    c = c(:); u = u(:); v = v(:); XYZ = reshape(XYZ,[],3);    
    
    % make sure [u] and [v] are UNIT-vectors
    if (norm(u) ~= 1), u = u/norm(u); end
    if (norm(v) ~= 1), v = v/norm(v); end
    
    % initialize some variables to speed up computation    
    R = [u, v, cross(u,v)];   % rotation matrix to put ellipse in standard form    
    comp0 = [eye(3),[0;0;0]]; % part of a companion matrix for a quartic     
        
    % initialize output
    min_dist = zeros(size(XYZ,1),1);
    f_min    = min_dist;
    
    % loop through all points in [XYZ]
    for ii = 1:size(XYZ,1)
        
        % find optimal point on the ellipse
        s = R\(XYZ(ii,:).' - c); % transform current point
        A = a*s(1);              % The constants A,B and C follow from the
        B = b*s(2);              % condition dQ/dt = 0, with Q = Q(s,E,t) the
        C = b*b - a*a;           % XY-distance between point s and ellipse E

        % we have to find [t_hat], the true anomaly on the ellipse that minimizes
        % the distance between the associated point on the ellipse [E] and the
        % point [s]. The solution depends on the value of [C]. 
        % If C = 0, the solution is easy:
        if C == 0
            t_hat = atan2(B, A);

        % otherwise, we have to solve a quartic eqution in A,B,C, which is
        % done most quickly by using EIG() on its companion matrix:
        else        
            % associated companion matrix
            comp  = [-2*A/C, -(A*A+B*B-C*C)/C/C, +2*A/C, (A/C)^2; comp0];
            % solve this quartic (real values only)
            Roots = eig(comp);  
            Roots = Roots(imag(Roots)==0);        
            % extract optimal point
            sint1  = sqrt(1 - Roots.^2);    sint2 = -sint1;
            sints  = [sint1, sint2];        costs = [Roots,Roots];
            selld  = (s(1)-a*costs).^2 + (s(2)-b*sints).^2;
            [dummy, tind] = min(selld(:));%#ok
            sinth = sints(tind);            costh = costs(tind); 
            % t_hat
            t_hat = atan2(sinth, costh);

        end

        % compute distance
        min_dist(ii) = sqrt( (s(1)-a*cos(t_hat))^2 + (s(2)-b*sin(t_hat))^2 + s(3)^2 );    
        % insert the optimal thetas
        f_min(ii) = t_hat;
    
    end
    
end % function (Kim's method)
