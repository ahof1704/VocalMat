function [trx, didsomething] = apply_convert_units(trx,pxpermm,fps, alreadyconverted)
% split from convert_units_f 9/10/11 JAB

pxpermminput = exist('pxpermm','var');
fpsinput = exist('fps','var');
if ~exist( 'alreadyconverted', 'var' )
   alreadyconverted = false;
end

if ~pxpermminput
  pxpermm = trx(1).pxpermm;
end
if ~fpsinput
  fps = trx(1).fps;
end

%% actually do the conversion now

pxfns = {'xpred','ypred','dx','dy','v'};
% these are used for plotting, so we want to keep them in pixels
pxcpfns = {'x','y','a','b'};
okfns = {'x','y','theta','a','b','id','moviename','firstframe','arena',...
  'f2i','nframes','endframe','xpred','ypred','thetapred','dx','dy','v',...
  'a_mm','b_mm','x_mm','y_mm','matname','sex','type','timestamps'};
unknownfns = setdiff(getperframepropnames(trx),okfns);

if ~alreadyconverted
   if ~isempty(unknownfns),
     b = questdlg({'Do not know how to convert the following variables: ',...
       sprintf('%s, ',unknownfns{:}),'Ignore these variables and continue?'},...
       'Unknown Variables','Continue','Abort','Abort');
     if strcmpi(b,'abort'),
       return;
     end
   end

   for ii = 1:length(pxfns),
     fn = pxfns{ii};
     if isfield(trx,fn),
       for fly = 1:length(trx),
         trx(fly).(fn) = trx(fly).(fn) / pxpermm;
       end
     end
   end
end

didsomething = false;
for ii = 1:length(pxcpfns),
  fn = pxcpfns{ii};
  newfn = [fn,'_mm'];
  if isfield(trx,fn),
    for fly = 1:length(trx),
      trx(fly).(newfn) = trx(fly).(fn) / pxpermm;
      didsomething = true;
    end
  end
end

for fly = 1:length(trx),
  if pxpermminput && ~alreadyconverted,
    trx(fly).pxpermm = pxpermm;
  end
  if fpsinput,
     if ~alreadyconverted
        trx(fly).fps = fps;
     end
  end
end
  
if ~isfield( trx, 'timestamps' )
   if isfield( trx, 'fps' )
      fprintf( 1, 'no timestamps saved in file -- faking\n' );
      for fly = 1:length(trx),
        trx(fly).timestamps = (trx(fly).firstframe:trx(fly).endframe)/fps;
      end
      didsomething = true;
   else
      fprintf( 1, 'no timestamps saved in file and no fps number to calculate from\n' );
   end
end
