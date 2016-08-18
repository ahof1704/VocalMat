function BW = fnPrv_edgelist2mask(M,N,xe,ye,scale)
%EDGELIST2MASK Convert horizontal edge list to a region mask.
%   BW = EDGELIST2MASK(M,N,XE,YE) converts a edge list, in the
%   form of two vectors XE and YE representing horizontal edge
%   locations on a scaled integer grid, to a logical matrix BW that
%   is nonzero inside the polygon from which the edge list was
%   computed.  The integer grid scale factor is 5.
%
%   BW = EDGELIST2MASK(M,N,XE,YE,SCALE) uses SCALE for the integer
%   grid scale factor instead of 5.  SCALE must be a positive odd
%   integer.

%   Copyright 1993-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2006/10/04 22:38:45 $

if nargin < 5
    scale = 5;
end

shift = (scale - 1)/2;

% Scale x values, throwing away edgelist points that aren't on a pixel's
% center column. 
xe = (xe+shift)/5;
idx = xe == floor(xe);
xe = xe(idx);
ye = ye(idx);

% Scale y values.
ye = ceil((ye + shift)/scale);

% Throw away horizontal edges that are too far left, too far right, or below the image.
bad_indices = find((xe < 1) | (xe > N) | (ye > M));
xe(bad_indices) = [];
ye(bad_indices) = [];

% Treat horizontal edges above the top of the image as they are along the
% upper edge.
ye = max(1,ye);

% Insert the edge list locations into a sparse matrix, taking
% advantage of the accumulation behavior of the SPARSE function.
S = sparse(ye,xe,1,M,N);

% We reduce the memory consumption of edgelist2mask by processing only a
% group of columns at a time (g274577); this does not compromise speed.
BW = false(size(S));
numCols = size(S,2);
columnChunk = 50;
for k = 1:columnChunk:numCols
  firstColumn = k;
  lastColumn = min(k + columnChunk - 1, numCols);
  columns = full(S(:, firstColumn:lastColumn));
  BW(:, firstColumn:lastColumn) = fnPrv_parityscan(columns); 
end