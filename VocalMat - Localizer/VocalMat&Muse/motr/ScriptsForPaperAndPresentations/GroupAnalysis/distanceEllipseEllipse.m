% distanceEllipseEllipse    Computes the distances between two 
%                           arbitrary ellipses (in 3D)
%
% USAGE:
%   [min_dist, fp_min, fs_min] = ...
%       distanceEllipseEllipse(a,b,c,u,v)
%
% The input arguments are 
%
% =============================================================
%  name     description                           size
% =============================================================
%   a       Semi-major axes for both ellipses     (1x2)
%   b       Semi-minor axes for both ellipses     (1x2)
%   c       Locations of ellipse-centers          {(1x3),(1x3)}
%   u       Directions of Ellipse's primary axes  {(1x3),(1x3)}
%           (unit vectors)
%   v       Direction of Ellipse's secondary axis {(1x3),(1x3)}
%           (unit vectors)            
%
% The output arguments are
% =============================================================
%  name     description                           size
% =============================================================
% min_dist  minimum distance between the two      (1x1)  
%           ellipses 
% fp_min    corresponding true anomaly on the     (1x1)
%           "primary" ellipse (-pi <= f <= +pi)         
% fs_min    corresponding true anomaly on the     (1x1)
%           "secondary" ellipse (-pi <= f <= +pi)         
%
% This is a MATLAB-efficient implementation of the algorithm 
% described in:
%
% Ik-Sung Kim: "An algorithm for finding the distance between two 
% ellipses". Commun. Korean Math. Soc. 21 (2006), No.3, pp.559-567
%
%
% See also distanceEllipsePoint.

function [min_dist, fp_min, fs_min] = distanceEllipseEllipse(a,b,c,u,v)
% Author:
% Name       : Rody P.S. Oldenhuis
% E-mail     : oldenhuis@dds.nl / oldenhuis@gmail.com
% Affiliation: Delft University of Technology
%
% please report any bugs or suggestions to oldnhuis@dds.nl.

