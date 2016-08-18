function H = tightsubplot(varargin)
% TIGHTSUBPLOT  Tiles axes without wasting space
%   H = TIGHTSUBPLOT(K,P) returns an handle to the P-th axis in a
%   regular grid of K axes. The K axes are numbered from left to right
%   and from top to bottom.  The function operates similarly to
%   SUBPLOT(), but by default it does not put any margin between axes.
%
%   H = TIGHTSUBPLOT(M,N,P) retursn an handle to the P-th axes in a
%   regular subdivision with M rows and N columns.
%
%   The function accepts the following option-value pairs:
%
%   'Spacing' [0]
%     Set extra spacing between axes.  The space is added between the
%     inner or outer boxes, depending on the setting below.
%
%   'Box' ['inner'] (** ONLY >R14 **)
%     If set to 'outer', the function displaces the axes by their
%     outer box, thus protecting title and labels. Unfortunately
%     MATLAB typically picks unnecessarily large insets, so that a bit
%     of space is wasted in this case.  If set to 'inner', the
%     function uses the inner box. This causes the instets of nearby
%     axes to overlap, but it is very space conservative.
%
%   REMARK. While SUBPLOT kills any pre-existing axes that overalps a
%   new one, this function does not.
%
%   See also SUBPLOT().

% AUTORIGHTS
% Copyright (c) 2006 The Regents of the University of California.
% All Rights Reserved.
%
% Created by Andrea Vedaldi
% UCLA Vision Lab - Department of Computer Science
%
% Permission to use, copy, modify, and distribute this software and its
% documentation for educational, research and non-profit purposes,
% without fee, and without a written agreement is hereby granted,
% provided that the above copyright notice, this paragraph and the
% following three paragraphs appear in all copies.
%
% This software program and documentation are copyrighted by The Regents
% of the University of California. The software program and
% documentation are supplied "as is", without any accompanying services
% from The Regents. The Regents does not warrant that the operation of
% the program will be uninterrupted or error-free. The end-user
% understands that the program was developed for research purposes and
% is advised not to rely exclusively on the program for any reason.
%
% This software embodies a method for which the following patent has
% been issued: "Method and apparatus for identifying scale invariant
% features in an image and use of same for locating an object in an
% image," David G. Lowe, US Patent 6,711,293 (March 23,
% 2004). Provisional application filed March 8, 1999. Asignee: The
% University of British Columbia.
%
% IN NO EVENT SHALL THE UNIVERSITY OF CALIFORNIA BE LIABLE TO ANY PARTY
% FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES,
% INCLUDING LOST PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND
% ITS DOCUMENTATION, EVEN IF THE UNIVERSITY OF CALIFORNIA HAS BEEN
% ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. THE UNIVERSITY OF
% CALIFORNIA SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT
% LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
% A PARTICULAR PURPOSE. THE SOFTWARE PROVIDED HEREUNDER IS ON AN "AS IS"
% BASIS, AND THE UNIVERSITY OF CALIFORNIA HAS NO OBLIGATIONS TO PROVIDE
% MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
parent = gcf;
sp=0.0 ;
use_outer=0 ;

% --------------------------------------------------------------------
%                                                      Parse arguments
% --------------------------------------------------------------------
K=varargin{1} ;
p=varargin{2} ;
N = ceil(sqrt(K)) ;
M = ceil(K/N) ;

a=3 ;
NA = length(varargin) ;
if NA > 2
  if isa(varargin{3},'char')
    % Called with K and p
  else
    % Called with M,N and p
    a = 4 ;
    M = K ;
    N = p ;
    p = varargin{3} ;
  end
end

for a=a:2:NA
  switch varargin{a}
    case 'Spacing'
      sp=varargin{a+1} ;
      case 'Parent'
          parent = varargin{a+1} ;
    case 'Box'
      switch varargin{a+1}
        case 'inner'
          use_outer = 0 ;
        case 'outer'
  if ~strcmp(version('-release'), '14')
          %warning(['Box option supported only on MATALB 14']) ;
    continue;
  end
        use_outer = 1 ;
        otherwise
          error(['Box is either ''inner'' or ''outer''']) ;
      end
    otherwise
      error(['Uknown parameter ''', varargin{a}, '''.']) ;
  end
end

% --------------------------------------------------------------------
%                                                  Check the arguments
% --------------------------------------------------------------------

[j,i]=ind2sub([N M],p) ;
i=i-1 ;
j=j-1 ;

dt = sp/2 ;
db = sp/2 ;
dl = sp/2 ;
dr = sp/2 ;

pos = [  j*1/N+dl,...
       1-i*1/M-1/M+dt,...
       1/N-dl-dr,...
       1/M-dt-db] ;

switch use_outer
  case 0
    H = findobj(gcf, 'Type', 'axes', 'Position', pos) ;
    if(isempty(H))
      H = axes('Position', pos,'parent',parent) ;
    else
      axes(H) ;
    end

  case 1
    H = findobj(gcf, 'Type', 'axes', 'OuterPosition', pos) ;
    if(isempty(H))
      H = axes('ActivePositionProperty', 'outerposition',...
               'OuterPosition', pos,'parent',parent) ;
    else
      axes(H) ;
    end
end
