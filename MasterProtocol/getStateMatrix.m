function [sma, TrialParams] = getStateMatrix(TrialType, TrialNum, TrialParams)    
global S

TrialParams.bit = setBitCodeParams();

switch S.GUI.ProtocolType
    case {1, 2, 3} % soundTask2AFC
        
        [sma, TrialParams] = getStateMatrix_soundTask2AFC(TrialParams, TrialType, TrialNum);
        
    case 4 % Spontaneous 2 ports
        
        [sma, TrialParams] = getStateMatrix_Spontaneous(TrialParams, TrialType, TrialNum);
%         params.Nlicks = 1;
%         params.ITI = ITI;
        
    case 5 % Lick Sequence
        
        [sma, TrialParams] = getStateMatrix_LickSequence(TrialParams, TrialType, TrialNum);
        
end


function bitparam = setBitCodeParams()
bitparam.Ntrial = 12;
bitparam.Nrand = 12;
bitparam.bitTime = 0.005;
bitparam.interBitTime = 0.005;
bitparam.randNum = floor(rand(1)*(2^bitparam.Nrand));

