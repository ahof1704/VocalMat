% Merge ground truth files....
strRoot = 'D:\Data\Janelia Farm\GroundTruth\popcage18gt_andrew\Unrandom\';

A=load([strRoot,'GroundTruth_popcage_18_09.15.11_10.56.24.135_AM_seg1_complete_UnRandomized.mat']);
B=load([strRoot,'GroundTruth_popcage_18_09.15.11_10.56.24.135_AM_seg2_complete_UnRandomized.mat']);
C=load([strRoot,'GroundTruth_popcage_18_09.15.11_10.56.24.135_AM_seg3_complete_UnRandomized.mat']);

aiIndA = find(~ismember({A.astrctGT.m_strDescr},'Not Checked'));
aiIndB = find(~ismember({B.astrctGT.m_strDescr},'Not Checked'));
aiIndC = find(~ismember({C.astrctGT.m_strDescr},'Not Checked'));
% Merge into A
astrctTrackers = A.astrctTrackers;
astrctGT = A.astrctGT;
astrctGT(aiIndB) = B.astrctGT(aiIndB);
astrctGT(aiIndC) = C.astrctGT(aiIndC);


save([strRoot,'b6_popcage_18_09.15.11_10.56.24.135.mat'],'astrctTrackers','astrctGT');

%%

A=load([strRoot,'GroundTruth_b6_popcage_18_09.17.11_10.56.27.049_AM_seg5_complete_UnRandomized.mat']);
B=load([strRoot,'GroundTruth_b6_popcage_18_09.17.11_10.56.27.049_AM_seg6_complete_UnRandomized.mat']);
C=load([strRoot,'GroundTruth_b6_popcage_18_09.17.11_10.56.27.049_AM_seg7_complete_UnRandomized.mat']);

aiIndA = find(~ismember({A.astrctGT.m_strDescr},'Not Checked'));
aiIndB = find(~ismember({B.astrctGT.m_strDescr},'Not Checked'));
aiIndC = find(~ismember({C.astrctGT.m_strDescr},'Not Checked'));
% Merge into A
astrctTrackers = A.astrctTrackers;
astrctGT = A.astrctGT;
for k=1:length(aiIndB)
    astrctGT(aiIndB(k)).m_iFrame            = B.astrctGT(aiIndB(k)).m_iFrame;
    astrctGT(aiIndB(k)).m_abHeadTailSwap    = B.astrctGT(aiIndB(k)).m_abHeadTailSwap;
    astrctGT(aiIndB(k)).m_abNeitherHeadTail = B.astrctGT(aiIndB(k)).m_abNeitherHeadTail;
    astrctGT(aiIndB(k)).m_aiPerm            = B.astrctGT(aiIndB(k)).m_aiPerm;
    astrctGT(aiIndB(k)).m_strDescr          = B.astrctGT(aiIndB(k)).m_strDescr;
    astrctGT(aiIndB(k)).m_bHuddling         = B.astrctGT(aiIndB(k)).m_bHuddling;
    astrctGT(aiIndB(k)).m_iIdConfLevel      = B.astrctGT(aiIndB(k)).m_iIdConfLevel;
end
for k=1:length(aiIndC)
    astrctGT(aiIndC(k)).m_iFrame            = C.astrctGT(aiIndC(k)).m_iFrame;
    astrctGT(aiIndC(k)).m_abHeadTailSwap    = C.astrctGT(aiIndC(k)).m_abHeadTailSwap;
    astrctGT(aiIndC(k)).m_abNeitherHeadTail = C.astrctGT(aiIndC(k)).m_abNeitherHeadTail;
    astrctGT(aiIndC(k)).m_aiPerm            = C.astrctGT(aiIndC(k)).m_aiPerm;
    astrctGT(aiIndC(k)).m_strDescr          = C.astrctGT(aiIndC(k)).m_strDescr;
    astrctGT(aiIndC(k)).m_bHuddling         = C.astrctGT(aiIndC(k)).m_bHuddling;
    astrctGT(aiIndC(k)).m_iIdConfLevel      = C.astrctGT(aiIndC(k)).m_iIdConfLevel;
end



save([strRoot,'b6_popcage_18_09.17.11_10.56.27.049.mat'],'astrctTrackers','astrctGT');



copyfile([strRoot,'GroundTruth_b6_popcage_18_09.15.11_22.56.24.848_AM_seg4_complete_UnRandomized.mat'],...
        [strRoot,'b6_popcage_18_09.15.11_22.56.24.848.mat']);
    
 
%%


strRoot = 'D:\Data\Janelia Farm\GroundTruth\popcage18gt_ashley\Unrandomized\';

