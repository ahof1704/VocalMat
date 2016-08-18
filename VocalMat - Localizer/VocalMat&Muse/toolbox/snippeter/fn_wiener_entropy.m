function [ start_sample stop_sample ] = fn_wiener_entropy( x1, x2, x3, x4, x5, fc )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

close all

% tmp = x1;
% % tmp = rfilter(tmp,47000,70000,fc);
% figure
% r_specgram_mouse_mod(tmp,fc);
% ban = r_specgram_mouse_mod(tmp,fc);
% [h1,logpower1] = wiener(ban);
% figure
% plot(h1)
% ylim([1 2.5])

% tmp = x2;
% % tmp = rfilter(tmp,47000,70000,fc);
% figure
% r_specgram_mouse_mod(tmp,fc); 
% ban = r_specgram_mouse_mod(tmp,fc); 
% [h2,logpower2] = wiener(ban);
% figure
% plot(h2)
% ylim([1 2.5])

tmp = x3;
% tmp = rfilter(tmp,40000,80000,fc);
figure
r_specgram_mouse_mod(tmp,fc); 
ban = r_specgram_mouse_mod(tmp,fc); 
[h3,logpower3] = wiener(ban);
figure
plot(h3)
% ylim([1 2.5])
[z,dummy,dummy,handle1] = fn_rfft_jpn(tmp,fc);

% tmp = x4;
% % tmp = rfilter(tmp,47000,70000,fc);
% figure
% r_specgram_mouse_mod(tmp,fc); 
% ban = r_specgram_mouse_mod(tmp,fc); 
% [h4,logpower4] = wiener(ban);
% figure
% plot(h4)
% ylim([1 2.5])

% tmp = x5;
% % tmp = rfilter(tmp,47000,70000,fc);
% figure
% r_specgram_mouse_mod(tmp,fc); 
% ban = r_specgram_mouse_mod(tmp,fc); 
% [h5,logpower5] = wiener(ban);
% figure
% plot(h5)
% ylim([1 2.5])

disp(1)

% end
start_sample = 1;
stop_sample = 1;


end

