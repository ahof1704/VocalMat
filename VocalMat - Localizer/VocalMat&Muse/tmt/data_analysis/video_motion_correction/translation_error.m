function error = translation_error(theta,frame1,frame2,border)

% Break out theta
A=eye(2);
b=theta;
% calculate error
error=registration_error(frame1,frame2,border,A,b);
%fprintf(1,'.');