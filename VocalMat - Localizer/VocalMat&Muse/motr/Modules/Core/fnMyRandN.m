function a2fRandMat = fnMyRandN(a,b)
global g_strctRandBuffer

if isempty(g_strctRandBuffer)
    g_strctRandBuffer.m_iBufferSize = 50000;
    g_strctRandBuffer.m_afBuffer = randn(1,g_strctRandBuffer.m_iBufferSize);
    g_strctRandBuffer.m_iIndex = 1;
end;

iNumRequiredValues = a*b;
if iNumRequiredValues == 0
    a2fRandMat = zeros(a,b);
else
    aiIndices = mod(g_strctRandBuffer.m_iIndex:g_strctRandBuffer.m_iIndex+iNumRequiredValues-1, g_strctRandBuffer.m_iBufferSize-1) + 1;
    afValues = g_strctRandBuffer.m_afBuffer(aiIndices);
    g_strctRandBuffer.m_iIndex = aiIndices(end);
    a2fRandMat = reshape(afValues,[a,b]);
end;
return;
