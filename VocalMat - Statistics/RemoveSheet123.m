function RemoveSheet123(excelFileName,sheetName)
% RemoveSheet123 - removes the sheets that are automatically added to excel
% file. 
% When Matlab writes data to a new Excel file, the Excel software
% automatically creates 3 sheets (the names are depended on the user
% languade). This appears even if the user has defined the sheet name to be
% added. 
%
% Usage:
% RemoveSheet123(excelFileName) - remove "sheet1", "sheet2","sheet3" from
% the excel file. excelFileName is a string of the Excel file name.
% RemoveSheet123(excelFileName,sheetName) - enables the user to enter the
% sheet name when the language is other than English.
% sheetName is the default sheet name, without the number.
%
%
%                       Written by Noam Greenboim
%                       www.perigee.co.il
%


%% check input arguments
if nargin < 1 || isempty(excelFileName)
    error('Filename must be specified.');
end

if ~ischar(excelFileName)
    error('Filename must be a string.');
end

try
    excelFileName = validpath(excelFileName);
catch 
    error('File not found.');
end


if nargin < 2
    sheetName = 'Sheet'; % EN: Sheet, DE: Tabelle, HE: גיליון , etc. (Lang. dependent)
else
    if ~ischar(sheetName)
        error('Default sheet name must be a string.');
    end
end

%%
% Open Excel file.
objExcel = actxserver('Excel.Application');
objExcel.Workbooks.Open(excelFileName); % Full path is necessary!
% Delete sheets.
try
      % Throws an error if the sheets do not exist.
      objExcel.ActiveWorkbook.Worksheets.Item([sheetName '1']).Delete;
      fprintf('\nsheet #1 - deleted.')
      objExcel.ActiveWorkbook.Worksheets.Item([sheetName '2']).Delete;
      fprintf('\nsheet #2 - deleted.')
      objExcel.ActiveWorkbook.Worksheets.Item([sheetName '3']).Delete;
      fprintf('\nsheet #3 - deleted.\n')
catch
    fprintf('\n')
    O=objExcel.ActiveWorkbook.Worksheets.get;
    if O.Count==1
        error('Can''t delete the last sheet. Excel file must containt at least one sheet.')
    else
      warning('Problem occured. Check excel file.'); 
    end
end
% Save, close and clean up.
objExcel.ActiveWorkbook.Save;
objExcel.ActiveWorkbook.Close;
objExcel.Quit;
objExcel.delete;
end

function filenameOut = validpath(filename)
    % VALIDPATH builds a full path from a partial path specification
    %   FILENAME = VALIDPATH(FILENAME) returns a string vector containing full
    %   path to a file. FILENAME is string vector containing a partial path
    %   ending in a file or directory name. May contain ..\  or ../ or \\. The
    %   current directory (pwd) is prepended to create a full path if
    %   necessary. On UNIX, when the path starts with a tilde, '~', then the
    %   current directory is not prepended.
    %
    %   See also XLSREAD, XLSWRITE, XLSFINFO.
    
    %   Copyright 1984-2012 The MathWorks, Inc.
    
    %First check for wild cards, since that is not supported.
    if strfind(filename, '*') > 0
        error(message('MATLAB:xlsread:Wildcard', filename));
    end
    
    % break partial path in to file path parts.
    [Directory, file, ext] = fileparts(filename);

    if ~isempty(ext)
        filenameOut = getFullName(filename);
    else
        extIn = matlab.io.internal.xlsreadSupportedExtensions;
        for i=1:length(extIn)
            try                                                                %#ok<TRYNC>
                filenameOut = getFullName(fullfile(Directory, [file, extIn{i}]));
                return;
            end
        end
        error(message('MATLAB:xlsread:FileDoesNotExist', filename));    
    end
end

function absolutepath=abspath(partialpath)
    
    % parse partial path into path parts
    [pathname, filename, ext] = fileparts(partialpath);
    % no path qualification is present in partial path; assume parent is pwd, except
    % when path string starts with '~' or is identical to '~'.
    if isempty(pathname) && strncmp('~', partialpath, 1)
        Directory = pwd;
    elseif isempty(regexp(partialpath,'(.:|\\\\)', 'once')) && ...
            ~strncmp('/', partialpath, 1) && ...
            ~strncmp('~', partialpath, 1);
        % path did not start with any of drive name, UNC path or '~'.
        Directory = [pwd,filesep,pathname];
    else
        % path content present in partial path; assume relative to current directory,
        % or absolute.
        Directory = pathname;
    end
    
    % construct absolute filename
    absolutepath = fullfile(Directory,[filename,ext]);
end

function filename = getFullName(filename)
    FileOnPath = which(filename);
    if isempty(FileOnPath)
        % construct full path to source file
        filename = abspath(filename);
        if isempty(dir(filename)) && ~isdir(filename)
            % file does not exist. Terminate importation of file.
            error(message('MATLAB:xlsread:FileDoesNotExist', filename));
        end
    else
        filename = FileOnPath;
    end
end