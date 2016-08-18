function [acOBs, aiOBfeatureNum, abOBelapted, abOBfreq, aiOBtimeScale] = getRelevantOtherBehaviors(BCparams)
%                   
% Prepare list of relevant other behaviors (OB = OtherBehavior)
%
if isfield(BCparams.Features, 'strctOtherBehaviors')
     strctOBs = BCparams.Features.strctOtherBehaviors;
     acOBs = fieldnames(strctOBs);
     [abOBelapted, abOBfreq] = deal(false(size(acOBs)));
     aiOBtimeScale = zeros(size(acOBs));
     for iOB=1:length(acOBs)
         strctOB = getfield(strctOBs, acOBs{iOB});
         abOBelapted(iOB) = strctOB.bElapsedFrames;
         abOBfreq(iOB) = strctOB.bFrequency;
         if ~isempty(strctOB.iFreqTimeScale)
             aiOBtimeScale(iOB) = strctOB.iFreqTimeScale;
         end
     end
     abRelevant = abOBelapted | abOBfreq;
     acOBs = acOBs(abRelevant);
     abOBelapted = abOBelapted(abRelevant);
     abOBfreq = abOBfreq(abRelevant);
     aiOBfeatureNum = abOBelapted + abOBfreq;
     aiOBtimeScale = aiOBtimeScale(abRelevant);
else
     acOBs = cell(0);
     [aiOBfeatureNum,  abOBelapted, abOBfreq, aiOBtimeScale] = deal([]);
end
