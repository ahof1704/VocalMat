s=fnReadVideoInfo('D:\Data\Janelia Farm\Movies\vs_single_mouse.seq');
X=randi(s.m_iNumFrames,1,30);
X(6) = 2122;
clear I;
for k=1:length(X)
    I(:,:,k)=fnReadFrameFromSeq(s,X(k));
end;
M=median(double(I),3);
figure;
imshow(M,[]);

figure(1);
clf;
imshow(I(:,:,6),[])

axis( 1.0e+002 *[   2.080264306685641   3.147562655491630   3.142488778756568   3.942962540361060]);

J=abs(double(I(:,:,6))-M);
figure;
imshow(J,[]);
axis( 1.0e+002 *[   2.080264306685641   3.147562655491630   3.142488778756568   3.942962540361060]);

figure;
imshow(J>95,[]);
P=get(gcf,'position');P(3:4)=[400,235];set(gcf,'position',P);
axis( 1.0e+002 *[   2.080264306685641   3.147562655491630   3.142488778756568   3.942962540361060]);

B=J>95;
Bc= bwdist(~(bwdist(B)<10))>10;
Bc(1:50,:)=0;

figure;
imshow(Bc,[]);
P=get(gcf,'position');P(3:4)=[400,235];set(gcf,'position',P);
axis( 1.0e+002 *[   2.080264306685641   3.147562655491630   3.142488778756568   3.942962540361060]);

[aiI,aiJ] = find(Bc);
[Mue,Cov]=fnFitGaussian([aiJ,aiI]);
E=fnCov2EllipseStrct(Mue,Cov);

figure;
imshow(Bc,[]);
P=get(gcf,'position');P(3:4)=[400,235];set(gcf,'position',P);
axis( 1.0e+002 *[   2.080264306685641   3.147562655491630   3.142488778756568   3.942962540361060]);
hold on;
plot(E.m_afX,E.m_afY,'ro');

fnDrawEllipse(gca,E.m_afX,E.m_afY,E.m_afA,E.m_afB,E.m_afTheta-pi/2,'r',2,false);

