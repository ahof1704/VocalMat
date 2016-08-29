function fnCreatePDFlog()
%
global g_CaptainsLogDir;
load Config/logFileOptions;
logFileOptions.outputDir = g_CaptainsLogDir;
publish('fnDisplayLogs', logFileOptions);
