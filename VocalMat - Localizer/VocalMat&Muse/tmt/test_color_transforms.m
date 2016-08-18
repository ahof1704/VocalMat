color_sRGB=[0 1 1 0 0 0 1 1 ; ...
            0 0 1 1 1 0 0 1 ; ...
            0 0 0 0 1 1 1 1 ]'

color_rXYZ=srgb2xyz(color_sRGB)

denoms=sum(color_rXYZ,2);
color_xyz=color_rXYZ./repmat(denoms,[1 3])
% these values check

color_sRGB_check=xyz2srgb(color_rXYZ)
% this checks

% now test the conversion to rLab
color_rLab=xyz2lab(color_rXYZ)
% this looks right

% check the inverse
color_rXYZ_check=lab2xyz(color_rLab)
% this checks

% plot in the chromaticity plane
figure;
plot(color_xyz(2,1),color_xyz(2,2),'ro',...
     color_xyz(3,1),color_xyz(3,1),'yo',...
     color_xyz(4,1),color_xyz(4,2),'go',...
     color_xyz(5,1),color_xyz(5,2),'co',...
     color_xyz(6,1),color_xyz(6,2),'bo',...
     color_xyz(7,1),color_xyz(7,2),'mo',...
     color_xyz(8,1),color_xyz(8,2),'ko');
xl(0,1);
yl(0,1);
axis square;

% plot in XYZ space
figure;
plot3(color_rXYZ(2,1),color_rXYZ(2,2),color_rXYZ(2,3),'ro',...
      color_rXYZ(3,1),color_rXYZ(3,2),color_rXYZ(3,3),'yo',...
      color_rXYZ(4,1),color_rXYZ(4,2),color_rXYZ(4,3),'go',...
      color_rXYZ(5,1),color_rXYZ(5,2),color_rXYZ(5,3),'co',...
      color_rXYZ(6,1),color_rXYZ(6,2),color_rXYZ(6,3),'bo',...
      color_rXYZ(7,1),color_rXYZ(7,2),color_rXYZ(7,3),'mo',...
      color_rXYZ(8,1),color_rXYZ(8,2),color_rXYZ(8,3),'ko');
xlim([0,1.2]);
ylim([0,1.2]);
zlim([0,1.2]);
xlabel('X');
ylabel('Y');
zlabel('Z');
set(gca,'xtick',[0 0.2 0.4 0.6 0.8 1.0 1.2]);
set(gca,'ytick',[0 0.2 0.4 0.6 0.8 1.0 1.2]);
set(gca,'ztick',[0 0.2 0.4 0.6 0.8 1.0 1.2]);
grid on;
axis square;
set(gca,'projection','perspective');
