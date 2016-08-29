acMov{1} = 'D:\Data\Janelia Farm\Movies\cage16\b6_popcage_16_110405_09.58.30.268.seq';
acMov{2} = 'D:\Data\Janelia Farm\Movies\cage17\b6_popcage_17_05.30.11_10.00.07.777.seq';
acMov{3} = 'D:\Data\Janelia Farm\Movies\cage18\b6_popcage_18_09.15.11_10.56.24.135.seq';
acMov{4} = 'D:\Data\Janelia Farm\Movies\cage19\b6_popcage_19_10.16.11_11.01.17.231_.seq';
acMov{5} = 'D:\Data\Janelia Farm\Movies\cage20\b6_popcage_20_11.02.11_11.01.25.237.seq';
acMov{6} = 'D:\Data\Janelia Farm\Movies\cage23\b6_popcage_23_04.05.12_11.00.18.424.seq';

acCage{1} = 'cage16_matrix.mat';
acCage{2} = 'cage17_matrix.mat';
acCage{3} = 'cage18_matrix.mat';
acCage{4} = 'cage19_matrix.mat';
acCage{5} = 'cage20_matrix.mat';
acCage{6} = 'cage23_matrix.mat';


iCageIter=6;

strctMov = fnReadVideoInfo(acMov{iCageIter});
strFolder = 'D:\Data\Janelia Farm\ResultsFromNewTrunk\';
strDatfile = [strFolder,acCage{iCageIter}];
strctData = load(strDatfile);

abValid = ~isnan(strctData.X) & ~isnan(strctData.Y);
a2fCenter=hist2(strctData.X(abValid),strctData.Y(abValid),1:1024,1:768);
a2fPercentTime= conv2(a2fCenter,fspecial('gaussian',[50 50],fSmooth),'same')/sum(a2fCenter(:))*1e2;
a2fLog = log10(a2fPercentTime);

I=fnReadFrameFromSeq(strctMov,1);
A=a2fLog;
A(A<-4)=0;
A(A>-2)=0;
A(A>-4 & A<-1.5) = (A(A>-4 & A<-2)+4)/6;

clear acRegions
acRegionNames = {'Right tube','Left tube','Top left corner','Top right corner','Bottom left corner','Bottom right corner','Entrance left tube top','Entrance right tube top','Entrance left tube bottom','Entrance right tube bottom'};
for k=1:length(acRegionNames)
    figure(11);clf;set(11,'name',acRegionNames{k});
    Region = roipoly(0.5*double(I)/255+0.5*A);
    acRegions{k} = Region;
end
strOutFile = ['D:\Data\Janelia Farm\Final_Data_For_Paper\Regions\',acCage{iCageIter}(1:6),'_Regions.mat'];
    fprintf('Saving regions to %s\n',strOutFile);
save(strOutFile,'acRegions','acRegionNames');
    