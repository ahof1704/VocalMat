function result=islinux()

result=(~ispc() && ~ismac() && isunix() );

end
