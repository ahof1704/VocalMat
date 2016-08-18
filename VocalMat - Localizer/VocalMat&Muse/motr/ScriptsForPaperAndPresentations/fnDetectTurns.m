function [acRapidTurnsCCW,acRapidTurnsCW]=fnDetectTurns(astrctTrackers)
for iMouseIter=1:length(astrctTrackers)
  afVelTheta = diff(astrctTrackers(iMouseIter).m_afTheta)/pi*180;
  afVelTheta(afVelTheta>90) =  afVelTheta(afVelTheta>90)-180;
 afVelTheta(afVelTheta>90) =  afVelTheta(afVelTheta>90)-180;
 afVelTheta(afVelTheta<-90) =  afVelTheta(afVelTheta<-90) +180;
 afVelTheta(afVelTheta<-90) =  afVelTheta(afVelTheta<-90) +180;

    acRapidTurnsCCW{iMouseIter} = fnHysteresisThreshold(afVelTheta, 10, 15, 2);
    acRapidTurnsCW{iMouseIter} = fnHysteresisThreshold(-afVelTheta, 10, 15, 2);
end
