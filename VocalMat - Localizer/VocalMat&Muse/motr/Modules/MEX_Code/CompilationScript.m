% Compiling Script
if ~exist('./MEX/linux64','dir')
    mkdir('./MEX/linux64','dir');
end;

mex ./MEX_Code/LabelsHist/LabelsHist.cpp -output ./MEX/linux64/fnLabelsHist.mexa64
mex ./MEX_Code/SelectLabels/SelectLabels.cpp -output ./MEX/linux64/fnSelectLabels.mexa64
mex ./MEX_Code/EM/fnEM.cpp -output ./MEX/linux64/fnEM.mexa64
mex ./MEX_Code/HOGfeatures/HOGfeatures.cpp -output ./MEX/linux64/fnHOGfeatures.mexa64
mex ./MEX_Code/Viterbi/Viterbi.cpp -output ./MEX/linux64/fndllViterbi.mexa64
mex ./MEX_Code/ViterbiOnTheFly/ViterbiOnTheFly.cpp -output ./MEX/linux64/fndllViterbiOnTheFly.mexa64
mex ./MEX_Code/fnViterbiLikelihood1AA/fnViterbiLikelihood1AA.cpp -output ./MEX/linux64/fnViterbiLikelihood1AA.mexa64
mex ./MEX_Code/fnViterbiLikelihoodForHeadTail/fnViterbiLikelihoodForHeadTail.cpp -output ./MEX/linux64/fnViterbiLikelihoodForHeadTail.mexa64
mex ./MEX_Code/Interp2/FastInterp2.cpp -output ./MEX/linux64/fnFastInterp2.mexa64
