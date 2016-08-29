function k = strfindi( text, pattern )
% k = strfindi( text, pattern )
%
% a case-insensitive version of the built-in strfind()
%
% JAB 3/23/10

k = strfind( lower( text ), lower( pattern ) );
