function bLogMode = fnGetLogMode(iLevel)
% Returns true if a log event of the given log level (iLevel) should be
% logged.
global g_iLogLevel;
bLogMode = ~isempty(g_iLogLevel) && ...
           (iLevel <= g_iLogLevel) && ...
           ~isempty(whos('global','g_CaptainsLogDir'));
