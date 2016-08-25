function aiRemapInd = fnGet4x4Remapping(iMale1,iMale2,iFemale1,iFemale2)
% The default matrix:
Table=[...
        iFemale1, iFemale1;
        iFemale1, iFemale2;
        iFemale1, iMale1;
        iFemale1, iMale2;
        iFemale2, iFemale1;
        iFemale2, iFemale2;
        iFemale2, iMale1;
        iFemale2, iMale2;
        iMale1, iFemale1;
        iMale1, iFemale2;
        iMale1, iMale1;
        iMale1, iMale2;
        iMale2, iFemale1;
        iMale2, iFemale2;
        iMale2, iMale1;
        iMale2, iMale2];

% A=reshape(1:16,4,4);
aiRemapInd = sub2ind([4,4],Table(:,2),Table(:,1))';
%reshape(A(aiRemap),4,4)

% 1,5,9 ,13
% 2,6,10,14
% 3,7,11,15
% 4,8,12,16
%            
% reshape(1:16,4,4)           
% [F1-F1, F1-F2, F1-M1, F1-M2;
%  F2-F1, F2-F2, F2-M1, F2-M2;
%  M1-F1, M1-F2, M1-M1, M1-M2;
%  M2-F1, M2-F2, M2-M1, M2-M2];


% [F1-F1, F1-F2, F1-M1, F1-M2;
%  F2-F1, F2-F2, F2-M1, F2-M2;
%  M1-F1, M1-F2, M1-M1, M1-M2;
%  M2-F1, M2-F2, M2-M1, M2-M2];

