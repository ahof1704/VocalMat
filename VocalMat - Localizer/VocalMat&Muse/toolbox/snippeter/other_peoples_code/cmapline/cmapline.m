function varargout=cmapline(varargin)
% CMAPLINE - Apply a colormap to lines in plot
%
%   CMAPLINE finds all lines in an axis and specifies their
%   colors according to a colormap. Also accepts custom 
%   colormaps in the form of a n x 3 matrix. 
%    
% OPTIONS and SYNTAX
%
%   cmapline - with no inputs, cmapline finds all lines in the 
%   current axis and applies the colormap 'jet'.
% 
%   cmapline('ax',gca,'colormap','hot') - will find all lines
%   in the specified axis (in this case, the current axis)
%   and applies the colormap 'hot'.
%
%   cmapline('lines',handles) - applies colormap values to line
%   objects with specified handles.   
%
%   cmapline('filled') - will fill markers (if included in the 
%   line) with corresponding colormap colors.
%
%   lineh=cmapline - The optional output variable returns the
%   handles to the line objects.
%
%   [lineh, cmap]=cmapline - Two optional outputs returns both the 
%   the handles to the line objects and the applied colormap. 
%
% EXAMPLE 1 - color lines in two subplots according to different colormaps
%  
%   %generate some data
%   x=(0:0.3:2*pi);
%   m=10;
%   exdata=bsxfun(@plus,repmat(10.*sin(x),[m 1]),[1:m]');
%   
%   figure
%   subplot(121);
%   plot(x,exdata,'o-','linewidth',2)
%   cmapline('colormap','jet');
%   set(gca,'color','k')
%   title('jet colormap')
%
%   subplot(122);
%   plot(x,exdata,'o-','linewidth',2)
%   custommap=flipud(hot);
%   cmapline('colormap',custommap,'filled')
%   set(gca,'color','k')
%   title('reverse hot colormap, filled markers')  
%
% EXAMPLE 2 (uses data from example 1) - add a colorbar to your plot
%
%   figure
%   plot(x,exdata,'linewidth',2)
%   [lh,cmap]=cmapline('colormap','jet');
%   colormap(cmap)
%   colorbar
%
% SEE ALSO  colormap 

% Andrew Stevens @ USGS, 8/15/2008
% astevens@usgs.gov

%default values
ax=gca;
cmap=@jet;
fillflag=0;
lh=[];

%parse inputs and do some error-checking
if nargin>0
    [m,n]=size(varargin);
    opts={'ax','lines','colormap','filled'};

    for i=1:n;
        indi=strcmpi(varargin{i},opts);
        ind=find(indi==1);
        if isempty(ind)~=1
            switch ind
                case 1
                    %make sure input is an axes handle, sort of
                    ax=varargin{i+1};
                    if ~ishandle(ax)
                        error(['Specified axes',...
                            ' must be a valid axis handle'])
                    end
                case 2
                    lh=varargin{i+1};
                    if ~all(ishandle(lh))
                        error('Invalid line handle')
                    else
                        lh=num2cell(lh);
                    end
                    
                case 3
                    cmap=varargin{i+1};
                    if isa(cmap,'function_handle')
                        cmap= func2str(cmap);
                    end
                    %check size of numeric colormap input
                    if isa(cmap,'numeric')
                        [m,n]=size(cmap);
                        if n~=3
                            error('Custom colormap must have 3 columns.')
                        end
                    end
                case 4
                    fillflag=1;

            end
        else
        end
    end
end

%find lines in axes
if isempty(lh)
    lh=num2cell(findobj(ax,'type','line'));
end

numlines=numel(lh);
if isempty(lh)
    fprintf('No lines present in specified axes.\n')
end

if isa(cmap,'numeric')
    %if needed, interpolate colormap to number of lines
    if numlines~=m
        int=m/numlines;
        ivec=1:m;
        ovec=1:int:1+(numlines-1)*int;

        cmap=num2cell(cmap,1);
        cmap=cellfun(@(x)(interp1(ivec,x,ovec,...
            'linear','extrap')'),cmap,'uni',0);
        colrs=num2cell(cell2mat(cmap),2);
    else
        colrs=num2cell(cmap,2);
    end
else
    %if standard colormap is supplied
    colrs=num2cell(feval(cmap,numlines),2);
end

%apply colors to lines
cellfun(@(x,y)(set(x,'color',y)),lh,colrs);

if strcmpi(get(lh{1},'marker'),'none')~=1 && ...
        fillflag==1;
    cellfun(@(x,y)(set(x,'markerfacecolor',y)),...
        lh,colrs);
end

%output 
if nargout>0
    varargout{1}=cell2mat(lh);
end
if nargout>1
    varargout{2}=cell2mat(colrs);
end






