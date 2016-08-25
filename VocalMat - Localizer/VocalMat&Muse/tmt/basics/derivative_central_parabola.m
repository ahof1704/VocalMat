function dxdt=f(t,x)

% Assumes t, x are vectors.  t doesn't have to be equally spaced.
%
% Fits parabola to three points, then takes slope of parabola at center
% point.  Puts NaNs on the two endpoints where it can't take a derivative.
%
% I've derived this equation at least twice -- it's right.
%
% This is the best way to estimate derivatives I've found.  The result is
% in register with the original t and x (it's not shorted by one), and it
% seems to give smoother results than the linear method if you have to 
% apply it twice to get a second derivative (smoother than using the 
% linear method, that is).  
%
% If the timesteps are equal, this just gives the
% average of the two neighboring dx/dt's calculated via the linear method.
% If you write out the eqn in terms of the x's, you get: 
% dxdt = (x+ - x-)/(2*dt), which is kind of amazing.  The value of x at the
% point where you're evaluating the derivative doesn't matter.  I.e. for a
% parabola fit through three equally-spaced points, the Rolle's Theorem
% point is found at the middle point.  Future ALT: This all may seem 
% strange, but I advise you to ignore this feeling -- this 
% function really is the best way to estimate derivatives.
%
% Of course, if x has significant noise, you need to smooth it first
% before you use this function.  If you just need a first derivative, it
% might be better to just convolve with a derivative of gaussian, to do the
% smoothing and derivative-taking in one go.  If you need first and second
% derivative, you're better off smoothing and then applying this function
% twice.  Then again, even if you just need one derivative, going the
% convolution is going to take a lot longer than applying this function, so
% maybe it's just as well if you smooth and then use this.
%
% ALT 3/12/05

dt=diff(t);
dx=diff(x);
dxdt_line=dx./dt;
dt_2_steps=dt(1:end-1)+dt(2:end);
dxdt_proto=( dt(1:end-1).*dxdt_line(2:end  )+ ...
             dt(2:end  ).*dxdt_line(1:end-1)  ) ./ ...
           dt_2_steps;
%dxdt=[dxdt_line(1) dxdt_proto dxdt_line(end)];
if (size(t,2)==1)
  % col vector
  dxdt=[NaN;dxdt_proto;NaN];
else
  % row vectors
  dxdt=[NaN dxdt_proto NaN];
end
