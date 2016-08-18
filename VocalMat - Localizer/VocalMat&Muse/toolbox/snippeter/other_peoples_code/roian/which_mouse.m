function [mid,mid4]=which_mouse(dir_name)
% which_mouse: function to return the order of tracks for a particular motr
% session
%
% form: [mid,mid4]=which_mouse(dir_name)
%
% dir_name is the directory where the Tuning directory is located (which contains
% the file Identities.mat), can be the full path
%
% mid is a struct with fields track, sex and num
% mid4 is an order of 1,2,3 and 4, for the tracks associated with m1, m2, f1 and
% f2 respectively (e.g. mid4(1) is the track for m1)--this is specifically
% for experiments with 2 males and 2 females

cd([dir_name '\Tuning\']);
load Identities.mat;

num_mice=size(strctIdentityClassifier.m_a3fRepImages,3);
xval=size(strctIdentityClassifier.m_a3fRepImages,2);
yval=size(strctIdentityClassifier.m_a3fRepImages,1);
figure('position',[122 229 915 875])
for i=1:num_mice
    subplot(2,2,i);
    imagesc(strctIdentityClassifier.m_a3fRepImages(:,:,i));
    colormap('gray');
    axis equal;
    axis xy;
    axis([0 xval 0 yval]);
    title(['track ' num2str(i)]);
end;

for i=1:num_mice
    disp(['for track ' num2str(i)]);
    mid(i).track=i;
    mid(i).sex=input('sex (m/f): ','s');
    mid(i).num=input('number (1,2...): ','s');
    mid(i).cage = input('cage number: ','s');
    disp(' ');
end;

z=cat(2,[mid(:).sex]',[mid(:).num]');
a=reshape(z',num_mice*2,1)';
mid4(1)=strfind(a,'m1');
mid4(2)=strfind(a,'m2');
mid4(3)=strfind(a,'f1');
mid4(4)=strfind(a,'f2');
mid4=(mid4+1)/2;

save('mouse_ID', 'mid', 'mid4');