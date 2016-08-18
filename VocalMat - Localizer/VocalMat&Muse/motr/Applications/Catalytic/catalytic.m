function varargout = catalytic(varargin)

c=CatalyticController();

if nargin>=1
  fileName=varargin{1};
  c.openGivenFileName(fileName);
end

if nargout>0
  varargout{1}=c;
end
  
end  % function