A=load([strRoot,'GroundTruth_bc_popcage_18_09.15.11_10.56.24.135.seq_af_seg1_complete_UnRandomized.mat']);
B=load([strRoot,'GroundTruth_bc_popcage_18_09.15.11_10.56.24.135.seq_af_seg2_complete_UnRandomized.mat']);
C=load([strRoot,'GroundTruth_bc_popcage_18_09.15.11_10.56.24.135.seq_af_seg3_complete_fixed_UnRandomized.mat']);

aiIndA = find(~ismember({A.astrctGT.m_strDescr},'Not Checked'));
aiIndB = find(~ismember({B.astrctGT.m_strDescr},'Not Checked'));
aiIndC = find(~ismember({C.astrctGT.m_strDescr},'Not Checked'));
% Merge into A
astrctTrackers = A.astrctTrackers;
astrctGT = A.astrctGT;
astrctGT(aiIndB) = B.astrctGT(aiIndB);
astrctGT(aiIndC) = C.astrctGT(aiIndC);

save([strRoot,'b6_popcage_18_09.15.11_10.56.24.135.mat'],'astrctTrackers','astrctGT');

%%
strRoot = 'D:\Data\Janelia Farm\GroundTruth\popcage18gt_ashley\Unrandomized\';

A=load([strRoot,'GroundTruth_b6_popcage_18_09.17.11_10.56.27.049.seq_af_seg5_complete_UnRandomized.mat']);
B=load([strRoot,'GroundTruth_bc_popcage_18_09.17.11_10.56.27.049.seq_af_seg6_complete_UnRandomized.mat']);
C=load([strRoot,'GroundTruth_b6_popcage_18_09.17.11_10.56.27.049.seq_af_seg7_complete_UnRandomized.mat']);

aiIndA = find(~ismember({A.astrctGT.m_strDescr},'Not Checked'));
aiIndB = find(~ismember({B.astrctGT.m_strDescr},'Not Checked'));
aiIndC = find(~ismember({C.astrctGT.m_strDescr},'Not Checked'));

% Merge into A
astrctTrackers = A.astrctTrackers;
astrctGT = A.astrctGT;
astrctGT(aiIndB) = B.astrctGT(aiIndB);
astrctGT(aiIndC) = C.astrctGT(aiIndC);

save([strRoot,'b6_popcage_18_09.17.11_10.56.27.049.mat'],'astrctTrackers','astrctGT');

%%
copyfile([strRoot,'GroundTruth_b6_popcage_18_09.15.11_22.26.24.848.seq_af_seg4_complete_UnRandomized.mat'],...
    [strRoot,'b6_popcage_18_09.15.11_22.26.24.848.mat']);



copyfile([strRoot,'GroundTruth_b6_popcage_18_09.17.11_22.56.27.802_af_seg8_complete_UnRandomized.mat'],...
    [strRoot,'b6_popcage_18_09.17.11_22.56.27.802.mat']);

%%

strRoot = 'D:\Data\Janelia Farm\GroundTruth\popcage18gt_ashley\Unrandomized\';

A=load([strRoot,'GroundTruth_b6_popcage_18_09.19.11_10.56.29.998.seq_af_seg9_complete_UnRandomized.mat']);
B=load([strRoot,'GroundTruth_b6_popcage_18_09.19.11_10.56.29.998.seq_af_seg10_complete_UnRandomized.mat']);
C=load([strRoot,'GroundTruth_b6_popcage_18.09.19.11_10.56.29.998.seq_af_seg11_complete_UnRandomized.mat']);

aiIndA = find(~ismember({A.astrctGT.m_strDescr},'Not Checked'));
aiIndB = find(~ismember({B.astrctGT.m_strDescr},'Not Checked'));
aiIndC = find(~ismember({C.astrctGT.m_strDescr},'Not Checked'));

% Merge into A
astrctTrackers = A.astrctTrackers;
astrctGT = A.astrctGT;

for k=1:length(aiIndB)
    astrctGT(aiIndB(k)).m_iFrame            = B.astrctGT(aiIndB(k)).m_iFrame;
    astrctGT(aiIndB(k)).m_abHeadTailSwap    = B.astrctGT(aiIndB(k)).m_abHeadTailSwap;
    astrctGT(aiIndB(k)).m_abNeitherHeadTail = B.astrctGT(aiIndB(k)).m_abNeitherHeadTail;
    astrctGT(aiIndB(k)).m_aiPerm            = B.astrctGT(aiIndB(k)).m_aiPerm;
    astrctGT(aiIndB(k)).m_strDescr          = B.astrctGT(aiIndB(k)).m_strDescr;
    astrctGT(aiIndB(k)).m_bHuddling         = B.astrctGT(aiIndB(k)).m_bHuddling;
    astrctGT(aiIndB(k)).m_iIdConfLevel      = B.astrctGT(aiIndB(k)).m_iIdConfLevel;
end

