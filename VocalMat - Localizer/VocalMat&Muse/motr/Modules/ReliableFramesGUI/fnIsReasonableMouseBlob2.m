function [bReasonable] = fnIsReasonableMouseBlob2(strctEllipse)
%
%Copyright (c) 2008 Shay Ohayon, California Institute of Technology. 
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

fMajorAxisMax = 55;
fMajorAxisMin = 18;
fMinorAxisMin = 10;
fMinorAxisMax = 23;

fMajorAxis = strctEllipse.m_fA;
fMinorAxis = strctEllipse.m_fB;
bReasonable =  ~isnan(fMajorAxis) && ~isnan(fMinorAxis) && ...
              (fMajorAxis < fMajorAxisMax && fMajorAxis > fMajorAxisMin && ...
               fMinorAxis <   fMinorAxisMax && fMinorAxis > fMinorAxisMin);
return;