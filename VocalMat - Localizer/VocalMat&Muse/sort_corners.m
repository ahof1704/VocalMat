function r_corners=sort_corners(r_corners_original)

% Sort the 2x4 list of four corners so that they're in clockwise
% order, starting with the one near the origin
  
r_corners=sortrows(r_corners_original')';  % make sure sorted by x
if (r_corners(2,1)>r_corners(2,2) )
    r_corners(:,1:2)=fliplr(r_corners(:,1:2));
end
if (r_corners(2,3)<r_corners(2,4) )
    r_corners(:,3:4)=fliplr(r_corners(:,3:4));
end

% now they're in clockwise order, starting with the one near the origin

end
