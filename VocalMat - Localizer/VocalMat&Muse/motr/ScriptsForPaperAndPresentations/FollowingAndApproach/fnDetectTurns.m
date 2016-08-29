function [acRapidTurnsCCW,acRapidTurnsCW]=fnDetectTurns(astrctTrackers)
iNumMice = length(astrctTrackers);
acRapidTurnsCW = cell(1,iNumMice);
acRapidTurnsCCW = cell(1,iNumMice);
fLowVelocity = 10;
fHighVelocity = 15;
iContiguous = 2;
for iMouseIter=1:iNumMice
    % compute angular velocity
    afVelTheta = diff(astrctTrackers(iMouseIter).m_afTheta)/pi*180;
    afVelTheta(afVelTheta>90) =  afVelTheta(afVelTheta>90)-180;
    afVelTheta(afVelTheta>90) =  afVelTheta(afVelTheta>90)-180;
    afVelTheta(afVelTheta<-90) =  afVelTheta(afVelTheta<-90) +180;
    afVelTheta(afVelTheta<-90) =  afVelTheta(afVelTheta<-90) +180;

    acRapidTurnsCCW{iMouseIter} = fnHysteresisThreshold(afVelTheta, fLowVelocity, fHighVelocity, iContiguous);
    acRapidTurnsCW{iMouseIter} = fnHysteresisThreshold(-afVelTheta, fLowVelocity, fHighVelocity, iContiguous);
end
