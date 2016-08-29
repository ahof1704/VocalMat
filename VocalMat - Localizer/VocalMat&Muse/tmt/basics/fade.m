function fader=f(t,T_fade)

% creates a signal for multiplying times an audio signal to make it
% smoothly fade in and out, with the duration of the fade being T_fade

x_start=linear_map([t(1) t(1)+T_fade],[0 1],t);
x_start=min(max(x_start,0),1);
x_end=linear_map([t(end)-T_fade t(end)],[1 0],t);
x_end=min(max(x_end,0),1);
fader_pre=x_start.*x_end;
fader=fader_pre.^2.*(3-2*fader_pre);  % soften the landings
