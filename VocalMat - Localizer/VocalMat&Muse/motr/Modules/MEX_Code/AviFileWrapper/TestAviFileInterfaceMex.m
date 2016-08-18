% A simple example how to use the wrapper for avifile lib:

% First, compile the project. 
mex AviFileInterfaceMex.cc AviFileInterface.cc -I/usr/include/avifile-0.7  /usr/lib/avifile-0.7/win32.so /usr/lib/avifile-0.7/xvid4.so -L/usr/lib -laviplay; 

% Note, you might need to call "export
% LD_LIBRARY_PATH=/usr/lib/avifile-0.7" before running matlab.
%

% The equivalent for "avifile(filename, iframe") is: 
hHandle = AviFileInterfaceMex('Open','/home/shayo/JaneliaFarm/Data/Movies//pera_mf_081030_D_XVID.avi');
strcInfo = AviFileInterfaceMex('Info',hHandle);
AviFileInterfaceMex('Seek',hHandle,142);
A=AviFileInterfaceMex('GetFrame',hHandle);
AviFileInterfaceMex('Close',hHandle);
I=AviFileInterfaceMex('GetFrame',hHandle);
AviFileInterfaceMex('Close',hHandle);

