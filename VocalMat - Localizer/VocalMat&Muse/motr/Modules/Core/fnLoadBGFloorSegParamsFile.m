function strctBackground=fnLoadBGFloorSegParamsFile(strFileName)

strctTmp = load(strFileName);
strctBackground = strctTmp.strctBackground;

end
