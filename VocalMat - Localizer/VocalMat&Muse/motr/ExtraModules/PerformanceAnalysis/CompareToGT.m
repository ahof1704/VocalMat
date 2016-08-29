function CompareToGT
dbstop if error
clc
% Comparison to GT automatic report.

% 
% strGTFile = 'D:\Data\Janelia Farm\GroundTruth\10.02.24.796_cropped23348-36000.mat';
% strResultsFile = 'D:\Data\Janelia Farm\Results\10.02.24.796_cropped23348-36000\SequenceRAW_08-Sep-2009.mat';
% strResultsViterbiFile = 'D:\Data\Janelia Farm\Results\10.02.24.796_cropped23348-36000\SequenceViterbi_08-Sep-2009.mat';
% CompareToGTAux(strGTFile, strResultsFile, strResultsViterbiFile);
% 
% 
% strGTFile = 'D:\Data\Janelia Farm\GroundTruth\10.02.24.796_cropped83082-96581.mat';
% strResultsFile = 'D:\Data\Janelia Farm\Results\10.02.24.796_cropped83082-96581\SequenceRAW_08-Sep-2009.mat';
% strResultsViterbiFile = 'D:\Data\Janelia Farm\Results\10.02.24.796_cropped83082-96581\SequenceViterbi_08-Sep-2009.mat';
% CompareToGTAux(strGTFile, strResultsFile, strResultsViterbiFile);
% 
%%
 strGTFile = 'D:\Data\Janelia Farm\GroundTruth\pera_mf_081107_A_lowrez_compressed.mat';
 strResultsFile = 'D:\Data\Janelia Farm\Results\pera_mf_081107_A_lowrez_compressed\SequenceRAW_Aug9.mat';
 strResultsViterbiFile = 'D:\Data\Janelia Farm\Results\pera_mf_081107_A_lowrez_compressed\SequenceViterbi_Aug09.mat';
CompareToGTAux(strGTFile, strResultsFile, strResultsViterbiFile);


 strGTFile = 'D:\Data\Janelia Farm\GroundTruth\pera_mf_081107_A_lowrez_compressed.mat';
 strResultsFile = 'D:\Data\Janelia Farm\Results\pera_mf_081107_A_lowrez_compressed\SequenceRAW_24-Dec-2009.mat';
 strResultsViterbiFile = 'D:\Data\Janelia Farm\Results\pera_mf_081107_A_lowrez_compressed\SequenceViterbi_26-Nov-2009.mat';
CompareToGTAux(strGTFile, strResultsFile, strResultsViterbiFile);



strGTFile = 'D:\Data\Janelia Farm\GroundTruth\10.04.19.390_cropped_120-175.mat';
strResultsFile = 'D:\Data\Janelia Farm\Results\10.04.19.390_cropped_120-175\SequenceRAW_09-Dec-2010.mat';
strResultsViterbiFile = 'D:\Data\Janelia Farm\Results\10.04.19.390_cropped_120-175\SequenceViterbi_09-Dec-2010.mat';
CompareToGTAux(strGTFile, strResultsFile, strResultsViterbiFile);



strGTFile = 'D:\Data\Janelia Farm\GroundTruth\10.04.19.390_cropped_120-175.mat';
strResultsFile = 'D:\Data\Janelia Farm\Results\10.04.19.390_cropped_120-175\SequenceRAW_24-Dec-2009.mat';
strResultsViterbiFile = 'D:\Data\Janelia Farm\Results\10.04.19.390_cropped_120-175\SequenceViterbi_26-Nov-2009.mat';
CompareToGTAux(strGTFile, strResultsFile, strResultsViterbiFile);



strGTFile = 'D:\Data\Janelia Farm\GroundTruth\10.04.19.390_cropped_120-175.mat';
strResultsFile = 'D:\Data\Janelia Farm\Results\10.04.19.390_cropped_120-175\SequenceRAW_24-Dec-2009.mat';
strResultsViterbiFile = 'D:\Data\Janelia Farm\Results\10.04.19.390_cropped_120-175\SequenceViterbi_19-Oct-2010.mat';
CompareToGTAux(strGTFile, strResultsFile, strResultsViterbiFile);



strGTFile = 'D:\Data\Janelia Farm\GroundTruth\10.04.19.390_MergeTestSeq.mat';
strResultsFile = 'D:\Data\Janelia Farm\Results\10.04.19.390_MergeTestSeq\SequenceRAW_Aug9.mat';
strResultsViterbiFile = 'D:\Data\Janelia Farm\Results\10.04.19.390_MergeTestSeq\SequenceViterbi_Aug9.mat';
CompareToGTAux(strGTFile, strResultsFile, strResultsViterbiFile);
  

strGTFile = 'D:\Data\Janelia Farm\GroundTruth\10.04.19.390_MergeTestSeq.mat';
strResultsFile = 'D:\Data\Janelia Farm\Results\10.04.19.390_MergeTestSeq\SequenceRAW_24-Dec-2009.mat';
strResultsViterbiFile = 'D:\Data\Janelia Farm\Results\10.04.19.390_MergeTestSeq\SequenceViterbi_26-Nov-2009.mat';
CompareToGTAux(strGTFile, strResultsFile, strResultsViterbiFile);
return;