for k=1:length(aiIndC)
    astrctGT(aiIndC(k)).m_iFrame            = C.astrctGT(aiIndC(k)).m_iFrame;
    astrctGT(aiIndC(k)).m_abHeadTailSwap    = C.astrctGT(aiIndC(k)).m_abHeadTailSwap;
    astrctGT(aiIndC(k)).m_abNeitherHeadTail = C.astrctGT(aiIndC(k)).m_abNeitherHeadTail;
    astrctGT(aiIndC(k)).m_aiPerm            = C.astrctGT(aiIndC(k)).m_aiPerm;
    astrctGT(aiIndC(k)).m_strDescr          = C.astrctGT(aiIndC(k)).m_strDescr;
    astrctGT(aiIndC(k)).m_bHuddling         = C.astrctGT(aiIndC(k)).m_bHuddling;
    astrctGT(aiIndC(k)).m_iIdConfLevel      = C.astrctGT(aiIndC(k)).m_iIdConfLevel;
end

save([strRoot,'b6_popcage_18_09.19.11_10.56.29.998.mat'],'astrctTrackers','astrctGT');

%%


copyfile([strRoot,'GroundTruth_b6_popcage_18_09.19.11_22.56.30.748_af_seg12_complete_UnRandomized.mat'],...
    [strRoot,'b6_popcage_18_09.19.11_22.56.30.748.mat']);

%%





%%
strRoot = 'D:\Data\Janelia Farm\GroundTruth\popcage18gt_andrew\Unrandom\';

copyfile([strRoot,'GroundTruth_b6_popcage_18_09.17.11_22.56.27.802_AM_seg8_complete_UnRandomized.mat'],...
    [strRoot,'b6_popcage_18_09.17.11_22.56.27.802.mat']);

%%

A=load([strRoot,'GroundTruth_b6_popcage_18_09.19.11_10.56.29.998_AM_seg9_complete_UnRandomized.mat']);
B=load([strRoot,'GroundTruth_b6_popcage_18_09.19.11_10.56.29.998_AM_seg10_complete_UnRandomized.mat']);
C=load([strRoot,'GroundTruth_b6_popcage_18_09.19.11_10.56.29.998_AM_seg11_complete_UnRandomized.mat']);

aiIndA = find(~ismember({A.astrctGT.m_strDescr},'Not Checked'));
aiIndB = find(~ismember({B.astrctGT.m_strDescr},'Not Checked'));
aiIndC = find(~ismember({C.astrctGT.m_strDescr},'Not Checked'));
% Merge into A
astrctTrackers = A.astrctTrackers;
astrctGT = A.astrctGT;

for k=1:length(aiIndB)
    astrctGT(aiIndB(k)).m_iFrame            = B.astrctGT(aiIndB(k)).m_iFrame;
    astrctGT(aiIndB(k)).m_abHeadTailSwap    = B.astrctGT(aiIndB(k)).m_abHeadTailSwap;
    astrctGT(aiIndB(k)).m_abNeitherHeadTail = B.astrctGT(aiIndB(k)).m_abNeitherHeadTail;
    astrctGT(aiIndB(k)).m_aiPerm            = B.astrctGT(aiIndB(k)).m_aiPerm;
    astrctGT(aiIndB(k)).m_strDescr          = B.astrctGT(aiIndB(k)).m_strDescr;
    astrctGT(aiIndB(k)).m_bHuddling         = B.astrctGT(aiIndB(k)).m_bHuddling;
    astrctGT(aiIndB(k)).m_iIdConfLevel      = B.astrctGT(aiIndB(k)).m_iIdConfLevel;
end

for k=1:length(aiIndC)
    astrctGT(aiIndC(k)).m_iFrame            = C.astrctGT(aiIndC(k)).m_iFrame;
    astrctGT(aiIndC(k)).m_abHeadTailSwap    = C.astrctGT(aiIndC(k)).m_abHeadTailSwap;
    astrctGT(aiIndC(k)).m_abNeitherHeadTail = C.astrctGT(aiIndC(k)).m_abNeitherHeadTail;
    astrctGT(aiIndC(k)).m_aiPerm            = C.astrctGT(aiIndC(k)).m_aiPerm;
    astrctGT(aiIndC(k)).m_strDescr          = C.astrctGT(aiIndC(k)).m_strDescr;
    astrctGT(aiIndC(k)).m_bHuddling         = C.astrctGT(aiIndC(k)).m_bHuddling;
    astrctGT(aiIndC(k)).m_iIdConfLevel      = C.astrctGT(aiIndC(k)).m_iIdConfLevel;
end


save([strRoot,'b6_popcage_18_09.19.11_10.56.29.998.mat'],'astrctTrackers','astrctGT');


%%
copyfile([strRoot,'GroundTruth_b6_popcage_18_09.19.11_22.56.30.748_AM_seg12_complete_UnRandomized.mat'],...
    [strRoot,'b6_popcage_18_09.19.11_22.56.30.748.mat']);


