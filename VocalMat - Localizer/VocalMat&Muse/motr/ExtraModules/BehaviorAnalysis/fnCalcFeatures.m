function F=fnCalcFeatures(astrctTrackers, strctMousePOIparams, astrctFramePOI, strctFeatureParams)
%
% calculate all features
%
for iMouseInd=1:length(astrctTrackers)
    F(:,:,:,:,iMouseInd) = fnCalcMouseFeatures(iMouseInd, astrctTrackers, strctMousePOIparams, astrctFramePOI, strctFeatureParams);
end

% function [F, pairInd,miceInd]=fnCalcFeatures(strctAllPos, aTimeScales)
% %
% % assuming length(aTimeScales )=2
% %
% T = max(aTimeScales);
% t = min(aTimeScales);
% iNumMice = length(strctAllPos);
% iNumFrames = length(strctAllPos(1).Cx) ;
% iPairsNum = iNumMice*(iNumMice-1)/2;
% D = zeros(12, iNumFrames);
% A = zeros(1, iNumFrames);
% F = zeros(38*iPairsNum, iNumFrames);
% i = 1;
% PI = 2*asin(1);
% pairInd = zeros(iNumMice);
% miceInd = [];
% % for j=1:iNumMice
% %     for s=1:length(aTimeScales)
% %         t1 = T - aTimeScales(s) + 1;
% %         t2 = aTimeScales(s);
% %         a= strctAllPos(j).a(T+1:end) - strctAllPos(j).a(t1:end-t2);
% %         a = mod(a,2*PI);
% %         a(a>PI) = abs(a(a>PI) - 2*PI);
% %         F(i:i+1,:) = [sqrt((strctAllPos(j).Cx(T+1:end)-strctAllPos(j).Cx(t1:end-t2)).^2 + ...
% %                                             (strctAllPos(j).Cy(T+1:end)-strctAllPos(j).Cy(t1:end-t2)).^2);
% %                                a];
% % %                                astrctAllPos(j).e];
% %         i = i+2;
% %     end
% % end
% t1 = T - t + 1;
% for j=1:iNumMice-1
%     dxjt = strctAllPos(j).Cx(T+1:end) - strctAllPos(j).Cx(t1:end-t);
%     dyjt = strctAllPos(j).Cy(T+1:end) - strctAllPos(j).Cy(t1:end-t);
%     dxjT = strctAllPos(j).Cx(T+1:end) - strctAllPos(j).Cx(1:end-T);
%     dyjT = strctAllPos(j).Cy(T+1:end) - strctAllPos(j).Cy(1:end-T);
%     djt = sqrt( dxjt.^2 + dyjt.^2 );
%     djT = sqrt( dxjT.^2 + dyjT.^2 );
%     for k=j+1:iNumMice
%         pairInd(j,k) = i;
%         pairInd(k,j) = i;
%         miceInd = [miceInd; [j, k]];
%         A = strctAllPos(j).a - strctAllPos(k).a;
%         A = mod(A,2*PI);
%         A(A>PI) = abs(A(A>PI) - 2*PI);
% 
%         dxkt = strctAllPos(k).Cx(T+1:end) - strctAllPos(k).Cx(t1:end-t);
%         dykt = strctAllPos(k).Cy(T+1:end) - strctAllPos(k).Cy(t1:end-t);
%         dxkT = strctAllPos(k).Cx(T+1:end) - strctAllPos(k).Cx(1:end-T);
%         dykT = strctAllPos(k).Cy(T+1:end) - strctAllPos(k).Cy(1:end-T);
%         
%         dtCorr = (dxjt.*dxkt + dyjt.*dykt)./(sqrt( (dxjt.^2 + dyjt.^2) .* (dxkt.^2 + dykt.^2) ) + 1);
%         dTCorr = (dxjT.*dxkT + dyjT.*dykT)./(sqrt( (dxjT.^2 + dyjT.^2) .* (dxkT.^2 + dykT.^2) ) + 1);
%         
%         dkt = sqrt( dxkt.^2 + dykt.^2 );
%         dkT = sqrt( dxkT.^2 + dykT.^2 );
%         
%         mindt = min([djt; dkt]);
%         maxdt = max([djt; dkt]);
%         mindT = min([djT; dkT]);
%         maxdT = max([djt; dkT]);
%         
%         x0 = (strctAllPos(j).Cx(T+1:end) + strctAllPos(k).Cx(T+1:end))/2;
%         xt = (strctAllPos(j).Cx(t1:end-t) + strctAllPos(k).Cx(t1:end-t))/2;
%         xT = (strctAllPos(j).Cx(1:end-T) + strctAllPos(k).Cx(1:end-T))/2;
%         y0 = (strctAllPos(j).Cy(T+1:end) + strctAllPos(k).Cy(T+1:end))/2;
%         yt = (strctAllPos(j).Cy(t1:end-t) + strctAllPos(k).Cy(t1:end-t))/2;
%         yT = (strctAllPos(j).Cy(1:end-T) + strctAllPos(k).Cy(1:end-T))/2;
%         
%         dt = sqrt( (xt-x0).^2 + (yt-y0).^2); 
%         dt(1:T) = 0;
%         dT = sqrt( (xT-x0).^2 + (yT-y0).^2); 
%         dT(1:T) = 0;
%         
%         dCC = sqrt((strctAllPos(j).Cx-strctAllPos(k).Cx).^2 + (strctAllPos(j).Cy-strctAllPos(k).Cy).^2);
% 
%         dNN = sqrt((strctAllPos(j).Nx-strctAllPos(k).Nx).^2 + (strctAllPos(j).Ny-strctAllPos(k).Ny).^2);
%         dNH = sqrt((strctAllPos(j).Nx-strctAllPos(k).Hx).^2 + (strctAllPos(j).Ny-strctAllPos(k).Hy).^2);
%         dHN = sqrt((strctAllPos(j).Hx-strctAllPos(k).Nx).^2 + (strctAllPos(j).Hy-strctAllPos(k).Ny).^2);
%         dHH = sqrt((strctAllPos(j).Cx-strctAllPos(k).Cx).^2 + (strctAllPos(j).Cy-strctAllPos(k).Cy).^2);
%         dMinF1 = min([dNH; dHN]);
%         dMinF2 = min([dMinF1; dNN]);
%         dMinF3 = min([dMinF2; dHH]);
%         dNT = min([sqrt((strctAllPos(j).Nx-strctAllPos(k).Tx).^2 + (strctAllPos(j).Ny-strctAllPos(k).Ty).^2);
%                                sqrt((strctAllPos(j).Tx-strctAllPos(k).Nx).^2 + (strctAllPos(j).Ty-strctAllPos(k).Ny).^2)]);
%         dNB = sqrt((strctAllPos(j).Nx-strctAllPos(k).Bx).^2 + (strctAllPos(j).Ny-strctAllPos(k).By).^2);
%         dBN = sqrt((strctAllPos(j).Bx-strctAllPos(k).Nx).^2 + (strctAllPos(j).By-strctAllPos(k).Ny).^2);
%         dHT = sqrt((strctAllPos(j).Hx-strctAllPos(k).Tx).^2 + (strctAllPos(j).Hy-strctAllPos(k).Ty).^2);
%         dTH = sqrt((strctAllPos(j).Tx-strctAllPos(k).Hx).^2 + (strctAllPos(j).Ty-strctAllPos(k).Hy).^2);
%         dHB = sqrt((strctAllPos(j).Hx-strctAllPos(k).Bx).^2 + (strctAllPos(j).Hy-strctAllPos(k).By).^2);
%         dBH = sqrt((strctAllPos(j).Bx-strctAllPos(k).Hx).^2 + (strctAllPos(j).By-strctAllPos(k).Hy).^2);
%         dMinB1 = min([dNB; dBN]);
%         dMinB2 = min([dMinB1; dNT]);
%         dMinB3 = min([dMinB2; dHB; dBH]);
%         
%         eMin = min([strctAllPos(j).e; strctAllPos(k).e]);
%         eMax = max([strctAllPos(j).e; strctAllPos(k).e]);
%         
%         D = [dNN; dMinF1; dMinF2; dMinF3; dCC-dMinF3; dNT; dMinB1; dMinB2; dMinB3; dCC-dMinB3; dCC; eMin; eMax];                
% %                 a];
%         dNTt = dNT(:,T+1:end)-dNT(:,t1:end-t);
%         dNTT = dNT(:,T+1:end)-dNT(:,1:end-T);
%         dCCt = dCC(:,T+1:end)-dCC(:,t1:end-t);
%         dCCT = dCC(:,T+1:end)-dCC(:,1:end-T);
%         fNum = 59;
%         F(i:i+fNum-1,:) = [zeros(fNum,T)  [D(:,T+1:end); D(:,T+1:end)-D(:,1:end-T); D(:,T+1:end)-D(:,t1:end-t); dT; dt; dtCorr; dTCorr;...
%                                                                             mindT; maxdT; mindt; maxdt; ...
%                                                                             mindT./(mindT+dCCT); mindt./(mindt+dCCt); ...
%                                                                             mindT./(mindT+dNTT); mindt./(mindt+dNTt); ...
%                                                                             dT-dNTT; dt-dNTt; dT-dCCT; dt-dCCt; ...
%                                                                             dNTT./(dNTT+dT); dNTt./(dNTt+dt); dCCT./(dCCT+dT); dCCt./(dCCt+dt);]];
%         i = i+ fNum;
%     end
% end
%         
% % F = zeros(10, iNumFrames);
% % i = 1;
% % PI = 2*asin(1);
% % pairInd = zeros(iNumMice);
% % miceInd = [];
% % for j=1:1 % iNumMice-1
% %     for k=j+1:2 % iNumMice
% %         pairInd(j,k) = i;
% %         pairInd(k,j) = i;
% %         miceInd = [miceInd; [j, k]];
% %         a= strctAllPos(j).a - strctAllPos(k).a;
% %         a = mod(a,2*PI);
% %         a(a>PI) = abs(a(a>PI) - 2*PI);
% %         d = [sqrt((strctAllPos(j).Cx-strctAllPos(k).Cx).^2 + (strctAllPos(j).Cy-strctAllPos(k).Cy).^2);
% %                 sqrt((strctAllPos(j).Hx-strctAllPos(k).Hx).^2 + (strctAllPos(j).Hy-strctAllPos(k).Hy).^2);
% %                 sqrt((strctAllPos(j).Hx-strctAllPos(k).Cx).^2 + (strctAllPos(j).Hy-strctAllPos(k).Cy).^2);
% %                 sqrt((strctAllPos(j).Cx-strctAllPos(k).Hx).^2 + (strctAllPos(j).Cy-strctAllPos(k).Hy).^2);
% %                 a];
% %         F = [d; [zeros(size(d,1),iTimeScale) d(:,iTimeScale+1:end)-d(:,1:end-iTimeScale)]];
% %     end
% % end
% % 
% % 
% %         d(i,:)                                    = sqrt((strctAllPos(j).Cx-strctAllPos(k).Cx).^2 + (strctAllPos(j).Cy-strctAllPos(k).Cy).^2);
% %         d(iPairsNum+1+i,:)     = sqrt((strctAllPos(j).Hx-strctAllPos(k).Hx).^2 + (strctAllPos(j).Hy-strctAllPos(k).Hy).^2);
% %         d(2*iPairsNum+1+i,:) = sqrt((strctAllPos(j).Hx-strctAllPos(k).Cx).^2 + (strctAllPos(j).Hy-strctAllPos(k).Cy).^2);
% %         d(3*iPairsNum+1+i,:) = sqrt((strctAllPos(j).Cx-strctAllPos(k).Hx).^2 + (strctAllPos(j).Cy-strctAllPos(k).Hy).^2);
% %         a(i,:) = strctAllPos(j).a - strctAllPos(k).a;
% %         i = i+1;
% %     end
% % end
% % a = mod(a,2*PI);
% % a(a>PI) = abs(a(a>PI) - 2*PI);
% % d(4*iPairsNum+1:5*iPairsNum,:) = a;
% % F = [d; [zeros(size(d,1),iTimeScale) d(:,iTimeScale+1:end)-d(:,1:end-iTimeScale)]];