% ELEMENTARY EXAMPLE:
% 
%  %   Ellipse1   Ellipse2(=circle)
%  a = [2.0       1.0];
%  b = [0.5       1.0];
%  c = {[0,0,0], [-2,2,0]}; % location of centers
%  u = {[1,0,0],  [1,0,0]}; % both oriented in XY-plane
%  v = {[0,1,0],  [0,1,0]}; % to visualize them more easily
% 
%  % plot the ellipses
%  f  = 0:0.01:2*pi;
%  E1 = [a(1)*cos(f) + c{1}(1); b(1)*sin(f) + c{1}(2)];
%  E2 = [a(2)*cos(f) + c{2}(1); b(2)*sin(f) + c{2}(2)];
%  figure, hold on
%  plot(E1(1,:),E1(2,:),'r', E2(1,:),E2(2,:),'b')
%  axis equal
% 
%  % run routine
%  [min_dist, fp_min, fs_min] = ...
%       distanceEllipseEllipse(a,b,c,u,v)
% 
%  % plot the minimum distance returned
%  x = [a(1)*cos(fp_min) + c{1}(1), a(2)*cos(fs_min) + c{2}(1)];
%  y = [b(1)*sin(fp_min) + c{1}(2), b(2)*sin(fs_min) + c{2}(2)];
%  line(x,y,'color', 'k')
% 
    
    % algorithm parameters    
    maxiters = 25;
    tolFun   = 1e-6;
    tolX     = 1e-6;
    
    % error traps
    if (~isvector(a) || ~isvector(b)) || ( numel(a)~=2 || numel(b) ~= 2 )
        error('distanceEllipseEllipse:ab_not_2Dvectors',...
            'Arguments [a] and [b] must be 2-element vectors.')
    end
    if ~iscell(c) || numel(c)~=2 ||~all(cellfun(@(x)numel(x)==3,c))
        error('distanceEllipseEllipse:c_not_cell_or_3Dvector',...
            ['Coordinates of the ellipse-centers [c] must be given as \n',...
             '    two 3-D vectors in a cell-array.'])
    end
    if ~iscell(u) || numel(u)~=2 || ~all(cellfun(@(x)numel(x)==3,u))
        error('distanceEllipseEllipse:u_not_cell_or_3Dvector',...
            ['Primary axes [u] of both ellipses must be given as \n',...
             '    two 3-D unit-vectors in a cell-array.'])
    end
    if ~iscell(v) || numel(v)~=2 || ~all(cellfun(@(x)numel(x)==3,v))
        error('distanceEllipseEllipse:v_not_cell_or_3Dvector',...
            ['Secondary axes [v] of both ellipses must be given as \n',...
             '    two 3-D unit-vectors in a cell-array.'])
    end
    
    % make sure everything is correct shape & size
    c{1} = c{1}(:); u{1} = u{1}(:); v{1} = v{1}(:);
    c{2} = c{2}(:); u{2} = u{2}(:); v{2} = v{2}(:);
    
    % make sure [u] and [v] are UNIT-vectors
    if (norm(u{1}) ~= 1), u{1} = u{1}/norm(u{1}); end
    if (norm(v{1}) ~= 1), v{1} = v{1}/norm(v{1}); end
    if (norm(u{2}) ~= 1), u{2} = u{2}/norm(u{2}); end
    if (norm(v{2}) ~= 1), v{2} = v{2}/norm(v{2}); end
    
    % initialize some variables to speed up computation
    R{1}  = [u{1}, v{1}, cross(u{1},v{1})]; % rotation matrix to put ellipse in standard form
    R{2}  = [u{2}, v{2}, cross(u{2},v{2})]; % rotation matrix to put ellipse in standard form
    comp0 = [eye(3),[0;0;0]];               % part of a companion matrix for a quartic
    
    % initialize output
    min_dist = inf;
    fp_min   = NaN;
    fs_min   = NaN;
    
    % initial values 
    % (4 equally distributed random values)
    f0 = rand + (0:3)*pi/2;
    
    % loop through all four initial values
    for i = 1:4
    
        % initialize some values
        tinit  = f0(i);                  w  = cell(2,1);
        converged  = false;              wt = cell(2,1);
        dmin2  = inf;                    t_hat = [0,0];
        iterations = 0;                  

        % initial point on first ellipse
        w{2}  = [a(2)*cos(tinit); b(2)*sin(tinit); 0]; % std. form
        wt{2} = R{2}*w{2} + c{2};                    % Cartesian coordinates

        % main loop
        while ~converged
            
            % save previous t_hat
            t_hatp = t_hat;

            % swap ellipses continuously
            for j = 1:2

                % find optimal point on the other ellipse
                s = R{j}\(wt{3-j} - c{j});  % transform current point
                A = a(j)*s(1);              % The constants A,B and C follow from the
                B = b(j)*s(2);              %   condition dQ/dt = 0, with Q = Q(s,E,t) the
                C = b(j)^2 - a(j)^2;        %   XY-distance between point s and ellipse E

                % we have to find [t_hat], the true anomaly on the ellipse that minimizes
                % the distance between the associated point on the ellipse [E] and the
                % point [s]. The solution depends on the value of [C].
                % If C = 0 (ellipse = circle), the solution is easy:
                if (C==0)
                    % t_hat
                    t_hat(j) = atan2(B, A);
                    % cos(t_hat), sin(t_hat) (more convenient this way)
                    sinth = sin(t_hat(j));          costh = cos(t_hat(j));

                % otherwise, we have to solve a quartic eqution in A,B,C, which is
                % done most quickly by using EIG() on its companion matrix:
                else

                    % associated companion matrix
                    comp  = [-2*A/C, -(A^2+B^2-C^2)/C^2, 2*A/C, (A/C)^2; comp0];
                    % solve quartic
                    Roots = eig(comp);
                    Roots = Roots(imag(Roots)==0);
                    % extract optimal point
                    sint1  = sqrt(1 - Roots.^2);    sint2 = -sint1;
                    sints  = [sint1, sint2];        costs = [Roots, Roots];
                    selld  = (s(1)-a(j)*costs).^2 + (s(2)-b(j)*sints).^2;
                    [~, tind] = min(selld(:));
                    sinth = sints(tind);            costh = costs(tind);
                    % t_hat
                    t_hat(j) = atan2(sinth, costh);
                end
                
                % get Cartesian coordinates of the corresponding point 
                % on the j-th ellipse
                w{j}  = [a(j)*costh; b(j)*sinth; 0];
                wt{j} = R{j}*w{j} + c{j};

            end % for (ellipse swapper)

            % distance-squared between the current optimal points
            diffvec = wt{1} - wt{2};     % difference vector between the two optimal points
            dmin2p  = dmin2;             % store previous value for convergence check
            dmin2   = diffvec.'*diffvec; % distance is magnitude of difference vector

            % increase iterations
            iterations = iterations + 1;

            % check if no. of iterations is still within bounds. 
            % If not, issue appropriate warning messages
            if (iterations >= maxiters)
                if (i < 4)
                    warning('distanceEllipseEllipse:maxiters_exceeded',...
                        ['Maximum number of iterations was exceeded. \n',...
                        'Continuing with the next initial value...'])
                else
                    warning('distanceEllipseEllipse:maxiters_exceeded',...
                        ['Maximum number of iterations was exceeded, and \n',...
                        'all initial estimates have been exhausted. Exiting...'])
                end
                break
            end

            % check convergence
            if (dmin2 >= dmin2p) || ...            % distance must DECREASE every iteration
               (abs(dmin2-dmin2p) < tolFun) || ... % diff. between two consecutive distances is smaller than TolFun
                all(abs(t_hatp-t_hat) < tolX)      % diff. between two consecutive true anomalies is smaller than TolFun
                converged = true; 
            end

        end % algorithm while-loop 
        
        % compute the real distance. If this is less than the stored value,
        % replace all corresponding entries
        new_distance = sqrt(dmin2);
        if (new_distance < min_dist)
            min_dist = new_distance;
            fp_min = t_hat(1);
            fs_min = t_hat(2);
        end
    
    end % for all initial values
    
end % function (Kim's method)