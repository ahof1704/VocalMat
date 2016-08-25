function cdirs = parsedirs(str,varargin)
%PARSEDIRS Convert string of directories into a cell array
%   C = PARSEDIRS(S) converts S, a string of directories separated by path
%   separators, to C, a cell array of directories. 
%
%   The function will clean up each directory name by converting file
%   separators to the appropriate operating system file separator, and by
%   ending each cell with a path separator. It will also remove repeated
%   file and path separators, and insignificant whitespace. 
%
%   C = PARSEDIRS(S,OUTPUT) will output the results as a char array if
%   OUTPUT is 'char', and will output the results as a cell array if OUTPUT
%   is 'cell'. If OUTPUT is empty or not specified, 'cell' is the default.
%
%   C = PARSEDIRS(S,OUTPUT,SEPS) additionally will use PC-style
%   separators if SEPS is either 'PC', '\', or ';'. Unix-style separators
%   will be used if 'Unix', '/', or ':' is specified. If SEPS is empty, the
%   default is used.
%
%   Example:
%       cp = parsedirs(path);

%   Copyright 1984-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $ $Date: 2007/09/27 22:46:10 $

tocell = true;
fs = filesep;
ps = pathsep;
if nargin>1
    switch lower(varargin{1})
        case {'cell','',[]}
            tocell = true;
        case {'char','string'}
            tocell = false;
        otherwise
            error('MATLAB:parsedirs:UnknownOutputOption', ...
                'OUTPUT option specified is an unknown case.')
    end
    if nargin>2
        switch lower(varargin{2})
            case {'pc','\',';'}
                fs = '\';
                ps = ';';
            case {'unix','/',':'}
                fs = '/';
                ps = ':';
            case {[],''}
                fs = filesep;
                ps = pathsep;
        end
    end
end

% Add a path separator to the end for regexp ease
if ~isempty(str) && str(end)~=ps
    str = [str ps];
end

cdirs = regexp(str, sprintf('[^\\s%s][^%s]*', ps, ps), 'match')';

if ps == ';'
    % Only iron fileseps on PC:
    cdirs = strrep(cdirs,'/','\');

    % Remove repeated "\"s unless they are the start of string
    % Also ensure a "\" exists after a colon
	cdirs = regexprep(cdirs, '(:)\s*$|(.)\\{2,}', '$1\');
else
    % Remove repeated "/"s
    cdirs = regexprep(cdirs, '/{2,}', '/');

    % Do any tilde expansion
    ix = find(strncmp(cdirs,'~',1));
    if ~isempty(ix)
      cdirs(ix) = unix_tilde_expansion(cdirs(ix));
    end
end

% Remove trailing fileseps, but allow a directory to be "X:\", "\" or "/" 
% Add pathseps to the end of all paths
cdirs = regexprep(cdirs,sprintf('(.*[^:])\\%s\\s*$|(.*)\\s*$',fs),sprintf('$1%s', ps));

% Remove empty paths
cdirs(cellfun('isempty', cdirs)) = [];

if ~tocell
    cdirs = [cdirs{:}];
end

