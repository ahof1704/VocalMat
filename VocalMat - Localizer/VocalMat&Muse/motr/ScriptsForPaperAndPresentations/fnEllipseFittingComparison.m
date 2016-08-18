afTheta = linspace(0,2*pi,100);

A = 25;
B = 10;
afX= cos(afTheta)*A;
afY = sin(afTheta)*B;
Xc = 50;
Yc = 70;
Theta = pi/7;

R =[cos(Theta), sin(Theta);
-sin(Theta) cos(Theta)]
Tmp = R * [afX; afY];

afXf = Tmp(1,:) + Xc;
afYf = Tmp(2,:) + Yc;

figure(1);
J=(roipoly(zeros(100,100),afXf,afYf));
imshow(J,[]);

[afI,afJ]=find(J);
[afMu, a2fCov] = fnFitGaussian([afJ,afI]);


strctEllipse = fnCov2EllipseStrct(afMu,a2fCov);








%%
meanI = mean(afI);
meanJ = mean(afJ);
strctEllipseRegionProps.m_afX = meanJ;
strctEllipseRegionProps.m_afY = meanI;
x = afJ - meanJ;
y = -(afI-meanI);
            % orientation calculation (measured in the
            % counter-clockwise direction).

            N = length(x);

            % Calculate normalized second central moments for the region. 1/12 is
            % the normalized second central moment of a pixel with unit length.
            uxx = sum(x.^2)/N + 1/12;
            uyy = sum(y.^2)/N + 1/12;
            uxy = sum(x.*y)/N;

            % Calculate major axis length, minor axis length, and eccentricity.
            common = sqrt((uxx - uyy)^2 + 4*uxy^2);
            strctEllipseRegionProps.afA = (2*sqrt(2)*sqrt(uxx + uyy + common))/2;
            strctEllipseRegionProps.afB = (2*sqrt(2)*sqrt(uxx + uyy - common))/2;
            

            % Calculate orientation.
            if (uyy > uxx)
                num = uyy - uxx + sqrt((uyy - uxx)^2 + 4*uxy^2);
                den = 2*uxy;
            else
                num = 2*uxy;
                den = uxx - uyy + sqrt((uxx - uyy)^2 + 4*uxy^2);
            end
            if (num == 0) && (den == 0)
                strctEllipseRegionProps.Orientation = 0;
            else
                strctEllipseRegionProps.Orientation =  2*pi-(atan(num/den) + pi/2)
            end

            
strctEllipseRegionProps
strctEllipse
