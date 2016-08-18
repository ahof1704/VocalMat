function [t_fs,fs]=f(ts)

dt=diff(ts);
fs=1./dt;
t_fs=(ts(1:end-1)+ts(2:end))/2;
